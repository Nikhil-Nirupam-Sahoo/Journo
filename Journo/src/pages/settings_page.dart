import 'package:flutter/material.dart';
import 'package:local_auth/local_auth.dart';

import '../services/settings_service.dart';
import '../services/notifications_service.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key, required this.themeController});
  final ThemeController themeController;

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  final SettingsService _settings = SettingsService();
  final NotificationsService _notifications = NotificationsService();
  final LocalAuthentication _auth = LocalAuthentication();

  bool _biometric = false;
  bool _reminderEnabled = false;
  TimeOfDay _reminderTime = const TimeOfDay(hour: 20, minute: 0);

  @override
  void initState() {
    super.initState();
    _load();
    _notifications.initialize();
  }

  Future<void> _load() async {
    final bool bio = await _settings.loadBiometricLockEnabled();
    final bool remind = await _settings.loadReminderEnabled();
    final TimeOfDay time = await _settings.loadReminderTime();
    setState(() {
      _biometric = bio;
      _reminderEnabled = remind;
      _reminderTime = time;
    });
  }

  Future<void> _toggleBiometric(bool value) async {
    if (value) {
      final bool can = await _auth.canCheckBiometrics && await _auth.isDeviceSupported();
      if (!can) return;
      final bool ok = await _auth.authenticate(localizedReason: 'Enable biometric lock');
      if (!ok) return;
    }
    setState(() => _biometric = value);
    await _settings.saveBiometricLockEnabled(value);
  }

  Future<void> _pickReminderTime() async {
    final TimeOfDay? picked = await showTimePicker(context: context, initialTime: _reminderTime);
    if (picked == null) return;
    setState(() => _reminderTime = picked);
    await _settings.saveReminder(enabled: _reminderEnabled, time: picked);
    if (_reminderEnabled) {
      await _notifications.scheduleDailyReminder(picked);
    }
  }

  Future<void> _toggleReminder(bool value) async {
    setState(() => _reminderEnabled = value);
    await _settings.saveReminder(enabled: value, time: _reminderTime);
    if (value) {
      await _notifications.scheduleDailyReminder(_reminderTime);
    } else {
      await _notifications.cancelDailyReminder();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: ListView(
        children: <Widget>[
          const ListTile(title: Text('Theme')),
          RadioListTile<ThemeMode>(
            title: const Text('System'),
            value: ThemeMode.system,
            groupValue: widget.themeController.themeMode,
            onChanged: (ThemeMode? m) => widget.themeController.update(m ?? ThemeMode.system),
          ),
          RadioListTile<ThemeMode>(
            title: const Text('Light'),
            value: ThemeMode.light,
            groupValue: widget.themeController.themeMode,
            onChanged: (ThemeMode? m) => widget.themeController.update(m ?? ThemeMode.system),
          ),
          RadioListTile<ThemeMode>(
            title: const Text('Dark'),
            value: ThemeMode.dark,
            groupValue: widget.themeController.themeMode,
            onChanged: (ThemeMode? m) => widget.themeController.update(m ?? ThemeMode.system),
          ),
          const Divider(),
          SwitchListTile(
            title: const Text('Biometric Lock'),
            value: _biometric,
            onChanged: _toggleBiometric,
          ),
          const Divider(),
          SwitchListTile(
            title: const Text('Daily Reminder'),
            subtitle: Text('Time: ${_reminderTime.format(context)}'),
            value: _reminderEnabled,
            onChanged: _toggleReminder,
          ),
          ListTile(
            leading: const Icon(Icons.schedule),
            title: const Text('Pick Reminder Time'),
            onTap: _pickReminderTime,
          ),
        ],
      ),
    );
  }
}
