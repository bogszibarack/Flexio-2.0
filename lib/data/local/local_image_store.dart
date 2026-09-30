import 'dart:io';

import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:uuid/uuid.dart';

/// Kiválasztott képek másolása az app dokumentumkönyvtárába, hogy a galéria
/// törlése után is megmaradjanak.
///
/// FONTOS: az adatbázisba **relatív** útvonal kerül (`progress_photos/x.jpg`).
/// Az app dokumentumkönyvtárának abszolút útvonala minden újratelepítésnél
/// megváltozik (iOS-en a konténer UUID-je cserélődik), ezért abszolút utat
/// eltárolni egyenlő azzal, hogy a kép a következő telepítés után elvész.
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

  /// A forrásfájl bemásolása, és a **relatív** útvonal visszaadása.
  static Future<String> persist({
    required String sourcePath,
    required String folder,
    String? fileName,
  }) async {
    final directory = await directoryFor(folder);
    final extension =
        p.extension(sourcePath).isEmpty ? ".jpg" : p.extension(sourcePath);
    final name = fileName ?? "${_uuid.v4()}$extension";
    final destination = File(p.join(directory.path, name));
    await File(sourcePath).copy(destination.path);
    return relativeOf(folder: folder, fileName: name);
  }

  static String relativeOf({required String folder, required String fileName}) =>
      "$folder/$fileName";

  /// Bármilyen korábban eltárolt értékből relatív útvonalat csinál.
  /// A régi, abszolút utakból a mappa + fájlnév részt tartja meg.
  static String? toRelative(String? stored, {String? fallbackFolder}) {
    if (stored == null || stored.trim().isEmpty) {
      return null;
    }
    final normalized = stored.replaceAll("\\", "/");
    if (!normalized.startsWith("/")) {
      return normalized;
    }
    final segments = p.split(normalized);
    if (segments.length >= 2) {
      final folder = segments[segments.length - 2];
      final name = segments.last;
      if (folder.isNotEmpty && folder != "/") {
        return "$folder/$name";
      }
    }
    if (fallbackFolder != null) {
      return "$fallbackFolder/${p.basename(normalized)}";
    }
    return null;
  }

  /// A tárolt (relatív vagy régi abszolút) útvonalból létező abszolút fájl.
  /// Ha a fájl nem található, `null`.
  static Future<String?> resolve(String? stored,
      {String? fallbackFolder}) async {
    if (stored == null || stored.trim().isEmpty) {
      return null;
    }

    // Régi, abszolút út: ha véletlenül még él, jó nekünk.
    if (stored.startsWith("/") && File(stored).existsSync()) {
      return stored;
    }

    final relative = toRelative(stored, fallbackFolder: fallbackFolder);
    if (relative == null) {
      return null;
    }

    final root = await getApplicationDocumentsDirectory();
    final candidate = File(p.join(root.path, relative));
    if (candidate.existsSync()) {
      return candidate.path;
    }

    // Utolsó esély: a fájlnév a megadott mappában.
    if (fallbackFolder != null) {
      final byName = File(
        p.join(root.path, fallbackFolder, p.basename(relative)),
      );
      if (byName.existsSync()) {
        return byName.path;
      }
    }
    return null;
  }

  static Future<void> deleteFile(String? path, {String? fallbackFolder}) async {
    final resolved = await resolve(path, fallbackFolder: fallbackFolder);
    if (resolved == null) {
      return;
    }
    final file = File(resolved);
    if (await file.exists()) {
      await file.delete();
    }
  }
}
