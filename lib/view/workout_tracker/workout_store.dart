import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/scheduler.dart';
import 'package:uuid/uuid.dart';

import '../../data/repositories/workout_repository.dart';

class WorkoutStore {
  WorkoutStore._();

  /// A profilban beállított testsúly, a kalóriabecslés alapja.
  static double userWeightKg = 65;

  static final List<Map<String, dynamic>> workouts = <Map<String, dynamic>>[];

  static final List<Map<String, dynamic>> scheduledWorkouts = [];

  /// Befejezett edzések. Egy elem kulcsai:
  /// title, image, difficulty, date, minutes, calories, volume,
  /// completedSets, totalSets, workout.
  static final List<Map<String, dynamic>> completedWorkouts = [];

  static const Uuid _uuid = Uuid();
  static WorkoutRepository? _repository;
  static String? _userId;
  static Future<void> _persistChain = Future<void>.value();

  /// A felületek ezen keresztül tudják, hogy megjött-e a felhasználó adata.
  static final ValueNotifier<int> revision = ValueNotifier<int>(0);

  static bool get isBound => _repository != null && _userId != null;

  /// A bejelentkezett felhasználó edzései kerülnek a memóriába. Fiókváltásnál
  /// a korábbi tartalom eltűnik, hogy ne szivárogjon át a másik felhasználóhoz.
  static Future<void> bind({
    required WorkoutRepository repository,
    required String userId,
  }) async {
    final orphanTemplates = _repository == null
        ? List<Map<String, dynamic>>.from(workouts)
        : const <Map<String, dynamic>>[];
    final orphanScheduled = _repository == null
        ? List<Map<String, dynamic>>.from(scheduledWorkouts)
        : const <Map<String, dynamic>>[];
    final orphanCompleted = _repository == null
        ? List<Map<String, dynamic>>.from(completedWorkouts)
        : const <Map<String, dynamic>>[];

    if (_userId != null && _userId != userId) {
      _clearLists();
    }

    _repository = repository;
    _userId = userId;

    final snapshot = await repository.load(userId);
    _clearLists();
    workouts.addAll(snapshot.templates);
    scheduledWorkouts.addAll(snapshot.scheduled);
    completedWorkouts.addAll(snapshot.completed);

    for (final item in orphanTemplates) {
      workouts.add(item);
      _persist(WorkoutRepository.kindTemplate, item);
    }
    for (final item in orphanScheduled) {
      scheduledWorkouts.add(item);
      _persist(WorkoutRepository.kindScheduled, item);
    }
    for (final item in orphanCompleted) {
      completedWorkouts.add(item);
      _persist(WorkoutRepository.kindCompleted, item);
    }

    _relinkScheduledWorkouts();
    await flushPersists();
    _bump();
  }

  /// A háttérben futó mentések befejezésére várunk szinkron előtt.
  static Future<void> flushPersists() => _persistChain;

  static void unbind() {
    _repository = null;
    _userId = null;
    _clearLists();
    _bump();
  }

  static void _clearLists() {
    workouts.clear();
    scheduledWorkouts.clear();
    completedWorkouts.clear();
  }

  /// A tervezett elemek a saját edzésük térképére hivatkoznak. Visszaolvasás
  /// után ezek külön példányok lennének, ezért összefűzzük őket az id alapján.
  static void _relinkScheduledWorkouts() {
    for (final event in scheduledWorkouts) {
      final workout = event["workout"];
      if (workout is! Map) {
        continue;
      }
      final id = "${workout["id"] ?? ""}";
      final match = workouts.firstWhere(
        (template) => "${template["id"] ?? ""}" == id && id.isNotEmpty,
        orElse: () => <String, dynamic>{},
      );
      if (match.isNotEmpty) {
        event["workout"] = match;
      }
    }
  }

  static void Function(Map<String, dynamic> entry)? onCompletedLogged;

  static void _bump() => revision.value++;

  static String _ensureId(Map<String, dynamic> item) {
    final existing = "${item["id"] ?? ""}";
    if (existing.isNotEmpty) {
      return existing;
    }
    final id = _uuid.v4();
    item["id"] = id;
    return id;
  }

  static void _persist(String kind, Map<String, dynamic> item) {
    _ensureId(item);
    final repository = _repository;
    final userId = _userId;
    if (repository == null || userId == null) {
      return;
    }
    final payload = _persistable(item);
    _persistChain = _persistChain.then((_) async {
      await repository.save(userId: userId, kind: kind, item: payload);
    });
  }

