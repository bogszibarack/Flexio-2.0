import 'package:uuid/uuid.dart';

import '../local/app_database.dart';
import '../models/diary_entry.dart';
import '../models/food_item.dart';
import '../models/nutrients.dart';
import '../remote/supabase_gateway.dart';

/// Étkezési napló. Offline-first: minden írás először a helyi adatbázisba
/// kerül `isDirty` jelöléssel, a feltöltés utána történik.
class DiaryRepository {
  DiaryRepository({
    required AppDatabase database,
    required SupabaseGateway gateway,
  })  : _database = database,
        _gateway = gateway;

  final AppDatabase _database;
  final SupabaseGateway _gateway;
  final Uuid _uuid = const Uuid();

  void Function(DiaryEntry entry)? onLogged;

  Stream<List<DiaryEntry>> watch(String userId) =>
      _database.watchDiary(userId).map(
            (rows) => rows.map(_fromRow).toList()
              ..sort((a, b) => a.loggedAt.compareTo(b.loggedAt)),
          );

  Future<List<DiaryEntry>> load(String userId) async {
    final rows = await _database.diaryForUser(userId);
    return rows.map(_fromRow).toList()
      ..sort((a, b) => a.loggedAt.compareTo(b.loggedAt));
  }

  Future<DiaryEntry> logFood({
    required String userId,
    required FoodItem food,
    required double amountG,
    required String mealType,
    DateTime? loggedAt,
    String? servingLabel,
  }) async {
    final entry = DiaryEntry.fromFood(
      id: _uuid.v4(),
      food: food,
      amountG: amountG,
      mealType: mealType,
      loggedAt: loggedAt,
      servingLabel: servingLabel,
    );

    await save(userId, entry);
    return entry;
  }

  Future<void> save(String userId, DiaryEntry entry) async {
    await _database.saveDiaryRow(_toRow(userId, entry, dirty: true));
    if (entry.deletedAt == null) {
      onLogged?.call(entry);
    }
    await _syncEntry(entry);
  }

  Future<void> delete(String userId, DiaryEntry entry) async {
    final removed = entry.copyWith(
      deletedAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
    await _database.saveDiaryRow(_toRow(userId, removed, dirty: true));
    await _syncEntry(removed);
  }

  Future<void> restore(String userId, DiaryEntry entry) async {
    final restored = DiaryEntry(
      id: entry.id,
      loggedAt: entry.loggedAt,
      mealType: entry.mealType,
      foodId: entry.foodId,
      foodLocalId: entry.foodLocalId,
      foodName: entry.foodName,
      foodImage: entry.foodImage,
      amountG: entry.amountG,
      servingLabel: entry.servingLabel,
      totals: entry.totals,
      updatedAt: DateTime.now(),
    );
    await save(userId, restored);
  }

  Future<void> _syncEntry(DiaryEntry entry) async {
    if (!_gateway.isSignedIn) {
      return;
    }
    final pushed = await _gateway.pushDiaryEntries([entry]);
    if (pushed) {
      await _database.markDiarySynced(entry.id);
    }
  }

  static DiaryEntry _fromRow(DiaryRow row) => DiaryEntry(
        id: row.id,
        loggedAt: row.loggedAt,
        mealType: MealTypes.normalize(row.mealType),
        foodId: row.foodId,
        foodLocalId: row.foodLocalId,
        foodName: row.foodName,
        foodImage: row.foodImage,
        amountG: row.amountG,
        servingLabel: row.servingLabel,
        totals: Nutrients(
          kcal: row.kcal,
          protein: row.protein,
          fat: row.fat,
          carbs: row.carbs,
          sugar: row.sugar,
          saturatedFat: row.saturatedFat,
          salt: row.salt,
          fiber: row.fiber,
        ),
        updatedAt: row.updatedAt,
        deletedAt: row.deletedAt,
      );

  static DiaryRow _toRow(String userId, DiaryEntry entry,
          {required bool dirty}) =>
      DiaryRow(
        id: entry.id,
        userId: userId,
        loggedAt: entry.loggedAt,
        localDate: _dateKey(entry.localDate),
        mealType: entry.mealType,
        foodId: entry.foodId,
        foodLocalId: entry.foodLocalId,
        foodName: entry.foodName,
        foodImage: entry.foodImage,
        amountG: entry.amountG,
        servingLabel: entry.servingLabel,
        kcal: entry.totals.kcal,
        protein: entry.totals.protein,
        fat: entry.totals.fat,
        carbs: entry.totals.carbs,
        sugar: entry.totals.sugar,
        saturatedFat: entry.totals.saturatedFat,
        salt: entry.totals.salt,
        fiber: entry.totals.fiber,
        updatedAt: entry.updatedAt,
        deletedAt: entry.deletedAt,
        isDirty: dirty,
      );

  static String _dateKey(DateTime date) =>
      "${date.year.toString().padLeft(4, '0')}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}";

  /// A szinkron használja: a helyi másolat frissítése a szerverről.
  Future<void> applyRemote(String userId, List<DiaryEntry> entries) async {
    for (final entry in entries) {
      final existing = await (_database.select(_database.diaryRows)
            ..where((t) => t.id.equals(entry.id)))
          .getSingleOrNull();

      // Utolsó írás győz: a helyi módosítás csak akkor marad, ha frissebb.
      if (existing != null &&
          existing.isDirty &&
          existing.updatedAt.isAfter(entry.updatedAt)) {
        continue;
      }

      await _database.saveDiaryRow(_toRow(userId, entry, dirty: false));
    }
  }

  Future<List<DiaryEntry>> pendingUploads(String userId) async {
    final rows = await _database.dirtyDiary(userId);
    return rows.map(_fromRow).toList();
  }

  Future<void> markSynced(String id) => _database.markDiarySynced(id);
}
