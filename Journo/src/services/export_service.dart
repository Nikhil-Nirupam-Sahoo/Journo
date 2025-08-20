import 'dart:convert';
import 'dart:io';

import 'package:path_provider/path_provider.dart';

import '../models/journal_entry.dart';

class ExportService {
  Future<File> exportToJson(List<JournalEntry> entries) async {
    final Directory dir = await getDownloadsDirectory() ?? await getApplicationSupportDirectory();
    final String path = '${dir.path}/journo_export_${DateTime.now().millisecondsSinceEpoch}.json';
    final File file = File(path);
    await file.writeAsString(jsonEncode(entries.map((e) => e.toJson()).toList()));
    return file;
  }

  Future<List<JournalEntry>> importFromJson(File file) async {
    final String content = await file.readAsString();
    final List<dynamic> data = jsonDecode(content) as List<dynamic>;
    return data.map((dynamic e) => JournalEntry.fromJson(e as Map<String, dynamic>)).toList();
  }
}
