import 'dart:convert';
import 'dart:io';

import 'package:drift/drift.dart' show Value;
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:uuid/uuid.dart';

import '../models/progress_photo.dart';
import '../local/app_database.dart';
import '../local/local_image_store.dart';
import '../remote/storage_gateway.dart';
import '../remote/supabase_gateway.dart';

/// Haladásfotók: helyi fájl + Supabase Storage + meta sor szinkronnal.
class ProgressPhotoRepository {
  ProgressPhotoRepository({
    required AppDatabase database,
    required SupabaseGateway gateway,
    required StorageGateway storage,
  })  : _database = database,
        _gateway = gateway,
        _storage = storage;

  final AppDatabase _database;
  final SupabaseGateway _gateway;
  final StorageGateway _storage;
  final Uuid _uuid = const Uuid();

  Future<List<ProgressPhoto>> load(String userId) async {
    await _importLegacyIndexIfNeeded(userId);
    final rows = await _database.progressPhotosForUser(userId);
    final photos = <ProgressPhoto>[];

    for (final row in rows) {
      final resolved = await _resolve(row.localPath);
      if (resolved != null) {
        // Régi, abszolút útvonal esetén relatívra normalizáljuk, hogy a
        // következő újratelepítés után is megtaláljuk.
        final relative = LocalImageStore.toRelative(
          row.localPath,
          fallbackFolder: _folder,
        );
        if (relative != null && relative != row.localPath) {
          await _database.saveProgressPhotoRow(
            row.copyWith(localPath: Value(relative)),
          );
        }
        photos.add(_fromRow(row, resolved));
        continue;
      }

      if (_gateway.isSignedIn && row.storagePath.isNotEmpty) {
        final downloaded =
            await _storage.downloadProgressPhoto(row.storagePath);
        final downloadedAbsolute = await _resolve(downloaded);
        if (downloadedAbsolute != null) {
          await _database.saveProgressPhotoRow(row.copyWith(
            localPath: Value(downloaded),
            isDirty: false,
          ));
          photos.add(_fromRow(row, downloadedAbsolute));
          continue;
        }
      }
    }

    return photos;
  }

  Future<ProgressPhoto?> add({
    required String userId,
    required String sourcePath,
    required PhotoPose pose,
    DateTime? takenAt,
  }) async {
    final id = _uuid.v4();
    final stored = await LocalImageStore.persist(
      sourcePath: sourcePath,
      folder: "progress_photos",
      fileName: "$id.jpg",
    );
    final at = takenAt ?? DateTime.now();
    var storagePath = "";

    if (_gateway.isSignedIn) {
      storagePath =
          await _storage.uploadProgressPhoto(photoId: id, localPath: stored) ??
              "";
    }

    final row = ProgressPhotoRow(
      id: id,
      userId: userId,
      takenAt: at,
      pose: pose.name,
      storagePath: storagePath,
      localPath: stored,
      updatedAt: DateTime.now(),
      isDirty: true,
    );
    await _database.saveProgressPhotoRow(row);
    await pushPending(userId);

    final absolute = await _resolve(stored);
    return absolute == null ? null : _fromRow(row, absolute);
  }

  Future<void> remove({
    required String userId,
    required String id,
  }) async {
    final existing = await (_database.select(_database.progressPhotoRows)
          ..where((t) => t.id.equals(id)))
        .getSingleOrNull();
    if (existing == null) {
      return;
    }

    await _database.saveProgressPhotoRow(existing.copyWith(
      deletedAt: Value(DateTime.now()),
      updatedAt: DateTime.now(),
      isDirty: true,
    ));

    if (existing.storagePath.isNotEmpty) {
      await _storage.deleteProgressPhoto(existing.storagePath);
    }
    await LocalImageStore.deleteFile(
      existing.localPath,
      fallbackFolder: _folder,
    );

    await pushPending(userId);
  }

