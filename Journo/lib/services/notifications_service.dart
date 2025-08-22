import 'dart:async';
import 'dart:io' show Platform;

import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest.dart' as tzdb;
import 'package:timezone/timezone.dart' as tz;

class NotificationsService {
  final FlutterLocalNotificationsPlugin _plugin = FlutterLocalNotificationsPlugin();
  Timer? _ticker;
  TimeOfDay? _scheduledTime;

  Future<void> initialize() async {
    tzdb.initializeTimeZones();

    const AndroidInitializationSettings androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const LinuxInitializationSettings linuxSettings = LinuxInitializationSettings(defaultActionName: 'Open');

    const InitializationSettings initSettings = InitializationSettings(
      android: androidSettings,
      linux: linuxSettings,
    );

    await _plugin.initialize(initSettings);
  }

  Future<void> scheduleDailyReminder(TimeOfDay time) async {
    _scheduledTime = time;

    final AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
      'journo_daily',
      'Daily Reminders',
      channelDescription: 'Daily journaling reminders',
      importance: Importance.defaultImportance,
      priority: Priority.defaultPriority,
    );
    final LinuxNotificationDetails linuxDetails = LinuxNotificationDetails(
      urgency: LinuxNotificationUrgency.normal,
    );

    final NotificationDetails details = NotificationDetails(
      android: androidDetails,
      linux: linuxDetails,
    );

    if (Platform.isAndroid) {
      final tz.TZDateTime now = tz.TZDateTime.now(tz.local);
      tz.TZDateTime scheduled = tz.TZDateTime(tz.local, now.year, now.month, now.day, time.hour, time.minute);
      if (scheduled.isBefore(now)) {
        scheduled = scheduled.add(const Duration(days: 1));
      }
      await _plugin.zonedSchedule(
        1,
        'Journo',
        'Write a few lines today.',
        scheduled,
        details,
        androidAllowWhileIdle: true,
        uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
        matchDateTimeComponents: DateTimeComponents.time,
      );
    } else {
      // Desktop fallback: run an in-app ticker that fires at the specified time daily.
      _startInAppReminderLoop(details);
      // Show a confirmation notification now
      await _plugin.show(1001, 'Journo', 'Daily reminder scheduled at ${_format(time)}', details);
    }
  }

  Future<void> cancelDailyReminder() async {
    _ticker?.cancel();
    _ticker = null;
    _scheduledTime = null;
    await _plugin.cancel(1);
    await _plugin.cancel(1001);
  }

  void _startInAppReminderLoop(NotificationDetails details) {
    _ticker?.cancel();
    if (_scheduledTime == null) return;
    final TimeOfDay target = _scheduledTime!;

    Duration timeUntilNextTrigger() {
      final DateTime now = DateTime.now();
      DateTime targetTime = DateTime(now.year, now.month, now.day, target.hour, target.minute);
      if (targetTime.isBefore(now)) {
        targetTime = targetTime.add(const Duration(days: 1));
      }
      return targetTime.difference(now);
    }

    Future<void> scheduleOnce() async {
      // Wait until next trigger time
      await Future<void>.delayed(timeUntilNextTrigger());
      await _plugin.show(1, 'Journo', 'Write a few lines today.', details);
      // After firing, schedule the next day
      if (_ticker != null) {
        scheduleOnce();
      }
    }

    // Use a dummy periodic timer to keep a reference for cancellation
    _ticker = Timer.periodic(const Duration(hours: 24), (_) {});
    // Kick off the first schedule
    // ignore: discarded_futures
    scheduleOnce();
  }

  String _format(TimeOfDay t) {
    final String h = t.hour.toString().padLeft(2, '0');
    final String m = t.minute.toString().padLeft(2, '0');
    return '$h:$m';
  }
}
