import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:note_x/note/model.dart';
import 'package:note_x/note/card.dart';
import 'package:note_x/note/repository.dart';
import 'package:note_x/l10n.dart';

class HomePage extends ConsumerWidget {
  HomePage({super.key});

  final List<Map<String, dynamic>> _actions = [
    {
      'bg_color': const Color(0x17f5b839),
      'color': const Color(0xfff5b839),
      'text_key': 'new_note',
      'icon': Icons.note_add_outlined,
      'note_type': NoteType.note,
    },
    {
      'bg_color': const Color(0x17759b4a),
      'color': const Color(0xff759b4a),
      'text_key': 'checklist',
      'icon': Icons.check_box_outlined,
      'note_type': NoteType.checklist,
    },
    {
      'bg_color': const Color(0x174894b5),
      'color': const Color(0xff4894b5),
      'text_key': 'voice_note',
      'icon': Icons.mic_outlined,
      'note_type': NoteType.voice,
    },
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notesAsync = ref.watch(notesProvider);
    final repository = ref.read(notesProvider.notifier);
    final colorScheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final l10n = context.l10n(ref);

    return notesAsync.when(
      data: (notes) => Scaffold(
        backgroundColor: colorScheme.surface,
        appBar: AppBar(
          backgroundColor: colorScheme.surface,
          elevation: 0,
          title: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(
                    l10n.translate('app_title'),
                    style: TextStyle(
                      color: colorScheme.onSurface,
                      fontSize: 30,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    'X',
                    style: const TextStyle(
                      color: Color(0xfff9c35e),
                      fontSize: 33,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              Text(
                l10n.translate('app_subtitle'),
                style: GoogleFonts.nunito(
                  color: colorScheme.onSurface.withAlpha(115),
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          actions: [
            Padding(
              padding: const EdgeInsets.only(right: 10),
              child: Row(
                children: [
                  IconButton(
                    icon: Icon(
                      Icons.search_rounded,
                      color: colorScheme.onSurface,
                      size: 26,
                    ),
                    onPressed: () {
                      final nonTrashedNotes = notes
                          .where((n) => !n.isTrashed)
                          .toList();
                      context.push('/search', extra: nonTrashedNotes);
                    },
                  ),
                  const SizedBox(width: 4),
                  IconButton(
                    onPressed: () {
                      context.push('/settings');
                    },
                    icon: Icon(
                      Icons.settings_outlined,
                      color: colorScheme.onSurface,
                      size: 26,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        body: Column(
          children: [
            SizedBox(
              height: 100,
              child: ListView.separated(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                scrollDirection: Axis.horizontal,
                itemBuilder: (context, index) => InkWell(
                  onTap: () {
                    NoteModel note = repository.createNewNote(
                      _actions[index]['note_type'] as NoteType,
                    );
                    repository.addNote(note);
                    context.push('/note/${note.id}/edit');
                  },
                  borderRadius: BorderRadius.circular(12),
                  child: Container(
                    width: 110,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      color: isDark
                          ? (_actions[index]['color'] as Color).withAlpha(40)
                          : _actions[index]['bg_color'] as Color,
                      border: isDark
                          ? Border.all(
                              color: (_actions[index]['color'] as Color)
                                  .withAlpha(80),
                            )
                          : null,
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          _actions[index]['icon'] as IconData,
                          color: _actions[index]['color'] as Color,
                          size: 28,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          l10n.translate(_actions[index]['text_key'] as String),
                          textAlign: TextAlign.center,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: GoogleFonts.nunito(
                            color: colorScheme.onSurface,
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                separatorBuilder: (context, index) => const SizedBox(width: 10),
                itemCount: _actions.length,
              ),
            ),
            Expanded(
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Icon(
                              Icons.timer_outlined,
                              color: colorScheme.onSurface.withAlpha(200),
                              size: 16,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              l10n.translate('recent_notes'),
                              style: GoogleFonts.nunito(
                                color: colorScheme.onSurface,
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                        IconButton(
                          onPressed: () {
                            context.push('/all_notes');
                          },
                          icon: Row(
                            children: [
                              Text(
                                l10n.translate('see_all'),
                                style: GoogleFonts.nunito(
                                  color: colorScheme.onSurface.withAlpha(150),
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              Icon(
                                Icons.arrow_forward_ios_outlined,
                                color: colorScheme.onSurface.withAlpha(150),
                                size: 12,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: GridView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 2,
                              crossAxisSpacing: 12,
                              mainAxisSpacing: 12,
                              childAspectRatio: 0.85,
                            ),
                        itemCount: notes.where((n) => !n.isTrashed).length,
                        itemBuilder: (context, index) {
                          final activeNotes = notes
                              .where((n) => !n.isTrashed)
                              .toList();
                          if (activeNotes.isEmpty) {
                            return Center(
                              child: Text(
                                l10n.translate('no_notes'),
                                style: GoogleFonts.nunito(
                                  fontSize: 16,
                                  color: colorScheme.onSurface.withAlpha(138),
                                ),
                              ),
                            );
                          }
                          return NoteCard(note: activeNotes[index]);
                        },
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            showModalBottomSheet(
              context: context,
              backgroundColor: colorScheme.surface,
              shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
              ),
              builder: (BuildContext context) {
                return Container(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: _actions.map((action) {
                      return ListTile(
                        leading: Icon(
                          action['icon'] as IconData,
                          color: action['color'] as Color,
                        ),
                        title: Text(
                          l10n.translate(action['text_key'] as String),
                          style: GoogleFonts.nunito(
                            color: colorScheme.onSurface,
                          ),
                        ),
                        onTap: () {
                          NoteModel note = repository.createNewNote(
                            action['note_type'] as NoteType,
                          );
                          repository.addNote(note);
                          context.pop();
                          context.push('/note/${note.id}/edit');
                        },
                      );
                    }).toList(),
                  ),
                );
              },
            );
          },
          backgroundColor: const Color(0xfff9c35e),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30),
          ),
          child: const Icon(Icons.add, color: Colors.black87, size: 30),
        ),
      ),
      error: (error, stackTrace) => Center(
        child: Text(
          'Erreur lors du chargement des notes : $error',
          style: const TextStyle(color: Colors.red),
        ),
      ),
      loading: () => const Center(child: CircularProgressIndicator()),
    );
  }
}
