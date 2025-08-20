import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';

import '../models/journal_entry.dart';

class EditPage extends StatefulWidget {
  const EditPage({super.key, required this.entry});
  final JournalEntry entry;

  @override
  State<EditPage> createState() => _EditPageState();
}

class _EditPageState extends State<EditPage> {
  late final TextEditingController _title = TextEditingController(text: widget.entry.title);
  late final TextEditingController _body = TextEditingController(text: widget.entry.body);
  late final TextEditingController _tags = TextEditingController(text: widget.entry.tags.join(', '));
  bool _preview = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Entry'),
        actions: <Widget>[
          IconButton(
            tooltip: _preview ? 'Edit' : 'Preview',
            icon: Icon(_preview ? Icons.edit : Icons.preview),
            onPressed: () => setState(() => _preview = !_preview),
          ),
          IconButton(
            icon: const Icon(Icons.check),
            onPressed: () {
              final List<String> tags = _tags.text
                  .split(',')
                  .map((String s) => s.trim())
                  .where((String s) => s.isNotEmpty)
                  .toList();
              final JournalEntry updated = JournalEntry(
                id: widget.entry.id,
                title: _title.text.trim(),
                body: _body.text,
                createdAt: widget.entry.createdAt,
                updatedAt: DateTime.now(),
                tags: tags,
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
            TextField(
              controller: _tags,
              decoration: const InputDecoration(
                labelText: 'Tags (comma-separated)',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            Expanded(
              child: _preview
                  ? Markdown(data: _body.text)
                  : TextField(
                      controller: _body,
                      maxLines: null,
                      expands: true,
                      decoration: const InputDecoration(
                        labelText: 'Body (Markdown supported)',
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
