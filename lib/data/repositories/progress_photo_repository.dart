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
      final localPath = row.localPath;
      if (localPath != null && File(localPath).existsSync()) {
        photos.add(_fromRow(row, localPath));
        continue;
      }

      if (_gateway.isSignedIn && row.storagePath.isNotEmpty) {
        final downloaded =
            await _storage.downloadProgressPhoto(row.storagePath);
        if (downloaded != null) {
          await _database.saveProgressPhotoRow(row.copyWith(
            localPath: Value(downloaded),
            isDirty: false,
          ));
          photos.add(_fromRow(row, downloaded));
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

    return _fromRow(row, stored);
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
    await LocalImageStore.deleteFile(existing.localPath);

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
    if (pushed) {
      for (final row in dirty) {
        await _database.markProgressPhotoSynced(row.id);
      }
    }
  }

  Future<void> pull(String userId, {DateTime? since}) async {
    if (!_gateway.isSignedIn) {
      return;
    }

    final rows = await _gateway.pullRows("progress_photos", since: since);
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
        final needsDownload = localPath == null || !File(localPath).existsSync();
        if (needsDownload) {
          localPath = await _storage.downloadProgressPhoto(storagePath);
        }
      } else if (deletedAt != null) {
        await LocalImageStore.deleteFile(localPath);
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
        if (!File(photo.filePath).existsSync()) {
          continue;
        }

        var storagePath = "";
        if (_gateway.isSignedIn) {
          storagePath = await _storage.uploadProgressPhoto(
                photoId: photo.id,
                localPath: photo.filePath,
              ) ??
              "";
        }

        await _database.saveProgressPhotoRow(ProgressPhotoRow(
          id: photo.id,
          userId: userId,
          takenAt: photo.takenAt,
          pose: photo.pose.name,
          storagePath: storagePath,
          localPath: photo.filePath,
          updatedAt: photo.takenAt,
          isDirty: true,
        ));
      }

      await file.delete();
    } on Object {
      // Nem kritikus.
    }
  }

  static ProgressPhoto _fromRow(ProgressPhotoRow row, String filePath) =>
      ProgressPhoto(
        id: row.id,
        takenAt: row.takenAt,
        pose: PhotoPose.fromName(row.pose),
        filePath: filePath,
      );
}
