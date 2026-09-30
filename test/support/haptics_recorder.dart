import 'package:fitness/common/app_haptics.dart';

/// A tesztek alatt a rezgés nem a platformra megy, hanem ide gyűlik.
class HapticsRecorder {
  final List<HapticKind> played = [];
  late HapticDriver _original;

  void install() {
    _original = AppHaptics.driver;
    AppHaptics.driver = (kind) async => played.add(kind);
    AppHaptics.skipDelays = true;
  }

  void uninstall() {
    AppHaptics.driver = _original;
    AppHaptics.skipDelays = false;
  }
}
