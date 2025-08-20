import 'package:intl/intl.dart';

class JournalEntry {
  final String id;
  String title;
  String body;
  DateTime createdAt;
  DateTime updatedAt;
  List<String> tags;

  JournalEntry({
    required this.id,
    required this.title,
    required this.body,
    required this.createdAt,
    required this.updatedAt,
    List<String>? tags,
  }) : tags = tags ?? <String>[];

  String get formattedDate => DateFormat.yMMMEd().add_jm().format(updatedAt);

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'body': body,
        'createdAt': createdAt.toIso8601String(),
        'updatedAt': updatedAt.toIso8601String(),
        'tags': tags,
      };

  factory JournalEntry.fromJson(Map<String, dynamic> json) => JournalEntry(
        id: json['id'] as String,
        title: json['title'] as String,
        body: json['body'] as String,
        createdAt: DateTime.parse(json['createdAt'] as String),
        updatedAt: DateTime.parse(json['updatedAt'] as String),
        tags: (json['tags'] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? <String>[],
      );
}
