import 'package:supabase_flutter/supabase_flutter.dart';

import '../app_config.dart';
import '../models/diary_entry.dart';
import '../models/food_item.dart';
import '../models/user_profile.dart';

/// Egyetlen belépési pont a Supabase felé. Ha nincs konfigurálva backend, minden
/// metódus üresen tér vissza, és az app helyi módban működik tovább.
class SupabaseGateway {
  const SupabaseGateway();

  bool get isEnabled => AppConfig.hasRemote;

  SupabaseClient? get _client {
    if (!isEnabled) {
      return null;
    }
    try {
      return Supabase.instance.client;
    } on Object {
      return null;
    }
  }

  String? get userId => _client?.auth.currentUser?.id;

  bool get isSignedIn => userId != null;

  // --- Keresés ------------------------------------------------------------

  Future<List<FoodItem>> searchFoods(String query, {int limit = 30}) async {
    final client = _client;
    if (client == null) {
      return const [];
    }

    try {
      final result = await client.rpc<dynamic>(
        "search_foods",
        params: {"q": query, "max_results": limit},
      );
      return _mapFoodRows(result);
    } on Object {
      return const [];
    }
  }

  Future<FoodItem?> foodByBarcode(String barcode) async {
    final client = _client;
    if (client == null) {
      return null;
    }

    try {
      final result = await client.rpc<dynamic>(
        "food_by_barcode",
        params: {"code": barcode},
      );
      final foods = _mapFoodRows(result);
      return foods.isEmpty ? null : foods.first;
    } on Object {
      return null;
    }
  }

  Future<void> logSearchMiss(String query, int resultCount) async {
    final client = _client;
    if (client == null || !isSignedIn) {
      return;
    }
    try {
      await client.rpc<dynamic>(
        "log_search_miss",
        params: {"q": query, "result_count": resultCount},
      );
    } on Object {
      // A statisztika nem kritikus.
    }
  }

  Future<void> incrementPopularity(String foodRemoteId) async {
    final client = _client;
    if (client == null || !isSignedIn) {
      return;
    }
    try {
      await client.rpc<dynamic>(
        "increment_food_popularity",
        params: {"target": foodRemoteId},
      );
    } on Object {
      // Nem kritikus.
    }
  }

  /// Az Open Food Facts-ból élőben behozott termék beírása a közös katalógusba.
  Future<String?> cacheOffFood(FoodItem food) async {
    final client = _client;
    if (client == null || !isSignedIn || food.barcode == null) {
      return null;
    }

    try {
      final result = await client.rpc<dynamic>("upsert_off_food", params: {
        "p_barcode": food.barcode,
        "p_name": food.name,
        "p_brand": food.brand,
        "p_quantity": food.quantityLabel,
        "p_image_url": food.imageUrl,
        "p_kcal": food.per100g.kcal,
        "p_protein": food.per100g.protein,
        "p_fat": food.per100g.fat,
        "p_carbs": food.per100g.carbs,
        "p_sugar": food.per100g.sugar,
        "p_saturated_fat": food.per100g.saturatedFat,
        "p_salt": food.per100g.salt,
        "p_fiber": food.per100g.fiber,
        "p_servings": food.servings.map((s) => s.toJson()).toList(),
      });

      if (result is Map) {
        return result["id"] as String?;
      }
      if (result is List && result.isNotEmpty && result.first is Map) {
        return (result.first as Map)["id"] as String?;
      }
      return null;
    } on Object {
      return null;
    }
  }

  /// Saját étel felvitele. A soron RLS miatt kötelező az `owner_id`.
  Future<String?> createUserFood(FoodItem food) async {
    final client = _client;
    final uid = userId;
    if (client == null || uid == null) {
      return null;
    }

    try {
      final inserted = await client
          .from("foods")
          .insert({
            "source": "user",
            "owner_id": uid,
            "external_id": food.id,
            "barcode": food.barcode,
            "name": food.name,
            "brand": food.brand,
            "quantity": food.quantityLabel,
            "category": food.category,
            "kcal": food.per100g.kcal,
            "protein": food.per100g.protein,
            "fat": food.per100g.fat,
            "carbs": food.per100g.carbs,
            "sugar": food.per100g.sugar,
            "saturated_fat": food.per100g.saturatedFat,
            "salt": food.per100g.salt,
            "fiber": food.per100g.fiber,
          })
          .select("id")
          .single();

      final foodId = inserted["id"] as String?;
      if (foodId != null && food.servings.isNotEmpty) {
        await client.from("food_servings").insert(
              food.servings
                  .map((serving) => {
                        "food_id": foodId,
                        "label": serving.label,
                        "grams": serving.grams,
                      })
                  .toList(),
            );
      }
      return foodId;
    } on Object {
      return null;
    }
  }

