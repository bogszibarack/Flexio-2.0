import 'package:fitness/common_widget/tab_button.dart';
import 'package:fitness/view/main_tab/main_tab_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';

import '../support/haptics_recorder.dart';

void main() {
  final haptics = HapticsRecorder();
  setUp(haptics.install);
  tearDown(haptics.uninstall);

  test("az alsó sáv 5 fül: edzés, étrend és alvás is saját helyet kap", () {
    expect(MainTab.values.map((tab) => tab.label),
        ["Főoldal", "Edzés", "Étrend", "Alvás", "Fotók"]);
  });

  test("egységes ikoncsalád: minden fülnek saját, egyedi ikonja van", () {
    final icons = MainTab.values.map((tab) => tab.icon).toSet();
    final active = MainTab.values.map((tab) => tab.activeIcon).toSet();
    expect(icons, hasLength(MainTab.values.length));
    expect(active, hasLength(MainTab.values.length));
    for (final tab in MainTab.values) {
      expect(tab.icon.fontFamily, "MaterialIcons");
      expect(tab.activeIcon.fontFamily, "MaterialIcons");
    }
    // A funkció nélküli nagyító gomb nem kerülhet vissza.
    expect(icons.contains(Icons.search), isFalse);
  });

  testWidgets("a fül koppintásra vált, rezgéssel, a felirat látszik",
      (tester) async {
    var selected = MainTab.home;
    await tester.pumpWidget(MaterialApp(
      home: StatefulBuilder(
        builder: (context, setState) => Scaffold(
          bottomNavigationBar: Row(children: [
            for (final tab in MainTab.values)
              Expanded(
                child: TabButton(
                  icon: tab.icon,
                  activeIcon: tab.activeIcon,
                  label: tab.label,
                  isActive: tab == selected,
                  onTap: () => setState(() => selected = tab),
                ),
              ),
          ]),
        ),
      ),
    ));

    for (final tab in MainTab.values) {
      expect(find.text(tab.label), findsOneWidget);
    }
    expect(find.byIcon(Icons.search), findsNothing);

    await tester.tap(find.text("Alvás"));
    await tester.pumpAndSettle();
    expect(selected, MainTab.sleep);
    expect(find.byIcon(Icons.bedtime_rounded), findsOneWidget);
    expect(haptics.played, isNotEmpty);

    // Az aktív fülre újra koppintva nincs felesleges rezgés.
    haptics.played.clear();
    await tester.tap(find.text("Alvás"));
    await tester.pump();
    expect(haptics.played, isEmpty);
  });

  testWidgets(
      "a szinkron-jelzés a szinkron végén ténylegesen eltűnik, nem fagy be",
      (tester) async {
    Widget indicator(bool visible) => MaterialApp(
          home: Scaffold(
              body: Stack(children: [SyncIndicator(visible: visible)])),
        );
    double renderedOpacity() => tester
        .renderObject<RenderAnimatedOpacity>(find.byType(AnimatedOpacity))
        .opacity
        .value;

    await tester.pumpWidget(indicator(true));
    await tester.pump(const Duration(milliseconds: 300));
    expect(renderedOpacity(), 1);
    // Szinkron közben a karika pörög.
    expect(tester.hasRunningAnimations, isTrue);

    // A szinkron véget ér: a ténylegesen kirajzolt átlátszóság 0-ra megy.
    await tester.pumpWidget(indicator(false));
    await tester.pumpAndSettle();
    expect(renderedOpacity(), 0);
    expect(tester.hasRunningAnimations, isFalse);
  });
}
