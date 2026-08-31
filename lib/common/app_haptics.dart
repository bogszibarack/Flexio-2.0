import 'package:flutter/services.dart';

/// Egységes tapintás az appban. A gombok, fülek és sikeres műveletek ettől
/// érződnek „élőnek”, nem csak kinéznek annak.
class AppHaptics {
  AppHaptics._();

  static Future<void> selection() => HapticFeedback.selectionClick();

  static Future<void> light() => HapticFeedback.lightImpact();

  static Future<void> medium() => HapticFeedback.mediumImpact();

  static Future<void> heavy() => HapticFeedback.heavyImpact();

  static Future<void> success() => HapticFeedback.mediumImpact();

  static Future<void> warning() => HapticFeedback.heavyImpact();
}
