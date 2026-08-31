import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest.dart' as tzdata;
import 'package:timezone/timezone.dart' as tz;

import '../view/photo_progress/photo_progress_store.dart';
import '../view/sleep_tracker/sleep_store.dart';
import '../view/workout_tracker/workout_store.dart';
import 'coach/coach_rules.dart';
import 'local/app_database.dart';

class AppNotificationItem {
  const AppNotificationItem({
    required this.id,
    required this.title,
    required this.body,
    required this.image,
    required this.at,
    required this.kind,
  });

  final String id;
  final String title;
  final String body;
  final String image;
  final DateTime at;
  final String kind;

  Map<String, dynamic> toJson() => {
        "id": id,
        "title": title,
        "body": body,
        "image": image,
        "at": at.toIso8601String(),
        "kind": kind,
      };

  factory AppNotificationItem.fromJson(Map<String, dynamic> json) =>
      AppNotificationItem(
        id: "${json["id"]}",
        title: "${json["title"]}",
        body: "${json["body"] ?? ""}",
        image: "${json["image"]}",
        at: DateTime.tryParse("${json["at"]}") ?? DateTime.now(),
        kind: "${json["kind"]}",
      );

  String get timeLabel {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final day = DateTime(at.year, at.month, at.day);
    final diff = day.difference(today).inDays;
    final clock =
        "${at.hour.toString().padLeft(2, "0")}:${at.minute.toString().padLeft(2, "0")}";
    if (diff == 0) {
      return at.isAfter(now) ? "Ma $clock" : "Ma, $clock";
    }
    if (diff == 1) {
      return "Holnap $clock";
    }
    if (diff == -1) {
      return "Tegnap $clock";
    }
    if (diff > 1 && diff < 7) {
      return "$diff nap múlva, $clock";
    }
    return "${at.year}.${at.month.toString().padLeft(2, "0")}.${at.day.toString().padLeft(2, "0")}. $clock";
  }
}

/// Helyi (készüléken ütemezett) emlékeztetők. A kapcsoló a Profilban van.
class NotificationService extends ChangeNotifier {
  NotificationService({required AppDatabase database}) : _database = database;

  static const _enabledKey = "local_notifications_enabled";
  static const _inboxKey = "local_notification_inbox";
  static const _channelId = "flexio_reminders";

  static const _idSleepBed = 2001;
  static const _idSleepWake = 2002;
  static const _idPhoto = 3001;

  final AppDatabase _database;
  final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();

  bool _ready = false;
  bool _enabled = false;
  bool _busy = false;
  List<AppNotificationItem> _inbox = [];
  Timer? _rescheduleTimer;

  /// A Profil coach-kapcsolója. Csendes órától függetlenül az esti tipp mehet.
  bool sleepCoachEnabled = true;

  bool get enabled => _enabled;
  bool get busy => _busy;
  List<AppNotificationItem> get inbox => List.unmodifiable(_inbox);

  List<AppNotificationItem> get visibleInbox => _inbox
      .where((item) =>
          enabled || item.kind.startsWith("coach"))
      .toList();

  Future<void> bootstrap() async {
    try {
      await _ensureReady();
    } catch (error, stack) {
      debugPrint("Notification bootstrap failed: $error\n$stack");
    }
    _enabled = await _database.metaValue(_enabledKey) == "true";
    _inbox = _decodeInbox(await _database.metaValue(_inboxKey));
    if (_enabled) {
      await reschedule();
    }
    notifyListeners();
  }

  Future<bool> setEnabled(bool value) async {
    if (value) {
      return enable();
    }
    await disable();
    return true;
  }

  Future<bool> enable() async {
    _busy = true;
    notifyListeners();
    try {
      await _ensureReady();
      final granted = await _requestPermission();
      if (!granted) {
        return false;
      }
      _enabled = true;
      await _database.setMeta(_enabledKey, "true");
      await reschedule();
      return true;
    } finally {
      _busy = false;
      notifyListeners();
    }
  }

  Future<void> disable() async {
    _enabled = false;
    await _database.setMeta(_enabledKey, "false");
    await _plugin.cancelAll();
    notifyListeners();
  }

