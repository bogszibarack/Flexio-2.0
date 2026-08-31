import 'dart:io';

import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:uuid/uuid.dart';

/// Kiválasztott képek másolása az app dokumentumkönyvtárába, hogy a galéria
/// törlése után is megmaradjanak.
class LocalImageStore {
  LocalImageStore._();

  static const Uuid _uuid = Uuid();

  static Future<Directory> directoryFor(String folder) async {
    final root = await getApplicationDocumentsDirectory();
    final directory = Directory(p.join(root.path, folder));
    if (!await directory.exists()) {
      await directory.create(recursive: true);
    }
    return directory;
  }

  static Future<String> persist({
    required String sourcePath,
    required String folder,
    String? fileName,
  }) async {
    final directory = await directoryFor(folder);
    final extension = p.extension(sourcePath).isEmpty
        ? ".jpg"
        : p.extension(sourcePath);
    final name = fileName ?? "${_uuid.v4()}$extension";
    final destination = File(p.join(directory.path, name));
    await File(sourcePath).copy(destination.path);
    return destination.path;
  }

  static Future<void> deleteFile(String? path) async {
    if (path == null || path.isEmpty) {
      return;
    }
    final file = File(path);
    if (await file.exists()) {
      await file.delete();
    }
  }

  static Future<void> deleteFolder(String folder) async {
    final root = await getApplicationDocumentsDirectory();
    final directory = Directory(p.join(root.path, folder));
    if (await directory.exists()) {
      await directory.delete(recursive: true);
    }
  }
}
