import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

part 'app_database.g.dart';

/// Katalógus-gyorsítótár: a keresésből, vonalkódból vagy kézi bevitelből
/// megismert ételek. Offline is elérhetők.
@DataClassName("CachedFoodRow")
class CachedFoods extends Table {
  TextColumn get id => text()();
  TextColumn get remoteId => text().nullable()();
  TextColumn get source => text().withDefault(const Constant("off"))();
  TextColumn get barcode => text().nullable()();
  TextColumn get name => text()();
  TextColumn get normalizedName => text().withDefault(const Constant(""))();
  TextColumn get brand => text().nullable()();
  TextColumn get category => text().nullable()();
  TextColumn get imageUrl => text().nullable()();
  RealColumn get kcal => real().withDefault(const Constant(0))();
  RealColumn get protein => real().withDefault(const Constant(0))();
  RealColumn get fat => real().withDefault(const Constant(0))();
  RealColumn get carbs => real().withDefault(const Constant(0))();
  RealColumn get sugar => real().nullable()();
  RealColumn get saturatedFat => real().nullable()();
  RealColumn get salt => real().nullable()();
  RealColumn get fiber => real().nullable()();
  TextColumn get servingsJson => text().withDefault(const Constant("[]"))();
  IntColumn get popularity => integer().withDefault(const Constant(0))();
  RealColumn get qualityScore => real().withDefault(const Constant(0))();
  BoolColumn get isFavorite => boolean().withDefault(const Constant(false))();
  DateTimeColumn get lastUsedAt => dateTime().nullable()();

  /// Saját étel, ami még nincs felküldve a szerverre.
  BoolColumn get isDirty => boolean().withDefault(const Constant(false))();

  @override
  Set<Column> get primaryKey => {id};
}

/// Étkezési napló. Az `isDirty` sorok alkotják a kimenő művelet-sort.
@DataClassName("DiaryRow")
class DiaryRows extends Table {
  TextColumn get id => text()();
  TextColumn get userId => text()();
  DateTimeColumn get loggedAt => dateTime()();
  TextColumn get localDate => text()();
  TextColumn get mealType => text()();
  TextColumn get foodId => text().nullable()();
  TextColumn get foodLocalId => text().nullable()();
  TextColumn get foodName => text()();
  TextColumn get foodImage => text().nullable()();
  RealColumn get amountG => real().withDefault(const Constant(0))();
  TextColumn get servingLabel => text().nullable()();
  RealColumn get kcal => real().withDefault(const Constant(0))();
  RealColumn get protein => real().withDefault(const Constant(0))();
  RealColumn get fat => real().withDefault(const Constant(0))();
  RealColumn get carbs => real().withDefault(const Constant(0))();
  RealColumn get sugar => real().nullable()();
  RealColumn get saturatedFat => real().nullable()();
  RealColumn get salt => real().nullable()();
  RealColumn get fiber => real().nullable()();
  DateTimeColumn get updatedAt => dateTime()();
  DateTimeColumn get deletedAt => dateTime().nullable()();
  BoolColumn get isDirty => boolean().withDefault(const Constant(true))();

  @override
  Set<Column> get primaryKey => {id};
}

/// Edzés adatok. A részletes szerkezet JSON-ként utazik, mert a meglévő
/// edzés-nézetek térkép alapú objektumokkal dolgoznak.
@DataClassName("WorkoutRow")
class WorkoutRows extends Table {
  TextColumn get id => text()();
  TextColumn get userId => text()();
  TextColumn get kind => text()();
  TextColumn get title => text().withDefault(const Constant(""))();
  DateTimeColumn get scheduledAt => dateTime().nullable()();
  DateTimeColumn get completedAt => dateTime().nullable()();
  IntColumn get durationMinutes => integer().nullable()();
  RealColumn get calories => real().nullable()();
  TextColumn get difficulty => text().nullable()();
  TextColumn get payloadJson => text().withDefault(const Constant("{}"))();
  DateTimeColumn get updatedAt => dateTime()();
  DateTimeColumn get deletedAt => dateTime().nullable()();
  BoolColumn get isDirty => boolean().withDefault(const Constant(true))();

