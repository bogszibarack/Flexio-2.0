import 'dart:io';

import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

/// Friss telepítés felismerése.
///
/// iOS-en a Keychain túléli az app törlését, a dokumentumkönyvtár nem. A
/// Supabase session a Keychainben van, ezért újratelepítés után az app régi
/// tokennel, de üres helyi adatbázissal indulna: félig belépett állapot,
/// alapértelmezett (kitalált) adatokkal. Friss telepítésnél ezért a régi
/// sessiont eldobjuk, és a felhasználó tisztán, a belépéssel indul.
class FreshInstallGuard {
  FreshInstallGuard({
    required Future<Directory> Function() documentsDirectory,
    required Future<void> Function() clearPersistedSession,
  })  : _documentsDirectory = documentsDirectory,
        _clearPersistedSession = clearPersistedSession;

  /// Az éles app beállítása: a dokumentumkönyvtárban lévő jelzőfájl.
  factory FreshInstallGuard.standard({
    required Future<void> Function() clearPersistedSession,
  }) =>
      FreshInstallGuard(
        documentsDirectory: getApplicationDocumentsDirectory,
        clearPersistedSession: clearPersistedSession,
      );

  static const String markerFileName = ".flexio_install";

  /// A helyi adatbázis fájlneve (lásd `app_database.dart`). Ha ez már létezik,
  /// a telepítés nem friss, csak a jelzőfájl hiányzik egy régebbi verzióból.
  static const String databaseFileName = "flexio.sqlite";

  final Future<Directory> Function() _documentsDirectory;
  final Future<void> Function() _clearPersistedSession;

  /// `true`, ha friss telepítés volt, és a régi session törlődött.
  Future<bool> run() async {
    final directory = await _documentsDirectory();
    final marker = File(p.join(directory.path, markerFileName));
    if (await marker.exists()) {
      return false;
    }

    final hasExistingData =
        await File(p.join(directory.path, databaseFileName)).exists();
    if (!hasExistingData) {
      await _clearPersistedSession();
    }

    await marker.create(recursive: true);
    return !hasExistingData;
  }
}
