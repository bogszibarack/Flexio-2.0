import 'dart:convert';
import 'dart:io' show Platform;

import 'package:flutter/foundation.dart';
import 'package:health/health.dart';

import '../view/sleep_tracker/sleep_store.dart';
import '../view/workout_tracker/workout_store.dart';
import 'local/app_database.dart';
import 'models/diary_entry.dart';
import 'models/user_profile.dart';
import 'repositories/sleep_repository.dart';
import 'sync_ids.dart';

/// Apple Health (HealthKit) híd. Csak iOS-en él: írja az edzést, alvást,
/// testsúlyt, magasságot és étkezést, a lépésszámot pedig olvassa.
class HealthSyncService extends ChangeNotifier {
  HealthSyncService({required AppDatabase database}) : _database = database;

  static const _enabledKey = "apple_health_enabled";
  static const _syncedKey = "apple_health_synced_ids";

  static const _lookback = Duration(days: 180);

  static const _types = <HealthDataType>[
    HealthDataType.STEPS,
    HealthDataType.WEIGHT,
    HealthDataType.HEIGHT,
    HealthDataType.WORKOUT,
    HealthDataType.SLEEP_ASLEEP,
    HealthDataType.SLEEP_DEEP,
    HealthDataType.SLEEP_LIGHT,
    HealthDataType.SLEEP_REM,
    HealthDataType.SLEEP_IN_BED,
    HealthDataType.HEART_RATE,
    HealthDataType.RESTING_HEART_RATE,
    HealthDataType.NUTRITION,
    HealthDataType.WATER,
  ];

  static const _permissions = <HealthDataAccess>[
    HealthDataAccess.READ,
    HealthDataAccess.READ_WRITE,
    HealthDataAccess.READ_WRITE,
    HealthDataAccess.READ_WRITE,
    HealthDataAccess.READ_WRITE,
    HealthDataAccess.READ,
    HealthDataAccess.READ,
    HealthDataAccess.READ,
    HealthDataAccess.READ,
    HealthDataAccess.READ,
    HealthDataAccess.READ,
    HealthDataAccess.READ_WRITE,
    HealthDataAccess.READ_WRITE,
  ];

  static const _asleepTypes = {
    HealthDataType.SLEEP_ASLEEP,
    HealthDataType.SLEEP_DEEP,
    HealthDataType.SLEEP_LIGHT,
    HealthDataType.SLEEP_REM,
  };

  final AppDatabase _database;

  Health? _health;
  bool _configured = false;
  bool _enabled = false;
  bool _busy = false;
  int? _todaySteps;
  HeartRateDay _heartRate = HeartRateDay.empty;
  int lastImportedSleep = 0;
  int lastImportedWorkouts = 0;
  DateTime? _lastPull;
  _SyncedIds _synced = _SyncedIds.empty();

  bool get isSupported => !kIsWeb && Platform.isIOS;
  bool get enabled => _enabled;
  bool get busy => _busy;
  int? get todaySteps => _todaySteps;
  HeartRateDay get heartRate => _heartRate;

  Future<void> bootstrap() async {
    if (!isSupported) {
      return;
    }

    _enabled = await _database.metaValue(_enabledKey) == "true";
    _synced = _SyncedIds.decode(await _database.metaValue(_syncedKey));
    if (_enabled) {
      await _ensureReady();
      await pullFromApple();
    }
    notifyListeners();
  }

  /// Engedélykérés, majd a meglévő napló feltöltése Healthbe.
  Future<bool> connect({
    UserProfile? profile,
    List<DiaryEntry> meals = const [],
  }) async {
    if (!isSupported) {
      return false;
    }

    _busy = true;
    notifyListeners();

    try {
      if (!await _ensureReady()) {
        return false;
      }

      final granted = await _health!.requestAuthorization(
        _types,
        permissions: _permissions,
      );
      if (!granted) {
        return false;
      }

      _enabled = true;
      await _database.setMeta(_enabledKey, "true");

      await syncBody(profile);
      for (final entry in WorkoutStore.completedWorkouts) {
        await syncWorkout(entry);
      }
      for (final entry in SleepStore.entries) {
        await syncSleep(entry);
      }
      for (final meal in meals) {
        await syncMeal(meal);
      }
      await pullFromApple(force: true);
      return true;
    } catch (error, stack) {
      debugPrint("Apple Health connect failed: $error\n$stack");
      return false;
    } finally {
      _busy = false;
      notifyListeners();
    }
  }

