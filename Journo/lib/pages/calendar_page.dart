import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../models/journal_entry.dart';

class CalendarPage extends StatefulWidget {
  const CalendarPage({super.key, required this.entries});

  final List<JournalEntry> entries;

  @override
  State<CalendarPage> createState() => _CalendarPageState();
}

class _CalendarPageState extends State<CalendarPage> {
  late DateTime _visibleMonth;
  late Map<DateTime, int> _counts;

  @override
  void initState() {
    super.initState();
    _visibleMonth = DateTime(DateTime.now().year, DateTime.now().month);
    _recomputeCounts();
  }

  @override
  void didUpdateWidget(covariant CalendarPage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.entries != widget.entries) {
      _recomputeCounts();
    }
  }

  void _recomputeCounts() {
    _counts = <DateTime, int>{};
    for (final JournalEntry e in widget.entries) {
      final DateTime d = DateTime(e.updatedAt.year, e.updatedAt.month, e.updatedAt.day);
      _counts[d] = (_counts[d] ?? 0) + 1;
    }
    setState(() {});
  }

  void _prevMonth() {
    setState(() {
      _visibleMonth = DateTime(_visibleMonth.year, _visibleMonth.month - 1);
    });
  }

  void _nextMonth() {
    setState(() {
      _visibleMonth = DateTime(_visibleMonth.year, _visibleMonth.month + 1);
    });
  }

  List<Widget> _buildWeekdayHeaders(TextStyle? style) {
    const List<String> labels = <String>['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    return labels
        .map((String l) => Expanded(
              child: Center(child: Text(l, style: style)),
            ))
        .toList();
  }

  List<Widget> _buildMonthGrid(BuildContext context) {
    final DateTime firstDayOfMonth = DateTime(_visibleMonth.year, _visibleMonth.month, 1);
    final int weekday = firstDayOfMonth.weekday; // 1..7 (Mon..Sun)
    final DateTime gridStart = firstDayOfMonth.subtract(Duration(days: (weekday - 1) % 7));
    final List<Row> rows = <Row>[];

    DateTime cursor = gridStart;
    for (int w = 0; w < 6; w++) {
      final List<Widget> cells = <Widget>[];
      for (int d = 0; d < 7; d++) {
        final DateTime key = DateTime(cursor.year, cursor.month, cursor.day);
        final bool inMonth = cursor.month == _visibleMonth.month;
        final int count = _counts[key] ?? 0;
        cells.add(Expanded(
          child: GestureDetector(
            onTap: () => _showDayEntries(context, key),
            child: Container(
              margin: const EdgeInsets.all(4),
              height: 64,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                color: inMonth
                    ? (count == 0
                        ? Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.4)
                        : Theme.of(context).colorScheme.primary.withOpacity(0.20 + (count.clamp(1, 5) * 0.12)))
                    : Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.15),
                border: Border.all(
                  color: inMonth
                      ? Theme.of(context).colorScheme.outlineVariant
                      : Theme.of(context).dividerColor.withOpacity(0.3),
                ),
              ),
            ),
          ),
        ));
        cursor = cursor.add(const Duration(days: 1));
      }
      rows.add(Row(children: cells));
    }

    return rows;
  }

  Future<void> _showDayEntries(BuildContext context, DateTime day) async {
    final List<JournalEntry> dayEntries = widget.entries
        .where((JournalEntry e) => e.updatedAt.year == day.year && e.updatedAt.month == day.month && e.updatedAt.day == day.day)
        .toList()
      ..sort((JournalEntry a, JournalEntry b) => b.updatedAt.compareTo(a.updatedAt));

    final String label = DateFormat.yMMMMEEEEd().format(day);
    await showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      isScrollControlled: true,
      builder: (BuildContext context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: SizedBox(
              height: MediaQuery.of(context).size.height * 0.6,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(label, style: Theme.of(context).textTheme.titleMedium),
                  const SizedBox(height: 8),
                  if (dayEntries.isEmpty)
                    const Expanded(child: Center(child: Text('No entries for this day')))
                  else
                    Expanded(
                      child: ListView.separated(
                        itemCount: dayEntries.length,
                        separatorBuilder: (_, __) => const Divider(height: 1),
                        itemBuilder: (BuildContext context, int index) {
                          final JournalEntry e = dayEntries[index];
                          final String time = DateFormat.jm().format(e.updatedAt);
                          return ListTile(
                            leading: const Icon(Icons.note_outlined),
                            title: Text(e.title.isEmpty ? 'Untitled' : e.title),
                            subtitle: Text(time),
                          );
                        },
                      ),
                    ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final TextStyle? headerStyle = Theme.of(context).textTheme.titleMedium;
    final String monthLabel = '${_monthName(_visibleMonth.month)} ${_visibleMonth.year}';

    return Scaffold(
      appBar: AppBar(title: const Text('Calendar')),
      body: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: <Widget>[
            Row(
              children: <Widget>[
                IconButton(onPressed: _prevMonth, icon: const Icon(Icons.chevron_left)),
                Expanded(child: Center(child: Text(monthLabel, style: headerStyle))),
                IconButton(onPressed: _nextMonth, icon: const Icon(Icons.chevron_right)),
              ],
            ),
            const SizedBox(height: 8),
            Row(children: _buildWeekdayHeaders(Theme.of(context).textTheme.labelMedium)),
            const SizedBox(height: 8),
            Expanded(
              child: Column(
                children: _buildMonthGrid(context),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _monthName(int m) {
    const List<String> names = <String>[
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December'
    ];
    return names[m - 1];
  }
}
