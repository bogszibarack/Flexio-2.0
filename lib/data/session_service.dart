import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uuid/uuid.dart';

import 'app_config.dart';
import 'local/app_database.dart';
import 'remote/supabase_gateway.dart';

class AuthOutcome {
  final bool success;
  final String? message;

  const AuthOutcome.ok([this.message]) : success = true;
  const AuthOutcome.error(this.message) : success = false;
}

/// A Supabase session titkosított tárolása. A hozzáférési token nem kerül a
/// sima beállítások közé.
class SecureSessionStorage extends LocalStorage {
  SecureSessionStorage({FlutterSecureStorage? storage})
      : _storage = storage ??
            const FlutterSecureStorage(
              aOptions: AndroidOptions(),
              iOptions: IOSOptions(
                accessibility: KeychainAccessibility.first_unlock_this_device,
              ),
            );

  static const String _key = "flexio.supabase.session";

  final FlutterSecureStorage _storage;

  @override
  Future<void> initialize() async {}

  @override
  Future<String?> accessToken() => _storage.read(key: _key);

  @override
  Future<bool> hasAccessToken() async =>
      (await _storage.read(key: _key)) != null;

  @override
  Future<void> persistSession(String persistSessionString) =>
      _storage.write(key: _key, value: persistSessionString);

  @override
  Future<void> removePersistedSession() => _storage.delete(key: _key);
}

/// Bejelentkezés és aktuális felhasználó. Ha nincs backend konfigurálva, a
/// felhasználó egy készülékhez kötött helyi azonosítót kap, így az app
/// önmagában is működik.
class SessionService extends ChangeNotifier {
  SessionService({required AppDatabase database, required SupabaseGateway gateway})
      : _database = database,
        _gateway = gateway;

  static const String _localUserKey = "local_user_id";
  static const String _localNameKey = "local_first_name";
  static const String _onboardingKey = "onboarding_done";
  static const String _sessionKey = "session_active";

  final AppDatabase _database;
  final SupabaseGateway _gateway;
  final Uuid _uuid = const Uuid();

  String? _userId;
  String? _email;
  String? _firstName;
  bool _ready = false;
  bool _onboarded = false;
  bool _sessionActive = false;

  bool get usesRemote => AppConfig.hasRemote;
  bool get isReady => _ready;
  bool get isAuthenticated => _userId != null;
  bool get hasOnboarded => _onboarded;

  /// Bejelentkező képernyő csak kijelentkezés után — friss telepítésnél az
  /// onboarding jön előbb, nem a login.
  bool get shouldShowLoginScreen => _onboarded && !_sessionActive;
  String? get userId => _userId;
  String? get email => _email;
  String? get firstName => _firstName;

  /// Van-e aktív belépés. Kijelentkezés után a helyi adatok megmaradnak, de
  /// a főoldal helyett a belépő képernyő jön.
  bool get isSignedIn {
    if (!_sessionActive) {
      return false;
    }
    if (usesRemote) {
      return _userId != null;
    }
    return _userId != null && _onboarded;
  }

  Future<void> completeOnboarding({String? firstName}) async {
    _onboarded = true;
    _sessionActive = true;
    await _database.setMeta(_onboardingKey, "true");
    await _database.setMeta(_sessionKey, "true");
    if (firstName != null && firstName.trim().isNotEmpty) {
      await _saveLocalName(firstName);
    }
    if (_userId == null && !usesRemote) {
      _userId = await _ensureLocalUser();
    }
    notifyListeners();
  }

  Future<void> bootstrap() async {
    _onboarded = (await _database.metaValue(_onboardingKey)) == "true";
    _sessionActive = (await _database.metaValue(_sessionKey)) != "false";

    if (usesRemote) {
      final client = Supabase.instance.client;
      _applySession(client.auth.currentSession);
      client.auth.onAuthStateChange.listen((state) {
        _applySession(state.session);
      });
    } else {
      _userId = await _ensureLocalUser();
      _firstName = await _database.metaValue(_localNameKey);
    }

    _ready = true;
    notifyListeners();
  }

  Future<String> _ensureLocalUser() async {
    final existing = await _database.metaValue(_localUserKey);
    if (existing != null && existing.isNotEmpty) {
      return existing;
    }
    final generated = _uuid.v4();
    await _database.setMeta(_localUserKey, generated);
    return generated;
  }

  void _applySession(Session? session) {
    final user = session?.user;
    _userId = user?.id;
    _email = user?.email;
    _firstName = user?.userMetadata?["first_name"] as String?;
    if (user != null) {
      _sessionActive = true;
    }
    notifyListeners();
  }

