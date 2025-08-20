Future<void> scheduleDailyReminder(TimeOfDay time) async {
  final android = AndroidNotificationDetails('journo_daily','Daily Reminders',
    channelDescription: 'Daily journaling reminders');
  final details = NotificationDetails(android: android);
  await _plugin.show(1, 'Journo', 'Write a few lines today.', details);
}
