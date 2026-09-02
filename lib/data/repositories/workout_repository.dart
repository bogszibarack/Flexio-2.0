import 'dart:convert';

import 'package:drift/drift.dart' show Value;

import '../local/app_database.dart';
import '../remote/supabase_gateway.dart';

/// Az edzés-nézetek térkép alapú objektumokkal dolgoznak, ezért a részletes
/// szerkezet JSON pillanatfelvételként utazik. A dátumokat külön jelöljük, hogy
/// a visszaolvasás után is `DateTime` legyenek.
class WorkoutJson {
  WorkoutJson._();

  static const String _dateMarker = "__date";

  static Object? encode(Object? value) {
    if (value is DateTime) {
      return {_dateMarker: value.toIso8601String()};
    }
    if (value is Map) {
      return value.map((key, item) => MapEntry("$key", encode(item)));
    }
    if (value is List) {
      return value.map(encode).toList();
    }
    return value;
  }

  static Object? decode(Object? value) {
    if (value is Map) {
      if (value.length == 1 && value.containsKey(_dateMarker)) {
        return DateTime.tryParse("${value[_dateMarker]}");
      }
      return value.map((key, item) => MapEntry("$key", decode(item)));
    }
    if (value is List) {
      return value.map(decode).toList();
    }
    return value;
  }

  static String toJsonString(Map<String, dynamic> map) =>
      jsonEncode(encode(map));

  static Map<String, dynamic> fromJsonString(String raw) {
    try {
      final decoded = decode(jsonDecode(raw));
      if (decoded is Map<String, dynamic>) {
        return decoded;
      }
      if (decoded is Map) {
        return Map<String, dynamic>.from(decoded);
      }
    } on Object {
      // Sérült sor: inkább üres, mint összeomlás.
    }
    return <String, dynamic>{};
  }
}

class WorkoutSnapshot {
  final List<Map<String, dynamic>> templates;
  final List<Map<String, dynamic>> scheduled;
  final List<Map<String, dynamic>> completed;

  const WorkoutSnapshot({
    required this.templates,
    required this.scheduled,
    required this.completed,
  });

  static const WorkoutSnapshot empty = WorkoutSnapshot(
    templates: [],
    scheduled: [],
    completed: [],
  );
}

/// Edzés adatok felhasználóhoz kötött tárolása, ugyanazon a szinkron-sínen,
/// mint a napló.
class WorkoutRepository {
  WorkoutRepository({
    required AppDatabase database,
    required SupabaseGateway gateway,
  })  : _database = database,
        _gateway = gateway;

  static const String kindTemplate = "template";
  static const String kindScheduled = "scheduled";
  static const String kindCompleted = "completed";

  final AppDatabase _database;
  final SupabaseGateway _gateway;

  Future<WorkoutSnapshot> load(String userId) async {
    final rows = await _database.workoutsForUser(userId);

    final templates = <Map<String, dynamic>>[];
    final scheduled = <Map<String, dynamic>>[];
    final completed = <Map<String, dynamic>>[];

    for (final row in rows) {
      final map = WorkoutJson.fromJsonString(row.payloadJson);
      if (map.isEmpty) {
        continue;
      }
      map["id"] = row.id;

      switch (row.kind) {
        case kindTemplate:
          templates.add(map);
          break;
        case kindScheduled:
          scheduled.add(map);
          break;
        default:
          completed.add(map);
      }
    }

    return WorkoutSnapshot(
      templates: templates,
      scheduled: scheduled,
      completed: completed,
    );
  }

  Future<void> save({
    required String userId,
    required String kind,
    required Map<String, dynamic> item,
  }) async {
    final id = "${item["id"] ?? ""}";
    if (id.isEmpty) {
      return;
    }

    final now = DateTime.now();
    await _database.saveWorkoutRow(WorkoutRow(
      id: id,
      userId: userId,
      kind: kind,
      title: "${item["title"] ?? item["name"] ?? ""}",
      scheduledAt: item["date"] as DateTime?,
      completedAt: (item["completedAt"] ?? item["date"]) is DateTime &&
              kind == kindCompleted
          ? (item["completedAt"] ?? item["date"]) as DateTime
          : item["completedAt"] as DateTime?,
      durationMinutes: (item["minutes"] as num?)?.toInt(),
      calories: (item["calories"] as num?)?.toDouble(),
      difficulty: item["difficulty"] as String?,
      payloadJson: WorkoutJson.toJsonString(item),
      updatedAt: now,
      isDirty: true,
    ));

    await pushPending(userId);
  }

  Future<void> remove({required String userId, required String id}) async {
    final existing = await (_database.select(_database.workoutRows)
          ..where((t) => t.id.equals(id)))
        .getSingleOrNull();
    if (existing == null) {
      return;
    }

    await _database.saveWorkoutRow(existing.copyWith(
      deletedAt: Value(DateTime.now()),
      updatedAt: DateTime.now(),
      isDirty: true,
    ));

    await pushPending(userId);
  }

  Future<void> pushPending(String userId) async {
    if (!_gateway.isSignedIn) {
      return;
    }

    final rows = await _database.dirtyWorkouts(userId);
    if (rows.isEmpty) {
      return;
    }

    final pushed = await _gateway.pushRows(
      "workout_sessions",
      rows.map((row) => _toRemote(userId, row)).toList(),
    );

    if (pushed) {
      for (final row in rows) {
        await _database.markWorkoutSynced(row.id);
      }
    }
  }

  Future<void> pull(String userId, {DateTime? since}) async {
    if (!_gateway.isSignedIn) {
      return;
    }

    final rows = await _gateway.pullRows("workout_sessions", since: since);
    for (final row in rows) {
      final id = "${row["id"]}";
      final updatedAt =
          DateTime.tryParse("${row["updated_at"]}")?.toLocal() ?? DateTime.now();

      final local = await (_database.select(_database.workoutRows)
            ..where((t) => t.id.equals(id)))
          .getSingleOrNull();

      if (local != null && local.isDirty && local.updatedAt.isAfter(updatedAt)) {
        continue;
      }

      final payload = row["payload"];
      await _database.saveWorkoutRow(WorkoutRow(
        id: id,
        userId: userId,
        kind: "${row["kind"] ?? kindCompleted}",
        title: "${row["title"] ?? ""}",
        scheduledAt: DateTime.tryParse("${row["scheduled_at"]}")?.toLocal(),
        completedAt: DateTime.tryParse("${row["completed_at"]}")?.toLocal(),
        durationMinutes: (row["duration_minutes"] as num?)?.toInt(),
        calories: (row["calories"] as num?)?.toDouble(),
        difficulty: row["difficulty"] as String?,
        payloadJson: payload is String ? payload : jsonEncode(payload ?? {}),
        updatedAt: updatedAt,
        deletedAt: DateTime.tryParse("${row["deleted_at"]}")?.toLocal(),
        isDirty: false,
      ));
    }
  }

  Map<String, dynamic> _toRemote(String userId, WorkoutRow row) => {
        "id": row.id,
        "user_id": userId,
        "title": row.title,
        "kind": row.kind,
        "scheduled_at": row.scheduledAt?.toUtc().toIso8601String(),
        "completed_at": row.completedAt?.toUtc().toIso8601String(),
        "duration_minutes": row.durationMinutes,
        "calories": row.calories,
        "difficulty": row.difficulty,
        "payload": jsonDecode(row.payloadJson),
        "updated_at": row.updatedAt.toUtc().toIso8601String(),
        "deleted_at": row.deletedAt?.toUtc().toIso8601String(),
      };
}
