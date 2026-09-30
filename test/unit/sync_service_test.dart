import 'dart:async';

import 'package:fitness/data/sync_service.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group("SyncStepRunner", () {
    test("egy lépés hibája után a többi lépés is lefut", () async {
      final runner = SyncStepRunner();
      final executed = <String>[];

      await runner.run("push", () async {
        executed.add("push");
        throw const SyncStepException("hálózati hiba");
      });
      await runner.run("pull:workouts", () async => executed.add("pull"));
      await runner.run("pull:photos", () async => executed.add("photos"));

      expect(executed, ["push", "pull", "photos"]);
      expect(runner.failedSteps, ["push"]);
      expect(runner.hasFailures, isTrue);
    });

    test("beragadt lépés időtúllépéssel hibára fut, a kör nem akad el",
        () async {
      final runner =
          SyncStepRunner(stepTimeout: const Duration(milliseconds: 50));
      final executed = <String>[];

      await runner.run("pull:photos", () => Completer<void>().future);
      await runner.run("pull:water", () async => executed.add("water"));

      expect(runner.failedSteps, ["pull:photos"]);
      expect(executed, ["water"]);
    });

    test("sikeres lépés az eredményét adja vissza", () async {
      final runner = SyncStepRunner();
      expect(await runner.run("x", () async => 42), 42);
      expect(runner.hasFailures, isFalse);
    });
  });

  group("újraszinkron előtérbe kerüléskor", () {
    final now = DateTime(2026, 9, 30, 12);

    test("futó kör alatt nem indul új", () {
      expect(
        shouldResyncOnResume(
            const SyncStatus(phase: SyncPhase.running), now),
        isFalse,
      );
    });

    test("elbukott kör után azonnal újrapróbálja (pl. alvó szerver)", () {
      expect(
        shouldResyncOnResume(
          SyncStatus(
            phase: SyncPhase.failed,
            lastSuccessAt: now.subtract(const Duration(minutes: 1)),
          ),
          now,
        ),
        isTrue,
      );
    });

    test("friss sikeres kör után nem terheli a szervert", () {
      expect(
        shouldResyncOnResume(
          SyncStatus(
            phase: SyncPhase.succeeded,
            lastSuccessAt: now.subtract(const Duration(minutes: 5)),
          ),
          now,
        ),
        isFalse,
      );
    });

    test("30 percnél régebbi adat esetén frissít", () {
      expect(
        shouldResyncOnResume(
          SyncStatus(
            phase: SyncPhase.succeeded,
            lastSuccessAt: now.subtract(const Duration(minutes: 31)),
          ),
          now,
        ),
        isTrue,
      );
    });

    test("ha még sosem volt sikeres kör, szinkronizál", () {
      expect(shouldResyncOnResume(const SyncStatus(), now), isTrue);
    });
  });
}
