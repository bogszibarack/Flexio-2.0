import 'nutrients.dart';

enum FoodSource { curated, off, user }

FoodSource foodSourceFromName(String? value) {
  switch (value) {
    case "curated":
      return FoodSource.curated;
    case "user":
      return FoodSource.user;
    default:
      return FoodSource.off;
  }
}

String foodSourceName(FoodSource source) => source.name;

class FoodServing {
  final String label;
  final double grams;

  const FoodServing({required this.label, required this.grams});

  Map<String, dynamic> toJson() => {"label": label, "grams": grams};

  factory FoodServing.fromJson(Map<dynamic, dynamic> json) => FoodServing(
        label: "${json["label"] ?? ""}",
        grams: Nutrients.readDouble(json["grams"]),
      );

  static List<FoodServing> listFromJson(Object? value) {
    if (value is! List) {
      return const [];
    }
    return value
        .whereType<Map>()
        .map(FoodServing.fromJson)
        .where((serving) => serving.label.isNotEmpty && serving.grams > 0)
        .toList();
  }
}

/// Egy katalógustétel: kurátorolt magyar alapanyag, Open Food Facts termék vagy
/// a felhasználó saját étele.
class FoodItem {
  /// Helyi azonosító. Kurátorolt tételnél `curated:<slug>`, vonalkódosnál
  /// `off:<barcode>`, sajátnál `user:<uuid>`.
  final String id;

  /// A szerveroldali uuid, ha ismert. Ehhez kötjük a naplóbejegyzést.
  final String? remoteId;

  final FoodSource source;
  final String? barcode;
  final String name;
  final String? brand;

  /// A csomagoláson szereplő kiszerelés, például "330 ml".
  final String? quantityLabel;
  final String? category;
  final String? imageUrl;
  final Nutrients per100g;
  final List<FoodServing> servings;
  final int popularity;
  final double qualityScore;
  final bool isFavorite;
  final DateTime? lastUsedAt;

  const FoodItem({
    required this.id,
    required this.name,
    required this.per100g,
    this.remoteId,
    this.source = FoodSource.curated,
    this.barcode,
    this.brand,
    this.quantityLabel,
    this.category,
    this.imageUrl,
    this.servings = const [],
    this.popularity = 0,
    this.qualityScore = 0,
    this.isFavorite = false,
    this.lastUsedAt,
  });

  String get subtitle {
    final parts = <String>[
      if (brand != null && brand!.trim().isNotEmpty) brand!.trim(),
      "${per100g.kcal.round()} kcal / 100 g",
    ];
    return parts.join(" · ");
  }

  /// Az adag-választóban felajánlott lehetőségek. A 100 grammos alap mindig
  /// szerepel, hogy a kézi bevitel is működjön.
  List<FoodServing> get selectableServings {
    final result = <FoodServing>[...servings];
    final hasHundred = result.any((serving) => serving.grams == 100);
    if (!hasHundred) {
      result.add(const FoodServing(label: "100 g", grams: 100));
    }
    return result;
  }

  FoodItem copyWith({
    String? remoteId,
    bool? isFavorite,
    DateTime? lastUsedAt,
    int? popularity,
  }) =>
      FoodItem(
        id: id,
        remoteId: remoteId ?? this.remoteId,
        source: source,
        barcode: barcode,
        name: name,
        brand: brand,
        quantityLabel: quantityLabel,
        category: category,
        imageUrl: imageUrl,
        per100g: per100g,
        servings: servings,
        popularity: popularity ?? this.popularity,
        qualityScore: qualityScore,
        isFavorite: isFavorite ?? this.isFavorite,
        lastUsedAt: lastUsedAt ?? this.lastUsedAt,
      );

  /// A beépített magyar katalógus (assets/food_catalog_hu.json) formátuma.
  factory FoodItem.fromCatalogJson(Map<dynamic, dynamic> json) {
    final slug = "${json["id"] ?? ""}";
    return FoodItem(
      id: "curated:$slug",
      source: FoodSource.curated,
      name: "${json["name"] ?? ""}",
      category: json["category"] as String?,
      per100g: Nutrients(
        kcal: Nutrients.readDouble(json["kcal"]),
        protein: Nutrients.readDouble(json["protein"]),
        fat: Nutrients.readDouble(json["fat"]),
        carbs: Nutrients.readDouble(json["carbs"]),
        sugar: Nutrients.readNullableDouble(json["sugar"]),
        saturatedFat: Nutrients.readNullableDouble(json["saturatedFat"]),
        salt: Nutrients.readNullableDouble(json["salt"]),
        fiber: Nutrients.readNullableDouble(json["fiber"]),
      ),
      servings: FoodServing.listFromJson(json["servings"]),
      qualityScore: 1,
    );
  }

  /// A `search_foods` RPC és a `foods` tábla soraiból.
  factory FoodItem.fromRemoteRow(Map<dynamic, dynamic> row) {
    final source = foodSourceFromName(row["source"] as String?);
    final barcode = row["barcode"] as String?;
    final externalId = row["external_id"] as String?;
    final remoteId = row["id"] as String?;

    final localId = switch (source) {
      FoodSource.curated => "curated:${externalId ?? remoteId}",
      FoodSource.off => "off:${barcode ?? remoteId}",
      FoodSource.user => "user:${remoteId ?? externalId}",
    };

    return FoodItem(
      id: localId,
      remoteId: remoteId,
      source: source,
      barcode: barcode,
      name: "${row["name"] ?? ""}",
      brand: row["brand"] as String?,
      quantityLabel: row["quantity"] as String?,
      category: row["category"] as String?,
      imageUrl: row["image_url"] as String?,
      per100g: Nutrients.fromRow(row).withDerivedCalories(),
      servings: FoodServing.listFromJson(row["servings"]),
      popularity: (row["popularity"] as num?)?.toInt() ?? 0,
      qualityScore: Nutrients.readDouble(row["quality_score"]),
    );
  }
}
