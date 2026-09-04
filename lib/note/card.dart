import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:note_x/note/model.dart';
import 'package:note_x/note/repository.dart';

class NoteCard extends ConsumerWidget {
  final NoteModel note;
  final bool isInTrash;
  final bool isInFavorites;

  const NoteCard({
    super.key,
    required this.note,
    this.isInTrash = false,
    this.isInFavorites = false,
  });

  Color getBackgroundColor() {
    switch (note.type) {
      case NoteType.note:
        return const Color(0xfffdf8ec);
      case NoteType.checklist:
        return const Color(0xfff2f8ec);
      case NoteType.voice:
        return const Color(0xffedf5f8);
      case NoteType.image:
        return const Color(0xfff3edf8);
    }
  }

  Color getAccentColor() {
    switch (note.type) {
      case NoteType.note:
        return const Color(0xfff5b839);
      case NoteType.checklist:
        return const Color(0xff759b4a);
      case NoteType.voice:
        return const Color(0xff4894b5);
      case NoteType.image:
        return const Color(0xff8c7ad5);
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

  String _getTypeName() {
    switch (note.type) {
      case NoteType.note:
        return 'Notes';
      case NoteType.checklist:
        return 'Checklist';
      case NoteType.voice:
        return 'Vocal';
      case NoteType.image:
        return 'Image';
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return InkWell(
      onTap: isInTrash ? null : () => context.push('/note/${note.id}/edit'),
      borderRadius: BorderRadius.circular(16),
      child: Container(
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
                if (isInTrash)
                  IconButton(
                    onPressed: () => _deletePermanently(ref),
                    icon: const Icon(
                      Icons.delete_forever_outlined,
                      size: 18,
                      color: Colors.redAccent,
                    ),
                    tooltip: 'Supprimer définitivement',
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                    visualDensity: VisualDensity.compact,
                  )
                else
                  Row(
                    children: [
                      if (!isInFavorites) ...[
                        IconButton(
                          onPressed: () => _togglePinned(ref),
                          icon: Icon(
                            note.pinned ? Icons.push_pin : Icons.push_pin_outlined,
                            size: 16,
                            color: note.pinned ? getAccentColor() : Colors.black38,
                          ),
                          tooltip: note.pinned ? 'Désépingler' : 'Épingler',
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                          visualDensity: VisualDensity.compact,
                        ),
                        const SizedBox(width: 8),
                      ],
                      IconButton(
                        onPressed: () => _moveToTrash(ref),
                        icon: const Icon(
                          Icons.delete_outline,
                          size: 16,
                          color: Colors.black38,
                        ),
                        tooltip: 'Déplacer vers la corbeille',
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                        visualDensity: VisualDensity.compact,
                      ),
                    ],
                  ),
              ],
            ),
            const SizedBox(height: 10),
            Text(
              note.title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
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
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: getAccentColor().withAlpha(25),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                _getTypeName(),
                style: GoogleFonts.nunito(
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  color: getAccentColor(),
                ),
              ),
            ),
            const SizedBox(height: 4),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  formatDate(note.lastModified),
                  style: GoogleFonts.nunito(
                    fontSize: 11,
                    color: Colors.black45,
                  ),
                ),
                if (isInTrash)
                  IconButton(
                    onPressed: () => _restoreNote(ref),
                    icon: Icon(
                      Icons.restore_from_trash_outlined,
                      size: 18,
                      color: getAccentColor(),
                    ),
                    tooltip: 'Restaurer la note',
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                    visualDensity: VisualDensity.compact,
                  )
                else
                  IconButton(
                    onPressed: () => _toggleFavorite(ref),
                    icon: Icon(
                      note.isFavorite ? Icons.star : Icons.star_border,
                      size: 16,
                      color: note.isFavorite ? getAccentColor() : Colors.black26,
                    ),
                    tooltip: note.isFavorite
                        ? 'Retirer des favoris'
                        : 'Ajouter aux favoris',
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                    visualDensity: VisualDensity.compact,
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _togglePinned(WidgetRef ref) async {
    await ref.read(notesProvider.notifier).updateNote(
          _copyWith(pinned: !note.pinned),
        );
  }

  Future<void> _toggleFavorite(WidgetRef ref) async {
    await ref.read(notesProvider.notifier).updateNote(
          _copyWith(isFavorite: !note.isFavorite),
        );
  }

  Future<void> _moveToTrash(WidgetRef ref) async {
    await ref.read(notesProvider.notifier).moveToTrash(note.id);
  }

  Future<void> _restoreNote(WidgetRef ref) async {
    await ref.read(notesProvider.notifier).updateNote(
          _copyWith(isTrashed: false),
        );
  }

  Future<void> _deletePermanently(WidgetRef ref) async {
    await ref.read(notesProvider.notifier).deleteNotePermanently(note.id);
  }

  NoteModel _copyWith({bool? pinned, bool? isFavorite, bool? isTrashed}) {
    return NoteModel(
      id: note.id,
      title: note.title,
      content: note.content,
      checklist: note.checklist,
      imageUrl: note.imageUrl,
      lastModified: note.lastModified,
      type: note.type,
      pinned: pinned ?? note.pinned,
      isFavorite: isFavorite ?? note.isFavorite,
      isTrashed: isTrashed ?? note.isTrashed,
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
                          getPlainTextFromContent(item),
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
      getPlainTextFromContent(note.content),
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