import 'package:flutter/foundation.dart';

import 'local/app_database.dart';
import 'session_service.dart';
import 'remote/supabase_gateway.dart';
import 'repositories/diary_repository.dart';
import 'repositories/food_repository.dart';
import 'repositories/profile_repository.dart';
import 'repositories/progress_photo_repository.dart';
import 'repositories/sleep_repository.dart';
import 'repositories/water_repository.dart';
import 'repositories/workout_repository.dart';
import '../view/workout_tracker/workout_store.dart';

/// A szinkron állapota a felületnek (pl. „Szinkronizálás…” jelzés).
enum SyncPhase { idle, running, succeeded, failed }

class SyncStatus {
  final SyncPhase phase;
  final DateTime? lastSuccessAt;
  final List<String> failedSteps;

  const SyncStatus({
    this.phase = SyncPhase.idle,
    this.lastSuccessAt,
    this.failedSteps = const [],
  });

  bool get isRunning => phase == SyncPhase.running;
}

/// Előtérbe kerüléskor kell-e új kör: ha az előző elbukott, vagy a legutóbbi
/// sikeres 30 percnél régebbi. Futó kör alatt soha.
bool shouldResyncOnResume(SyncStatus status, DateTime now) {
  switch (status.phase) {
    case SyncPhase.running:
      return false;
    case SyncPhase.failed:
      return true;
    case SyncPhase.idle:
    case SyncPhase.succeeded:
      final last = status.lastSuccessAt;
      return last == null ||
          now.difference(last) > const Duration(minutes: 30);
  }
}

/// Lépésenkénti futtatás: egy lépés hibája nem állítja meg a többit, és a hiba
/// nem tűnik el nyomtalanul. Korábban egyetlen kivétel az egész kört elvitte,
/// így például egy elbukott feltöltés miatt a lehúzás sem futott le.
class SyncStepRunner {
  SyncStepRunner({this.stepTimeout = const Duration(minutes: 2)});

  /// Egy lépés felső határa. A közvetlen Supabase-hívásoknak nincs saját
  /// időkorlátja; enélkül egy beragadt kérés örökre „szinkronizál” állapotban
  /// tartaná az appot. Az API-hívások 90 mp-es korlátja belefér.
  final Duration stepTimeout;

  final List<String> failedSteps = [];

  Future<T?> run<T>(String name, Future<T> Function() action) async {
    try {
      return await action().timeout(stepTimeout);
    } on Object catch (error, stack) {
      failedSteps.add(name);
      debugPrint("Szinkron lépés sikertelen ($name): $error");
      debugPrintStack(stackTrace: stack, maxFrames: 5);
      return null;
    }
  }

  bool get hasFailures => failedSteps.isNotEmpty;
}

/// Kimenő és bejövő szinkron. A kimenő oldalt a helyi adatbázis `isDirty`
/// soraiból építjük, a bejövő oldal `updated_at` alapján növekményes.
class SyncService {
  SyncService({
    required AppDatabase database,
    required SupabaseGateway gateway,
    required DiaryRepository diary,
    required FoodRepository foods,
    required ProfileRepository profiles,
    required WorkoutRepository workouts,
    required SleepRepository sleep,
    required WaterRepository water,
    required ProgressPhotoRepository progressPhotos,
  })  : _database = database,
        _gateway = gateway,
        _diary = diary,
        _foods = foods,
        _profiles = profiles,
        _workouts = workouts,
        _sleep = sleep,
        _water = water,
        _progressPhotos = progressPhotos;

  final AppDatabase _database;
  final SupabaseGateway _gateway;
  final DiaryRepository _diary;
  final FoodRepository _foods;
  final ProfileRepository _profiles;
  final WorkoutRepository _workouts;
  final SleepRepository _sleep;
  final WaterRepository _water;
  final ProgressPhotoRepository _progressPhotos;

  final ValueNotifier<SyncStatus> status =
      ValueNotifier<SyncStatus>(const SyncStatus());

  Future<void>? _inFlight;

  /// Egyszerre egy kör fut. Ha közben újra hívják, ugyanarra a körre várnak,
  /// így a hívó biztosan a friss adatot tölti be utána.
  Future<void> syncAll(String userId) {
    if (!_gateway.isSignedIn) {
      return Future<void>.value();
    }
    return _inFlight ??= _runSync(userId).whenComplete(() => _inFlight = null);
  }

  Future<void> _runSync(String userId) async {
    final previous = status.value;
    status.value = SyncStatus(
      phase: SyncPhase.running,
      lastSuccessAt: previous.lastSuccessAt,
    );

    // Az alvó Render-példány ébresztése párhuzamosan a helyi előkészítéssel.
    final warmUp = _gateway.warmUp();
    final steps = SyncStepRunner();

    await steps.run("repair", () => _repairLegacyData(userId));
    await steps.run("flush", WorkoutStore.flushPersists);
    await warmUp;
    await _pushEverything(userId, steps);
    await _pullEverything(userId, steps);
    await steps.run("purge", () => _database.purgeDeletedDiary(userId));

    status.value = steps.hasFailures
        ? SyncStatus(
            phase: SyncPhase.failed,
            lastSuccessAt: previous.lastSuccessAt,
            failedSteps: List.unmodifiable(steps.failedSteps),
          )
        : SyncStatus(
            phase: SyncPhase.succeeded,
            lastSuccessAt: DateTime.now(),
          );
  }

