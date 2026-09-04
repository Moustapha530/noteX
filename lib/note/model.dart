import 'dart:convert';

enum NoteType { checklist, voice, note, image }


String getPlainTextFromContent(String? rawContent) {
  if (rawContent == null || rawContent.isEmpty) return '';

  try {
    final decoded = jsonDecode(rawContent);

    // Handles standard Delta/Quill JSON format: [{"insert": "Text\n"}]
    if (decoded is List) {
      final buffer = StringBuffer();
      for (final op in decoded) {
        if (op is Map && op.containsKey('insert')) {
          final insertVal = op['insert'];
          if (insertVal is String) {
            buffer.write(insertVal);
          }
        }
      }
      return buffer.toString().trim();
    }

    // Handles generic key-value map format
    if (decoded is Map && decoded.containsKey('insert')) {
      return decoded['insert'].toString().trim();
    }
  } catch (_) {
    // If it's plain text (not JSON), return as is
    return rawContent;
  }

  return rawContent;
}

class NoteModel {
  final String id;
  final String title;
  final String? content;
  final List<String>? checklist;
  final String? imageUrl;
  final DateTime lastModified;
  final NoteType type;
  bool pinned;
  bool isFavorite;
  bool isTrashed;

  NoteModel({
    required this.id,
    required this.type,
    this.content,
    this.checklist,
    this.imageUrl,
    DateTime? lastModified,
    this.title = 'Sans titre',
    this.pinned = false,
    this.isFavorite = false,
    this.isTrashed = false,
  }) : lastModified = lastModified ?? DateTime.now();

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'type': type.toString(),
      'content': content,
      'checklist': checklist,
      'imageUrl': imageUrl,
      'lastModified': lastModified.toIso8601String(),
      'pinned': pinned,
      'isFavorite': isFavorite,
      'isTrashed': isTrashed,
    };
  }

  factory NoteModel.fromJson(Map<String, dynamic> json) {
    return NoteModel(
      id: json['id'] as String,
      title: json['title'] as String,
      type: NoteType.values.firstWhere((v) => v.toString() == json['type']),
      content: json['content'] as String?,
      checklist: (json['checklist'] as List<dynamic>?)
          ?.map((item) => item as String)
          .toList(),
      imageUrl: json['imageUrl'] as String?,
      lastModified: DateTime.parse(json['lastModified'] as String),
      pinned: json['pinned'] as bool? ?? false,
      isFavorite: json['isFavorite'] as bool? ?? false,
      isTrashed: json['isTrashed'] as bool? ?? false,
    );
  }
}