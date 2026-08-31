import 'package:flutter/foundation.dart';

import '../../data/repositories/sleep_repository.dart';

/// Alvásnapló a felhasználóhoz kötve, ugyanazon a mintán, mint az edzés store.
/// A felület a statikus listát olvassa, az írás pedig a repository-n megy át.
class SleepStore {
  SleepStore._();

  static final List<SleepEntry> entries = <SleepEntry>[];

  static SleepRepository? _repository;
  static String? _userId;

  static final ValueNotifier<int> revision = ValueNotifier<int>(0);

  static void Function(SleepEntry entry)? onLogged;

  static bool get isBound => _repository != null && _userId != null;

  static Future<void> bind({
    required SleepRepository repository,
    required String userId,
  }) async {
    _repository = repository;
    _userId = userId;

    final loaded = await repository.load(userId);
    entries
      ..clear()
      ..addAll(loaded);
    _sort();
    _bump();
  }

  static void unbind() {
    _repository = null;
    _userId = null;
    entries.clear();
    _bump();
  }

  static void _sort() =>
      entries.sort((a, b) => a.wakeTime.compareTo(b.wakeTime));

  static void _bump() => revision.value++;

  static Future<SleepEntry?> log({
    required DateTime bedtime,
    required DateTime wakeTime,
    int? quality,
    String? note,
  }) async {
    final repository = _repository;
    final userId = _userId;
    if (repository == null || userId == null) {
      return null;
    }

    final entry = await repository.log(
      userId: userId,
      bedtime: bedtime,
      wakeTime: wakeTime,
      quality: quality,
      note: note,
    );

    entries.add(entry);
    _sort();
    _bump();
    onLogged?.call(entry);
    return entry;
  }

  /// Apple Healthből hozott éjszaka. Nem írjuk vissza a Healthbe.
  static Future<SleepEntry?> importFromHealth({
    required String id,
    required DateTime bedtime,
    required DateTime wakeTime,
  }) async {
    if (entries.any((item) => item.id == id || _overlaps(item, bedtime, wakeTime))) {
      return null;
    }

    final repository = _repository;
    final userId = _userId;
    if (repository == null || userId == null) {
      return null;
    }

    final entry = await repository.log(
      userId: userId,
      id: id,
      bedtime: bedtime,
      wakeTime: wakeTime,
      note: "Apple Health",
    );
    entries.add(entry);
    _sort();
    _bump();
    return entry;
  }

  static bool _overlaps(SleepEntry existing, DateTime bedtime, DateTime wakeTime) {
    final start = existing.bedtime.isAfter(bedtime) ? existing.bedtime : bedtime;
    final end = existing.wakeTime.isBefore(wakeTime) ? existing.wakeTime : wakeTime;
    return end.difference(start) >= const Duration(hours: 2);
  }

  static Future<void> remove(SleepEntry entry) async {
    entries.removeWhere((item) => item.id == entry.id);
    _bump();

    final repository = _repository;
    final userId = _userId;
    if (repository != null && userId != null) {
      await repository.remove(userId: userId, id: entry.id);
    }
  }

  /// A legutóbbi lezárt alvás. Ez a „Múlt éjszaka" kártya alapja.
  static SleepEntry? get lastNight => entries.isEmpty ? null : entries.last;

  /// Az adott naptári napon reggel véget ért alvás.
  static SleepEntry? entryForWakeDay(DateTime day) {
    final target = DateTime(day.year, day.month, day.day);
    for (final entry in entries.reversed) {
      final wake = entry.wakeTime;
      if (DateTime(wake.year, wake.month, wake.day) == target) {
        return entry;
      }
    }
    return null;
  }

  /// A megadott naphoz tartozó hét kezdete (vasárnap).
  static DateTime startOfWeek(DateTime date) {
    final day = DateTime(date.year, date.month, date.day);
    return day.subtract(Duration(days: day.weekday % 7));
  }

  /// Hét napra bontott alvásóra, a 0. index a vasárnap. A felkelés napjához
  /// soroljuk az éjszakát, mert a felületen is így nézzük.
  static List<double> weeklyHours(DateTime weekStart) {
    final totals = List<double>.filled(7, 0);
    final start = DateTime(weekStart.year, weekStart.month, weekStart.day);
    final end = start.add(const Duration(days: 7));

    for (final entry in entries) {
      final wake = entry.wakeTime;
      if (wake.isBefore(start) || !wake.isBefore(end)) {
        continue;
      }
      final index =
          DateTime(wake.year, wake.month, wake.day).difference(start).inDays;
      if (index < 0 || index > 6) {
        continue;
      }
      totals[index] += entry.hours;
    }

    return totals;
  }

  static double get averageHours {
    if (entries.isEmpty) {
      return 0;
    }
    final total = entries.fold<double>(0, (sum, entry) => sum + entry.hours);
    return total / entries.length;
  }

  /// A szokásos lefekvés és kelés a legutóbbi hét éjszaka alapján. Ebből jön a
  /// napi javasolt ütemezés, amíg nincs kézzel beállított emlékeztető.
  static ({int bedHour, int bedMinute, int wakeHour, int wakeMinute})?
      typicalSchedule() {
    if (entries.isEmpty) {
      return null;
    }

    final recent = entries.length <= 7
        ? entries
        : entries.sublist(entries.length - 7);

    var bedMinutes = 0;
    var wakeMinutes = 0;
    for (final entry in recent) {
      // Az éjfél utáni lefekvést a nap végéhez toljuk, hogy az átlag ne
      // csússzon délre.
      final bed = entry.bedtime.hour * 60 + entry.bedtime.minute;
      bedMinutes += bed < 12 * 60 ? bed + 24 * 60 : bed;
      wakeMinutes += entry.wakeTime.hour * 60 + entry.wakeTime.minute;
    }

    final bedAverage = (bedMinutes / recent.length).round() % (24 * 60);
    final wakeAverage = (wakeMinutes / recent.length).round() % (24 * 60);

    return (
      bedHour: bedAverage ~/ 60,
      bedMinute: bedAverage % 60,
      wakeHour: wakeAverage ~/ 60,
      wakeMinute: wakeAverage % 60,
    );
  }
}