  @override
  Set<Column> get primaryKey => {id};
}

@DataClassName("SleepRow")
class SleepRows extends Table {
  TextColumn get id => text()();
  TextColumn get userId => text()();
  DateTimeColumn get bedtime => dateTime()();
  DateTimeColumn get wakeTime => dateTime()();
  IntColumn get quality => integer().nullable()();
  TextColumn get note => text().nullable()();
  DateTimeColumn get updatedAt => dateTime()();
  DateTimeColumn get deletedAt => dateTime().nullable()();
  BoolColumn get isDirty => boolean().withDefault(const Constant(true))();

  @override
  Set<Column> get primaryKey => {id};
}

@DataClassName("ProfileRow")
class ProfileRows extends Table {
  TextColumn get userId => text()();
  TextColumn get firstName => text().nullable()();
  TextColumn get gender => text().nullable()();
  DateTimeColumn get birthDate => dateTime().nullable()();
  RealColumn get heightCm => real().nullable()();
  RealColumn get weightKg => real().nullable()();
  TextColumn get activityLevel =>
      text().withDefault(const Constant("moderate"))();
  TextColumn get goal => text().nullable()();
  RealColumn get calorieGoal => real().nullable()();
  RealColumn get proteinGoal => real().nullable()();
  RealColumn get fatGoal => real().nullable()();
  RealColumn get carbsGoal => real().nullable()();
  IntColumn get waterGoalMl => integer().nullable()();
  BoolColumn get manualGoals => boolean().withDefault(const Constant(false))();
  TextColumn get avatarUrl => text().nullable()();
  DateTimeColumn get avatarUpdatedAt => dateTime().nullable()();
  DateTimeColumn get updatedAt => dateTime()();
  BoolColumn get isDirty => boolean().withDefault(const Constant(true))();

  @override
  Set<Column> get primaryKey => {userId};
}

@DataClassName("WaterRow")
class WaterRows extends Table {
  TextColumn get id => text()();
  TextColumn get userId => text()();
  DateTimeColumn get loggedAt => dateTime()();
  TextColumn get localDate => text()();
  IntColumn get ml => integer()();
  DateTimeColumn get updatedAt => dateTime()();
  DateTimeColumn get deletedAt => dateTime().nullable()();
  BoolColumn get isDirty => boolean().withDefault(const Constant(true))();

  @override
  Set<Column> get primaryKey => {id};
}

@DataClassName("ProgressPhotoRow")
class ProgressPhotoRows extends Table {
  TextColumn get id => text()();
  TextColumn get userId => text()();
  DateTimeColumn get takenAt => dateTime()();
  TextColumn get pose => text()();
  TextColumn get storagePath => text()();
  TextColumn get localPath => text().nullable()();
  DateTimeColumn get updatedAt => dateTime()();
  DateTimeColumn get deletedAt => dateTime().nullable()();
  BoolColumn get isDirty => boolean().withDefault(const Constant(true))();

  @override
  Set<Column> get primaryKey => {id};
}

/// Kulcs-érték tábla: helyi felhasználó azonosító, utolsó szinkron időpontok.
@DataClassName("MetaRow")
class SyncMeta extends Table {
  TextColumn get key => text()();
  TextColumn get value => text()();

  @override
  Set<Column> get primaryKey => {key};
}

