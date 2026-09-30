import 'dart:convert';
import 'dart:io';

import 'package:fitness/data/local/local_image_store.dart';
import 'package:fitness/data/remote/storage_gateway.dart';
import 'package:fitness/data/remote/supabase_gateway.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider_platform_interface/path_provider_platform_interface.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

/// Memóriában tartott „szerver”: a sorok JSON-on keresztül utaznak, ahogy a
/// valóságban (jsonb), így a kulcssorrend és a típusok is úgy jönnek vissza.
class FakeRemote extends SupabaseGateway {
  FakeRemote({this.signedInUserId = "00000000-0000-4000-8000-000000000001"});

  final String? signedInUserId;
  final Map<String, Map<String, String>> tables = {};

  @override
  String? get userId => signedInUserId;

  @override
  bool get isSignedIn => signedInUserId != null;

  @override
  Future<int> pushRows(String table, List<Map<String, dynamic>> rows) async {
    final target = tables.putIfAbsent(table, () => {});
    for (final row in rows) {
      target["${row["id"]}"] = jsonEncode(row);
    }
    return rows.length;
  }

  @override
  Future<List<Map<String, dynamic>>?> pullRows(String table,
      {DateTime? since}) async {
    final rows = tables[table]?.values ?? const <String>[];
    return rows
        .map((raw) => Map<String, dynamic>.from(jsonDecode(raw) as Map))
        .toList();
  }
}

/// A Storage: feltöltéskor elteszi a bájtokat, letöltéskor a valódi
/// [LocalImageStore] mappájába írja vissza, relatív útvonallal.
class FakeStorage extends StorageGateway {
  FakeStorage();

  final Map<String, List<int>> objects = {};

  @override
  Future<String?> uploadProgressPhoto({
    required String photoId,
    required String localPath,
  }) async {
    final absolute = await LocalImageStore.resolve(localPath,
        fallbackFolder: "progress_photos");
    if (absolute == null) {
      return null;
    }
    final path = "user/$photoId.jpg";
    objects[path] = await File(absolute).readAsBytes();
    return path;
  }

  @override
  Future<String?> downloadProgressPhoto(String storagePath) async {
    final bytes = objects[storagePath];
    if (bytes == null) {
      return null;
    }
    final directory = await LocalImageStore.directoryFor("progress_photos");
    final name = storagePath.split("/").last;
    await File(p.join(directory.path, name)).writeAsBytes(bytes);
    return LocalImageStore.relativeOf(folder: "progress_photos", fileName: name);
  }

  @override
  Future<void> deleteProgressPhoto(String storagePath) async {
    objects.remove(storagePath);
  }
}

/// Cserélhető dokumentumkönyvtár: így szimulálható, hogy iOS frissítéskor
/// vagy újratelepítéskor az app konténerének útvonala megváltozik.
class FakePathProvider extends PathProviderPlatform
    with MockPlatformInterfaceMixin {
  FakePathProvider(this.documentsPath);

  String documentsPath;

  @override
  Future<String?> getApplicationDocumentsPath() async => documentsPath;

  @override
  Future<String?> getApplicationSupportPath() async => documentsPath;

  @override
  Future<String?> getTemporaryPath() async => documentsPath;
}
