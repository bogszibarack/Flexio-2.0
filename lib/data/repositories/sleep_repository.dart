import 'package:drift/drift.dart' show Value;
import 'package:uuid/uuid.dart';

import '../local/app_database.dart';
import '../remote/supabase_gateway.dart';

class SleepEntry {
  final String id;
  final DateTime bedtime;
  final DateTime wakeTime;
  final int? quality;
  final String? note;

  const SleepEntry({
    required this.id,
    required this.bedtime,
    required this.wakeTime,
    this.quality,
    this.note,
  });

  Duration get duration => wakeTime.difference(bedtime);

  double get hours => duration.inMinutes / 60;

  String get durationLabel {
    final minutes = duration.inMinutes.clamp(0, 24 * 60);
    return "${minutes ~/ 60}ó ${(minutes % 60).toString().padLeft(2, '0')}p";
  }
}

/// Alvásnaplózás. Ugyanaz a minta, mint az étkezésnél: helyi írás, majd
/// feltöltés, ha van bejelentkezett felhasználó.
class SleepRepository {
  SleepRepository({
    required AppDatabase database,
    required SupabaseGateway gateway,
  })  : _database = database,
        _gateway = gateway;

  final AppDatabase _database;
  final SupabaseGateway _gateway;
  final Uuid _uuid = const Uuid();

  Future<List<SleepEntry>> load(String userId) async {
    final rows = await _database.sleepForUser(userId);
    return rows.map(_fromRow).toList();
  }

  Future<SleepEntry> log({
    required String userId,
    required DateTime bedtime,
    required DateTime wakeTime,
    int? quality,
    String? note,
    String? id,
  }) async {
    final entry = SleepEntry(
      id: id ?? _uuid.v4(),
      bedtime: bedtime,
      wakeTime: wakeTime.isAfter(bedtime)
          ? wakeTime
          : wakeTime.add(const Duration(days: 1)),
      quality: quality,
      note: note,
    );

    await _database.saveSleepRow(SleepRow(
      id: entry.id,
      userId: userId,
      bedtime: entry.bedtime,
      wakeTime: entry.wakeTime,
      quality: entry.quality,
      note: entry.note,
      updatedAt: DateTime.now(),
      isDirty: true,
    ));

    pushPending(userId);
    return entry;
  }

  Future<void> remove({required String userId, required String id}) async {
    final existing = await (_database.select(_database.sleepRows)
          ..where((t) => t.id.equals(id)))
        .getSingleOrNull();
    if (existing == null) {
      return;
    }

    await _database.saveSleepRow(existing.copyWith(
      deletedAt: Value(DateTime.now()),
      updatedAt: DateTime.now(),
      isDirty: true,
    ));

    pushPending(userId);
  }

  Future<void> pushPending(String userId) async {
    if (!_gateway.isSignedIn) {
      return;
    }

    final rows = await _database.dirtySleep(userId);
    if (rows.isEmpty) {
      return;
    }

    final pushed = await _gateway.pushRows(
      "sleep_entries",
      rows
          .map((row) => {
                "id": row.id,
                "user_id": userId,
                "bedtime": row.bedtime.toUtc().toIso8601String(),
                "wake_time": row.wakeTime.toUtc().toIso8601String(),
                "quality": row.quality,
                "note": row.note,
                "updated_at": row.updatedAt.toUtc().toIso8601String(),
                "deleted_at": row.deletedAt?.toUtc().toIso8601String(),
              })
          .toList(),
    );

    if (pushed) {
      for (final row in rows) {
        await _database.markSleepSynced(row.id);
      }
    }
  }

  Future<void> pull(String userId, {DateTime? since}) async {
    if (!_gateway.isSignedIn) {
      return;
    }

    final rows = await _gateway.pullRows("sleep_entries", since: since);
    for (final row in rows) {
      final id = "${row["id"]}";
      final updatedAt =
          DateTime.tryParse("${row["updated_at"]}")?.toLocal() ?? DateTime.now();

      final local = await (_database.select(_database.sleepRows)
            ..where((t) => t.id.equals(id)))
          .getSingleOrNull();

      if (local != null && local.isDirty && local.updatedAt.isAfter(updatedAt)) {
        continue;
      }

      await _database.saveSleepRow(SleepRow(
        id: id,
        userId: userId,
        bedtime: DateTime.parse("${row["bedtime"]}").toLocal(),
        wakeTime: DateTime.parse("${row["wake_time"]}").toLocal(),
        quality: (row["quality"] as num?)?.toInt(),
        note: row["note"] as String?,
        updatedAt: updatedAt,
        deletedAt: DateTime.tryParse("${row["deleted_at"]}")?.toLocal(),
        isDirty: false,
      ));
    }
  }

  static SleepEntry _fromRow(SleepRow row) => SleepEntry(
        id: row.id,
        bedtime: row.bedtime,
        wakeTime: row.wakeTime,
        quality: row.quality,
        note: row.note,
      );
}
