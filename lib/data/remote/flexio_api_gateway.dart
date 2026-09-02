import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../app_config.dart';
import '../models/diary_entry.dart';
import '../models/food_item.dart';
import '../models/user_profile.dart';
import 'supabase_gateway.dart';

/// A saját C# API kapuja. Ugyanazt a felületet adja, mint a
/// [SupabaseGateway], így a repository-k nem tudják, melyik út él.
///
/// Bekapcsolás:
/// `flutter run --dart-define=API_BASE_URL=https://api.example.com`
///
/// A még nem átírt műveletek (fióktörlés, kedvencek, user food create)
/// továbbra is a Supabase úton mennek, amíg azok is átköltöznek.
class FlexioApiGateway extends SupabaseGateway {
  const FlexioApiGateway();

  @override
  Future<List<FoodItem>> searchFoods(String query, {int limit = 30}) async {
    final payload = await _getJson(
      _join("/api/v1/foods/search").replace(
        queryParameters: {"q": query, "limit": "$limit"},
      ),
    );
    if (payload is! List) {
      return const [];
    }
    return payload
        .whereType<Map>()
        .map(FoodItem.fromRemoteRow)
        .where((food) => food.name.isNotEmpty)
        .toList();
  }

  @override
  Future<FoodItem?> foodByBarcode(String barcode) async {
    final payload = await _getJson(
      _join("/api/v1/foods/barcode/${Uri.encodeComponent(barcode)}"),
    );
    if (payload is! Map) {
      return null;
    }
    return FoodItem.fromRemoteRow(payload);
  }

  @override
  Future<void> logSearchMiss(String query, int resultCount) async {
    await _postJson("/api/v1/foods/search-miss", {
      "query": query,
      "result_count": resultCount,
    });
  }

  @override
  Future<bool> pushDiaryEntries(List<DiaryEntry> entries) async {
    final uid = userId;
    if (uid == null || entries.isEmpty) {
      return false;
    }

    final response = await _postJson("/api/v1/sync", {
      "diary": entries.map((entry) => entry.toRemoteRow(uid)).toList(),
      "since": const <String, dynamic>{},
    });
    return response != null;
  }

  @override
  Future<List<DiaryEntry>> pullDiaryEntries({DateTime? since}) async {
    final response = await _postJson("/api/v1/sync", {
      "since": {
        if (since != null) "diary": since.toUtc().toIso8601String(),
      },
    });
    if (response is! Map) {
      return const [];
    }
    final diary = response["diary"];
    if (diary is! List) {
      return const [];
    }
    return diary.whereType<Map>().map(DiaryEntry.fromRemoteRow).toList();
  }

  @override
  Future<bool> pushProfile(UserProfile profile) async {
    final uid = userId;
    if (uid == null) {
      return false;
    }

    final body = <String, dynamic>{
      "profile": profile.toRemoteRow(uid),
      "since": const <String, dynamic>{},
    };
    final goals = profile.manualGoals;
    if (goals != null) {
      body["goals"] = {
        "user_id": uid,
        "calorie_goal": goals.calories,
        "protein_goal": goals.protein,
        "fat_goal": goals.fat,
        "carbs_goal": goals.carbs,
        "water_goal_ml": goals.waterMl,
        "is_manual": goals.isManual,
      };
    }

    return await _postJson("/api/v1/sync", body) != null;
  }

  @override
  Future<UserProfile?> pullProfile() async {
    final response = await _postJson("/api/v1/sync", {
      "since": const <String, dynamic>{},
    });
    if (response is! Map || response["profile"] is! Map) {
      return null;
    }

    var profile = UserProfile.fromRemoteRow(response["profile"] as Map);
    final goalRow = response["goals"];
    if (goalRow is Map && goalRow["calorie_goal"] != null) {
      profile = profile.copyWith(
        manualGoals: NutritionGoals(
          calories: (goalRow["calorie_goal"] as num).toDouble(),
          protein: (goalRow["protein_goal"] as num?)?.toDouble() ?? 0,
          fat: (goalRow["fat_goal"] as num?)?.toDouble() ?? 0,
          carbs: (goalRow["carbs_goal"] as num?)?.toDouble() ?? 0,
          waterMl: (goalRow["water_goal_ml"] as num?)?.toInt() ?? 2500,
          isManual: goalRow["is_manual"] == true,
        ),
      );
    }
    return profile;
  }

