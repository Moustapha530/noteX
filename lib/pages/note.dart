import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

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

class NoteCard extends StatelessWidget {
  final NoteModel note;

  const NoteCard({super.key, required this.note});

  Color getBackgroundColor() {
    switch (note.type) {
      case NoteType.idea:
        return const Color(0xfffdf8ec);
      case NoteType.checklist:
        return const Color(0xfff2f8ec);
      case NoteType.voice:
        return const Color(0xffedf5f8);
      case NoteType.meeting:
        return const Color(0xfff8eded);
      case NoteType.quick:
      case NoteType.image:
        return const Color(0xfff3edf8);
      default:
        return Colors.white;
    }
  }

  Color getAccentColor() {
    switch (note.type) {
      case NoteType.idea:
        return const Color(0xfff5b839);
      case NoteType.checklist:
        return const Color(0xff759b4a);
      case NoteType.voice:
        return const Color(0xff4894b5);
      case NoteType.meeting:
        return const Color(0xffd57a7a);
      case NoteType.quick:
      case NoteType.image:
        return const Color(0xff8c7ad5);
      default:
        return Colors.black;
    }
  }

  String formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date).inDays;

    if (difference == 0) {
      return "${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}";
    } else if (difference == 1) {
      return "Hier";
    } else {
      final months = [
        'janv.',
        'févr.',
        'mars',
        'avr.',
        'mai',
        'juin',
        'juil.',
        'août',
        'sept.',
        'oct.',
        'nov.',
        'déc.'
      ];
      return "${date.day} ${months[date.month - 1]}";
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: getBackgroundColor(),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  color: getAccentColor(),
                  shape: BoxShape.circle,
                ),
              ),
              Icon(
                note.pinned ? Icons.push_pin_outlined : Icons.more_vert,
                size: 16,
                color: Colors.black38,
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            note.title,
            style: GoogleFonts.nunito(
              fontWeight: FontWeight.bold,
              fontSize: 15,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 6),
          Expanded(
            child: _buildContent(),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                formatDate(note.creationDate),
                style: GoogleFonts.nunito(
                  fontSize: 11,
                  color: Colors.black45,
                ),
              ),
              Icon(
                note.isFavorite ? Icons.star : Icons.star_border,
                size: 16,
                color: note.isFavorite ? getAccentColor() : Colors.black26,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildContent() {
    if (note.imageUrl != null) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: Image.network(
          note.imageUrl!,
          fit: BoxFit.cover,
          width: double.infinity,
          errorBuilder: (context, error, stackTrace) => Container(
            color: Colors.black12,
            child: const Icon(Icons.image, color: Colors.black26),
          ),
        ),
      );
    }

    if (note.checklist != null) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: note.checklist!
            .take(4)
            .map((item) => Padding(
                  padding: const EdgeInsets.only(bottom: 2),
                  child: Row(
                    children: [
                      const Icon(Icons.check_box_outline_blank,
                          size: 12, color: Colors.black38),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          item,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: GoogleFonts.nunito(
                              fontSize: 12, color: Colors.black54),
                        ),
                      ),
                    ],
                  ),
                ))
            .toList(),
      );
    }

    return Text(
      note.content ?? '',
      maxLines: 4,
      overflow: TextOverflow.ellipsis,
      style: GoogleFonts.nunito(
        fontSize: 12,
        color: Colors.black54,
        height: 1.3,
      ),
    );
  }
}
