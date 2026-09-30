import 'package:flutter/services.dart';

/// A tapintás egy lépése: milyen erős, és mennyit várunk előtte.
enum HapticKind { selection, light, medium, heavy }

class HapticPulse {
  final HapticKind kind;
  final Duration delayBefore;

  const HapticPulse(this.kind, [this.delayBefore = Duration.zero]);

  @override
  bool operator ==(Object other) =>
      other is HapticPulse &&
      other.kind == kind &&
      other.delayBefore == delayBefore;

  @override
  int get hashCode => Object.hash(kind, delayBefore);

  @override
  String toString() => "HapticPulse($kind, ${delayBefore.inMilliseconds}ms)";
}

/// A tényleges rezgés. Tesztben lecserélhető egy rögzítőre.
typedef HapticDriver = Future<void> Function(HapticKind kind);

Future<void> _platformDriver(HapticKind kind) {
  switch (kind) {
    case HapticKind.selection:
      return HapticFeedback.selectionClick();
    case HapticKind.light:
      return HapticFeedback.lightImpact();
    case HapticKind.medium:
      return HapticFeedback.mediumImpact();
    case HapticKind.heavy:
      return HapticFeedback.heavyImpact();
  }
}

/// Egységes tapintás az appban. Az egyszerű koppintások mellett mintázatok is
/// vannak, hogy a művelet „érződjön”: a víz tölt, a befejezett edzés ünnepel,
/// a hiba kétszer koppan.
class AppHaptics {
  AppHaptics._();

  static HapticDriver driver = _platformDriver;

  /// Tesztekhez: a késleltetések kihagyása.
  static bool skipDelays = false;

  static Future<void> selection() => driver(HapticKind.selection);

  static Future<void> light() => driver(HapticKind.light);

  static Future<void> medium() => driver(HapticKind.medium);

  static Future<void> heavy() => driver(HapticKind.heavy);

  /// Sikeres mentés, naplózás.
  static Future<void> success() => play(Patterns.success);

  /// Hiba vagy nem engedélyezett művelet.
  static Future<void> warning() => play(Patterns.warning);

  /// Törlés: egy határozott, tompa koppanás.
  static Future<void> delete() => heavy();

  /// Vízhozzáadás: a pohár „megtelik”.
  static Future<void> waterFill(int ml) => play(Patterns.waterFill(ml));

  /// Kör teljesítve: rövid, határozott pipa.
  static Future<void> roundDone() => medium();

  /// Egy gyakorlat összes köre kész.
  static Future<void> exerciseDone() => play(Patterns.exerciseDone);

  static Future<void> workoutStart() => play(Patterns.workoutStart);

  static Future<void> workoutFinish() => play(Patterns.celebration);

  /// Sikeres vonalkód-olvasás.
  static Future<void> scanned() => play(Patterns.scanned);

  static Future<void> play(List<HapticPulse> pattern) async {
    for (final pulse in pattern) {
      if (!skipDelays && pulse.delayBefore > Duration.zero) {
        await Future<void>.delayed(pulse.delayBefore);
      }
      await driver(pulse.kind);
    }
  }
}

/// A mintázatok külön, hogy tesztelhetők legyenek lejátszás nélkül.
class Patterns {
  Patterns._();

  static const List<HapticPulse> success = [
    HapticPulse(HapticKind.medium),
    HapticPulse(HapticKind.light, Duration(milliseconds: 90)),
  ];

  static const List<HapticPulse> warning = [
    HapticPulse(HapticKind.heavy),
    HapticPulse(HapticKind.heavy, Duration(milliseconds: 120)),
  ];

  static const List<HapticPulse> exerciseDone = [
    HapticPulse(HapticKind.medium),
    HapticPulse(HapticKind.medium, Duration(milliseconds: 80)),
    HapticPulse(HapticKind.heavy, Duration(milliseconds: 80)),
  ];

  static const List<HapticPulse> workoutStart = [
    HapticPulse(HapticKind.light),
    HapticPulse(HapticKind.medium, Duration(milliseconds: 110)),
    HapticPulse(HapticKind.heavy, Duration(milliseconds: 110)),
  ];

  static const List<HapticPulse> celebration = [
    HapticPulse(HapticKind.heavy),
    HapticPulse(HapticKind.light, Duration(milliseconds: 70)),
    HapticPulse(HapticKind.light, Duration(milliseconds: 70)),
    HapticPulse(HapticKind.medium, Duration(milliseconds: 70)),
    HapticPulse(HapticKind.heavy, Duration(milliseconds: 140)),
  ];

  static const List<HapticPulse> scanned = [
    HapticPulse(HapticKind.light),
    HapticPulse(HapticKind.medium, Duration(milliseconds: 60)),
  ];

  /// Töltődő pohár: minden ~50 ml egy csepp. A cseppek egyre sűrűbbek és
  /// erősebbek (ahogy a víz szintje emelkedik), a végén egy „teli” koppanás.
  static List<HapticPulse> waterFill(int ml) {
    final drops = (ml / 50).round().clamp(3, 10);
    final pulses = <HapticPulse>[];
    for (var index = 0; index < drops; index++) {
      final progress = drops == 1 ? 1.0 : index / (drops - 1);
      final gap = Duration(milliseconds: (110 - 70 * progress).round());
      final kind = progress < 0.5
          ? HapticKind.selection
          : (progress < 0.85 ? HapticKind.light : HapticKind.medium);
      pulses.add(HapticPulse(kind, index == 0 ? Duration.zero : gap));
    }
    pulses.add(const HapticPulse(HapticKind.heavy, Duration(milliseconds: 90)));
    return pulses;
  }
}
