import 'package:fitness/common/colo_extension.dart';
import 'package:fitness/data/models/user_profile.dart';
import 'package:fitness/data/providers.dart';
import 'package:fitness/view/main_tab/main_tab_view.dart';
import 'package:fitness/view/meal_planner/meal_planner_view.dart';
import 'package:fitness/view/workout_tracker/workout_tracker_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/date_symbol_data_local.dart';

/// Csak README / marketing képernyőképekhez. Nem része a normál app indításnak.
///
/// flutter test integration_test/screenshot_test.dart -d "iPhone 16 Pro" \
///   --dart-define=SCREENSHOT_SCREEN=home
const String screenshotScreen = String.fromEnvironment(
  'SCREENSHOT_SCREEN',
  defaultValue: 'home',
);

class ScreenshotApp extends StatelessWidget {
  const ScreenshotApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flexio',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primaryColor: TColor.primaryColor1,
        fontFamily: 'Poppins',
      ),
      locale: const Locale('hu'),
      supportedLocales: const [Locale('hu'), Locale('en')],
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      home: const ScreenshotShell(),
    );
  }
}

class ScreenshotShell extends ConsumerStatefulWidget {
  const ScreenshotShell({super.key});

  @override
  ConsumerState<ScreenshotShell> createState() => _ScreenshotShellState();
}

class _ScreenshotShellState extends ConsumerState<ScreenshotShell> {
  bool _ready = false;

  @override
  void initState() {
    super.initState();
    _prepare();
  }

  Future<void> _prepare() async {
    final session = ref.read(sessionServiceProvider);
    await session.bootstrap();
    await session.completeOnboarding(firstName: 'Ádám');

    final userId = session.userId;
    if (userId != null) {
      await ref.read(profileControllerProvider).update(
            firstName: 'Ádám',
            gender: Gender.male,
            birthDate: DateTime(2000, 3, 15),
            heightCm: 178,
            weightKg: 75,
            activityLevel: ActivityLevel.moderate,
            goal: FitnessGoal.keepFit,
          );
    }

    await ref.read(foodRepositoryProvider).warmUp();

    if (mounted) {
      setState(() => _ready = true);
    }
  }

  Widget _screenFor(String name) {
    return switch (name) {
      'meals' => const MealPlannerView(),
      'workout' => const WorkoutTrackerView(),
      _ => const MainTabView(firstName: 'Ádám'),
    };
  }

  @override
  Widget build(BuildContext context) {
    if (!_ready) {
      return Scaffold(
        backgroundColor: TColor.white,
        body: Center(
          child: CircularProgressIndicator(color: TColor.primaryColor1),
        ),
      );
    }

    return _screenFor(screenshotScreen);
  }
}
