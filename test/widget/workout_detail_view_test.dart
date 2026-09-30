import 'package:fitness/common/app_haptics.dart';
import 'package:fitness/view/workout_tracker/workour_detail_view.dart';
import 'package:fitness/view/workout_tracker/workout_store.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../support/haptics_recorder.dart';

Map<String, dynamic> _workout() => {
      "id": "w1",
      "title": "Lábnap",
      "image": "assets/img/Workout1.png",
      "difficulty": "Kezdő",
      "exercises": "1 gyakorlat",
      "exerciseList": [
        {
          "name": "Guggolás",
          "image": "assets/img/Workout1.png",
          "repetitions": 10,
          "rounds": 2,
          "weight": 40,
          "roundWeights": [40, 45],
        },
      ],
    };

void main() {
  final haptics = HapticsRecorder();

  setUp(haptics.install);
  tearDown(() {
    haptics.uninstall();
    WorkoutStore.unbind();
  });

  Future<Map<String, dynamic>> pumpDetail(WidgetTester tester) async {
    tester.view.physicalSize = const Size(1170, 2532);
    tester.view.devicePixelRatio = 3;
    addTearDown(tester.view.reset);

    final workout = _workout();
    await tester.pumpWidget(ProviderScope(
      child: MaterialApp(home: Scaffold(body: WorkoutDetailView(dObj: workout))),
    ));
    await tester.pumpAndSettle();
    return workout;
  }

  Future<void> expandExercise(WidgetTester tester) async {
    await tester.tap(find.text("Guggolás"));
    await tester.pumpAndSettle();
  }

  Future<void> startWorkout(WidgetTester tester) async {
    await tester.tap(find.text("Edzés indítása"));
    await tester.pump();
  }

  /// A tree lebontása, hogy a stopper Timer leálljon a teszt vége előtt.
  Future<void> dispose(WidgetTester tester) async {
    await tester.pumpWidget(const SizedBox());
    await tester.pump();
  }

  group("Körök pipálása", () {
    testWidgets("indítás előtt nem lehet teljesítettnek jelölni",
        (tester) async {
      await pumpDetail(tester);
      await expandExercise(tester);

      final checkbox = find.byType(Checkbox).first;
      expect(tester.widget<Checkbox>(checkbox).onChanged, isNull);

      await tester.tap(checkbox);
      await tester.pump();

      expect(tester.widget<Checkbox>(checkbox).value, isFalse);
      expect(find.textContaining("Előbb indítsd el az edzést"), findsOneWidget);
      expect(haptics.played, contains(HapticKind.heavy));
      await dispose(tester);
    });

    testWidgets("indítás után pipálható, a kör rezgéssel nyugtáz",
        (tester) async {
      await pumpDetail(tester);
      await expandExercise(tester);
      await startWorkout(tester);
      haptics.played.clear();

      await tester.tap(find.byType(Checkbox).first);
      await tester.pump();

      expect(tester.widget<Checkbox>(find.byType(Checkbox).first).value, isTrue);
      expect(haptics.played, [HapticKind.medium]);

      haptics.played.clear();
      await tester.tap(find.byType(Checkbox).last);
      await tester.pump();
      // Az utolsó kör az egész gyakorlatot lezárja: erősebb mintázat.
      expect(haptics.played, Patterns.exerciseDone.map((p) => p.kind));
      await dispose(tester);
    });
  });

  group("Súlymező", () {
    testWidgets(
        "gépelés közben a stopper frissülése sem veszi el a fókuszt",
        (tester) async {
      await pumpDetail(tester);
      await expandExercise(tester);
      await startWorkout(tester);

      final field = find.byType(TextField).first;
      await tester.tap(field);
      await tester.pump();

      // Karakterenként gépelünk, közben a stopper másodpercenként újraépít.
      for (final text in ["7", "72", "72"]) {
        tester.testTextInput.enterText(text);
        await tester.pump(const Duration(seconds: 1));
        final editable = tester.widget<EditableText>(
          find.descendant(of: field, matching: find.byType(EditableText)),
        );
        expect(editable.focusNode.hasFocus, isTrue,
            reason: "a mező elvesztette a fókuszt a(z) '$text' után");
      }
      expect(tester.testTextInput.isVisible, isTrue);
      await dispose(tester);
    });

    testWidgets("a mezőből kikattintva az érték mentődik", (tester) async {
      final workout = await pumpDetail(tester);
      await expandExercise(tester);

      await tester.tap(find.byType(TextField).last);
      await tester.pump();
      tester.testTextInput.enterText("50");
      await tester.pump();

      // Mellé koppintás: bezárul a billentyűzet, és a sablonba íródik.
      await tester.tapAt(const Offset(20, 400));
      await tester.pumpAndSettle();

      final saved = (workout["exerciseList"] as List).single as Map;
      expect(saved["roundWeights"], [40, 50]);
      expect(tester.testTextInput.isVisible, isFalse);
      await dispose(tester);
    });

    testWidgets("csak számjegy írható be", (tester) async {
      await pumpDetail(tester);
      await expandExercise(tester);

      await tester.enterText(find.byType(TextField).first, "8a7,-");
      await tester.pump();
      expect(find.text("87"), findsOneWidget);
      await dispose(tester);
    });
  });

  testWidgets("az edzés képe utólag cserélhető a katalógusból", (tester) async {
    final workout = await pumpDetail(tester);

    await tester.tap(find.text("Kép módosítása"));
    await tester.pumpAndSettle();
    expect(find.text("Edzés képe"), findsOneWidget);

    final options = find.descendant(
      of: find.byType(GridView),
      matching: find.byType(InkWell),
    );
    final chosen = tester
        .widget<Image>(find.descendant(
            of: options.at(1), matching: find.byType(Image)))
        .image as AssetImage;
    await tester.tap(options.at(1));
    await tester.pumpAndSettle();

    expect(workout["image"], chosen.assetName);
    expect(workout["image"], isNot("assets/img/Workout1.png"));
    await dispose(tester);
  });
}
