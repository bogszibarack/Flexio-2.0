import 'package:fitness/view/meal_planner/barcode_scan_view.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test("az első érvényes kódot veszi át, és lefoglalja a zárat", () {
    final gate = BarcodeScanGate();
    expect(gate.accept([null, "123", " 5998200210014 "]), "5998200210014");
    expect(gate.isBusy, isTrue);
  });

  test("feldolgozás közben a kamera ismételt észlelései elvesznek", () {
    final gate = BarcodeScanGate();
    gate.accept(["5998200210014"]);

    // A kamera másodpercenként többször is látja ugyanazt a kódot, amíg a
    // kézi felviteli oldal nyitva van. Korábban mindegyik új oldalt nyitott.
    for (var index = 0; index < 20; index++) {
      expect(gate.accept(["5998200210014"]), isNull);
    }
  });

  test("felszabadítás után újra lehet olvasni", () {
    final gate = BarcodeScanGate();
    gate.accept(["5998200210014"]);
    gate.release();
    expect(gate.accept(["4006381333931"]), "4006381333931");
  });

  test("túl rövid vagy üres kód nem foglalja le a zárat", () {
    final gate = BarcodeScanGate();
    expect(gate.accept(["1234567", "", null]), isNull);
    expect(gate.isBusy, isFalse);
  });
}