  Future<void> disconnect() async {
    _enabled = false;
    await _database.setMeta(_enabledKey, "false");
    notifyListeners();
  }

  /// Health → Flexio: az utóbbi hónapok alvása, edzése és a mai lépésszám.
  Future<void> pullFromApple({bool force = false}) async {
    if (!_enabled || !await _ensureReady()) {
      return;
    }
    if (!force &&
        _lastPull != null &&
        DateTime.now().difference(_lastPull!) < const Duration(minutes: 20)) {
      await refreshSteps();
      await refreshHeartRate();
      return;
    }

    _lastPull = DateTime.now();
    lastImportedSleep = await _importSleep();
    lastImportedWorkouts = await _importWorkouts();
    await refreshSteps();
    await refreshHeartRate();
    notifyListeners();
  }

  Future<void> refreshSteps() async {
    if (!_enabled || !await _ensureReady()) {
      return;
    }

    try {
      final now = DateTime.now();
      final midnight = DateTime(now.year, now.month, now.day);
      _todaySteps = await _health!.getTotalStepsInInterval(midnight, now);
      notifyListeners();
    } catch (error) {
      debugPrint("Apple Health steps failed: $error");
    }
  }

  Future<void> refreshHeartRate() async {
    if (!_enabled || !await _ensureReady()) {
      return;
    }

    try {
      final now = DateTime.now();
      final midnight = DateTime(now.year, now.month, now.day);
      final points = _health!.removeDuplicates(
        await _health!.getHealthDataFromTypes(
          types: const [HealthDataType.HEART_RATE],
          startTime: midnight,
          endTime: now,
        ),
      );

      final samples = <({DateTime time, double bpm})>[];
      for (final point in points) {
        final value = point.value;
        if (value is! NumericHealthValue) {
          continue;
        }
        final bpm = value.numericValue.toDouble();
        if (bpm < 30 || bpm > 230) {
          continue;
        }
        samples.add((time: point.dateFrom, bpm: bpm));
      }
      samples.sort((a, b) => a.time.compareTo(b.time));

      final buckets = <int, List<double>>{};
      for (final sample in samples) {
        buckets.putIfAbsent(sample.time.hour, () => []).add(sample.bpm);
      }
      final hourly = buckets.entries.map((entry) {
        final avg = entry.value.reduce((a, b) => a + b) / entry.value.length;
        return HeartRatePoint(hour: entry.key + 0.5, bpm: avg);
      }).toList()
        ..sort((a, b) => a.hour.compareTo(b.hour));

      double? resting;
      try {
        final restPoints = await _health!.getHealthDataFromTypes(
          types: const [HealthDataType.RESTING_HEART_RATE],
          startTime: now.subtract(const Duration(days: 7)),
          endTime: now,
        );
        restPoints.sort((a, b) => a.dateFrom.compareTo(b.dateFrom));
        final last = restPoints.isEmpty ? null : restPoints.last.value;
        if (last is NumericHealthValue) {
          resting = last.numericValue.toDouble();
        }
      } catch (error) {
        debugPrint("Apple Health resting HR failed: $error");
      }

      _heartRate = HeartRateDay(
        hourly: hourly,
        latestBpm: samples.isEmpty ? null : samples.last.bpm,
        minBpm: samples.isEmpty
            ? null
            : samples.map((s) => s.bpm).reduce((a, b) => a < b ? a : b),
        maxBpm: samples.isEmpty
            ? null
            : samples.map((s) => s.bpm).reduce((a, b) => a > b ? a : b),
        restingBpm: resting,
      );
      notifyListeners();
    } catch (error) {
      debugPrint("Apple Health heart rate failed: $error");
    }
  }

  Future<void> syncBody(UserProfile? profile) async {
    if (profile == null || !_enabled || !await _ensureReady()) {
      return;
    }

    final now = DateTime.now();
    final weight = profile.weightKg;
    if (weight != null && weight > 0) {
      await _write(
        type: HealthDataType.WEIGHT,
        value: weight,
        start: now,
      );
    }

    final heightCm = profile.heightCm;
    if (heightCm != null && heightCm > 0) {
      await _write(
        type: HealthDataType.HEIGHT,
        value: heightCm / 100,
        start: now,
      );
    }
  }

