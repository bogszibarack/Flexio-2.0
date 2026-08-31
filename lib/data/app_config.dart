/// Futásidejű konfiguráció. A Supabase kulcsokat build időben adjuk át:
///
/// flutter run --dart-define=SUPABASE_URL=https://xxx.supabase.co \
///             --dart-define=SUPABASE_PUBLISHABLE_KEY=sb_publishable_...
///
/// Ha nincs megadva, az app helyi módban indul: minden adat a készüléken
/// marad, a keresés a beépített magyar katalógusból megy.
class AppConfig {
  AppConfig._();

  static const String supabaseUrl = String.fromEnvironment("SUPABASE_URL");

  /// A régi `SUPABASE_ANON_KEY` név is működik, hogy a meglévő build-szkriptek
  /// ne törjenek el.
  static const String supabasePublishableKey =
      String.fromEnvironment("SUPABASE_PUBLISHABLE_KEY");

  static const String _legacyAnonKey =
      String.fromEnvironment("SUPABASE_ANON_KEY");

  static String get supabaseKey => supabasePublishableKey.isNotEmpty
      ? supabasePublishableKey
      : _legacyAnonKey;

  /// Az Open Food Facts kéri, hogy azonosítsuk magunkat a hívásokban.
  static const String offUserAgent =
      "Flexio/1.0 (Flutter; kapcsolat: hello@flexio.app)";

  static const String offBaseUrl = "https://world.openfoodfacts.org";

  static bool get hasRemote => supabaseUrl.isNotEmpty && supabaseKey.isNotEmpty;

  /// Saját C# API gyökér URL. Ha meg van adva, a sync / keresés / coach a
  /// FlexioApiGateway-en megy; egyébként a Supabase közvetlen út marad.
  /// flutter run --dart-define=API_BASE_URL=https://api.example.com
  static const String apiBaseUrl = String.fromEnvironment("API_BASE_URL");

  static bool get hasOwnApi => apiBaseUrl.isNotEmpty;

  /// Saját coach API. Üresen a kliens csak a helyi szabályszöveget mutatja.
  /// Ha [apiBaseUrl] be van állítva és ez üres, a coach is az API_BASE_URL-t
  /// használja (`/api/v1/coach`).
  /// flutter run --dart-define=COACH_API_URL=https://api.example.com
  /// A kliens a `/api/v1/coach` végpontra hív (JWT-vel). A régi `/coach`
  /// útvonal is működik, ha a URL azzal végződik.
  static const String coachApiUrl = String.fromEnvironment("COACH_API_URL");

  static String get effectiveCoachApiUrl =>
      coachApiUrl.isNotEmpty ? coachApiUrl : apiBaseUrl;

  /// Supabase e-mail megerősítés / jelszó-visszaállítás deep link.
  /// Ugyanezt add hozzá a Supabase Dashboard → Auth → URL Configuration
  /// → Redirect URLs listához is.
  static const String authRedirectUrl =
      "com.codeforany.fitness://login-callback/";
}
