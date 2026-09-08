import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:note_x/note/model.dart';
import 'package:note_x/note/repository.dart';
import 'package:note_x/l10n.dart';

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

  Color getBackgroundColor(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    switch (note.type) {
      case NoteType.note:
        return isDark ? const Color(0xFF2D2A20) : const Color(0xfffdf8ec);
      case NoteType.checklist:
        return isDark ? const Color(0xFF252D20) : const Color(0xfff2f8ec);
      case NoteType.voice:
        return isDark ? const Color(0xFF202A2D) : const Color(0xffedf5f8);
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
    }
  }

  String formatDate(DateTime date, L10n l10n) {
    final now = DateTime.now();
    final difference = now.difference(date).inDays;

    if (difference == 0) {
      return "${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}";
    } else if (difference == 1) {
      return l10n.translate('yesterday');
    } else {
      final months = l10n.months;
      return "${date.day} ${months[date.month - 1]}";
    }
  }

  String _getTypeName(L10n l10n) {
    switch (note.type) {
      case NoteType.note:
        return l10n.translate('filter_notes');
      case NoteType.checklist:
        return l10n.translate('checklist');
      case NoteType.voice:
        return l10n.translate('voice_note');
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colorScheme = Theme.of(context).colorScheme;
    final l10n = context.l10n(ref);

    return InkWell(
      onTap: isInTrash ? null : () => context.push('/note/${note.id}/edit'),
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: getBackgroundColor(context),
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
                    onPressed: () => _deletePermanently(context, ref),
                    icon: const Icon(
                      Icons.delete_forever_outlined,
                      size: 18,
                      color: Colors.redAccent,
                    ),
                    tooltip: l10n.translate('delete'),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                    visualDensity: VisualDensity.compact,
                  )
                else
                  Row(
                    children: [
                      IconButton(
                        onPressed: () => _moveToTrash(ref),
                        icon: Icon(
                          Icons.delete_outline,
                          size: 16,
                          color: colorScheme.onSurface.withAlpha(97),
                        ),
                        tooltip: l10n.translate('delete'),
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
                color: colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 6),
            Expanded(child: _buildContent(context)),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: getAccentColor().withAlpha(25),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                _getTypeName(l10n),
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
                  formatDate(note.lastModified, l10n),
                  style: GoogleFonts.nunito(
                    fontSize: 11,
                    color: colorScheme.onSurface.withAlpha(125),
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
                    tooltip: 'Restaurer',
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
                      color: note.isFavorite
                          ? getAccentColor()
                          : colorScheme.onSurface.withAlpha(66),
                    ),
                    tooltip: l10n.translate('favorites'),
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

  Future<void> _toggleFavorite(WidgetRef ref) async {
    await ref
        .read(notesProvider.notifier)
        .updateNote(note.copyWith(isFavorite: !note.isFavorite));
  }

  Future<void> _moveToTrash(WidgetRef ref) async {
    await ref.read(notesProvider.notifier).moveToTrash(note.id);
  }

  Future<void> _restoreNote(WidgetRef ref) async {
    await ref
        .read(notesProvider.notifier)
        .updateNote(note.copyWith(isTrashed: false));
  }

  Future<void> _deletePermanently(BuildContext context, WidgetRef ref) async {
    final l10n = ref.read(l10nProvider);
    showDialog(
      context: context, 
      builder: (context) {
        return AlertDialog(
            title: Text(
                      l10n.translate('empty_trash_q'),
                      style: GoogleFonts.nunito(
                        color: Theme.of(context).colorScheme.onSurface,
                        fontSize: 23,
                        fontWeight: FontWeight.bold
                      ),
                    ),
                    content: Text(
                      l10n.translate('empty_trash_desc'),
                      style: GoogleFonts.nunito(
                        color: Theme.of(context).colorScheme.onSurface,
                        fontSize: 19,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    actions: [
                      TextButton(
                        onPressed: () {
                          ref.read(notesProvider.notifier).emptyTrash();
                        }, 
                        child: Text(
                          l10n.translate('confirm'),
                          style: GoogleFonts.nunito(
                            color: Colors.red,
                            fontSize: 19,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      TextButton(
                        onPressed: () {
                          context.pop();
                        }, 
                        child: Text(
                          l10n.translate('cancel'),
                          style: GoogleFonts.nunito(
                            color: Theme.of(context).colorScheme.onSurface,
                            fontSize: 19,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      )
                    ],
                  );
                },
              );
                      
  }

  Widget _buildContent(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    if (note.checklist != null) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: note.checklist!
            .take(4)
            .map(
              (item) => Padding(
                padding: const EdgeInsets.only(bottom: 2),
                child: Row(
                  children: [
                    Icon(
                      Icons.check_box_outline_blank,
                      size: 12,
                      color: colorScheme.onSurface.withAlpha(97),
                    ),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        getPlainTextFromContent(item),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.nunito(
                          fontSize: 12,
                          color: colorScheme.onSurface.withAlpha(138),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            )
            .toList(),
      );
    }

    return Text(
      getPlainTextFromContent(note.content),
      maxLines: 4,
      overflow: TextOverflow.ellipsis,
      style: GoogleFonts.nunito(
        fontSize: 12,
        color: colorScheme.onSurface.withAlpha(138),
        height: 1.3,
      ),
    );
  }
}