  /// A szerver köteghatára 500 sor; ennél nagyobb kérést elutasít, és akkor
  /// *egyetlen* sor sem megy fel. Ezért darabolunk.
  static const int _pushChunkSize = 200;

  Future<void> _pushEverything(String userId, SyncStepRunner steps) async {
    await steps.run("push:diary", () => _pushDiary(userId));
    await steps.run("push:foods", _foods.pushPendingFoods);
    await steps.run("push:profile", () => _profiles.pushPending(userId));
    await steps.run("push:workouts", () => _workouts.pushPending(userId));
    await steps.run("push:sleep", () => _sleep.pushPending(userId));
    await steps.run("push:water", () => _water.pushPending(userId));
    await steps.run(
        "push:progress_photos", () => _progressPhotos.pushPending(userId));
  }

  Future<void> _pushDiary(String userId) async {
    final pending = await _diary.pendingUploads(userId);
    for (var offset = 0; offset < pending.length; offset += _pushChunkSize) {
      final end = (offset + _pushChunkSize) < pending.length
          ? offset + _pushChunkSize
          : pending.length;
      final chunk = pending.sublist(offset, end);
      final pushed = await _gateway.pushDiaryEntries(chunk);
      if (!pushed) {
        // Hálózati hiba: a sorok piszkosak maradnak, a következő kör újrapróbálja.
        throw const SyncStepException("A napló feltöltése nem sikerült.");
      }
      for (final entry in chunk) {
        await _diary.markSynced(entry.id);
      }
    }
  }

  /// A watermarkot **csak sikeres** lekérés után léptetjük. Korábban akkor is
  /// beíródott, ha a hívás elszállt (offline, alvó Render-példány, lejárt
  /// token) — onnantól az app csak az azóta változott sorokat kérte, és a
  /// régebbi napok soha többé nem jöttek vissza a szerverről.
  Future<void> _pullEverything(String userId, SyncStepRunner steps) async {
    final stamp = DateTime.now().toUtc().toIso8601String();

    await steps.run("pull:diary", () async {
      final entries =
          await _gateway.pullDiaryEntries(since: await _lastPull("diary"));
      if (entries == null) {
        throw const SyncStepException("A napló lehúzása nem sikerült.");
      }
      if (entries.isNotEmpty) {
        await _diary.applyRemote(userId, entries);
      }
      await _database.setMeta("last_pull_diary", stamp);
    });

    await steps.run("pull:profile", () => _profiles.pull(userId));

    await _pullDomain(steps, "workouts", stamp,
        (since) => _workouts.pull(userId, since: since));
    await _pullDomain(steps, "sleep", stamp,
        (since) => _sleep.pull(userId, since: since));
    await _pullDomain(steps, "water", stamp,
        (since) => _water.pull(userId, since: since));
    await _pullDomain(steps, "progress_photos", stamp,
        (since) => _progressPhotos.pull(userId, since: since));
  }

  /// A watermark csak sikeres lehúzás után lép.
  Future<void> _pullDomain(
    SyncStepRunner steps,
    String domain,
    String stamp,
    Future<bool> Function(DateTime? since) pull,
  ) {
    return steps.run("pull:$domain", () async {
      if (!await pull(await _lastPull(domain))) {
        throw SyncStepException("A(z) $domain lehúzása nem sikerült.");
      }
      await _database.setMeta("last_pull_$domain", stamp);
    });
  }

  /// Egyszeri helyreállítás a régi hibák után:
  ///
  /// 1. A fiók nélküli módban rögzített sorok a készülékhez kötött helyi
  ///    azonosító alatt maradtak. Bejelentkezés után az app a Supabase
  ///    user id-t használja, így azok a sorok „eltűntek" — pedig ott vannak.
  ///    Átkötjük őket, és piszkosra jelöljük, hogy fel is kerüljenek.
  /// 2. A hibásan léptetett watermarkok miatt a szerveren lévő régebbi sorok
  ///    sem jöttek le. A vízjelek törlésével a következő kör mindent lehúz.
  Future<void> _repairLegacyData(String userId) async {
    const flagKey = "repair_v1_done";
    if (await _database.metaValue(flagKey) == "true") {
      return;
    }

    final legacyId = await _database.metaValue(SessionService.localUserKey);
    if (legacyId != null && legacyId.isNotEmpty && legacyId != userId) {
      final moved = await _database.adoptRowsFrom(legacyId, userId);
      if (moved > 0) {
        debugPrint("Helyreállítás: $moved korábbi sor átkötve a fiókodra.");
      }
    }

    await _database.clearPullWatermarks();
    await _database.setMeta(flagKey, "true");
  }

  Future<DateTime?> _lastPull(String domain) async {
    final raw = await _database.metaValue("last_pull_$domain");
    if (raw == null || raw.isEmpty) {
      return null;
    }
    return DateTime.tryParse(raw);
  }
}

class SyncStepException implements Exception {
  final String message;
  const SyncStepException(this.message);

  @override
  String toString() => message;
}
