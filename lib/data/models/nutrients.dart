import 'dart:math' as math;

/// Tápanyagértékek. A katalógusban 100 grammra, a naplóban a tényleges
/// mennyiségre vetítve értendők.
class Nutrients {
  final double kcal;
  final double protein;
  final double fat;
  final double carbs;
  final double? sugar;
  final double? saturatedFat;
  final double? salt;
  final double? fiber;

  const Nutrients({
    this.kcal = 0,
    this.protein = 0,
    this.fat = 0,
    this.carbs = 0,
    this.sugar,
    this.saturatedFat,
    this.salt,
    this.fiber,
  });

  static const Nutrients zero = Nutrients();

  static const double proteinKcalPerGram = 4;
  static const double carbsKcalPerGram = 4;
  static const double fatKcalPerGram = 9;

  double get proteinCalories => protein * proteinKcalPerGram;
  double get carbsCalories => carbs * carbsKcalPerGram;
  double get fatCalories => fat * fatKcalPerGram;

  /// A makrókból számolt energia. A halmozott diagram ezzel dolgozik, hogy az
  /// oszlop magassága és a színek mindig összhangban legyenek.
  double get macroCalories => proteinCalories + carbsCalories + fatCalories;

  bool get isEmpty => kcal == 0 && protein == 0 && fat == 0 && carbs == 0;

  Nutrients scale(double factor) => Nutrients(
        kcal: kcal * factor,
        protein: protein * factor,
        fat: fat * factor,
        carbs: carbs * factor,
        sugar: sugar == null ? null : sugar! * factor,
        saturatedFat: saturatedFat == null ? null : saturatedFat! * factor,
        salt: salt == null ? null : salt! * factor,
        fiber: fiber == null ? null : fiber! * factor,
      );

  /// 100 grammra vetített értékekből a megadott mennyiségre.
  Nutrients forGrams(double grams) => scale(grams / 100);

  Nutrients operator +(Nutrients other) => Nutrients(
        kcal: kcal + other.kcal,
        protein: protein + other.protein,
        fat: fat + other.fat,
        carbs: carbs + other.carbs,
        sugar: _addNullable(sugar, other.sugar),
        saturatedFat: _addNullable(saturatedFat, other.saturatedFat),
        salt: _addNullable(salt, other.salt),
        fiber: _addNullable(fiber, other.fiber),
      );

  Map<String, dynamic> toJson() => {
        "kcal": kcal,
        "protein": protein,
        "fat": fat,
        "carbs": carbs,
        if (sugar != null) "sugar": sugar,
        if (saturatedFat != null) "saturatedFat": saturatedFat,
        if (salt != null) "salt": salt,
        if (fiber != null) "fiber": fiber,
      };

  factory Nutrients.fromJson(Map<dynamic, dynamic> json) => Nutrients(
        kcal: readDouble(json["kcal"]),
        protein: readDouble(json["protein"]),
        fat: readDouble(json["fat"]),
        carbs: readDouble(json["carbs"]),
        sugar: readNullableDouble(json["sugar"]),
        saturatedFat: readNullableDouble(json["saturatedFat"]),
        salt: readNullableDouble(json["salt"]),
        fiber: readNullableDouble(json["fiber"]),
      );

  /// Supabase és Open Food Facts oldali, aláhúzásos mezőnevek.
  factory Nutrients.fromRow(Map<dynamic, dynamic> row) => Nutrients(
        kcal: readDouble(row["kcal"]),
        protein: readDouble(row["protein"]),
        fat: readDouble(row["fat"]),
        carbs: readDouble(row["carbs"]),
        sugar: readNullableDouble(row["sugar"]),
        saturatedFat: readNullableDouble(row["saturated_fat"]),
        salt: readNullableDouble(row["salt"]),
        fiber: readNullableDouble(row["fiber"]),
      );

  /// Ha a forrásban nincs energia, a makrókból számolunk.
  Nutrients withDerivedCalories() {
    if (kcal > 0) {
      return this;
    }
    final derived = macroCalories;
    return derived <= 0 ? this : scale(1).copyWith(kcal: derived);
  }

  Nutrients copyWith({
    double? kcal,
    double? protein,
    double? fat,
    double? carbs,
  }) =>
      Nutrients(
        kcal: kcal ?? this.kcal,
        protein: protein ?? this.protein,
        fat: fat ?? this.fat,
        carbs: carbs ?? this.carbs,
        sugar: sugar,
        saturatedFat: saturatedFat,
        salt: salt,
        fiber: fiber,
      );

  static double? _addNullable(double? a, double? b) {
    if (a == null && b == null) {
      return null;
    }
    return (a ?? 0) + (b ?? 0);
  }

  static double readDouble(Object? value) {
    if (value is num) {
      return value.toDouble();
    }
    return double.tryParse("${value ?? ""}".replaceAll(",", ".")) ?? 0;
  }

  static double? readNullableDouble(Object? value) {
    if (value == null) {
      return null;
    }
    if (value is num) {
      return value.toDouble();
    }
    return double.tryParse("$value".replaceAll(",", "."));
  }

  /// Kerekített megjelenítés, hogy ne írjunk ki értelmetlen tizedeseket.
  static String formatGrams(double value) {
    if (value >= 10 || value == value.roundToDouble()) {
      return value.round().toString();
    }
    return value.toStringAsFixed(1);
  }

  static double clampPositive(double value) => math.max(0, value);
}
