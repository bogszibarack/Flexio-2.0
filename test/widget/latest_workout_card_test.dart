import 'package:fitness/common_widget/latest_workout_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';

import '../support/haptics_recorder.dart';

void main() {
  final haptics = HapticsRecorder();
  setUpAll(() => initializeDateFormatting("hu"));
  setUp(haptics.install);
  tearDown(haptics.uninstall);

  final entry = <String, dynamic>{
    "title": "Felsőtest",
    "image": "assets/img/Workout1.png",
    "date": DateTime(2026, 9, 30, 17, 30),
    "minutes": 48,
    "calories": 320,
    "volume": 1950.0,
    "completedSets": 5,
    "totalSets": 6,
    "exerciseList": [
      {
        "name": "Fekvenyomás",
        "repetitions": 10,
        "rounds": 3,
        "weight": 60,
        "roundWeights": [60, 65, 70],
      },
      {"name": "Fekvőtámasz", "repetitions": 15, "rounds": 2, "weight": 0},
    ],
  };

  Future<void> pump(WidgetTester tester) => tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: SingleChildScrollView(child: LatestWorkoutCard(entry: entry)),
        ),
      ));

  testWidgets("zárva az összefoglalót mutatja", (tester) async {
    await pump(tester);

    expect(find.text("Felsőtest"), findsOneWidget);
    expect(find.text("5/6 kör teljesítve"), findsOneWidget);
    expect(find.textContaining("48 perc"), findsOneWidget);
    expect(find.text("Fekvenyomás"), findsNothing);
  });

  testWidgets("koppintásra lenyílik: gyakorlatok, körök, súlyok",
      (tester) async {
    await pump(tester);
    await tester.tap(find.text("Felsőtest"));
    await tester.pumpAndSettle();

    expect(find.text("Fekvenyomás"), findsOneWidget);
    expect(find.text("60 kg × 10"), findsOneWidget);
    expect(find.text("65 kg × 10"), findsOneWidget);
    expect(find.text("70 kg × 10"), findsOneWidget);
    // Saját testsúlyos gyakorlatnál nincs „0 kg”.
    expect(find.text("15 ismétlés"), findsNWidgets(2));
    expect(find.text("0 kg × 15"), findsNothing);
    expect(find.text("Megmozgatott súly: 1950 kg"), findsOneWidget);
    expect(find.text("Részletek"), findsOneWidget);
    expect(haptics.played, isNotEmpty);

    await tester.tap(find.text("Felsőtest"));
    await tester.pumpAndSettle();
    expect(find.text("Fekvenyomás"), findsNothing);
  });
}