  @override
  Future<int> pushRows(String table, List<Map<String, dynamic>> rows) async {
    if (rows.isEmpty) {
      return 0;
    }

    final key = switch (table) {
      "workout_sessions" => "workouts",
      "sleep_entries" => "sleep",
      _ => null,
    };
    if (key == null) {
      return super.pushRows(table, rows);
    }

    final response = await _postJson("/api/v1/sync", {
      key: rows,
      "since": const <String, dynamic>{},
    });
    if (response is! Map) {
      return 0;
    }

    final push = response["push"];
    if (push is! Map) {
      return 0;
    }

    return switch (key) {
      "workouts" => (push["workoutsAccepted"] as num?)?.toInt() ?? 0,
      "sleep" => (push["sleepAccepted"] as num?)?.toInt() ?? 0,
      _ => 0,
    };
  }

  @override
  Future<List<Map<String, dynamic>>> pullRows(
    String table, {
    DateTime? since,
  }) async {
    final sinceKey = switch (table) {
      "workout_sessions" => "workouts",
      "sleep_entries" => "sleep",
      _ => null,
    };
    if (sinceKey == null) {
      return super.pullRows(table, since: since);
    }

    final response = await _postJson("/api/v1/sync", {
      "since": {
        if (since != null) sinceKey: since.toUtc().toIso8601String(),
      },
    });
    if (response is! Map) {
      return const [];
    }
    final rows = response[sinceKey];
    if (rows is! List) {
      return const [];
    }
    return rows
        .whereType<Map>()
        .map((row) => Map<String, dynamic>.from(row))
        .toList();
  }

  Uri _join(String path) {
    final base = AppConfig.apiBaseUrl.endsWith("/")
        ? AppConfig.apiBaseUrl.substring(0, AppConfig.apiBaseUrl.length - 1)
        : AppConfig.apiBaseUrl;
    return Uri.parse("$base$path");
  }

  Future<String?> _accessToken() async {
    try {
      return Supabase.instance.client.auth.currentSession?.accessToken;
    } on Object {
      return null;
    }
  }

  Future<Object?> _getJson(Uri uri) async {
    final token = await _accessToken();
    if (token == null) {
      return null;
    }

    final client = HttpClient();
    try {
      final request = await client.getUrl(uri);
      request.headers.set(HttpHeaders.authorizationHeader, "Bearer $token");
      request.headers.set(HttpHeaders.acceptHeader, "application/json");
      final response =
          await request.close().timeout(const Duration(seconds: 20));
      final text = await response.transform(utf8.decoder).join();
      if (response.statusCode < 200 || response.statusCode >= 300) {
        debugPrint("Flexio API GET ${uri.path} -> ${response.statusCode}");
        return null;
      }
      return jsonDecode(text);
    } on Object catch (error) {
      debugPrint("Flexio API GET failed: $error");
      return null;
    } finally {
      client.close(force: true);
    }
  }

  Future<Object?> _postJson(String path, Map<String, dynamic> body) async {
    final token = await _accessToken();
    if (token == null) {
      return null;
    }

    final client = HttpClient();
    try {
      final request = await client.postUrl(_join(path));
      request.headers.contentType =
          ContentType("application", "json", charset: "utf-8");
      request.headers.set(HttpHeaders.authorizationHeader, "Bearer $token");
      request.add(utf8.encode(jsonEncode(body)));
      final response =
          await request.close().timeout(const Duration(seconds: 30));
      final text = await response.transform(utf8.decoder).join();
      if (response.statusCode < 200 || response.statusCode >= 300) {
        debugPrint(
          "Flexio API POST $path -> ${response.statusCode}: $text",
        );
        return null;
      }
      if (text.isEmpty) {
        return const <String, dynamic>{};
      }
      return jsonDecode(text);
    } on Object catch (error) {
      debugPrint("Flexio API POST failed: $error");
      return null;
    } finally {
      client.close(force: true);
    }
  }
}
