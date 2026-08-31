import 'package:flutter/foundation.dart';

import '../local/app_database.dart';

/// Profilban kapcsolható coach-csatornák és csendes órák.
class CoachSettings extends ChangeNotifier {
  CoachSettings({required AppDatabase database}) : _database = database;

  static const _workoutKey = "coach_workout";
  static const _mealKey = "coach_meal";
  static const _mealCardKey = "coach_meal_card";
  static const _sleepKey = "coach_sleep";
  static const _quietStartKey = "coach_quiet_start";
  static const _quietEndKey = "coach_quiet_end";
  static const _weeklyAtKey = "coach_weekly_at";

  final AppDatabase _database;

  bool workout = true;
  bool meal = true;
  bool mealCard = false;
  bool sleep = true;
  int quietStartHour = 22;
  int quietEndHour = 7;
  DateTime? lastWeeklyAt;
  bool loaded = false;

  Future<void> load() async {
    workout = await _database.metaValue(_workoutKey) != "false";
    meal = await _database.metaValue(_mealKey) != "false";
    mealCard = await _database.metaValue(_mealCardKey) == "true";
    sleep = await _database.metaValue(_sleepKey) != "false";
    quietStartHour =
        int.tryParse(await _database.metaValue(_quietStartKey) ?? "") ?? 22;
    quietEndHour =
        int.tryParse(await _database.metaValue(_quietEndKey) ?? "") ?? 7;
    lastWeeklyAt = DateTime.tryParse(
      await _database.metaValue(_weeklyAtKey) ?? "",
    );
    loaded = true;
    notifyListeners();
  }

  bool get isQuietNow => isQuietAt(DateTime.now());

  bool isQuietAt(DateTime time) {
    final hour = time.hour;
    if (quietStartHour == quietEndHour) {
      return false;
    }
    if (quietStartHour < quietEndHour) {
      return hour >= quietStartHour && hour < quietEndHour;
    }
    return hour >= quietStartHour || hour < quietEndHour;
  }

  Future<void> setWorkout(bool value) async {
    workout = value;
    notifyListeners();
    await _database.setMeta(_workoutKey, "$value");
  }

  Future<void> setMeal(bool value) async {
    meal = value;
    notifyListeners();
    await _database.setMeta(_mealKey, "$value");
  }

  Future<void> setMealCard(bool value) async {
    mealCard = value;
    notifyListeners();
    await _database.setMeta(_mealCardKey, "$value");
  }

  Future<void> setSleep(bool value) async {
    sleep = value;
    notifyListeners();
    await _database.setMeta(_sleepKey, "$value");
  }

  Future<void> setQuietHours({required int start, required int end}) async {
    quietStartHour = start;
    quietEndHour = end;
    notifyListeners();
    await _database.setMeta(_quietStartKey, "$start");
    await _database.setMeta(_quietEndKey, "$end");
  }

  Future<void> markWeeklyPushed() async {
    lastWeeklyAt = DateTime.now();
    await _database.setMeta(_weeklyAtKey, lastWeeklyAt!.toIso8601String());
  }

  String get quietLabel {
    final start = "${quietStartHour.toString().padLeft(2, "0")}:00";
    final end = "${quietEndHour.toString().padLeft(2, "0")}:00";
    return "$start–$end";
  }
}
