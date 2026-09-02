import 'dart:io';
import 'dart:typed_data';

import 'package:supabase_flutter/supabase_flutter.dart';

import '../app_config.dart';
import '../local/local_image_store.dart';

/// Supabase Storage feltöltés és letöltés. Auth mindig a Supabase kliensen megy,
/// akkor is, ha az adatszinkron a saját API-n keresztül történik.
class StorageGateway {
  const StorageGateway();

  bool get isEnabled => AppConfig.hasRemote;

  SupabaseClient? get _client {
    if (!isEnabled) {
      return null;
    }
    try {
      return Supabase.instance.client;
    } on Object {
      return null;
    }
  }

  String? get userId => _client?.auth.currentUser?.id;

  bool get isSignedIn => userId != null;

  Future<String?> uploadAvatar(String localPath) async {
    final client = _client;
    final uid = userId;
    if (client == null || uid == null) {
      return null;
    }

    try {
      final storagePath = "$uid/avatar.jpg";
      await client.storage.from("avatars").upload(
            storagePath,
            File(localPath),
            fileOptions: const FileOptions(
              upsert: true,
              contentType: "image/jpeg",
            ),
          );
      return client.storage.from("avatars").getPublicUrl(storagePath);
    } on Object {
      return null;
    }
  }

  Future<String?> downloadAvatar(String userId) async {
    final client = _client;
    if (client == null) {
      return null;
    }

    try {
      final bytes = await client.storage
          .from("avatars")
          .download("$userId/avatar.jpg");
      return _persistBytes(bytes, folder: "avatars", fileName: "avatar.jpg");
    } on Object {
      return null;
    }
  }

  Future<String?> uploadProgressPhoto({
    required String photoId,
    required String localPath,
  }) async {
    final client = _client;
    final uid = userId;
    if (client == null || uid == null) {
      return null;
    }

    try {
      final storagePath = "$uid/$photoId.jpg";
      await client.storage.from("progress-photos").upload(
            storagePath,
            File(localPath),
            fileOptions: const FileOptions(
              upsert: true,
              contentType: "image/jpeg",
            ),
          );
      return storagePath;
    } on Object {
      return null;
    }
  }

  Future<String?> downloadProgressPhoto(String storagePath) async {
    final client = _client;
    if (client == null) {
      return null;
    }

    try {
      final bytes =
          await client.storage.from("progress-photos").download(storagePath);
      final fileName = storagePath.split("/").last;
      return _persistBytes(
        bytes,
        folder: "progress_photos",
        fileName: fileName,
      );
    } on Object {
      return null;
    }
  }

  Future<void> deleteProgressPhoto(String storagePath) async {
    final client = _client;
    if (client == null) {
      return;
    }

    try {
      await client.storage.from("progress-photos").remove([storagePath]);
    } on Object {
      // A helyi törlés ettől még megtörténhet.
    }
  }

  Future<String> _persistBytes(
    Uint8List bytes, {
    required String folder,
    required String fileName,
  }) async {
    final directory = await LocalImageStore.directoryFor(folder);
    final path = "${directory.path}/$fileName";
    await File(path).writeAsBytes(bytes, flush: true);
    return path;
  }
}
