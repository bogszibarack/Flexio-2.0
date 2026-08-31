import 'dart:convert';

import 'package:uuid/uuid.dart';

import '../local/app_database.dart';
import '../local_catalog.dart';
import '../models/food_item.dart';
import '../models/nutrients.dart';
import '../remote/off_api.dart';
import '../remote/supabase_gateway.dart';

/// Ételkeresés és katalógus-kezelés. A találatok létrája:
/// beépített magyar katalógus és helyi gyorsítótár, majd a szerveroldali
/// keresés, végül élő Open Food Facts hívás.
class FoodRepository {
  FoodRepository({
    required AppDatabase database,
    required SupabaseGateway gateway,
    OffApi? off,
  })  : _database = database,
        _gateway = gateway,
        _off = off ?? OffApi();

  final AppDatabase _database;
  final SupabaseGateway _gateway;
  final OffApi _off;
  final Uuid _uuid = const Uuid();

  Future<void> warmUp() => LocalCatalog.instance.ensureLoaded();

  Future<List<FoodItem>> search(String query, {int limit = 30}) async {
    final trimmed = query.trim();
    if (trimmed.length < 2) {
      return const [];
    }

    await LocalCatalog.instance.ensureLoaded();

    final results = <String, FoodItem>{};
    void collect(Iterable<FoodItem> foods) {
      for (final food in foods) {
        final key = _dedupeKey(food);
        final existing = results[key];
        if (existing == null) {
          results[key] = food;
          continue;
        }
        // A szerveroldali találat többet tud (uuid, népszerűség), de a
        // kurátorolt magyar név a jobb.
        if (existing.remoteId == null && food.remoteId != null) {
          results[key] = existing.copyWith(
            remoteId: food.remoteId,
            popularity: food.popularity,
          );
        }
      }
    }

    collect(LocalCatalog.instance.search(trimmed, limit: limit));
    collect(await _cachedMatches(trimmed, limit: limit));

    if (results.length < limit) {
      collect(await _gateway.searchFoods(trimmed, limit: limit));
    }

    // Ha még mindig kevés a találat, élő Open Food Facts keresés. A találatokat
    // elmentjük, így legközelebb offline is megvannak.
    if (results.length < 5) {
      final remote = await _off.search(trimmed, limit: 15);
      collect(remote);
      for (final food in remote.take(10)) {
        await cacheFood(food);
      }
    }

    final ordered = results.values.toList()
      ..sort((a, b) {
        final byFavorite =
            (b.isFavorite ? 1 : 0).compareTo(a.isFavorite ? 1 : 0);
        if (byFavorite != 0) {
          return byFavorite;
        }
        final bySource = _sourceRank(a.source).compareTo(_sourceRank(b.source));
        if (bySource != 0) {
          return bySource;
        }
        final byPopularity = b.popularity.compareTo(a.popularity);
        if (byPopularity != 0) {
          return byPopularity;
        }
        return a.name.length.compareTo(b.name.length);
      });

    if (ordered.isEmpty) {
      await _gateway.logSearchMiss(trimmed, 0);
    }

    return ordered.take(limit).toList();
  }

  /// Vonalkód feloldása: helyi gyorsítótár, szerver, majd Open Food Facts.
  Future<FoodItem?> resolveBarcode(String barcode) async {
    final code = barcode.replaceAll(RegExp(r"[^0-9]"), "");
    if (code.length < 8) {
      return null;
    }

    final cached = await _database.foodByBarcode(code);
    if (cached != null) {
      return _fromRow(cached);
    }

    final remote = await _gateway.foodByBarcode(code);
    if (remote != null) {
      await cacheFood(remote);
      return remote;
    }

    final fromOff = await _off.productByBarcode(code);
    if (fromOff == null) {
      return null;
    }

    // Cache-on-write: a közös katalógusba is bekerül, hogy másnak is meglegyen.
    final remoteId = await _gateway.cacheOffFood(fromOff);
    final enriched =
        remoteId == null ? fromOff : fromOff.copyWith(remoteId: remoteId);
    await cacheFood(enriched);
    return enriched;
  }

  Future<List<FoodItem>> recentFoods({int limit = 30}) async {
    final rows = await _database.recentFoods(limit: limit);
    return rows.map(_fromRow).toList();
  }

  Future<List<FoodItem>> favoriteFoods() async {
    final rows = await _database.favoriteFoods();
    return rows.map(_fromRow).toList();
  }

  Future<List<FoodItem>> ownFoods() async {
    final rows = await _database.ownFoods();
    return rows.map(_fromRow).toList();
  }

  Future<FoodItem?> byLocalId(String id) async {
    final cached = await _database.foodById(id);
    if (cached != null) {
      return _fromRow(cached);
    }
    await LocalCatalog.instance.ensureLoaded();
    return LocalCatalog.instance.byId(id);
  }