  Future<void> syncWorkout(Map<String, dynamic> entry) async {
    if (!_enabled || !await _ensureReady()) {
      return;
    }

    final id = "${entry["id"] ?? ""}";
    if (id.isEmpty ||
        id.startsWith("hk_") ||
        entry["source"] == "apple_health" ||
        _synced.workouts.contains(id)) {
      return;
    }

    final date = entry["date"];
    if (date is! DateTime) {
      return;
    }

    final minutes = (entry["minutes"] as num?)?.toInt() ?? 0;
    final calories = (entry["calories"] as num?)?.toInt() ?? 0;
    final start = minutes > 0
        ? date.subtract(Duration(minutes: minutes))
        : date.subtract(const Duration(minutes: 20));

    try {
      final ok = await _health!.writeWorkoutData(
        activityType: HealthWorkoutActivityType.TRADITIONAL_STRENGTH_TRAINING,
        start: start,
        end: date,
        totalEnergyBurned: calories > 0 ? calories : null,
        title: entry["title"]?.toString(),
        recordingMethod: RecordingMethod.manual,
      );
      if (ok) {
        _synced.workouts.add(id);
        await _persistSynced();
      }
    } catch (error) {
      debugPrint("Apple Health workout write failed: $error");
    }
  }

  Future<void> syncSleep(SleepEntry entry) async {
    if (!_enabled || !await _ensureReady()) {
      return;
    }
    if (entry.id.startsWith("hk_") ||
        entry.note == "Apple Health" ||
        _synced.sleep.contains(entry.id)) {
      return;
    }

    final ok = await _write(
      type: HealthDataType.SLEEP_ASLEEP,
      value: 0,
      start: entry.bedtime,
      end: entry.wakeTime,
      clientRecordId: entry.id,
    );
    if (ok) {
      _synced.sleep.add(entry.id);
      await _persistSynced();
    }
  }

  Future<void> syncMeal(DiaryEntry entry) async {
    if (!_enabled || entry.deletedAt != null || !await _ensureReady()) {
      return;
    }
    if (_synced.meals.contains(entry.id)) {
      return;
    }

    try {
      final ok = await _health!.writeMeal(
        mealType: _mealType(entry.mealType),
        startTime: entry.loggedAt,
        endTime: entry.loggedAt,
        clientRecordId: entry.id,
        name: entry.foodName,
        caloriesConsumed: entry.totals.kcal,
        protein: entry.totals.protein,
        carbohydrates: entry.totals.carbs,
        fatTotal: entry.totals.fat,
        recordingMethod: RecordingMethod.manual,
      );
      if (ok) {
        _synced.meals.add(entry.id);
        await _persistSynced();
      }
    } catch (error) {
      debugPrint("Apple Health meal write failed: $error");
    }
  }

  Future<void> syncWaterMl(int milliliters) async {
    if (!_enabled || milliliters <= 0 || !await _ensureReady()) {
      return;
    }

    final now = DateTime.now();
    await _write(
      type: HealthDataType.WATER,
      value: milliliters / 1000,
      start: now,
    );
  }

  Future<int> _importSleep() async {
    try {
      final now = DateTime.now();
      final points = _health!.removeDuplicates(
        await _health!.getHealthDataFromTypes(
          types: const [
            HealthDataType.SLEEP_ASLEEP,
            HealthDataType.SLEEP_DEEP,
            HealthDataType.SLEEP_LIGHT,
            HealthDataType.SLEEP_REM,
          ],
          startTime: now.subtract(_lookback),
          endTime: now,
        ),
      );

      var imported = 0;
      for (final night in _mergeSleepNights(points)) {
        if (night.ids.every(_synced.imported.contains)) {
          continue;
        }
        final healthId = "hk_${night.ids.first}";
        final entry = await SleepStore.importFromHealth(
          id: ensureSyncId(healthId),
          bedtime: night.bedtime,
          wakeTime: night.wakeTime,
        );
        if (entry != null) {
          imported++;
          _synced.imported.addAll(night.ids);
          _synced.sleep.add(entry.id);
        }
      }
      if (imported > 0) {
        await _persistSynced();
      }
      return imported;
    } catch (error) {
      debugPrint("Apple Health sleep import failed: $error");
      return 0;
    }
  }

