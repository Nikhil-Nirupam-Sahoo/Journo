import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';

import '../models/journal_entry.dart';
import '../services/storage_service.dart';
import '../services/quotes_service.dart';
import '../services/export_service.dart';
import 'calendar_page.dart';
import 'settings_page.dart';
import 'edit_page.dart';
import '../services/settings_service.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key, required this.themeController});
  final ThemeController themeController;

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final StorageService _storage = StorageService();
  final QuotesService _quotes = QuotesService();
  final TextEditingController _searchController = TextEditingController();
  final ExportService _export = ExportService();

  List<JournalEntry> _entries = <JournalEntry>[];
  List<JournalEntry> _filtered = <JournalEntry>[];
  String? _quote;
  int _tabIndex = 0;

  @override
  void initState() {
    super.initState();
    _initialize();
    _searchController.addListener(_applySearch);
  }

  Future<void> _initialize() async {
    final List<JournalEntry> loaded = await _storage.loadEntries();
    final String? q = await _quotes.getRandomQuote();
    setState(() {
      _entries = loaded..sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
      _filtered = List<JournalEntry>.from(_entries);
      _quote = q;
    });
  }

  Future<void> _shuffleQuote() async {
    final String? q = await _quotes.getRandomQuote(exclude: _quote);
    if (!mounted) return;
    setState(() {
      _quote = q;
    });
  }

  void _applySearch() {
    final String q = _searchController.text.trim().toLowerCase();
    setState(() {
      if (q.isEmpty) {
        _filtered = List<JournalEntry>.from(_entries);
      } else {
        _filtered = _entries
            .where((e) => e.title.toLowerCase().contains(q) || e.body.toLowerCase().contains(q))
            .toList();
      }
    });
  }

  Future<void> _createEntry() async {
    final JournalEntry entry = JournalEntry(
      id: const Uuid().v4(),
      title: 'Untitled',
      body: '',
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
      tags: <String>[],
    );
    final JournalEntry? edited = await Navigator.of(context).push<JournalEntry>(
      MaterialPageRoute<JournalEntry>(
        builder: (_) => EditPage(entry: entry),
      ),
    );
    if (edited != null) {
      setState(() {
        _entries.insert(0, edited);
        _entries.sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
        _applySearch();
      });
      await _storage.saveEntries(_entries);
    }
  }

  Future<void> _editEntry(JournalEntry entry) async {
    final JournalEntry? edited = await Navigator.of(context).push<JournalEntry>(
      MaterialPageRoute<JournalEntry>(
        builder: (_) => EditPage(entry: entry),
      ),
    );
    if (edited != null) {
      setState(() {
        final int idx = _entries.indexWhere((e) => e.id == edited.id);
        if (idx != -1) {
          _entries[idx] = edited;
        }
        _entries.sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
        _applySearch();
      });
      await _storage.saveEntries(_entries);
    }
  }

  Future<void> _deleteEntry(JournalEntry entry) async {
    setState(() {
      _entries.removeWhere((e) => e.id == entry.id);
      _applySearch();
    });
    await _storage.saveEntries(_entries);
  }

  Future<void> _exportEntries() async {
    await _export.exportToJson(_entries);
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Exported to Downloads')));
  }

  List<JournalEntry> get _searched {
    final String q = _searchController.text.trim().toLowerCase();
    if (q.isEmpty) return List<JournalEntry>.from(_entries);
    return _entries
        .where((JournalEntry e) =>
            e.title.toLowerCase().contains(q) ||
            e.body.toLowerCase().contains(q) ||
            e.tags.any((String t) => t.toLowerCase().contains(q)))
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> pages = <Widget>[
      _EntriesTab(
        quote: _quote,
        onShuffle: _shuffleQuote,
        searchController: _searchController,
        entries: _searched,
        onEdit: _editEntry,
        onDelete: _deleteEntry,
      ),
      CalendarPage(entries: _entries),
      SettingsPage(themeController: widget.themeController),
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Journo'),
        actions: <Widget>[
          if (_tabIndex == 0) ...<Widget>[
            IconButton(
              tooltip: 'Export',
              icon: const Icon(Icons.file_upload_outlined),
              onPressed: _exportEntries,
            ),
            IconButton(
              tooltip: 'New Entry',
              icon: const Icon(Icons.add),
              onPressed: _createEntry,
            ),
          ]
        ],
      ),
      body: pages[_tabIndex],
      bottomNavigationBar: NavigationBar(
        selectedIndex: _tabIndex,
        onDestinationSelected: (int i) => setState(() => _tabIndex = i),
        destinations: const <NavigationDestination>[
          NavigationDestination(icon: Icon(Icons.list_alt), label: 'Entries'),
          NavigationDestination(icon: Icon(Icons.calendar_month), label: 'Calendar'),
          NavigationDestination(icon: Icon(Icons.settings), label: 'Settings'),
        ],
      ),
      floatingActionButton: _tabIndex == 0
          ? FloatingActionButton(
              onPressed: _createEntry,
              child: const Icon(Icons.add),
            )
          : null,
    );
  }
}

class _EntriesTab extends StatelessWidget {
  const _EntriesTab({
    required this.quote,
    required this.onShuffle,
    required this.searchController,
    required this.entries,
    required this.onEdit,
    required this.onDelete,
  });

  final String? quote;
  final VoidCallback onShuffle;
  final TextEditingController searchController;
  final List<JournalEntry> entries;
  final void Function(JournalEntry) onEdit;
  final void Function(JournalEntry) onDelete;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        if (quote != null)
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
            child: Row(
              children: <Widget>[
                Expanded(
                  child: Text(
                    '“$quote”',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          fontStyle: FontStyle.italic,
                          color: Theme.of(context).colorScheme.secondary,
                        ),
                  ),
                ),
                IconButton(
                  tooltip: 'Shuffle Quote',
                  icon: const Icon(Icons.refresh),
                  onPressed: onShuffle,
                )
              ],
            ),
          ),
        Padding(
          padding: const EdgeInsets.all(12),
          child: TextField(
            controller: searchController,
            decoration: const InputDecoration(
              prefixIcon: Icon(Icons.search),
              hintText: 'Search by title, body, or #tag',
              border: OutlineInputBorder(),
            ),
          ),
        ),
        Expanded(
          child: entries.isEmpty
              ? const Center(child: Text('No entries yet. Tap + to create one.'))
              : ListView.separated(
                  itemCount: entries.length,
                  separatorBuilder: (_, __) => const Divider(height: 1),
                  itemBuilder: (BuildContext context, int index) {
                    final JournalEntry entry = entries[index];
                    final String subtitle = [
                      entry.formattedDate,
                      if (entry.tags.isNotEmpty) '#${entry.tags.join(' #')}',
                    ].join('  •  ');
                    return ListTile(
                      title: Text(entry.title.isEmpty ? 'Untitled' : entry.title),
                      subtitle: Text(subtitle),
                      onTap: () => onEdit(entry),
                      trailing: IconButton(
                        icon: const Icon(Icons.delete_outline),
                        onPressed: () => onDelete(entry),
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }
}