  Future<void> pushPending(String userId) async {
    if (!_gateway.isSignedIn) {
      return;
    }

    final dirty = await _database.dirtyProgressPhotos(userId);
    if (dirty.isEmpty) {
      return;
    }

    final payload = <Map<String, dynamic>>[];
    for (final row in dirty) {
      var storagePath = row.storagePath;
      if (storagePath.isEmpty &&
          row.deletedAt == null &&
          row.localPath != null) {
        storagePath = await _storage.uploadProgressPhoto(
              photoId: row.id,
              localPath: row.localPath!,
            ) ??
            "";
        if (storagePath.isNotEmpty) {
          await _database.saveProgressPhotoRow(row.copyWith(
            storagePath: storagePath,
            updatedAt: DateTime.now(),
          ));
        }
      }

      if (row.deletedAt == null && storagePath.isEmpty) {
        continue;
      }

      payload.add({
        "id": row.id,
        "user_id": userId,
        "taken_at": row.takenAt.toUtc().toIso8601String(),
        "pose": row.pose,
        "storage_path": storagePath,
        "updated_at": row.updatedAt.toUtc().toIso8601String(),
        "deleted_at": row.deletedAt?.toUtc().toIso8601String(),
      });
    }

    if (payload.isEmpty) {
      return;
    }

    final pushed = await _gateway.pushRows("progress_photos", payload);
    if (pushed > 0) {
      for (final row in dirty) {
        await _database.markProgressPhotoSynced(row.id);
      }
    }
  }

  /// `true`, ha a lekérés lefutott (akkor is, ha nem jött új sor).
  /// `false`, ha hiba volt — ilyenkor a hívó nem léptetheti a watermarkot.
  Future<bool> pull(String userId, {DateTime? since}) async {
    if (!_gateway.isSignedIn) {
      return false;
    }

    final rows = await _gateway.pullRows("progress_photos", since: since);
    if (rows == null) {
      return false;
    }
    for (final row in rows) {
      final id = "${row["id"]}";
      final updatedAt =
          DateTime.tryParse("${row["updated_at"]}")?.toLocal() ?? DateTime.now();

      final local = await (_database.select(_database.progressPhotoRows)
            ..where((t) => t.id.equals(id)))
          .getSingleOrNull();

      if (local != null && local.isDirty && local.updatedAt.isAfter(updatedAt)) {
        continue;
      }

      final storagePath = "${row["storage_path"]}";
      String? localPath = local?.localPath;
      final deletedAt = DateTime.tryParse("${row["deleted_at"]}")?.toLocal();

      if (deletedAt == null && storagePath.isNotEmpty) {
        final needsDownload = await _resolve(localPath) == null;
        if (needsDownload) {
          localPath = await _storage.downloadProgressPhoto(storagePath);
        }
      } else if (deletedAt != null) {
        await LocalImageStore.deleteFile(localPath, fallbackFolder: _folder);
        localPath = null;
      }

      await _database.saveProgressPhotoRow(ProgressPhotoRow(
        id: id,
        userId: userId,
        takenAt: DateTime.parse("${row["taken_at"]}").toLocal(),
        pose: "${row["pose"]}",
        storagePath: storagePath,
        localPath: localPath,
        updatedAt: updatedAt,
        deletedAt: deletedAt,
        isDirty: false,
      ));
    }
    return true;
  }

  Future<void> _importLegacyIndexIfNeeded(String userId) async {
    final existing = await _database.progressPhotosForUser(userId);
    if (existing.isNotEmpty) {
      return;
    }

    try {
      final root = await getApplicationDocumentsDirectory();
      final file = File(p.join(root.path, "progress_photos_$userId.json"));
      if (!await file.exists()) {
        return;
      }

      final decoded = jsonDecode(await file.readAsString());
      if (decoded is! List) {
        return;
      }

      for (final item in decoded.whereType<Map>()) {
        final photo =
            ProgressPhoto.fromJson(Map<String, dynamic>.from(item));
        final relative = LocalImageStore.toRelative(
          photo.filePath,
          fallbackFolder: _folder,
        );
        if (await _resolve(relative) == null) {
          continue;
        }

        var storagePath = "";
        if (_gateway.isSignedIn) {
          storagePath = await _storage.uploadProgressPhoto(
                photoId: photo.id,
                localPath: relative!,
              ) ??
              "";
        }

        await _database.saveProgressPhotoRow(ProgressPhotoRow(
          id: photo.id,
          userId: userId,
          takenAt: photo.takenAt,
          pose: photo.pose.name,
          storagePath: storagePath,
          localPath: relative,
          updatedAt: photo.takenAt,
          isDirty: true,
        ));
      }

      await file.delete();
    } on Object {
      // Nem kritikus.
    }
  }

  static const String _folder = "progress_photos";

  /// A tárolt (relatív vagy régi abszolút) útvonalból létező abszolút fájl.
  static Future<String?> _resolve(String? stored) =>
      LocalImageStore.resolve(stored, fallbackFolder: _folder);

  static ProgressPhoto _fromRow(ProgressPhotoRow row, String filePath) =>
      ProgressPhoto(
        id: row.id,
        takenAt: row.takenAt,
        pose: PhotoPose.fromName(row.pose),
        filePath: filePath,
      );
}
