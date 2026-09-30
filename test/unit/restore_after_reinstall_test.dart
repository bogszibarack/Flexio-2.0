import 'dart:io';

import 'package:drift/drift.dart' show driftRuntimeOptions;
import 'package:drift/native.dart';
import 'package:fitness/data/local/app_database.dart';
import 'package:fitness/data/models/progress_photo.dart';
import 'package:fitness/data/repositories/progress_photo_repository.dart';
import 'package:fitness/data/repositories/workout_repository.dart';
import 'package:fitness/view/workout_tracker/workout_store.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider_platform_interface/path_provider_platform_interface.dart';

import '../support/fakes.dart';

/// Az app törlése után a helyi adatbázis és a fájlok is eltűnnek; minden a
/// szerverről jön vissza. Ezek a tesztek ezt az utat járják végig a valódi
/// repository-kkal és egy memóriabeli SQLite-tal.
void main() {
  driftRuntimeOptions.dontWarnAboutMultipleDatabases = true;

  late FakeRemote remote;
  late FakeStorage storage;
  late FakePathProvider paths;
  late List<Directory> tempDirs;

  Future<String> newContainer() async {
    final directory = await Directory.systemTemp.createTemp("flexio_docs_");
    tempDirs.add(directory);
    return directory.path;
  }

  setUp(() async {
    tempDirs = [];
    remote = FakeRemote();
    storage = FakeStorage();
    paths = FakePathProvider(await newContainer());
    PathProviderPlatform.instance = paths;
  });

  tearDown(() async {
    WorkoutStore.unbind();
    for (final directory in tempDirs) {
      if (await directory.exists()) {
        await directory.delete(recursive: true);
      }
    }
  });

  AppDatabase freshDatabase() => AppDatabase.forTesting(NativeDatabase.memory());

  group("Befejezett edzések", () {
    test("újratelepítés után körökkel és súlyokkal együtt visszajönnek",
        () async {
      final userId = remote.userId!;
      final before = freshDatabase();
      final workouts = WorkoutRepository(database: before, gateway: remote);
      final loggedAt = DateTime(2026, 9, 30, 17, 30);

      await workouts.save(
        userId: userId,
        kind: WorkoutRepository.kindCompleted,
        item: {
          "id": "0b7c7e1e-7a4d-4a8e-9d0e-3f2a1c9b8d71",
          "title": "Felsőtest",
          "image": "assets/img/Workout1.png",
          "difficulty": "Középhaladó",
          "date": loggedAt,
          "minutes": 48,
          "calories": 320,
          "volume": 3600.0,
          "completedSets": 6,
          "totalSets": 6,
          "exerciseList": [
            {
              "name": "Fekvenyomás",
              "image": "assets/img/Workout1.png",
              "repetitions": 10,
              "rounds": 3,
              "weight": 60,
              "roundWeights": [60, 65, 70],
            },
          ],
        },
      );
      await before.close();

      // Újratelepítés: üres adatbázis, a szerveren lévő sorok maradnak.
      final after = freshDatabase();
      addTearDown(after.close);
      final restored = WorkoutRepository(database: after, gateway: remote);

      expect(await restored.pull(userId), isTrue);
      await WorkoutStore.bind(repository: restored, userId: userId);

      expect(WorkoutStore.completedWorkouts, hasLength(1));
      final entry = WorkoutStore.completedWorkouts.single;
      expect(entry["title"], "Felsőtest");
      expect(entry["date"], loggedAt);

      final exercises = WorkoutStore.exercisesOfCompleted(entry);
      expect(exercises.single["name"], "Fekvenyomás");
      expect(exercises.single["roundWeights"], [60, 65, 70]);
    });

    test("sikertelen lehúzás jelzi a hibát, hogy a watermark ne lépjen",
        () async {
      final offline = _OfflineRemote();
      final database = freshDatabase();
      addTearDown(database.close);
      final repository = WorkoutRepository(database: database, gateway: offline);

      expect(await repository.pull(offline.userId!), isFalse);
    });
  });

  group("Haladásfotók", () {
    test("újratelepítés után a Storage-ból visszatöltődnek", () async {
      final userId = remote.userId!;
      final source = File(p.join(await newContainer(), "shot.jpg"))
        ..writeAsBytesSync([1, 2, 3, 4]);

      final before = freshDatabase();
      final photos = ProgressPhotoRepository(
          database: before, gateway: remote, storage: storage);
      final added = await photos.add(
        userId: userId,
        sourcePath: source.path,
        pose: PhotoPose.front,
      );
      expect(added, isNotNull);
      await before.close();

      // Újratelepítés: új konténer (üres mappa), üres adatbázis.
      paths.documentsPath = await newContainer();
      final after = freshDatabase();
      addTearDown(after.close);
      final restored = ProgressPhotoRepository(
          database: after, gateway: remote, storage: storage);

      expect(await restored.pull(userId), isTrue);
      final loaded = await restored.load(userId);

      expect(loaded, hasLength(1));
      expect(loaded.single.pose, PhotoPose.front);
      expect(File(loaded.single.filePath).readAsBytesSync(), [1, 2, 3, 4]);
      expect(loaded.single.filePath, startsWith(paths.documentsPath));
    });

    test(
        "frissítéskor (új konténer-útvonal, a fájlok átköltöznek) a kép megmarad",
        () async {
      final userId = remote.userId!;
      final source = File(p.join(await newContainer(), "shot.jpg"))
        ..writeAsBytesSync([9, 9, 9]);
      final database = freshDatabase();
      addTearDown(database.close);
      final photos = ProgressPhotoRepository(
          database: database, gateway: remote, storage: storage);
      await photos.add(userId: userId, sourcePath: source.path, pose: PhotoPose.back);

      // A tárolt útvonal relatív, nem a régi konténer abszolút útja.
      final stored = (await database.progressPhotosForUser(userId)).single;
      expect(stored.localPath, isNot(startsWith("/")));

      // iOS frissítés: a konténer új helyre kerül, a tartalma vele megy.
      final oldContainer = paths.documentsPath;
      final newContainerPath = await newContainer();
      await Directory(p.join(oldContainer, "progress_photos"))
          .rename(p.join(newContainerPath, "progress_photos"));
      paths.documentsPath = newContainerPath;
      storage.objects.clear(); // Letöltés nélkül is meg kell lennie.

      final loaded = await photos.load(userId);
      expect(loaded, hasLength(1));
      expect(File(loaded.single.filePath).readAsBytesSync(), [9, 9, 9]);
    });
  });
}

class _OfflineRemote extends FakeRemote {
  @override
  Future<List<Map<String, dynamic>>?> pullRows(String table,
          {DateTime? since}) async =>
      null;
}
