import 'package:intl/intl.dart';

class Attachment {
  Attachment({required this.type, required this.path});
  final String type; // 'image' | 'drawing'
  final String path; // absolute file path

  Map<String, dynamic> toJson() => {
        'type': type,
        'path': path,
      };

  factory Attachment.fromJson(Map<String, dynamic> json) => Attachment(
        type: json['type'] as String,
        path: json['path'] as String,
      );
}

class JournalEntry {
  final String id;
  String title;
  String body;
  DateTime createdAt;
  DateTime updatedAt;
  List<String> tags;
  List<Attachment> attachments;

  JournalEntry({
    required this.id,
    required this.title,
    required this.body,
    required this.createdAt,
    required this.updatedAt,
    List<String>? tags,
    List<Attachment>? attachments,
  })  : tags = tags ?? <String>[],
        attachments = attachments ?? <Attachment>[];

  String get formattedDate => DateFormat.yMMMEd().add_jm().format(updatedAt);

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'body': body,
        'createdAt': createdAt.toIso8601String(),
        'updatedAt': updatedAt.toIso8601String(),
        'tags': tags,
        'attachments': attachments.map((Attachment a) => a.toJson()).toList(),
      };

  factory JournalEntry.fromJson(Map<String, dynamic> json) => JournalEntry(
        id: json['id'] as String,
        title: json['title'] as String,
        body: json['body'] as String,
        createdAt: DateTime.parse(json['createdAt'] as String),
        updatedAt: DateTime.parse(json['updatedAt'] as String),
        tags: (json['tags'] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? <String>[],
        attachments: (json['attachments'] as List<dynamic>?)
                ?.map((dynamic e) => Attachment.fromJson(e as Map<String, dynamic>))
                .toList() ??
            <Attachment>[],
      );
}