  Future<int> _importWorkouts() async {
    try {
      final now = DateTime.now();
      final points = _health!.removeDuplicates(
        await _health!.getHealthDataFromTypes(
          types: const [HealthDataType.WORKOUT],
          startTime: now.subtract(_lookback),
          endTime: now,
        ),
      );

      var imported = 0;
      for (final point in points) {
        if (_isOwnSource(point) || _synced.imported.contains(point.uuid)) {
          continue;
        }

        final value = point.value;
        final minutes = point.dateTo.difference(point.dateFrom).inMinutes;
        if (minutes < 5) {
          continue;
        }

        var calories = 0;
        var activity = HealthWorkoutActivityType.OTHER;
        if (value is WorkoutHealthValue) {
          calories = value.totalEnergyBurned ?? 0;
          activity = value.workoutActivityType;
        }

        final healthId = ensureSyncId("hk_${point.uuid}");
        final entry = WorkoutStore.importFromHealth({
          "id": healthId,
          "title": _workoutTitle(activity),
          "image": "assets/img/Workout1.png",
          "difficulty": "Középhaladó",
          "date": point.dateTo,
          "minutes": minutes,
          "calories": calories > 0
              ? calories
              : WorkoutStore.estimateCalories(
                  minutes: minutes,
                  difficulty: "Középhaladó",
                ),
          "volume": 0.0,
          "completedSets": 0,
          "totalSets": 0,
        });
        if (entry != null) {
          imported++;
          _synced.imported.add(point.uuid);
          _synced.workouts.add(healthId);
        }
      }
      if (imported > 0) {
        await _persistSynced();
      }
      return imported;
    } catch (error) {
      debugPrint("Apple Health workout import failed: $error");
      return 0;
    }
  }

  List<_SleepNight> _mergeSleepNights(List<HealthDataPoint> points) {
    final asleep = points
        .where((point) =>
            _asleepTypes.contains(point.type) && !_isOwnSource(point))
        .toList()
      ..sort((a, b) => a.dateFrom.compareTo(b.dateFrom));
    if (asleep.isEmpty) {
      return const [];
    }

    final nights = <_SleepNight>[];
    var start = asleep.first.dateFrom;
    var end = asleep.first.dateTo;
    var ids = <String>{asleep.first.uuid};

    for (final point in asleep.skip(1)) {
      if (point.dateFrom.difference(end) <= const Duration(minutes: 90)) {
        if (point.dateFrom.isBefore(start)) {
          start = point.dateFrom;
        }
        if (point.dateTo.isAfter(end)) {
          end = point.dateTo;
        }
        ids.add(point.uuid);
      } else {
        nights.add(_SleepNight(bedtime: start, wakeTime: end, ids: ids));
        start = point.dateFrom;
        end = point.dateTo;
        ids = {point.uuid};
      }
    }
    nights.add(_SleepNight(bedtime: start, wakeTime: end, ids: ids));

    return nights
        .where((night) =>
            night.wakeTime.difference(night.bedtime) >=
            const Duration(minutes: 90))
        .toList();
  }

  bool _isOwnSource(HealthDataPoint point) {
    final source = "${point.sourceId} ${point.sourceName}".toLowerCase();
    return source.contains("com.kokaiadam.flexio");
  }

  static String _workoutTitle(HealthWorkoutActivityType type) {
    switch (type) {
      case HealthWorkoutActivityType.WALKING:
        return "Séta";
      case HealthWorkoutActivityType.RUNNING:
        return "Futás";
      case HealthWorkoutActivityType.BIKING:
        return "Kerékpár";
      case HealthWorkoutActivityType.SWIMMING:
      case HealthWorkoutActivityType.SWIMMING_POOL:
      case HealthWorkoutActivityType.SWIMMING_OPEN_WATER:
        return "Úszás";
      case HealthWorkoutActivityType.TRADITIONAL_STRENGTH_TRAINING:
      case HealthWorkoutActivityType.FUNCTIONAL_STRENGTH_TRAINING:
      case HealthWorkoutActivityType.STRENGTH_TRAINING:
        return "Erőedzés";
      case HealthWorkoutActivityType.CORE_TRAINING:
        return "Törzs edzés";
      case HealthWorkoutActivityType.HIGH_INTENSITY_INTERVAL_TRAINING:
        return "HIIT";
      case HealthWorkoutActivityType.YOGA:
        return "Jóga";
      case HealthWorkoutActivityType.PILATES:
        return "Pilates";
      case HealthWorkoutActivityType.CARDIO_DANCE:
      case HealthWorkoutActivityType.SOCIAL_DANCE:
        return "Tánc";
      case HealthWorkoutActivityType.HIKING:
        return "Túrázás";
      case HealthWorkoutActivityType.TENNIS:
        return "Tenisz";
      case HealthWorkoutActivityType.SOCCER:
        return "Foci";
      case HealthWorkoutActivityType.BASKETBALL:
        return "Kosárlabda";
      case HealthWorkoutActivityType.ROWING:
        return "Evezés";
      case HealthWorkoutActivityType.ELLIPTICAL:
        return "Elliptikus gép";
      case HealthWorkoutActivityType.STAIR_CLIMBING:
      case HealthWorkoutActivityType.STAIRS:
        return "Lépcsőzés";
      case HealthWorkoutActivityType.COOLDOWN:
        return "Levezetés";
      case HealthWorkoutActivityType.FLEXIBILITY:
        return "Nyújtás";
      case HealthWorkoutActivityType.MIND_AND_BODY:
        return "Test-lélek";
      default:
        return "Edzés";
    }
  }

