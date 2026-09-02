import 'local/app_database.dart';
import 'remote/supabase_gateway.dart';
import 'repositories/diary_repository.dart';
import 'repositories/food_repository.dart';
import 'repositories/profile_repository.dart';
import 'repositories/progress_photo_repository.dart';
import 'repositories/sleep_repository.dart';
import 'repositories/water_repository.dart';
import 'repositories/workout_repository.dart';
import '../view/workout_tracker/workout_store.dart';

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

  bool _running = false;

  Future<void> syncAll(String userId) async {
    if (_running || !_gateway.isSignedIn) {
      return;
    }
    _running = true;

    try {
      await WorkoutStore.flushPersists();
      await _pushEverything(userId);
      await _pullEverything(userId);
      await _database.purgeDeletedDiary(userId);
    } on Object {
      // A szinkron újrapróbálkozik a következő indításnál, a helyi adat megvan.
    } finally {
      _running = false;
    }
  }

  Future<void> _pushEverything(String userId) async {
    final pending = await _diary.pendingUploads(userId);
    if (pending.isNotEmpty) {
      final pushed = await _gateway.pushDiaryEntries(pending);
      if (pushed) {
        for (final entry in pending) {
          await _diary.markSynced(entry.id);
        }
      }
    }

    await _foods.pushPendingFoods();
    await _profiles.pushPending(userId);
    await _workouts.pushPending(userId);
    await _sleep.pushPending(userId);
    await _water.pushPending(userId);
    await _progressPhotos.pushPending(userId);
  }

  Future<void> _pullEverything(String userId) async {
    final startedAt = DateTime.now().toUtc();

    final diarySince = await _lastPull("diary");
    final entries = await _gateway.pullDiaryEntries(since: diarySince);
    if (entries.isNotEmpty) {
      await _diary.applyRemote(userId, entries);
    }

    await _profiles.pull(userId);
    await _workouts.pull(userId, since: await _lastPull("workouts"));
    await _sleep.pull(userId, since: await _lastPull("sleep"));
    await _water.pull(userId, since: await _lastPull("water"));
    await _progressPhotos.pull(userId, since: await _lastPull("progress_photos"));

    for (final domain in [
      "diary",
      "workouts",
      "sleep",
      "water",
      "progress_photos",
    ]) {
      await _database.setMeta(
        "last_pull_$domain",
        startedAt.toIso8601String(),
      );
    }
  }

  Future<DateTime?> _lastPull(String domain) async {
    final raw = await _database.metaValue("last_pull_$domain");
    if (raw == null || raw.isEmpty) {
      return null;
    }
    return DateTime.tryParse(raw);
  }
}