  Future<AuthOutcome> signUp({
    required String email,
    required String password,
    String? firstName,
  }) async {
    if (!usesRemote) {
      await _saveLocalName(firstName);
      await _activateLocalSession();
      notifyListeners();
      return const AuthOutcome.ok();
    }

    try {
      final response = await Supabase.instance.client.auth.signUp(
        email: email.trim(),
        password: password,
        data: {"first_name": firstName?.trim()},
        emailRedirectTo: AppConfig.authRedirectUrl,
      );

      if (response.session == null) {
        return const AuthOutcome.ok(
          "Elküldtünk egy megerősítő e-mailt. Kattints a linkre, majd jelentkezz be.",
        );
      }
      _applySession(response.session);
      return const AuthOutcome.ok();
    } on AuthException catch (error) {
      return AuthOutcome.error(_translate(error));
    } on Object {
      return const AuthOutcome.error(
          "Nem sikerült a regisztráció. Ellenőrizd az internetkapcsolatot.");
    }
  }

  Future<AuthOutcome> signIn({
    required String email,
    required String password,
  }) async {
    if (!usesRemote) {
      await _activateLocalSession();
      notifyListeners();
      return const AuthOutcome.ok();
    }

    try {
      await Supabase.instance.client.auth.signInWithPassword(
        email: email.trim(),
        password: password,
      );
      _applySession(Supabase.instance.client.auth.currentSession);
      return const AuthOutcome.ok();
    } on AuthException catch (error) {
      return AuthOutcome.error(_translate(error));
    } on Object {
      return const AuthOutcome.error(
          "Nem sikerült a belépés. Ellenőrizd az internetkapcsolatot.");
    }
  }

  Future<AuthOutcome> sendPasswordReset(String email) async {
    if (!usesRemote) {
      return const AuthOutcome.error(
          "Helyi módban nincs jelszó, az adatok a készüléken maradnak.");
    }

    try {
      await Supabase.instance.client.auth.resetPasswordForEmail(
        email.trim(),
        redirectTo: AppConfig.authRedirectUrl,
      );
      return const AuthOutcome.ok(
          "Elküldtük a jelszó-visszaállító levelet.");
    } on AuthException catch (error) {
      return AuthOutcome.error(_translate(error));
    } on Object {
      return const AuthOutcome.error("Nem sikerült elküldeni a levelet.");
    }
  }

  Future<void> signOut({bool wipeLocalData = false}) async {
    final current = _userId;
    if (wipeLocalData && current != null) {
      await _database.wipeUserData(current);
    }

    if (usesRemote) {
      try {
        await Supabase.instance.client.auth.signOut();
      } on Object {
        // Offline kilépésnél a helyi session törlése is elég.
      }
    }

    _userId = null;
    _email = null;
    _sessionActive = false;
    await _database.setMeta(_sessionKey, "false");
    notifyListeners();
  }

  Future<void> _activateLocalSession() async {
    _userId = await _ensureLocalUser();
    _sessionActive = true;
    await _database.setMeta(_sessionKey, "true");
  }

  Future<bool> deleteAccount() async {
    final current = _userId;
    if (current != null) {
      await _database.wipeUserData(current);
    }

    if (!usesRemote) {
      await _database.setMeta(_localUserKey, "");
      await _database.setMeta(_sessionKey, "false");
      _userId = null;
      _sessionActive = false;
      notifyListeners();
      return true;
    }

    final deleted = await _gateway.deleteAccount();
    if (deleted) {
      _userId = null;
      _email = null;
      _sessionActive = false;
      await _database.setMeta(_sessionKey, "false");
      notifyListeners();
    }
    return deleted;
  }

  Future<void> _saveLocalName(String? firstName) async {
    final value = firstName?.trim() ?? "";
    if (value.isEmpty) {
      return;
    }
    await _database.setMeta(_localNameKey, value);
    _firstName = value;
  }

  String _translate(AuthException error) {
    final message = error.message.toLowerCase();
    if (message.contains("invalid login credentials")) {
      return "Hibás e-mail cím vagy jelszó.";
    }
    if (message.contains("already registered") ||
        message.contains("already been registered")) {
      return "Ezzel az e-mail címmel már létezik fiók.";
    }
    if (message.contains("password should be at least")) {
      return "A jelszó legyen legalább 6 karakter.";
    }
    if (message.contains("email not confirmed")) {
      return "Előbb erősítsd meg az e-mail címedet.";
    }
    if (message.contains("unable to validate email")) {
      return "Érvénytelen e-mail cím.";
    }
    if (message.contains("rate limit") || message.contains("too many")) {
      return "Túl sok próbálkozás. Várj egy kicsit, és próbáld újra.";
    }
    return "Sikertelen művelet: ${error.message}";
  }
}
