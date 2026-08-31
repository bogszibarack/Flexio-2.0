import '../../common/common.dart';
import '../../data/models/diary_entry.dart';
import '../../data/models/nutrients.dart';
import '../../data/models/user_profile.dart';

enum MealPeriod { daily, weekly, monthly }

/// Egy diagramoszlop: a felirat és a hozzá tartozó tápanyagösszeg.
class MealChartBucket {
  final String label;
  final MealTotals totals;

  const MealChartBucket({required this.label, required this.totals});
}

class MealTotals {
  final double protein;
  final double fat;
  final double carbs;

  const MealTotals({
    this.protein = 0,
    this.fat = 0,
    this.carbs = 0,
  });

  double get proteinCalories => protein * Nutrients.proteinKcalPerGram;
  double get fatCalories => fat * Nutrients.fatKcalPerGram;
  double get carbsCalories => carbs * Nutrients.carbsKcalPerGram;
  double get calories => proteinCalories + fatCalories + carbsCalories;

  bool get isEmpty => protein == 0 && fat == 0 && carbs == 0;

  MealTotals operator +(MealTotals other) => MealTotals(
        protein: protein + other.protein,
        fat: fat + other.fat,
        carbs: carbs + other.carbs,
      );

  factory MealTotals.fromNutrients(Nutrients nutrients) => MealTotals(
        protein: nutrients.protein,
        fat: nutrients.fat,
        carbs: nutrients.carbs,
      );
}

/// A naplóból számolt összesítések: napi, heti és havi diagram, összegek és
/// feliratok. Az adatot a repository adja, ez az osztály csak aggregál.
class MealStore {
  MealStore(this.entries, {NutritionGoals? goals})
      : goals = goals ?? NutritionGoals.fallback;

  final List<DiaryEntry> entries;
  final NutritionGoals goals;

  static const List<String> categories = MealTypes.all;

  static const Map<String, String> shortCategoryLabels = MealTypes.shortLabels;

  static const List<String> weekdayLabels = [
    "Vas",
    "Hét",
    "Ked",
    "Sze",
    "Csü",
    "Pén",
    "Szo",
  ];

  double get dailyCalorieGoal => goals.calories;
  double get dailyProteinGoal => goals.protein;
  double get dailyFatGoal => goals.fat;
  double get dailyCarbsGoal => goals.carbs;

  bool get isEmpty => entries.isEmpty;

  List<DiaryEntry> mealsForDay(DateTime day, {String? category}) {
    final start = DateTime(day.year, day.month, day.day);
    return mealsInRange(start, start.add(const Duration(days: 1)),
        category: category);
  }

  List<DiaryEntry> mealsInRange(DateTime start, DateTime endExclusive,
      {String? category}) {
    final meals = entries.where((entry) {
      if (entry.loggedAt.isBefore(start) || !entry.loggedAt.isBefore(endExclusive)) {
        return false;
      }
      return category == null || entry.mealType == category;
    }).toList();

    meals.sort((a, b) => a.loggedAt.compareTo(b.loggedAt));
    return meals;
  }

  MealTotals totalsOf(Iterable<DiaryEntry> meals) {
    var totals = const MealTotals();
    for (final meal in meals) {
      totals = totals + MealTotals.fromNutrients(meal.totals);
    }
    return totals;
  }

  /// A kiválasztott időszak oszlopai. Az `offset` 0 az aktuális időszak,
  /// negatív értékek a korábbiak (nap / hét / hónap egységben).
  List<MealChartBucket> chartBuckets({
    required MealPeriod period,
    required int offset,
  }) {
    switch (period) {
      case MealPeriod.daily:
        final day = _dayWithOffset(offset);
        final meals = mealsForDay(day);
        return categories
            .map((category) => MealChartBucket(
                  label: shortCategoryLabels[category] ?? category,
                  totals: totalsOf(
                      meals.where((meal) => meal.mealType == category)),
                ))
            .toList();

      case MealPeriod.weekly:
        final weekStart = _weekStartWithOffset(offset);
        return List.generate(7, (index) {
          final day = weekStart.add(Duration(days: index));
          return MealChartBucket(
            label: weekdayLabels[index],
            totals: totalsOf(mealsForDay(day)),
          );
        });

      case MealPeriod.monthly:
        final month = _monthWithOffset(offset);
        final daysInMonth = DateTime(month.year, month.month + 1, 0).day;
        final buckets = <MealChartBucket>[];
        for (var startDay = 1; startDay <= daysInMonth; startDay += 7) {
          final endDay =
              startDay + 6 > daysInMonth ? daysInMonth : startDay + 6;
          final start = DateTime(month.year, month.month, startDay);
          final endExclusive = DateTime(month.year, month.month, endDay)
              .add(const Duration(days: 1));
          buckets.add(MealChartBucket(
            label: "$startDay–$endDay",
            totals: totalsOf(mealsInRange(start, endExclusive)),
          ));
        }
        return buckets;
    }
  }

  MealTotals periodTotals({
    required MealPeriod period,
    required int offset,
  }) {
    switch (period) {
      case MealPeriod.daily:
        return totalsOf(mealsForDay(_dayWithOffset(offset)));
      case MealPeriod.weekly:
        final start = _weekStartWithOffset(offset);
        return totalsOf(mealsInRange(start, start.add(const Duration(days: 7))));
      case MealPeriod.monthly:
        final month = _monthWithOffset(offset);
        return totalsOf(mealsInRange(
            month, DateTime(month.year, month.month + 1, 1)));
    }
  }

  static String periodLabel({
    required MealPeriod period,
    required int offset,
  }) {
    switch (period) {
      case MealPeriod.daily:
        final day = _dayWithOffset(offset);
        if (offset == 0) {
          return "Ma";
        }
        if (offset == -1) {
          return "Tegnap";
        }
        return "${dateToMonthDay(day)}, ${dateToWeekday(day)}";

      case MealPeriod.weekly:
        final start = _weekStartWithOffset(offset);
        final end = start.add(const Duration(days: 6));
        return "${dateToShortMonthDay(start)} – ${dateToShortMonthDay(end)}";

      case MealPeriod.monthly:
        return dateToYearMonth(_monthWithOffset(offset));
    }
  }

  /// Egy oszlop maximuma, ha még nincs adat: a napi cél alapján.
  double fallbackMaxCalories(MealPeriod period) {
    switch (period) {
      case MealPeriod.daily:
        return dailyCalorieGoal / 2;
      case MealPeriod.weekly:
        return dailyCalorieGoal;
      case MealPeriod.monthly:
        return dailyCalorieGoal * 7;
    }
  }

  static DateTime startOfWeek(DateTime date) {
    final day = DateTime(date.year, date.month, date.day);
    return day.subtract(Duration(days: day.weekday % 7));
  }

  static DateTime _dayWithOffset(int offset) {
    final now = DateTime.now();
    return DateTime(now.year, now.month, now.day + offset);
  }

  static DateTime _weekStartWithOffset(int offset) =>
      startOfWeek(DateTime.now()).add(Duration(days: 7 * offset));

  static DateTime _monthWithOffset(int offset) {
    final now = DateTime.now();
    return DateTime(now.year, now.month + offset, 1);
  }
}
