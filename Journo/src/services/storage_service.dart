import 'dart:convert';
import 'dart:io';

import 'package:path_provider/path_provider.dart';

import '../models/journal_entry.dart';

class StorageService {
  static const String _fileName = 'entries.json';

  Future<Directory> _getAppDirectory() async {
    final Directory directory = await getApplicationSupportDirectory();
    if (!await directory.exists()) {
      await directory.create(recursive: true);
    }
    return directory;
  }

  Future<File> _getEntriesFile() async {
    final Directory dir = await _getAppDirectory();
    return File('${dir.path}/$_fileName');
  }

  Future<List<JournalEntry>> loadEntries() async {
    try {
      final File file = await _getEntriesFile();
      if (!await file.exists()) return <JournalEntry>[];
      final String content = await file.readAsString();
      if (content.trim().isEmpty) return <JournalEntry>[];
      final List<dynamic> data = jsonDecode(content) as List<dynamic>;
      return data
          .map((dynamic e) => JournalEntry.fromJson(e as Map<String, dynamic>))
          .toList();
    } catch (_) {
      return <JournalEntry>[];
    }
  }

  Future<void> saveEntries(List<JournalEntry> entries) async {
    final File file = await _getEntriesFile();
    final String data = jsonEncode(entries.map((e) => e.toJson()).toList());
    await file.writeAsString(data);
  }
}