  static void _forget(Map<String, dynamic> item) {
    final id = "${item["id"] ?? ""}";
    final repository = _repository;
    final userId = _userId;
    if (id.isEmpty || repository == null || userId == null) {
      return;
    }
    repository.remove(userId: userId, id: id);
  }

  /// A tervezett és a befejezett elem is hivatkozik a teljes edzésre. Mentéskor
  /// abból csak az azonosító és a fejadatok kellenek, különben a sablon minden
  /// szerkesztése után elavult másolatok halmozódnának.
  static Map<String, dynamic> _persistable(Map<String, dynamic> item) {
    final workout = item["workout"];
    if (workout is! Map) {
      return item;
    }
    return {
      ...item,
      "workout": {
        "id": workout["id"],
        "title": workout["title"],
        "image": workout["image"],
        "difficulty": workout["difficulty"],
        "exerciseList": workout["exerciseList"],
      },
    };
  }

  // --- Sablonok -----------------------------------------------------------

  static Map<String, dynamic> addWorkout(Map<String, dynamic> workout) {
    _ensureId(workout);
    workouts.add(workout);
    _persist(WorkoutRepository.kindTemplate, workout);
    _bump();
    return workout;
  }

  static void updateWorkout(Map<String, dynamic> workout, {bool notify = true}) {
    _persist(WorkoutRepository.kindTemplate, workout);
    if (notify) {
      _bump();
      return;
    }
    // dispose() közben a fa zárolt: a szülő setState-je a következő képkockára megy.
    SchedulerBinding.instance.addPostFrameCallback((_) => _bump());
  }

  /// A sablon és minden hozzá tartozó ütemezés törlése.
  static void removeWorkout(Map<String, dynamic> workout) {
    workouts.remove(workout);

    final events = scheduledWorkouts
        .where((event) => identical(event["workout"], workout))
        .toList();
    for (final event in events) {
      scheduledWorkouts.remove(event);
      _forget(event);
    }

    _forget(workout);
    _bump();
  }

  // --- Ütemezés -----------------------------------------------------------

  static Map<String, dynamic> addScheduledWorkout(Map<String, dynamic> event) {
    _ensureId(event);
    scheduledWorkouts.add(event);
    _persist(WorkoutRepository.kindScheduled, event);
    _bump();
    return event;
  }

  static void updateScheduledWorkout(Map<String, dynamic> event) {
    _persist(WorkoutRepository.kindScheduled, event);
    _bump();
  }

  static void removeScheduledWorkout(Map<String, dynamic> event) {
    scheduledWorkouts.remove(event);
    _forget(event);
    _bump();
  }

  static void restoreScheduledWorkout(Map<String, dynamic> event, {int? at}) {
    final index = (at ?? scheduledWorkouts.length)
        .clamp(0, scheduledWorkouts.length);
    scheduledWorkouts.insert(index, event);
    _persist(WorkoutRepository.kindScheduled, event);
    _bump();
  }

  static List<Map<String, dynamic>> get scheduledWorkoutsByDate {
    final sorted = List<Map<String, dynamic>>.from(scheduledWorkouts);
    sorted.sort((a, b) =>
        (a["date"] as DateTime).compareTo(b["date"] as DateTime));
    return sorted;
  }

  static List<Map<String, dynamic>> get upcomingScheduledWorkouts {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    return scheduledWorkoutsByDate.where((event) {
      if (event["completedAt"] != null) {
        return false;
      }
      final date = event["date"] as DateTime;
      return !DateTime(date.year, date.month, date.day).isBefore(today);
    }).toList();
  }

  /// Időrendben növekvő sorrend: a lista vége a legfrissebb edzés.
  static List<Map<String, dynamic>> get completedWorkoutsByDate {
    final sorted = List<Map<String, dynamic>>.from(completedWorkouts);
    sorted.sort((a, b) =>
        (a["date"] as DateTime).compareTo(b["date"] as DateTime));
    return sorted;
  }

  /// Időrendben csökkenő sorrend: a legfrissebb edzés az első.
  static List<Map<String, dynamic>> get completedWorkoutsByDateDesc =>
      completedWorkoutsByDate.reversed.toList();

