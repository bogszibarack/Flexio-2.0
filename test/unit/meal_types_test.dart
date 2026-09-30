import 'package:fitness/data/models/diary_entry.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test("nincs desszert kategória", () {
    expect(MealTypes.all, ["Reggeli", "Ebéd", "Snack", "Vacsora"]);
    expect(MealTypes.all.any((type) => type.toLowerCase().contains("dessz")),
        isFalse);
    expect(MealTypes.shortLabels.keys, MealTypes.all);
  });

  test("a régi desszert bejegyzések snackként jelennek meg, nem reggeliként",
      () {
    expect(MealTypes.normalize("Desszert"), MealTypes.snack);
    expect(MealTypes.normalize(" desszert "), MealTypes.snack);
  });

  test("a normalizálás a meglévő kategóriákat megtartja", () {
    for (final type in MealTypes.all) {
      expect(MealTypes.normalize(type), type);
    }
    expect(MealTypes.normalize("Snacks"), MealTypes.snack);
    expect(MealTypes.normalize(null), MealTypes.breakfast);
  });

  test("a napszak szerinti javaslat mindig létező kategória", () {
    for (var hour = 0; hour < 24; hour++) {
      expect(MealTypes.all,
          contains(MealTypes.suggestFor(DateTime(2026, 1, 1, hour))));
    }
  });
}
