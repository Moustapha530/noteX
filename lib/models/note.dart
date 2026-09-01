
enum NoteType { idea, checklist, voice, meeting, quick, image }

class NoteModel {
  final String title;
  final String? content;
  final List<String>? checklist;
  final String? imageUrl;
  final DateTime creationDate;
  final NoteType type;
  bool pinned;
  bool isFavorite;

  NoteModel({
    required this.title,
    required this.creationDate,
    required this.type,
    this.content,
    this.checklist,
    this.imageUrl,
    this.pinned = false,
    this.isFavorite = false,
  });
}