  static Map<String, dynamic> logCompletedWorkout({
    required String title,
    required String image,
    required String difficulty,
    required int minutes,
    DateTime? date,
    double volume = 0,
    int completedSets = 0,
    int totalSets = 0,
    int? rpe,
    Map<String, dynamic>? workout,
    List<Map<String, dynamic>>? exerciseList,
  }) {
    final entry = <String, dynamic>{
      "title": title,
      "image": image,
      "difficulty": difficulty,
      "date": date ?? DateTime.now(),
      "minutes": minutes,
      "calories": estimateCalories(
        minutes: minutes,
        difficulty: difficulty,
        volume: volume,
      ),
      "volume": volume,
      "completedSets": completedSets,
      "totalSets": totalSets,
      if (rpe != null) "rpe": rpe,
      "workout": workout,
      if (exerciseList != null) "exerciseList": exerciseList,
    };
    completedWorkouts.add(entry);
    _persist(WorkoutRepository.kindCompleted, entry);
    _bump();
    onCompletedLogged?.call(entry);
    return entry;
  }

  /// A befejezett edzés gyakorlatai: először a napló saját listája, aztán a
  /// beágyazott sablon. Régi bejegyzéseknél mindkettő lehet üres.
  static List<Map<String, dynamic>> exercisesOfCompleted(
      Map<String, dynamic> entry) {
    final top = entry["exerciseList"];
    if (top is List && top.isNotEmpty) {
      return top
          .whereType<Map>()
          .map((item) => Map<String, dynamic>.from(item))
          .toList();
    }
    final workout = entry["workout"];
    if (workout is Map) {
      final nested = workout["exerciseList"];
      if (nested is List && nested.isNotEmpty) {
        return nested
            .whereType<Map>()
            .map((item) => Map<String, dynamic>.from(item))
            .toList();
      }
    }
    return const [];
  }

  /// Az edzés utáni RPE a befejező lapon jön, a napló már létezik.
  static void setEntryRpe(Map<String, dynamic> entry, int rpe) {
    entry["rpe"] = rpe;
    _persist(WorkoutRepository.kindCompleted, entry);
  }

  static Map<String, dynamic>? nextPlanOf(Map workout) {
    final plan = workout["nextPlan"];
    return plan is Map ? Map<String, dynamic>.from(plan) : null;
  }

  /// Apple Healthből hozott edzés. Nem írjuk vissza a Healthbe.
  static Map<String, dynamic>? importFromHealth(Map<String, dynamic> entry) {
    final id = "${entry["id"] ?? ""}";
    final date = entry["date"];
    if (id.isEmpty || date is! DateTime) {
      return null;
    }
    if (completedWorkouts.any((item) => "${item["id"] ?? ""}" == id)) {
      return null;
    }
    if (completedWorkouts.any((item) {
      final other = item["date"];
      return other is DateTime && other.difference(date).abs() < const Duration(minutes: 15);
    })) {
      return null;
    }

    entry["source"] = "apple_health";
    completedWorkouts.add(entry);
    _persist(WorkoutRepository.kindCompleted, entry);
    _bump();
    return entry;
  }

  /// MET alapú becslés: MET * 3.5 * testsúly / 200 * perc, plusz a
  /// megmozgatott súly után számolt ráhagyás (kb. 8 kcal / 1000 kg).
  static int estimateCalories({
    required int minutes,
    required String difficulty,
    double volume = 0,
  }) {
    double met;
    switch (difficulty) {
      case "Haladó":
        met = 8.0;
        break;
      case "Középhaladó":
        met = 6.0;
        break;
      case "Kezdő":
        met = 4.5;
        break;
      default:
        met = 5.0;
    }

    final timeBased = met * 3.5 * userWeightKg / 200 * minutes;
    return (timeBased + volume * 0.008).round();
  }

  static List<Map<String, dynamic>> completionsOf(String title) =>
      completedWorkouts.where((entry) => entry["title"] == title).toList();

  /// A mért edzésekből számolt átlagos hossz, ha van már teljesítés.
  static int? averageMinutesFor(String title) {
    final completions = completionsOf(title);
    if (completions.isEmpty) {
      return null;
    }
    final total = completions.fold<int>(
        0, (sum, entry) => sum + (entry["minutes"] as int));
    return (total / completions.length).round();
  }

  /// A mért edzésekből számolt átlagos kalória, ha van már teljesítés.
  static int? averageCaloriesFor(String title) {
    final completions = completionsOf(title);
    if (completions.isEmpty) {
      return null;
    }
    final total = completions.fold<int>(
        0, (sum, entry) => sum + (entry["calories"] as int));
    return (total / completions.length).round();
  }

  /// Naplózáshoz használt hossz: a mért átlag, ennek hiányában a
  /// gyakorlatok körszámából becsült érték (kör × 2 perc).
  static int minutesForLogging(Map<String, dynamic> workout) {
    final average = averageMinutesFor(workout["title"]?.toString() ?? "");
    if (average != null) {
      return average;
    }

    var rounds = 0;
    final exercises = workout["exerciseList"] as List? ?? [];
    for (final exercise in exercises.whereType<Map>()) {
      rounds += exercise["rounds"] as int? ?? 1;
    }

    return rounds > 0 ? (rounds * 2).clamp(5, 180) : 20;
  }

