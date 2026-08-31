import 'package:dio/dio.dart';

import '../app_config.dart';
import '../models/food_item.dart';
import '../models/nutrients.dart';

/// Open Food Facts kliens. Akkor hívjuk, ha a saját katalógusban nincs találat:
/// vonalkód feloldására és szöveges keresésre.
///
/// Az adat forrása az Open Food Facts, licenc: Open Database License (ODbL).
class OffApi {
  OffApi({Dio? client})
      : _client = client ??
            Dio(BaseOptions(
              baseUrl: AppConfig.offBaseUrl,
              connectTimeout: const Duration(seconds: 8),
              receiveTimeout: const Duration(seconds: 12),
              headers: {"User-Agent": AppConfig.offUserAgent},
            ));

  final Dio _client;

  static const List<String> _fields = [
    "code",
    "product_name",
    "product_name_hu",
    "brands",
    "quantity",
    "image_small_url",
    "serving_size",
    "nutriments",
    "countries_tags",
  ];

  Future<FoodItem?> productByBarcode(String barcode) async {
    final code = barcode.replaceAll(RegExp(r"[^0-9]"), "");
    if (code.length < 8) {
      return null;
    }

    try {
      final response = await _client.get<Map<String, dynamic>>(
        "/api/v2/product/$code.json",
        queryParameters: {"fields": _fields.join(",")},
      );

      final data = response.data;
      if (data == null || data["status"] == 0) {
        return null;
      }

      final product = data["product"];
      if (product is! Map) {
        return null;
      }

      return _mapProduct(product, fallbackBarcode: code);
    } on DioException {
      return null;
    }
  }

  Future<List<FoodItem>> search(String query, {int limit = 20}) async {
    final trimmed = query.trim();
    if (trimmed.length < 3) {
      return const [];
    }

    try {
      final response = await _client.get<Map<String, dynamic>>(
        "/api/v2/search",
        queryParameters: {
          "search_terms": trimmed,
          // Magyar forgalmazású termékek előre.
          "countries_tags_en": "hungary",
          "fields": _fields.join(","),
          "page_size": limit,
          "sort_by": "unique_scans_n",
        },
      );

      final products = response.data?["products"];
      if (products is! List) {
        return const [];
      }

      return products
          .whereType<Map>()
          .map((product) => _mapProduct(product))
          .whereType<FoodItem>()
          .toList();
    } on DioException {
      return const [];
    }
  }

  FoodItem? _mapProduct(Map<dynamic, dynamic> product,
      {String? fallbackBarcode}) {
    final barcode = "${product["code"] ?? fallbackBarcode ?? ""}"
        .replaceAll(RegExp(r"[^0-9]"), "");
    if (barcode.isEmpty) {
      return null;
    }

    final name = _pickName(product);
    if (name == null) {
      return null;
    }

    final nutriments = product["nutriments"];
    final map = nutriments is Map ? nutriments : const {};

    final per100g = Nutrients(
      kcal: Nutrients.readDouble(map["energy-kcal_100g"]),
      protein: Nutrients.readDouble(map["proteins_100g"]),
      fat: Nutrients.readDouble(map["fat_100g"]),
      carbs: Nutrients.readDouble(map["carbohydrates_100g"]),
      sugar: Nutrients.readNullableDouble(map["sugars_100g"]),
      saturatedFat: Nutrients.readNullableDouble(map["saturated-fat_100g"]),
      salt: Nutrients.readNullableDouble(map["salt_100g"]),
      fiber: Nutrients.readNullableDouble(map["fiber_100g"]),
    ).withDerivedCalories();

    if (per100g.isEmpty) {
      // Tápanyagadat nélkül nem lehet naplózni.
      return null;
    }

    return FoodItem(
      id: "off:$barcode",
      source: FoodSource.off,
      barcode: barcode,
      name: name,
      brand: _firstBrand(product["brands"]),
      quantityLabel: product["quantity"] as String?,
      imageUrl: product["image_small_url"] as String?,
      per100g: per100g,
      servings: _servings(product["serving_size"]),
      qualityScore: per100g.kcal > 0 && per100g.protein + per100g.carbs > 0
          ? 0.8
          : 0.5,
    );
  }

  static String? _pickName(Map<dynamic, dynamic> product) {
    for (final key in ["product_name_hu", "product_name"]) {
      final value = "${product[key] ?? ""}".trim();
      if (value.length >= 2) {
        return value;
      }
    }

    final brand = _firstBrand(product["brands"]);
    final quantity = "${product["quantity"] ?? ""}".trim();
    final combined = [brand, quantity].whereType<String>().join(" ").trim();
    return combined.length >= 2 ? combined : null;
  }

  static String? _firstBrand(Object? brands) {
    final value = "${brands ?? ""}".trim();
    if (value.isEmpty) {
      return null;
    }
    return value.split(",").first.trim();
  }

  static List<FoodServing> _servings(Object? servingSize) {
    final raw = "${servingSize ?? ""}";
    final match = RegExp(r"([0-9]+([.,][0-9]+)?)\s*(g|ml)").firstMatch(raw);
    if (match == null) {
      return const [];
    }

    final grams = double.tryParse(match.group(1)!.replaceAll(",", "."));
    if (grams == null || grams <= 0 || grams > 3000) {
      return const [];
    }

    return [
      FoodServing(label: "1 adag (${Nutrients.formatGrams(grams)} g)", grams: grams),
    ];
  }
}
