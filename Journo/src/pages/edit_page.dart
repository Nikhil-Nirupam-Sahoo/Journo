import 'dart:io';
import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:image_picker/image_picker.dart';

import '../models/journal_entry.dart';
import '../services/file_service.dart';
import 'draw_page.dart';
import 'image_viewer_page.dart';

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
  late List<Attachment> _attachments = List<Attachment>.from(widget.entry.attachments);
  final FileService _files = FileService();
  bool _preview = false;

  Future<void> _pickImage() async {
    final FilePickerResult? result = await FilePicker.platform.pickFiles(type: FileType.image);
    if (result == null || result.files.isEmpty) return;
    final PlatformFile pf = result.files.first;
    final File saved = await _files.copyIn(File(pf.path!));
    setState(() => _attachments.add(Attachment(type: 'image', path: saved.path)));
  }

  Future<void> _takePhoto() async {
    if (!Platform.isAndroid) return;
    final ImagePicker picker = ImagePicker();
    final XFile? img = await picker.pickImage(source: ImageSource.camera);
    if (img == null) return;
    final File saved = await _files.copyIn(File(img.path));
    setState(() => _attachments.add(Attachment(type: 'image', path: saved.path)));
  }

  Future<void> _newDrawing() async {
    final Uint8List? png = await Navigator.of(context).push<Uint8List>(
      MaterialPageRoute<Uint8List>(builder: (_) => const DrawPage()),
    );
    if (png == null) return;
    final File saved = await _files.saveBytes(png, extension: 'png');
    setState(() => _attachments.add(Attachment(type: 'drawing', path: saved.path)));
  }

  void _removeAttachment(Attachment a) {
    setState(() => _attachments.remove(a));
  }

  void _openAttachment(Attachment a) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(builder: (_) => ImageViewerPage(file: File(a.path))),
    );
  }

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
                attachments: _attachments,
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
            if (_attachments.isNotEmpty)
              SizedBox(
                height: 96,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: _attachments.length,
                  separatorBuilder: (_, __) => const SizedBox(width: 8),
                  itemBuilder: (BuildContext context, int index) {
                    final Attachment a = _attachments[index];
                    return Stack(
                      children: <Widget>[
                        InkWell(
                          onTap: () => _openAttachment(a),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: Image.file(
                              File(a.path),
                              width: 128,
                              height: 96,
                              fit: BoxFit.cover,
                              errorBuilder: (_, __, ___) => Container(
                                width: 128,
                                height: 96,
                                color: Theme.of(context).colorScheme.surfaceVariant,
                                alignment: Alignment.center,
                                child: const Icon(Icons.broken_image_outlined),
                              ),
                            ),
                          ),
                        ),
                        Positioned(
                          top: 4,
                          right: 4,
                          child: Material(
                            color: Colors.black54,
                            shape: const CircleBorder(),
                            child: InkWell(
                              customBorder: const CircleBorder(),
                              onTap: () => _removeAttachment(a),
                              child: const Padding(
                                padding: EdgeInsets.all(4),
                                child: Icon(Icons.close, color: Colors.white, size: 18),
                              ),
                            ),
                          ),
                        )
                      ],
                    );
                  },
                ),
              ),
            if (_attachments.isNotEmpty) const SizedBox(height: 12),
            Row(
              children: <Widget>[
                ElevatedButton.icon(
                  onPressed: _pickImage,
                  icon: const Icon(Icons.photo_outlined),
                  label: const Text('Add Picture'),
                ),
                const SizedBox(width: 8),
                ElevatedButton.icon(
                  onPressed: _newDrawing,
                  icon: const Icon(Icons.brush_outlined),
                  label: const Text('Add Drawing'),
                ),
                const SizedBox(width: 8),
                if (Platform.isAndroid)
                  ElevatedButton.icon(
                    onPressed: _takePhoto,
                    icon: const Icon(Icons.photo_camera_outlined),
                    label: const Text('Take Photo'),
                  ),
              ],
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