  void scheduleSoon() {
    _rescheduleTimer?.cancel();
    _rescheduleTimer = Timer(const Duration(milliseconds: 400), () {
      reschedule();
    });
  }

  Future<void> reschedule() async {
    if (!_enabled) {
      return;
    }
    await _ensureReady();
    await _plugin.cancelAll();

    final now = DateTime.now();
    final upcoming = <AppNotificationItem>[];

    for (final event in WorkoutStore.upcomingScheduledWorkouts) {
      final date = event["date"];
      if (date is! DateTime || !date.isAfter(now)) {
        continue;
      }
      final when = date.subtract(const Duration(minutes: 15));
      final fireAt = when.isAfter(now) ? when : date;
      if (!fireAt.isAfter(now)) {
        continue;
      }
      final title = "${event["workout"] is Map ? event["workout"]["title"] ?? event["title"] : event["title"] ?? "Edzés"}";
      final image = "${event["workout"] is Map ? event["workout"]["image"] ?? "assets/img/Workout1.png" : "assets/img/Workout1.png"}";
      final id = 1000 + (title.hashCode.abs() % 800);
      upcoming.add(AppNotificationItem(
        id: "workout_${event["id"] ?? fireAt.millisecondsSinceEpoch}",
        title: "Edzés 15 percen belül",
        body: title.isEmpty ? "Következik egy edzésed." : "$title következik.",
        image: image.isEmpty ? "assets/img/Workout1.png" : image,
        at: fireAt,
        kind: "workout",
      ));
      await _scheduleOnce(id, upcoming.last);
    }

    final typical = SleepStore.typicalSchedule();
    if (typical != null) {
      final bed = _nextDaily(typical.bedHour, typical.bedMinute)
          .subtract(const Duration(minutes: 15));
      final wake = _nextDaily(typical.wakeHour, typical.wakeMinute);
      final sleepTip = sleepCoachEnabled
          ? CoachRules.sleepFromHistory()
          : null;
      upcoming.add(AppNotificationItem(
        id: "sleep_bed",
        title: "Ideje készülni az alvásra",
        body: sleepTip == null
            ? "15 perc múlva a szokásos lefekvésed."
            : sleepTip.detail,
        image: "assets/img/sleep_schedule.png",
        at: bed.isAfter(now) ? bed : bed.add(const Duration(days: 1)),
        kind: "sleep",
      ));
      upcoming.add(AppNotificationItem(
        id: "sleep_wake",
        title: "Jó reggelt",
        body: "Naplózd az éjszakát, amíg friss az emlék.",
        image: "assets/img/sleep_schedule.png",
        at: wake,
        kind: "sleep",
      ));
      await _scheduleDaily(
        _idSleepBed,
        upcoming[upcoming.length - 2],
        typical.bedHour,
        typical.bedMinute,
        minutesBefore: 15,
      );
      await _scheduleDaily(
        _idSleepWake,
        upcoming.last,
        typical.wakeHour,
        typical.wakeMinute,
      );
    }

    final photoAt = PhotoProgressStore.lastPhoto == null
        ? null
        : PhotoProgressStore.nextReminderDate;
    if (photoAt != null) {
      var fire = DateTime(photoAt.year, photoAt.month, photoAt.day, 10);
      if (!fire.isAfter(now)) {
        fire = now.add(const Duration(hours: 1));
      }
      upcoming.add(AppNotificationItem(
        id: "photo",
        title: "Haladási fotó ideje",
        body: "Készíts egy új fotót, hogy lásd a változást.",
        image: "assets/img/pic_4.png",
        at: fire,
        kind: "photo",
      ));
      await _scheduleOnce(_idPhoto, upcoming.last);
    }

    final coach = _inbox
        .where((item) =>
            item.kind.startsWith("coach") &&
            now.difference(item.at) < const Duration(days: 14))
        .toList();
    final past = _inbox
        .where((item) =>
            !item.kind.startsWith("coach") &&
            item.at.isBefore(now) &&
            now.difference(item.at) < const Duration(days: 14))
        .toList();
    _inbox = [...upcoming, ...coach, ...past]
      ..sort((a, b) => b.at.compareTo(a.at));
    await _database.setMeta(
      _inboxKey,
      jsonEncode(_inbox.map((item) => item.toJson()).toList()),
    );
    notifyListeners();
  }