  Future<bool> _ensureReady() async {
    if (!isSupported) {
      return false;
    }
    if (_configured && _health != null) {
      return true;
    }

    try {
      _health = Health();
      await _health!.configure();
      _configured = true;
      return true;
    } catch (error) {
      debugPrint("Apple Health configure failed: $error");
      return false;
    }
  }

  Future<bool> _write({
    required HealthDataType type,
    required double value,
    required DateTime start,
    DateTime? end,
    String? clientRecordId,
  }) async {
    try {
      return await _health!.writeHealthData(
        value: value,
        type: type,
        startTime: start,
        endTime: end,
        clientRecordId: clientRecordId,
        recordingMethod: RecordingMethod.manual,
      );
    } catch (error) {
      debugPrint("Apple Health write $type failed: $error");
      return false;
    }
  }

  Future<void> _persistSynced() =>
      _database.setMeta(_syncedKey, _synced.encode());

  static MealType _mealType(String mealType) {
    switch (mealType) {
      case MealTypes.breakfast:
        return MealType.BREAKFAST;
      case MealTypes.lunch:
        return MealType.LUNCH;
      case MealTypes.dinner:
        return MealType.DINNER;
      default:
        return MealType.SNACK;
    }
  }
}

class _SleepNight {
  const _SleepNight({
    required this.bedtime,
    required this.wakeTime,
    required this.ids,
  });

  final DateTime bedtime;
  final DateTime wakeTime;
  final Set<String> ids;
}

class _SyncedIds {
  _SyncedIds({
    required this.workouts,
    required this.sleep,
    required this.meals,
    required this.imported,
  });

  factory _SyncedIds.empty() => _SyncedIds(
        workouts: <String>{},
        sleep: <String>{},
        meals: <String>{},
        imported: <String>{},
      );

  factory _SyncedIds.decode(String? raw) {
    if (raw == null || raw.isEmpty) {
      return _SyncedIds.empty();
    }
    try {
      final json = jsonDecode(raw);
      if (json is! Map) {
        return _SyncedIds.empty();
      }
      return _SyncedIds(
        workouts: {...List<String>.from(json["w"] as List? ?? const [])},
        sleep: {...List<String>.from(json["s"] as List? ?? const [])},
        meals: {...List<String>.from(json["m"] as List? ?? const [])},
        imported: {...List<String>.from(json["i"] as List? ?? const [])},
      );
    } on Object {
      return _SyncedIds.empty();
    }
  }

  final Set<String> workouts;
  final Set<String> sleep;
  final Set<String> meals;
  final Set<String> imported;

  String encode() => jsonEncode({
        "w": workouts.toList(),
        "s": sleep.toList(),
        "m": meals.toList(),
        "i": imported.toList(),
      });
}

class HeartRatePoint {
  const HeartRatePoint({required this.hour, required this.bpm});

  final double hour;
  final double bpm;
}

class HeartRateDay {
  const HeartRateDay({
    required this.hourly,
    this.latestBpm,
    this.minBpm,
    this.maxBpm,
    this.restingBpm,
  });

  static const empty = HeartRateDay(hourly: []);

  final List<HeartRatePoint> hourly;
  final double? latestBpm;
  final double? minBpm;
  final double? maxBpm;
  final double? restingBpm;

  bool get hasData => hourly.isNotEmpty && latestBpm != null;
}
