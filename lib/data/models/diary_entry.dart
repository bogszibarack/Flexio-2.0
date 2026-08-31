import 'food_item.dart';
import 'nutrients.dart';

/// Étkezés-kategóriák. A napi diagram és az ütemezés nézet is ezt a sorrendet
/// használja.
class MealTypes {
  MealTypes._();

  static const String breakfast = "Reggeli";
  static const String lunch = "Ebéd";
  static const String snack = "Snack";
  static const String dinner = "Vacsora";
  static const String dessert = "Desszert";

  static const List<String> all = [breakfast, lunch, snack, dinner, dessert];

  static const List<String> mains = [breakfast, lunch, dinner];

  static bool isMain(String type) => mains.contains(type);

  static const Map<String, String> shortLabels = {
    breakfast: "Reg.",
    lunch: "Ebéd",
    snack: "Snack",
    dinner: "Vacs.",
    dessert: "Dessz.",
  };

  static String normalize(String? value) {
    if (value == null) {
      return breakfast;
    }
    for (final type in all) {
      if (type.toLowerCase() == value.trim().toLowerCase()) {
        return type;
      }
    }
    // A régi mock adatokban többes szám is előfordult.
    if (value.toLowerCase().startsWith("snack")) {
      return snack;
    }
    return breakfast;
  }

  /// Napszak alapján javasolt kategória, hogy a naplózás egy koppintással
  /// működjön.
  static String suggestFor(DateTime time) {
    final hour = time.hour;
    if (hour < 10) return breakfast;
    if (hour < 15) return lunch;
    if (hour < 17) return snack;
    if (hour < 22) return dinner;
    return snack;
  }
}

/// Egy naplózott étkezés. A tápanyagértékek pillanatfelvételként tárolódnak,
/// hogy a katalógus későbbi változása ne írja át a múltat.
class DiaryEntry {
  final String id;
  final DateTime loggedAt;
  final String mealType;
  final String? foodId;
  final String? foodLocalId;
  final String foodName;
  final String? foodImage;
  final double amountG;
  final String? servingLabel;
  final Nutrients totals;
  final DateTime updatedAt;
  final DateTime? deletedAt;

  const DiaryEntry({
    required this.id,
    required this.loggedAt,
    required this.mealType,
    required this.foodName,
    required this.amountG,
    required this.totals,
    required this.updatedAt,
    this.foodId,
    this.foodLocalId,
    this.foodImage,
    this.servingLabel,
    this.deletedAt,
  });

  DateTime get localDate =>
      DateTime(loggedAt.year, loggedAt.month, loggedAt.day);

  String get amountLabel {
    if (servingLabel != null && servingLabel!.isNotEmpty) {
      return "$servingLabel · ${Nutrients.formatGrams(amountG)} g";
    }
    return "${Nutrients.formatGrams(amountG)} g";
  }

  DiaryEntry copyWith({
    DateTime? loggedAt,
    String? mealType,
    double? amountG,
    String? servingLabel,
    Nutrients? totals,
    DateTime? updatedAt,
    DateTime? deletedAt,
  }) =>
      DiaryEntry(
        id: id,
        loggedAt: loggedAt ?? this.loggedAt,
        mealType: mealType ?? this.mealType,
        foodId: foodId,
        foodLocalId: foodLocalId,
        foodName: foodName,
        foodImage: foodImage,
        amountG: amountG ?? this.amountG,
        servingLabel: servingLabel ?? this.servingLabel,
        totals: totals ?? this.totals,
        updatedAt: updatedAt ?? DateTime.now(),
        deletedAt: deletedAt ?? this.deletedAt,
      );

  factory DiaryEntry.fromFood({
    required String id,
    required FoodItem food,
    required double amountG,
    required String mealType,
    DateTime? loggedAt,
    String? servingLabel,
  }) {
    final when = loggedAt ?? DateTime.now();
    return DiaryEntry(
      id: id,
      loggedAt: when,
      mealType: mealType,
      foodId: food.remoteId,
      foodLocalId: food.id,
      foodName: food.name,
      foodImage: food.imageUrl,
      amountG: amountG,
      servingLabel: servingLabel,
      totals: food.per100g.forGrams(amountG),
      updatedAt: when,
    );
  }

  Map<String, dynamic> toRemoteRow(String userId) => {
        "id": id,
        "user_id": userId,
        "logged_at": loggedAt.toUtc().toIso8601String(),
        "local_date":
            "${localDate.year.toString().padLeft(4, '0')}-${localDate.month.toString().padLeft(2, '0')}-${localDate.day.toString().padLeft(2, '0')}",
        "meal_type": mealType,
        "food_id": foodId,
        "food_name": foodName,
        "food_image": foodImage,
        "amount_g": amountG,
        "serving_label": servingLabel,
        "kcal": totals.kcal,
        "protein": totals.protein,
        "fat": totals.fat,
        "carbs": totals.carbs,
        "sugar": totals.sugar,
        "saturated_fat": totals.saturatedFat,
        "salt": totals.salt,
        "fiber": totals.fiber,
        "updated_at": updatedAt.toUtc().toIso8601String(),
        "deleted_at": deletedAt?.toUtc().toIso8601String(),
      };

  factory DiaryEntry.fromRemoteRow(Map<dynamic, dynamic> row) => DiaryEntry(
        id: "${row["id"]}",
        loggedAt: DateTime.parse("${row["logged_at"]}").toLocal(),
        mealType: MealTypes.normalize(row["meal_type"] as String?),
        foodId: row["food_id"] as String?,
        foodName: "${row["food_name"] ?? ""}",
        foodImage: row["food_image"] as String?,
        amountG: Nutrients.readDouble(row["amount_g"]),
        servingLabel: row["serving_label"] as String?,
        totals: Nutrients.fromRow(row),
        updatedAt: DateTime.parse("${row["updated_at"]}").toLocal(),
        deletedAt: row["deleted_at"] == null
            ? null
            : DateTime.parse("${row["deleted_at"]}").toLocal(),
      );
}
