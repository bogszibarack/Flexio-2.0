import 'dart:convert';

import 'package:uuid/uuid.dart';

import '../local/app_database.dart';
import '../remote/supabase_gateway.dart';

class WaterSip {
  const WaterSip({
    required this.id,
    required this.at,
    required this.ml,
  });

  final String id;
  final DateTime at;
  final int ml;

  Map<String, dynamic> toJson() => {
        "id": id,
        "at": at.toIso8601String(),
        "ml": ml,
      };

  factory WaterSip.fromJson(Map<String, dynamic> json) => WaterSip(
        id: json["id"] as String? ?? "",
        at: DateTime.tryParse("${json["at"]}") ?? DateTime.now(),
        ml: (json["ml"] as num?)?.toInt() ?? 0,
      );

  String get clockLabel =>
      "${at.hour.toString().padLeft(2, "0")}:${at.minute.toString().padLeft(2, "0")}";
}

/// A napi vízbevitel szinkronizálása. Minden korty külön sor a helyi DB-ben.
class WaterRepository {
  WaterRepository({
    required AppDatabase database,
    required SupabaseGateway gateway,
  })  : _database = database,
        _gateway = gateway;

  final AppDatabase _database;
  final SupabaseGateway _gateway;
  final Uuid _uuid = const Uuid();

  static String _localDateKey(DateTime day) =>
      "${day.year}-${day.month.toString().padLeft(2, "0")}-${day.day.toString().padLeft(2, "0")}";

  static String _legacyMetaKey(String userId, DateTime day) =>
      "water_${userId}_${_localDateKey(day)}";

  Future<List<WaterSip>> loadForDay(String userId, DateTime day) async {
    await _importLegacyMetaIfNeeded(userId, day);

    final rows =
        await _database.waterForDay(userId, _localDateKey(day));
    return rows
        .map(
          (row) => WaterSip(
            id: row.id,
            at: row.loggedAt,
            ml: row.ml,
          ),
        )
        .toList();
  }

  Future<WaterSip> addSip(String userId, int milliliters) async {
    final now = DateTime.now();
    final sip = WaterSip(
      id: _uuid.v4(),
      at: now,
      ml: milliliters,
    );

    await _database.saveWaterRow(WaterRow(
      id: sip.id,
      userId: userId,
      loggedAt: sip.at,
      localDate: _localDateKey(now),
      ml: sip.ml,
      updatedAt: now,
      isDirty: true,
    ));

    await pushPending(userId);
    return sip;
  }

  Future<void> pushPending(String userId) async {
    if (!_gateway.isSignedIn) {
      return;
    }

    final rows = await _database.dirtyWater(userId);
    if (rows.isEmpty) {
      return;
    }

    final pushed = await _gateway.pushRows(
      "water_entries",
      rows
          .map(
            (row) => {
              "id": row.id,
              "user_id": userId,
              "logged_at": row.loggedAt.toUtc().toIso8601String(),
              "local_date": row.localDate,
              "ml": row.ml,
              "updated_at": row.updatedAt.toUtc().toIso8601String(),
              "deleted_at": row.deletedAt?.toUtc().toIso8601String(),
            },
          )
          .toList(),
    );

    if (pushed) {
      for (final row in rows) {
        await _database.markWaterSynced(row.id);
      }
    }
  }

  Future<void> pull(String userId, {DateTime? since}) async {
    if (!_gateway.isSignedIn) {
      return;
    }

    final rows = await _gateway.pullRows("water_entries", since: since);
    for (final row in rows) {
      final id = "${row["id"]}";
      final updatedAt =
          DateTime.tryParse("${row["updated_at"]}")?.toLocal() ?? DateTime.now();

      final local = await (_database.select(_database.waterRows)
            ..where((t) => t.id.equals(id)))
          .getSingleOrNull();

      if (local != null && local.isDirty && local.updatedAt.isAfter(updatedAt)) {
        continue;
      }

      await _database.saveWaterRow(WaterRow(
        id: id,
        userId: userId,
        loggedAt: DateTime.parse("${row["logged_at"]}").toLocal(),
        localDate: "${row["local_date"]}",
        ml: (row["ml"] as num).toInt(),
        updatedAt: updatedAt,
        deletedAt: DateTime.tryParse("${row["deleted_at"]}")?.toLocal(),
        isDirty: false,
      ));
    }
  }

  Future<void> _importLegacyMetaIfNeeded(String userId, DateTime day) async {
    final existing =
        await _database.waterForDay(userId, _localDateKey(day));
    if (existing.isNotEmpty) {
      return;
    }

    final raw = await _database.metaValue(_legacyMetaKey(userId, day));
    if (raw == null || raw.isEmpty) {
      return;
    }

    try {
      final decoded = jsonDecode(raw);
      if (decoded is! List) {
        return;
      }

      for (final item in decoded.whereType<Map>()) {
        var sip = WaterSip.fromJson(Map<String, dynamic>.from(item));
        if (sip.ml <= 0) {
          continue;
        }
        if (sip.id.isEmpty) {
          sip = WaterSip(id: _uuid.v4(), at: sip.at, ml: sip.ml);
        }
        await _database.saveWaterRow(WaterRow(
          id: sip.id,
          userId: userId,
          loggedAt: sip.at,
          localDate: _localDateKey(day),
          ml: sip.ml,
          updatedAt: sip.at,
          isDirty: true,
        ));
      }
      await _database.setMeta(_legacyMetaKey(userId, day), "");
    } on Object {
      // A régi meta hibás lehet; nem blokkoljuk a betöltést.
    }
  }
}
