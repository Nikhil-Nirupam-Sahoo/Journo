import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter/material.dart';

class NotificationsService {
  final FlutterLocalNotificationsPlugin _plugin = FlutterLocalNotificationsPlugin();

  Future<void> initialize() async {
    const AndroidInitializationSettings androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const InitializationSettings initSettings = InitializationSettings(android: androidSettings);
    await _plugin.initialize(initSettings);
  }

  Future<void> scheduleDailyReminder(TimeOfDay time) async {
    final AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
      'journo_daily',
      'Daily Reminders',
      channelDescription: 'Daily journaling reminders',
      importance: Importance.defaultImportance,
      priority: Priority.defaultPriority,
    );
    final NotificationDetails details = NotificationDetails(android: androidDetails);
    final TimeOfDay t = time;
    final DateTime now = DateTime.now();
    DateTime scheduled = DateTime(now.year, now.month, now.day, t.hour, t.minute);
    if (scheduled.isBefore(now)) scheduled = scheduled.add(const Duration(days: 1));
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
  }

  Future<void> cancelDailyReminder() async {
    await _plugin.cancel(1);
  }
}
