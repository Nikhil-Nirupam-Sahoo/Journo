import 'package:flutter/material.dart';

import '../models/journal_entry.dart';

class CalendarPage extends StatelessWidget {
  const CalendarPage({super.key, required this.entries});

  final List<JournalEntry> entries;

  @override
  Widget build(BuildContext context) {
    final Map<DateTime, int> counts = <DateTime, int>{};
    for (final JournalEntry e in entries) {
      final DateTime d = DateTime(e.updatedAt.year, e.updatedAt.month, e.updatedAt.day);
      counts[d] = (counts[d] ?? 0) + 1;
    }
    final DateTime now = DateTime.now();
    final DateTime start = DateTime(now.year, now.month - 5, 1);
    final DateTime end = DateTime(now.year, now.month + 1, 0);
    final List<Widget> weeks = <Widget>[];
    DateTime cursor = DateTime(start.year, start.month, 1);
    while (cursor.isBefore(end)) {
      final List<Widget> days = <Widget>[];
      for (int i = 0; i < 7; i++) {
        final DateTime day = cursor.add(Duration(days: i));
        final DateTime key = DateTime(day.year, day.month, day.day);
        final int c = counts[key] ?? 0;
        final Color color = c == 0
            ? Colors.grey.withOpacity(0.2)
            : Color.lerp(Colors.green.shade200, Colors.green.shade900, (c / 5).clamp(0, 1).toDouble())!;
        days.add(Expanded(
          child: Container(
            height: 22,
            margin: const EdgeInsets.all(2),
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(4),
            ),
          ),
        ));
      }
      weeks.add(Row(children: days));
      cursor = cursor.add(const Duration(days: 7));
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Calendar')),
      body: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text('Entries heatmap', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            Expanded(child: SingleChildScrollView(child: Column(children: weeks))),
          ],
        ),
      ),
    );
  }
}
