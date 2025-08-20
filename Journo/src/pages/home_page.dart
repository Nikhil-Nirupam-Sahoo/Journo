import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';

import '../models/journal_entry.dart';
import '../services/storage_service.dart';
import '../services/quotes_service.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final StorageService _storage = StorageService();
  final QuotesService _quotes = QuotesService();
  final TextEditingController _searchController = TextEditingController();

  List<JournalEntry> _entries = <JournalEntry>[];
  List<JournalEntry> _filtered = <JournalEntry>[];
  String? _quote;

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
    );
    final JournalEntry? edited = await Navigator.of(context).push<JournalEntry>(
      MaterialPageRoute<JournalEntry>(
        builder: (_) => _EditPage(entry: entry),
      ),
    );
    if (edited != null) {
      setState(() {
        _entries.insert(0, edited);
        _applySearch();
      });
      await _storage.saveEntries(_entries);
    }
  }

  Future<void> _editEntry(JournalEntry entry) async {
    final JournalEntry? edited = await Navigator.of(context).push<JournalEntry>(
      MaterialPageRoute<JournalEntry>(
        builder: (_) => _EditPage(entry: entry),
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Journo'),
        actions: <Widget>[
          IconButton(
            tooltip: 'Shuffle Quote',
            icon: const Icon(Icons.refresh),
            onPressed: _shuffleQuote,
          ),
          IconButton(
            tooltip: 'New Entry',
            icon: const Icon(Icons.add),
            onPressed: _createEntry,
          ),
        ],
      ),
      body: Column(
        children: <Widget>[
          if (_quote != null)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  '“$_quote”',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontStyle: FontStyle.italic,
                        color: Theme.of(context).colorScheme.secondary,
                      ),
                ),
              ),
            ),
          Padding(
            padding: const EdgeInsets.all(12),
            child: TextField(
              controller: _searchController,
              decoration: const InputDecoration(
                prefixIcon: Icon(Icons.search),
                hintText: 'Search entries...',
                border: OutlineInputBorder(),
              ),
            ),
          ),
          Expanded(
            child: _filtered.isEmpty
                ? const Center(child: Text('No entries yet. Tap + to create one.'))
                : ListView.separated(
                    itemCount: _filtered.length,
                    separatorBuilder: (_, __) => const Divider(height: 1),
                    itemBuilder: (BuildContext context, int index) {
                      final JournalEntry entry = _filtered[index];
                      return ListTile(
                        title: Text(entry.title.isEmpty ? 'Untitled' : entry.title),
                        subtitle: Text(entry.formattedDate),
                        onTap: () => _editEntry(entry),
                        trailing: IconButton(
                          icon: const Icon(Icons.delete_outline),
                          onPressed: () => _deleteEntry(entry),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _createEntry,
        child: const Icon(Icons.add),
      ),
    );
  }
}

class _EditPage extends StatefulWidget {
  const _EditPage({required this.entry});
  final JournalEntry entry;

  @override
  State<_EditPage> createState() => _EditPageState();
}

class _EditPageState extends State<_EditPage> {
  late final TextEditingController _title = TextEditingController(text: widget.entry.title);
  late final TextEditingController _body = TextEditingController(text: widget.entry.body);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Entry'),
        actions: <Widget>[
          IconButton(
            icon: const Icon(Icons.check),
            onPressed: () {
              final JournalEntry updated = JournalEntry(
                id: widget.entry.id,
                title: _title.text.trim(),
                body: _body.text,
                createdAt: widget.entry.createdAt,
                updatedAt: DateTime.now(),
              );
              Navigator.of(context).pop(updated);
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: <Widget>[
            TextField(
              controller: _title,
              decoration: const InputDecoration(
                labelText: 'Title',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            Expanded(
              child: TextField(
                controller: _body,
                maxLines: null,
                expands: true,
                decoration: const InputDecoration(
                  labelText: 'Body',
                  alignLabelWithHint: true,
                  border: OutlineInputBorder(),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
