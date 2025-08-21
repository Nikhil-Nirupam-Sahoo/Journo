import 'dart:io';
import 'dart:typed_data';

import 'package:path_provider/path_provider.dart';
import 'package:uuid/uuid.dart';

class FileService {
  static const String _attachmentsDirName = 'attachments';

  Future<Directory> _appDir() async {
    final Directory dir = await getApplicationSupportDirectory();
    if (!await dir.exists()) {
      await dir.create(recursive: true);
    }
    return dir;
  }

  Future<Directory> attachmentsDir() async {
    final Directory app = await _appDir();
    final Directory att = Directory('${app.path}/$_attachmentsDirName');
    if (!await att.exists()) {
      await att.create(recursive: true);
    }
    return att;
  }

  Future<File> saveBytes(Uint8List bytes, {String extension = 'png'}) async {
    final Directory dir = await attachmentsDir();
    final String id = const Uuid().v4();
    final File f = File('${dir.path}/$id.$extension');
    await f.writeAsBytes(bytes);
    return f;
  }

  Future<File> copyIn(File source) async {
    final Directory dir = await attachmentsDir();
    final String id = const Uuid().v4();
    final String ext = source.path.split('.').last;
    final File dest = File('${dir.path}/$id.$ext');
    return source.copy(dest.path);
  }
}