import 'package:fitness/common/colo_extension.dart';
import 'package:fitness/common_widget/tab_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/providers.dart';
import '../../data/sync_service.dart';
import '../home/home_view.dart';
import '../meal_planner/meal_planner_view.dart';
import '../photo_progress/photo_progress_view.dart';
import '../sleep_tracker/sleep_tracker_view.dart';
import '../workout_tracker/workout_tracker_view.dart';

/// Az alsó sáv fülei, a megjelenés sorrendjében.
enum MainTab {
  home(Icons.home_outlined, Icons.home_rounded, "Főoldal"),
  workout(Icons.fitness_center_outlined, Icons.fitness_center_rounded, "Edzés"),
  meals(Icons.restaurant_outlined, Icons.restaurant_rounded, "Étrend"),
  sleep(Icons.bedtime_outlined, Icons.bedtime_rounded, "Alvás"),
  photos(Icons.photo_library_outlined, Icons.photo_library_rounded, "Fotók");

  const MainTab(this.icon, this.activeIcon, this.label);

  final IconData icon;
  final IconData activeIcon;
  final String label;
}

/// A fül-váltás elérése a lapokból (pl. a főoldal alvás-kártyája az Alvás
/// fülre vált, nem nyit új oldalt).
class MainTabScope extends InheritedWidget {
  const MainTabScope({
    super.key,
    required this.current,
    required this.select,
    required super.child,
  });

  final MainTab current;
  final ValueChanged<MainTab> select;

  static MainTabScope? maybeOf(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<MainTabScope>();

  @override
  bool updateShouldNotify(MainTabScope oldWidget) =>
      current != oldWidget.current;
}

class MainTabView extends ConsumerStatefulWidget {
  final String? firstName;

  const MainTabView({super.key, this.firstName});

  @override
  ConsumerState<MainTabView> createState() => _MainTabViewState();
}

class _MainTabViewState extends ConsumerState<MainTabView> {
  MainTab _current = MainTab.home;

  /// A fülek első megnyitáskor épülnek fel, utána megtartják az állapotukat
  /// (görgetés, lenyitott kártyák), így a váltás nem tölt újra mindent.
  final Set<MainTab> _visited = {MainTab.home};

  String get _firstName => (widget.firstName ?? '').trim();

  void _select(MainTab tab) {
    if (tab == _current) {
      return;
    }
    setState(() {
      _current = tab;
      _visited.add(tab);
    });
  }

  Widget _buildTab(MainTab tab) {
    switch (tab) {
      case MainTab.home:
        return HomeView(firstName: _firstName);
      case MainTab.workout:
        return const WorkoutTrackerView(inTab: true);
      case MainTab.meals:
        return const MealPlannerView(inTab: true);
      case MainTab.sleep:
        return const SleepTrackerView(inTab: true);
      case MainTab.photos:
        return const PhotoProgressView();
    }
  }

  @override
  Widget build(BuildContext context) {
    final sync = ref.watch(syncServiceProvider);

    return MainTabScope(
      current: _current,
      select: _select,
      child: Scaffold(
        backgroundColor: TColor.white,
        body: Stack(
          children: [
            IndexedStack(
              index: _current.index,
              children: [
                for (final tab in MainTab.values)
                  _visited.contains(tab)
                      ? _buildTab(tab)
                      : const SizedBox.shrink(),
              ],
            ),
            ValueListenableBuilder<SyncStatus>(
              valueListenable: sync.status,
              builder: (context, status, _) =>
                  SyncIndicator(visible: status.isRunning),
            ),
          ],
        ),
        bottomNavigationBar: Container(
          decoration: BoxDecoration(color: TColor.white, boxShadow: const [
            BoxShadow(
                color: Colors.black12, blurRadius: 2, offset: Offset(0, -2))
          ]),
          child: SafeArea(
            top: false,
            child: SizedBox(
              height: 62,
              child: Row(
                children: [
                  for (final tab in MainTab.values)
                    Expanded(
                      child: TabButton(
                        icon: tab.icon,
                        activeIcon: tab.activeIcon,
                        label: tab.label,
                        isActive: _current == tab,
                        onTap: () => _select(tab),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Apró jelzés a képernyő tetején, amíg a szerverről töltődnek az adatok.
/// Enélkül friss belépés után úgy tűnt, mintha az adatok elvesztek volna.
class SyncIndicator extends StatelessWidget {
  const SyncIndicator({super.key, required this.visible});

  final bool visible;

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: MediaQuery.paddingOf(context).top + 6,
      left: 0,
      right: 0,
      child: IgnorePointer(
        // Rejtve a pörgő jelző ne animáljon tovább a háttérben.
        child: TickerMode(
          enabled: visible,
          child: AnimatedOpacity(
            opacity: visible ? 1 : 0,
            duration: const Duration(milliseconds: 250),
            child: Center(
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: TColor.black.withValues(alpha: 0.75),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SizedBox(
                      width: 12,
                      height: 12,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    ),
                    SizedBox(width: 8),
                    Text(
                      "Szinkronizálás…",
                      style: TextStyle(color: Colors.white, fontSize: 11),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
