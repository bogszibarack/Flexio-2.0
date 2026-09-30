import 'package:fitness/common/app_haptics.dart';
import 'package:fitness/common_widget/app_snackbar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late List<HapticKind> played;
  late HapticDriver originalDriver;

  setUp(() {
    played = [];
    originalDriver = AppHaptics.driver;
    AppHaptics.driver = (kind) async => played.add(kind);
    AppHaptics.skipDelays = true;
  });

  tearDown(() {
    AppHaptics.driver = originalDriver;
    AppHaptics.skipDelays = false;
  });

  group("Vízhozzáadás: töltődő pohár", () {
    test("a cseppek száma a mennyiséggel nő, 3 és 10 között marad", () {
      int drops(int ml) => Patterns.waterFill(ml).length - 1;

      expect(drops(50), 3);
      expect(drops(250), 5);
      expect(drops(500), 10);
      expect(drops(2000), 10);
      expect(drops(250), lessThan(drops(400)));
    });

    test("a cseppek egyre sűrűbbek", () {
      final gaps = Patterns.waterFill(500)
          .skip(1)
          .take(9)
          .map((pulse) => pulse.delayBefore)
          .toList();
      for (var index = 1; index < gaps.length; index++) {
        expect(gaps[index], lessThanOrEqualTo(gaps[index - 1]));
      }
      expect(gaps.last, lessThan(gaps.first));
    });

    test("az erősség emelkedik, a vége egy teli koppanás", () {
      final pattern = Patterns.waterFill(500);
      final strengths = pattern.map((pulse) => pulse.kind.index).toList();
      for (var index = 1; index < strengths.length; index++) {
        expect(strengths[index], greaterThanOrEqualTo(strengths[index - 1]));
      }
      expect(pattern.first.kind, HapticKind.selection);
      expect(pattern.last.kind, HapticKind.heavy);
    });

    test("lejátszáskor a teljes mintázat a meghajtóra kerül", () async {
      await AppHaptics.waterFill(250);
      expect(played,
          Patterns.waterFill(250).map((pulse) => pulse.kind).toList());
    });
  });

  group("Edzés mintázatok", () {
    test("a befejezés ünnepel, erősebb, mint egy kör", () async {
      await AppHaptics.workoutFinish();
      expect(played.length, greaterThanOrEqualTo(4));
      expect(played.last, HapticKind.heavy);

      played.clear();
      await AppHaptics.roundDone();
      expect(played, [HapticKind.medium]);
    });

    test("a figyelmeztetés kétszer koppan", () async {
      await AppHaptics.warning();
      expect(played, [HapticKind.heavy, HapticKind.heavy]);
    });
  });

  group("Snackbar tapintás az üzenet jellegéhez igazodik", () {
    Future<List<HapticKind>> hapticOf(IconData icon) async {
      played.clear();
      await hapticForSnack(icon)();
      return List.of(played);
    }

    test("hiba és zárolt művelet: figyelmeztetés", () async {
      expect(await hapticOf(Icons.error_outline), Patterns.warning.map((p) => p.kind));
      expect(await hapticOf(Icons.lock_outline), Patterns.warning.map((p) => p.kind));
    });

    test("törlés: egy tompa koppanás", () async {
      expect(await hapticOf(Icons.delete_outline), [HapticKind.heavy]);
    });

    test("tájékoztatás: finom jelzés", () async {
      expect(await hapticOf(Icons.info_outline), [HapticKind.light]);
    });

    test("siker: pipa-mintázat", () async {
      expect(await hapticOf(Icons.check_circle_outline),
          Patterns.success.map((p) => p.kind));
    });
  });
}