@DriftDatabase(
  tables: [
    CachedFoods,
    DiaryRows,
    WorkoutRows,
    SleepRows,
    ProfileRows,
    WaterRows,
    ProgressPhotoRows,
    SyncMeta,
  ],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  AppDatabase.forTesting(super.executor);

  @override
  int get schemaVersion => 2;

  @override
  MigrationStrategy get migration => MigrationStrategy(
        onUpgrade: (migrator, from, to) async {
          if (from < 2) {
            await migrator.addColumn(profileRows, profileRows.avatarUrl);
            await migrator.addColumn(profileRows, profileRows.avatarUpdatedAt);
            await migrator.createTable(waterRows);
            await migrator.createTable(progressPhotoRows);
          }
        },
      );

  // --- Meta ---------------------------------------------------------------

  Future<String?> metaValue(String key) async {
    final row = await (select(syncMeta)..where((t) => t.key.equals(key)))
        .getSingleOrNull();
    return row?.value;
  }

  Future<void> setMeta(String key, String value) =>
      into(syncMeta).insertOnConflictUpdate(
        MetaRow(key: key, value: value),
      );

  // --- Napló --------------------------------------------------------------

  Stream<List<DiaryRow>> watchDiary(String userId) {
    return (select(diaryRows)
          ..where((t) => t.userId.equals(userId) & t.deletedAt.isNull())
          ..orderBy([(t) => OrderingTerm.desc(t.loggedAt)]))
        .watch();
  }

  Future<List<DiaryRow>> diaryForUser(String userId) {
    return (select(diaryRows)
          ..where((t) => t.userId.equals(userId) & t.deletedAt.isNull())
          ..orderBy([(t) => OrderingTerm.desc(t.loggedAt)]))
        .get();
  }

  Future<List<DiaryRow>> dirtyDiary(String userId) {
    return (select(diaryRows)
          ..where((t) => t.userId.equals(userId) & t.isDirty.equals(true)))
        .get();
  }

  Future<void> saveDiaryRow(DiaryRow row) =>
      into(diaryRows).insertOnConflictUpdate(row);

  Future<void> markDiarySynced(String id) => (update(diaryRows)
        ..where((t) => t.id.equals(id)))
      .write(const DiaryRowsCompanion(isDirty: Value(false)));

  Future<void> purgeDeletedDiary(String userId) =>
      (delete(diaryRows)..where((t) =>
              t.userId.equals(userId) &
              t.deletedAt.isNotNull() &
              t.isDirty.equals(false)))
          .go();

  // --- Katalógus-gyorsítótár ---------------------------------------------

  Future<void> saveFood(CachedFoodRow row) =>
      into(cachedFoods).insertOnConflictUpdate(row);

  Future<CachedFoodRow?> foodById(String id) =>
      (select(cachedFoods)..where((t) => t.id.equals(id))).getSingleOrNull();

  Future<CachedFoodRow?> foodByBarcode(String barcode) =>
      (select(cachedFoods)..where((t) => t.barcode.equals(barcode)))
          .getSingleOrNull();

  Future<List<CachedFoodRow>> recentFoods({int limit = 30}) =>
      (select(cachedFoods)
            ..where((t) => t.lastUsedAt.isNotNull())
            ..orderBy([(t) => OrderingTerm.desc(t.lastUsedAt)])
            ..limit(limit))
          .get();

  Future<List<CachedFoodRow>> favoriteFoods() => (select(cachedFoods)
        ..where((t) => t.isFavorite.equals(true))
        ..orderBy([(t) => OrderingTerm.asc(t.name)]))
      .get();

  Future<List<CachedFoodRow>> ownFoods() => (select(cachedFoods)
        ..where((t) => t.source.equals("user"))
        ..orderBy([(t) => OrderingTerm.asc(t.name)]))
      .get();

  Future<List<CachedFoodRow>> dirtyFoods() =>
      (select(cachedFoods)..where((t) => t.isDirty.equals(true))).get();

  Future<List<CachedFoodRow>> searchCachedFoods(String normalizedQuery,
          {int limit = 25}) =>
      (select(cachedFoods)
            ..where((t) => t.normalizedName.like("%$normalizedQuery%"))
            ..orderBy([
              (t) => OrderingTerm.desc(t.isFavorite),
              (t) => OrderingTerm.desc(t.popularity),
              (t) => OrderingTerm.asc(t.name),
            ])
            ..limit(limit))
          .get();

  // --- Edzés, alvás, profil ----------------------------------------------

  Future<List<WorkoutRow>> workoutsForUser(String userId) =>
      (select(workoutRows)
            ..where((t) => t.userId.equals(userId) & t.deletedAt.isNull()))
          .get();

  Future<void> saveWorkoutRow(WorkoutRow row) =>
      into(workoutRows).insertOnConflictUpdate(row);

  Future<List<WorkoutRow>> dirtyWorkouts(String userId) => (select(workoutRows)
        ..where((t) => t.userId.equals(userId) & t.isDirty.equals(true)))
      .get();

  Future<void> markWorkoutSynced(String id) => (update(workoutRows)
        ..where((t) => t.id.equals(id)))
      .write(const WorkoutRowsCompanion(isDirty: Value(false)));

  Future<List<SleepRow>> sleepForUser(String userId) => (select(sleepRows)
        ..where((t) => t.userId.equals(userId) & t.deletedAt.isNull())
        ..orderBy([(t) => OrderingTerm.desc(t.bedtime)]))
      .get();

  Future<void> saveSleepRow(SleepRow row) =>
      into(sleepRows).insertOnConflictUpdate(row);

  Future<List<SleepRow>> dirtySleep(String userId) => (select(sleepRows)
        ..where((t) => t.userId.equals(userId) & t.isDirty.equals(true)))
      .get();

  Future<void> markSleepSynced(String id) => (update(sleepRows)
        ..where((t) => t.id.equals(id)))
      .write(const SleepRowsCompanion(isDirty: Value(false)));

  Future<ProfileRow?> profileForUser(String userId) =>
      (select(profileRows)..where((t) => t.userId.equals(userId)))
          .getSingleOrNull();

  Future<void> saveProfileRow(ProfileRow row) =>
      into(profileRows).insertOnConflictUpdate(row);

  Future<void> markProfileSynced(String userId) => (update(profileRows)
        ..where((t) => t.userId.equals(userId)))
      .write(const ProfileRowsCompanion(isDirty: Value(false)));

  Future<List<WaterRow>> waterForDay(String userId, String localDate) =>
      (select(waterRows)
            ..where((t) =>
                t.userId.equals(userId) &
                t.localDate.equals(localDate) &
                t.deletedAt.isNull())
            ..orderBy([(t) => OrderingTerm.asc(t.loggedAt)]))
          .get();

  Future<void> saveWaterRow(WaterRow row) =>
      into(waterRows).insertOnConflictUpdate(row);

  Future<List<WaterRow>> dirtyWater(String userId) => (select(waterRows)
        ..where((t) => t.userId.equals(userId) & t.isDirty.equals(true)))
      .get();

  Future<void> markWaterSynced(String id) => (update(waterRows)
        ..where((t) => t.id.equals(id)))
      .write(const WaterRowsCompanion(isDirty: Value(false)));

  Future<List<ProgressPhotoRow>> progressPhotosForUser(String userId) =>
      (select(progressPhotoRows)
            ..where((t) => t.userId.equals(userId) & t.deletedAt.isNull())
            ..orderBy([(t) => OrderingTerm.asc(t.takenAt)]))
          .get();

  Future<void> saveProgressPhotoRow(ProgressPhotoRow row) =>
      into(progressPhotoRows).insertOnConflictUpdate(row);

  Future<List<ProgressPhotoRow>> dirtyProgressPhotos(String userId) =>
      (select(progressPhotoRows)
            ..where((t) => t.userId.equals(userId) & t.isDirty.equals(true)))
          .get();

  Future<void> markProgressPhotoSynced(String id) =>
      (update(progressPhotoRows)..where((t) => t.id.equals(id))).write(
        const ProgressPhotoRowsCompanion(isDirty: Value(false)),
      );

  /// Kilépésnél és fióktörlésnél a helyi adat is törlődik.
  Future<void> wipeUserData(String userId) async {
    await (delete(diaryRows)..where((t) => t.userId.equals(userId))).go();
    await (delete(workoutRows)..where((t) => t.userId.equals(userId))).go();
    await (delete(sleepRows)..where((t) => t.userId.equals(userId))).go();
    await (delete(waterRows)..where((t) => t.userId.equals(userId))).go();
    await (delete(progressPhotoRows)..where((t) => t.userId.equals(userId)))
        .go();
    await (delete(profileRows)..where((t) => t.userId.equals(userId))).go();
    await (delete(cachedFoods)..where((t) => t.source.equals("user"))).go();
  }
}

LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final directory = await getApplicationDocumentsDirectory();
    final file = File(p.join(directory.path, "flexio.sqlite"));
    return NativeDatabase.createInBackground(file);
  });
}