  Future<FoodItem> toggleFavorite(FoodItem food) async {
    final updated = food.copyWith(isFavorite: !food.isFavorite);
    await cacheFood(updated);
    if (updated.remoteId != null) {
      await _gateway.setFavorite(updated.remoteId!, updated.isFavorite);
    }
    return updated;
  }

  /// Naplózás után: a gyorsítótárban frissül a legutóbbi használat, a szerveren
  /// pedig a népszerűség, ami a keresési rangsort javítja.
  Future<void> markUsed(FoodItem food) async {
    await cacheFood(food.copyWith(
      lastUsedAt: DateTime.now(),
      popularity: food.popularity + 1,
    ));
    if (food.remoteId != null) {
      await _gateway.incrementPopularity(food.remoteId!);
    }
  }

  Future<FoodItem> createUserFood({
    required String name,
    String? brand,
    String? barcode,
    required Nutrients per100g,
    List<FoodServing> servings = const [],
  }) async {
    final food = FoodItem(
      id: "user:${_uuid.v4()}",
      source: FoodSource.user,
      name: name.trim(),
      brand: brand?.trim().isEmpty == true ? null : brand?.trim(),
      barcode: barcode,
      per100g: per100g.withDerivedCalories(),
      servings: servings,
      qualityScore: 0.7,
    );

    final remoteId = await _gateway.createUserFood(food);
    final stored = remoteId == null ? food : food.copyWith(remoteId: remoteId);
    await cacheFood(stored, pendingUpload: remoteId == null);
    return stored;
  }

  /// A saját ételek feltöltése, ha korábban offline jöttek létre.
  Future<void> pushPendingFoods() async {
    if (!_gateway.isSignedIn) {
      return;
    }

    for (final row in await _database.dirtyFoods()) {
      final food = _fromRow(row);
      if (food.source != FoodSource.user) {
        await cacheFood(food, pendingUpload: false);
        continue;
      }
      final remoteId = await _gateway.createUserFood(food);
      if (remoteId != null) {
        await cacheFood(food.copyWith(remoteId: remoteId), pendingUpload: false);
      }
    }
  }

  Future<void> cacheFood(FoodItem food, {bool pendingUpload = false}) async {
    await _database.saveFood(CachedFoodRow(
      id: food.id,
      remoteId: food.remoteId,
      source: foodSourceName(food.source),
      barcode: food.barcode,
      name: food.name,
      normalizedName: LocalCatalog.normalize("${food.name} ${food.brand ?? ""}"),
      brand: food.brand,
      category: food.category,
      imageUrl: food.imageUrl,
      kcal: food.per100g.kcal,
      protein: food.per100g.protein,
      fat: food.per100g.fat,
      carbs: food.per100g.carbs,
      sugar: food.per100g.sugar,
      saturatedFat: food.per100g.saturatedFat,
      salt: food.per100g.salt,
      fiber: food.per100g.fiber,
      servingsJson:
          jsonEncode(food.servings.map((serving) => serving.toJson()).toList()),
      popularity: food.popularity,
      qualityScore: food.qualityScore,
      isFavorite: food.isFavorite,
      lastUsedAt: food.lastUsedAt,
      isDirty: pendingUpload,
    ));
  }

  Future<List<FoodItem>> _cachedMatches(String query, {int limit = 25}) async {
    final rows = await _database.searchCachedFoods(
      LocalCatalog.normalize(query),
      limit: limit,
    );
    return rows.map(_fromRow).toList();
  }

  static int _sourceRank(FoodSource source) {
    switch (source) {
      case FoodSource.curated:
        return 0;
      case FoodSource.user:
        return 1;
      case FoodSource.off:
        return 2;
    }
  }

  static String _dedupeKey(FoodItem food) {
    if (food.barcode != null && food.barcode!.isNotEmpty) {
      return "barcode:${food.barcode}";
    }
    return "name:${LocalCatalog.normalize(food.name)}|${LocalCatalog.normalize(food.brand ?? "")}";
  }

  static FoodItem _fromRow(CachedFoodRow row) => FoodItem(
        id: row.id,
        remoteId: row.remoteId,
        source: foodSourceFromName(row.source),
        barcode: row.barcode,
        name: row.name,
        brand: row.brand,
        category: row.category,
        imageUrl: row.imageUrl,
        per100g: Nutrients(
          kcal: row.kcal,
          protein: row.protein,
          fat: row.fat,
          carbs: row.carbs,
          sugar: row.sugar,
          saturatedFat: row.saturatedFat,
          salt: row.salt,
          fiber: row.fiber,
        ),
        servings: FoodServing.listFromJson(_decodeServings(row.servingsJson)),
        popularity: row.popularity,
        qualityScore: row.qualityScore,
        isFavorite: row.isFavorite,
        lastUsedAt: row.lastUsedAt,
      );

  static Object? _decodeServings(String raw) {
    try {
      return jsonDecode(raw);
    } on FormatException {
      return const [];
    }
  }
}
