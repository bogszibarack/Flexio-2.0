import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../view/meal_planner/meal_store.dart';
import '../../view/sleep_tracker/sleep_store.dart';
import '../../view/workout_tracker/workout_store.dart';
import '../app_config.dart';
import '../models/user_profile.dart';
import '../notification_service.dart';
import 'coach_rules.dart';
import 'coach_settings.dart';

/// Rövid pillanatkép a saját coach API-nak. Nincs név, nincs étellista.
class CoachSnapshot {
  const CoachSnapshot({
    required this.kind,
    required this.payload,
  });

  final String kind;
  final Map<String, dynamic> payload;

  Map<String, dynamic> toJson() => {"kind": kind, ...payload};
}

class CoachService {
  CoachService({
    required this.settings,
    required this.notifications,
  });

  final CoachSettings settings;
  final NotificationService notifications;

  static CoachSnapshot workoutSnapshot({
    required UserProfile profile,
    required int rpe,
    required double percent,
    required Map<String, dynamic> entry,
  }) {
    final last = SleepStore.lastNight;
    return CoachSnapshot(
      kind: "workout",
      payload: {
        "goal": profile.goal?.name,
        "weightKg": profile.weightKg,
        "weeklyWorkouts": WorkoutStore.completedWorkouts.where((item) {
          final date = item["date"];
          return date is DateTime && DateTime.now().difference(date).inDays < 7;
        }).length,
        "title": "${entry["title"]}",
        "minutes": entry["minutes"],
        "volume": entry["volume"],
        "rpe": rpe,
        "percent": percent,
        "lastSleepHours": last?.hours,
        "avgSleepHours": SleepStore.averageHours,
      },
    );
  }

  static CoachSnapshot nutritionSnapshot({
    required UserProfile profile,
    required NutritionDigest digest,
  }) {
    return CoachSnapshot(
      kind: "nutrition",
      payload: {
        "goal": profile.goal?.name,
        "headline": digest.headline,
        "detail": digest.detail,
        "praiseOnly": digest.praiseOnly,
      },
    );
  }

  static CoachSnapshot sleepSnapshot({required SleepTip tip}) {
    return CoachSnapshot(
      kind: "sleep",
      payload: {
        "headline": tip.headline,
        "detail": tip.detail,
        "praise": tip.praise,
        "avgSleepHours": SleepStore.averageHours,
        "lastSleepHours": SleepStore.lastNight?.hours,
      },
    );
  }

  Future<CoachCopy> copyFor({
    required CoachSnapshot snapshot,
    ProgressionAdvice? advice,
    double percent = 0,
  }) async {
    final local = advice == null
        ? CoachCopy(
            prose:
                "${snapshot.payload["headline"] ?? ""} ${snapshot.payload["detail"] ?? ""}"
                    .trim(),
            pros: "",
            cons: "",
          )
        : CoachRules.localWorkoutCopy(percent: percent, advice: advice);
    if (AppConfig.effectiveCoachApiUrl.isEmpty) {
      return local;
    }
    try {
      final uri = _resolveCoachUri(AppConfig.effectiveCoachApiUrl);
      final client = HttpClient();
      try {
        final request = await client.postUrl(uri);
        request.headers.contentType =
            ContentType("application", "json", charset: "utf-8");
        final accessToken =
            Supabase.instance.client.auth.currentSession?.accessToken;
        if (accessToken != null && accessToken.isNotEmpty) {
          request.headers.set(
            HttpHeaders.authorizationHeader,
            "Bearer $accessToken",
          );
        }
        request.add(utf8.encode(jsonEncode({
          "snapshot": snapshot.toJson(),
          "fallback": {
            "prose": local.prose,
            "pros": local.pros,
            "cons": local.cons,
          },
        })));
        final response =
            await request.close().timeout(const Duration(seconds: 12));
        final text = await response.transform(utf8.decoder).join();
        if (response.statusCode < 200 || response.statusCode >= 300) {
          return local;
        }
        final decoded = jsonDecode(text);
        if (decoded is! Map) {
          return local;
        }
        return CoachCopy(
          prose: "${decoded["prose"] ?? local.prose}",
          pros: "${decoded["pros"] ?? local.pros}",
          cons: "${decoded["cons"] ?? local.cons}",
        );
      } finally {
        client.close(force: true);
      }
    } catch (error) {
      debugPrint("Coach API skipped: $error");
      return local;
    }
  }

  /// A régi Node coach `/coach` útvonalát és az új C# `/api/v1/coach`
  /// végpontot is elfogadja, hogy a dart-define ne törjön el átálláskor.
  static Uri _resolveCoachUri(String raw) {
    if (raw.endsWith("/coach") || raw.endsWith("/api/v1/coach")) {
      return Uri.parse(raw);
    }
    return Uri.parse("$raw/api/v1/coach");
  }

  Future<void> remember({
    required String title,
    required String body,
    required String kind,
    String image = "assets/img/notification_active.png",
  }) {
    return notifications.pushCoachItem(
      title: title,
      body: body,
      kind: kind,
      image: image,
    );
  }

  Future<void> maybeWeeklySummary({
    required UserProfile profile,
    required MealStore store,
  }) async {
    if (!settings.loaded) {
      return;
    }
    if (!settings.workout && !settings.meal && !settings.sleep) {
      return;
    }
    final now = DateTime.now();
    final last = settings.lastWeeklyAt;
    if (last != null && now.difference(last).inDays < 6) {
      return;
    }
    if (now.weekday != DateTime.sunday) {
      return;
    }

    final weekStart = WorkoutStore.startOfWeek(now);
    final workouts = WorkoutStore.completedWorkouts.where((item) {
      final date = item["date"];
      return date is DateTime && !date.isBefore(weekStart);
    }).length;
    if (workouts == 0 && store.isEmpty && SleepStore.entries.isEmpty) {
      return;
    }
    final nutrition = CoachRules.weeklyNutrition(
      store: store,
      goals: profile.goals,
    );
    final sleep = CoachRules.sleepFromHistory();
    final body =
        "Edzés: $workouts alkalom. ${nutrition.headline} ${sleep.headline}";
    await remember(
      title: "Heti coach-összesítő",
      body: body,
      kind: "coach_weekly",
    );
    await settings.markWeeklyPushed();
  }
}