  /// Ugyanannak az edzésnek a megadott bejegyzés előtti utolsó teljesítése.
  static Map<String, dynamic>? previousCompletionOf(
      Map<String, dynamic> entry) {
    final earlier = completedWorkoutsByDate
        .where((other) =>
            other["title"] == entry["title"] &&
            (other["date"] as DateTime).isBefore(entry["date"] as DateTime))
        .toList();
    return earlier.isEmpty ? null : earlier.last;
  }

  /// Az előző, azonos nevű edzéshez mért változás.
  static WorkoutProgress? progressionFor(Map<String, dynamic> entry) {
    final previous = previousCompletionOf(entry);
    if (previous == null) {
      return null;
    }

    final previousVolume = (previous["volume"] as num).toDouble();
    final volume = (entry["volume"] as num).toDouble();

    return WorkoutProgress(
      previous: previous,
      volumeDelta: volume - previousVolume,
      volumeDeltaPercent:
          previousVolume > 0 ? (volume - previousVolume) / previousVolume * 100 : null,
      minutesDelta: (entry["minutes"] as int) - (previous["minutes"] as int),
      caloriesDelta: (entry["calories"] as int) - (previous["calories"] as int),
    );
  }

  /// Az adott hét (vasárnaptól szombatig) napi összegei.
  /// A visszatérő lista 7 elemű, a 0. index a vasárnap.
  static List<double> weeklyTotals(DateTime weekStart,
      {required WorkoutMetric metric}) {
    final totals = List<double>.filled(7, 0);
    final start = DateTime(weekStart.year, weekStart.month, weekStart.day);
    final end = start.add(const Duration(days: 7));

    for (final entry in completedWorkouts) {
      final date = entry["date"] as DateTime;
      if (date.isBefore(start) || !date.isBefore(end)) {
        continue;
      }
      final dayIndex = DateTime(date.year, date.month, date.day)
          .difference(start)
          .inDays;
      if (dayIndex < 0 || dayIndex > 6) {
        continue;
      }
      totals[dayIndex] += metric == WorkoutMetric.calories
          ? (entry["calories"] as num?)?.toDouble() ?? 0
          : (entry["minutes"] as num?)?.toDouble() ?? 0;
    }

    return totals;
  }

  /// A megadott naphoz tartozó hét kezdete (vasárnap).
  static DateTime startOfWeek(DateTime date) {
    final day = DateTime(date.year, date.month, date.day);
    return day.subtract(Duration(days: day.weekday % 7));
  }

  /// Az aktuális hetet is beleértve az utolsó négy hét összege, legrégebbi elöl.
  static List<double> lastFourWeeksTotals({required WorkoutMetric metric}) {
    final thisWeek = startOfWeek(DateTime.now());
    return List<double>.generate(4, (index) {
      final start = thisWeek.subtract(Duration(days: 7 * (3 - index)));
      return weeklyTotals(start, metric: metric)
          .fold<double>(0, (sum, value) => sum + value);
    });
  }

  /// A főoldal és a listák közös sora: cím, kép, kalória, perc, készültség.
  static Map<String, dynamic> asWorkoutRow(Map<String, dynamic> entry) {
    final image = "${entry["image"] ?? ""}";
    final totalSets = entry["totalSets"] as int? ?? 0;
    final completedSets = entry["completedSets"] as int? ?? 0;
    return {
      "name": "${entry["title"] ?? "Edzés"}",
      "image": image.startsWith("assets/") ? image : "assets/img/Workout1.png",
      "kcal": "${entry["calories"] ?? 0}",
      "time": "${entry["minutes"] ?? 0}",
      "progress": totalSets > 0
          ? (completedSets / totalSets).clamp(0.0, 1.0)
          : 1.0,
    };
  }
}

enum WorkoutMetric { calories, minutes }

class WorkoutProgress {
  final Map<String, dynamic> previous;
  final double volumeDelta;
  final double? volumeDeltaPercent;
  final int minutesDelta;
  final int caloriesDelta;

  const WorkoutProgress({
    required this.previous,
    required this.volumeDelta,
    required this.volumeDeltaPercent,
    required this.minutesDelta,
    required this.caloriesDelta,
  });

  bool get isHarder => volumeDelta > 0 || (volumeDelta == 0 && caloriesDelta > 0);
}