  Future<void> setFavorite(String foodRemoteId, bool isFavorite) async {
    final client = _client;
    final uid = userId;
    if (client == null || uid == null) {
      return;
    }

    try {
      if (isFavorite) {
        await client.from("food_favorites").upsert({
          "user_id": uid,
          "food_id": foodRemoteId,
        });
      } else {
        await client
            .from("food_favorites")
            .delete()
            .eq("user_id", uid)
            .eq("food_id", foodRemoteId);
      }
    } on Object {
      // Offline esetben a helyi jelölés marad, a következő szinkron pótolja.
    }
  }

  // --- Napló --------------------------------------------------------------

  Future<bool> pushDiaryEntries(List<DiaryEntry> entries) async {
    final client = _client;
    final uid = userId;
    if (client == null || uid == null || entries.isEmpty) {
      return false;
    }

    try {
      await client.from("diary_entries").upsert(
            entries.map((entry) => entry.toRemoteRow(uid)).toList(),
            onConflict: "id",
          );
      return true;
    } on Object {
      return false;
    }
  }

  Future<List<DiaryEntry>> pullDiaryEntries({DateTime? since}) async {
    final client = _client;
    final uid = userId;
    if (client == null || uid == null) {
      return const [];
    }

    try {
      var query = client.from("diary_entries").select().eq("user_id", uid);
      if (since != null) {
        query = query.gt("updated_at", since.toUtc().toIso8601String());
      }
      final rows = await query;
      return (rows as List)
          .whereType<Map>()
          .map(DiaryEntry.fromRemoteRow)
          .toList();
    } on Object {
      return const [];
    }
  }

  // --- Profil -------------------------------------------------------------

  Future<bool> pushProfile(UserProfile profile) async {
    final client = _client;
    final uid = userId;
    if (client == null || uid == null) {
      return false;
    }

    try {
      await client
          .from("profiles")
          .upsert(profile.toRemoteRow(uid), onConflict: "user_id");

      final goals = profile.manualGoals;
      if (goals != null) {
        await client.from("goals").upsert({
          "user_id": uid,
          "calorie_goal": goals.calories,
          "protein_goal": goals.protein,
          "fat_goal": goals.fat,
          "carbs_goal": goals.carbs,
          "water_goal_ml": goals.waterMl,
          "is_manual": goals.isManual,
        }, onConflict: "user_id");
      }
      return true;
    } on Object {
      return false;
    }
  }

  Future<UserProfile?> pullProfile() async {
    final client = _client;
    final uid = userId;
    if (client == null || uid == null) {
      return null;
    }

    try {
      final row = await client
          .from("profiles")
          .select()
          .eq("user_id", uid)
          .maybeSingle();
      if (row == null) {
        return null;
      }

      final profile = UserProfile.fromRemoteRow(row);
      final goalRow = await client
          .from("goals")
          .select()
          .eq("user_id", uid)
          .maybeSingle();

      if (goalRow == null || goalRow["calorie_goal"] == null) {
        return profile;
      }

      return profile.copyWith(
        manualGoals: NutritionGoals(
          calories: (goalRow["calorie_goal"] as num).toDouble(),
          protein: (goalRow["protein_goal"] as num?)?.toDouble() ?? 0,
          fat: (goalRow["fat_goal"] as num?)?.toDouble() ?? 0,
          carbs: (goalRow["carbs_goal"] as num?)?.toDouble() ?? 0,
          waterMl: (goalRow["water_goal_ml"] as num?)?.toInt() ?? 2500,
          isManual: goalRow["is_manual"] == true,
        ),
      );
    } on Object {
      return null;
    }
  }

  // --- Edzés és alvás -----------------------------------------------------

  Future<int> pushRows(String table, List<Map<String, dynamic>> rows) async {
    final client = _client;
    if (client == null || userId == null || rows.isEmpty) {
      return 0;
    }

    try {
      await client.from(table).upsert(rows, onConflict: "id");
      return rows.length;
    } on Object {
      return 0;
    }
  }

  Future<List<Map<String, dynamic>>> pullRows(String table,
      {DateTime? since}) async {
    final client = _client;
    final uid = userId;
    if (client == null || uid == null) {
      return const [];
    }

    try {
      var query = client.from(table).select().eq("user_id", uid);
      if (since != null) {
        query = query.gt("updated_at", since.toUtc().toIso8601String());
      }
      final rows = await query;
      return (rows as List)
          .whereType<Map>()
          .map((row) => Map<String, dynamic>.from(row))
          .toList();
    } on Object {
      return const [];
    }
  }

  // --- Fiók ---------------------------------------------------------------

  Future<bool> deleteAccount() async {
    final client = _client;
    if (client == null || !isSignedIn) {
      return false;
    }

    try {
      await client.rpc<dynamic>("delete_account");
      await client.auth.signOut();
      return true;
    } on Object {
      return false;
    }
  }

  List<FoodItem> _mapFoodRows(Object? result) {
    if (result is! List) {
      return const [];
    }
    return result
        .whereType<Map>()
        .map(FoodItem.fromRemoteRow)
        .where((food) => food.name.isNotEmpty)
        .toList();
  }
}