  Future<void> _ensureReady() async {
    if (_ready) {
      return;
    }

    try {
      tzdata.initializeTimeZones();
      try {
        tz.setLocalLocation(tz.getLocation("Europe/Budapest"));
      } catch (_) {
        tz.setLocalLocation(tz.UTC);
      }

      const android = AndroidInitializationSettings("@mipmap/ic_launcher");
      const ios = DarwinInitializationSettings(
        requestAlertPermission: false,
        requestBadgePermission: false,
        requestSoundPermission: false,
      );
      await _plugin.initialize(
        const InitializationSettings(android: android, iOS: ios),
      );
      _ready = true;
    } on MissingPluginException {
      debugPrint(
        "Notification plugin nincs a natív oldalon. Állítsd le a flutter run-t, és indítsd újra (hot restart nem elég).",
      );
    } catch (error, stack) {
      debugPrint("Notification init failed: $error\n$stack");
    }
  }

  Future<bool> _requestPermission() async {
    final ios = _plugin.resolvePlatformSpecificImplementation<
        IOSFlutterLocalNotificationsPlugin>();
    if (ios != null) {
      return await ios.requestPermissions(
            alert: true,
            badge: true,
            sound: true,
          ) ??
          false;
    }

    final android = _plugin.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();
    if (android != null) {
      return await android.requestNotificationsPermission() ?? true;
    }
    return true;
  }

  Future<void> _scheduleOnce(int id, AppNotificationItem item) async {
    try {
      await _plugin.zonedSchedule(
        id,
        item.title,
        item.body,
        tz.TZDateTime.from(item.at, tz.local),
        _details,
        androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
      );
    } catch (error) {
      debugPrint("Notification schedule failed: $error");
    }
  }

  Future<void> _scheduleDaily(
    int id,
    AppNotificationItem item,
    int hour,
    int minute, {
    int minutesBefore = 0,
  }) async {
    var when = _nextDaily(hour, minute)
        .subtract(Duration(minutes: minutesBefore));
    if (!when.isAfter(DateTime.now())) {
      when = when.add(const Duration(days: 1));
    }
    try {
      await _plugin.zonedSchedule(
        id,
        item.title,
        item.body,
        tz.TZDateTime.from(when, tz.local),
        _details,
        androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
        matchDateTimeComponents: DateTimeComponents.time,
      );
    } catch (error) {
      debugPrint("Daily notification schedule failed: $error");
    }
  }

  DateTime _nextDaily(int hour, int minute) {
    final now = DateTime.now();
    var next = DateTime(now.year, now.month, now.day, hour, minute);
    if (!next.isAfter(now)) {
      next = next.add(const Duration(days: 1));
    }
    return next;
  }

  NotificationDetails get _details => const NotificationDetails(
        android: AndroidNotificationDetails(
          _channelId,
          "Flexio emlékeztetők",
          channelDescription:
              "Edzés, alvás és haladási fotó emlékeztetők.",
          importance: Importance.high,
          priority: Priority.high,
        ),
        iOS: DarwinNotificationDetails(
          presentAlert: true,
          presentBadge: true,
          presentSound: true,
        ),
      );

  Future<void> pushCoachItem({
    required String title,
    required String body,
    required String kind,
    String image = "assets/img/notification_active.png",
  }) async {
    final item = AppNotificationItem(
      id: "coach_${DateTime.now().millisecondsSinceEpoch}",
      title: title,
      body: body,
      image: image,
      at: DateTime.now(),
      kind: kind.startsWith("coach") ? kind : "coach_$kind",
    );
    _inbox = [item, ..._inbox].take(60).toList();
    await _database.setMeta(
      _inboxKey,
      jsonEncode(_inbox.map((row) => row.toJson()).toList()),
    );
    notifyListeners();
  }

  static List<AppNotificationItem> _decodeInbox(String? raw) {
    if (raw == null || raw.isEmpty) {
      return [];
    }
    try {
      final decoded = jsonDecode(raw);
      if (decoded is! List) {
        return [];
      }
      return decoded
          .whereType<Map>()
          .map((item) =>
              AppNotificationItem.fromJson(Map<String, dynamic>.from(item)))
          .toList();
    } on Object {
      return [];
    }
  }
}
