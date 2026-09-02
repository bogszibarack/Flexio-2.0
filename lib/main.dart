import 'package:fitness/view/on_boarding/started_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'common/colo_extension.dart';
import 'data/app_config.dart';
import 'data/providers.dart';
import 'data/session_service.dart';
import 'view/login/login_view.dart';
import 'view/main_tab/main_tab_view.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting("hu");

  if (AppConfig.hasRemote) {
    await Supabase.initialize(
      url: AppConfig.supabaseUrl,
      publishableKey: AppConfig.supabaseKey,
      authOptions: FlutterAuthClientOptions(
        localStorage: SecureSessionStorage(),
        authFlowType: AuthFlowType.pkce,
        detectSessionInUri: true,
      ),
    );
  }

  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flexio',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
          primaryColor: TColor.primaryColor1,
          fontFamily: "Poppins"),
      locale: const Locale("hu"),
      supportedLocales: const [Locale("hu"), Locale("en")],
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      home: const SessionGate(),
    );
  }
}

/// Belépési pont: van-e érvényes session. Ha igen, egyenesen a főoldal jön, ha
/// nincs, az onboarding.
class SessionGate extends ConsumerStatefulWidget {
  const SessionGate({super.key});

  @override
  ConsumerState<SessionGate> createState() => _SessionGateState();
}

class _SessionGateState extends ConsumerState<SessionGate> {
  @override
  void initState() {
    super.initState();
    _bootstrap();
  }

  Future<void> _bootstrap() async {
    final session = ref.read(sessionServiceProvider);
    await session.bootstrap();

    // A magyar katalógus betöltése a háttérben, hogy az első keresés is gyors
    // legyen.
    ref.read(foodRepositoryProvider).warmUp();

    final userId = session.userId;
    if (userId != null) {
      await ref.read(userScopeProvider).attachAndSync(
        userId,
        onAfterSync: () async {
          await ref.read(dailyWaterProvider).reload();
          await ref.read(profileControllerProvider).load();
        },
      );
      ref.read(notificationServiceProvider).scheduleSoon();
    }
  }

  @override
  Widget build(BuildContext context) {
    ref.watch(healthSyncProvider);
    ref.watch(notificationServiceProvider);
    ref.watch(coachSettingsProvider);
    final session = ref.watch(sessionServiceProvider);

    if (!session.isReady) {
      return Scaffold(
        backgroundColor: TColor.white,
        body: Center(
          child: CircularProgressIndicator(color: TColor.primaryColor1),
        ),
      );
    }

    if (session.isSignedIn) {
      return MainTabView(firstName: session.firstName ?? "");
    }

    if (session.shouldShowLoginScreen) {
      return const LoginView();
    }

    return const StartedView();
  }
}
