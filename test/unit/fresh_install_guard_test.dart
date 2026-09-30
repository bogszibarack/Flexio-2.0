import 'dart:io';

import 'package:fitness/data/fresh_install_guard.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart' as p;

void main() {
  late Directory documents;
  late int clearCalls;
  late FreshInstallGuard guard;

  setUp(() async {
    documents = await Directory.systemTemp.createTemp("flexio_guard_");
    clearCalls = 0;
    guard = FreshInstallGuard(
      documentsDirectory: () async => documents,
      clearPersistedSession: () async => clearCalls++,
    );
  });

  tearDown(() => documents.delete(recursive: true));

  test("friss telepítésnél a Keychainben maradt régi session törlődik",
      () async {
    expect(await guard.run(), isTrue);
    expect(clearCalls, 1);
  });

  test("a következő indításnál már nem nyúl a sessionhöz", () async {
    await guard.run();
    expect(await guard.run(), isFalse);
    expect(clearCalls, 1);
  });

  test(
      "régebbi verzióról frissítve (van helyi adatbázis) nem jelentkeztet ki",
      () async {
    await File(p.join(documents.path, FreshInstallGuard.databaseFileName))
        .writeAsString("db");

    expect(await guard.run(), isFalse);
    expect(clearCalls, 0);
    expect(
      await File(p.join(documents.path, FreshInstallGuard.markerFileName))
          .exists(),
      isTrue,
    );
  });
}
