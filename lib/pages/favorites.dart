import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:note_x/l10n.dart';
import 'package:note_x/note/model.dart';
import 'package:note_x/note/repository.dart';
import 'package:note_x/note/card.dart';

class FavoritesPage extends ConsumerStatefulWidget {
  const FavoritesPage({super.key});

  @override
  ConsumerState<FavoritesPage> createState() => _FavoritesPageState();
}

class _FavoritesPageState extends ConsumerState<FavoritesPage> {
  String _selectedFilter = 'Tous';

  final List<Map<String, dynamic>> _types = [
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

  final filters = [
    {'label_key': 'filter_all', 'value': 'Tous'},
    {'label_key': 'filter_notes', 'value': 'Notes'},
    {'label_key': 'filter_checklists', 'value': 'Checklists'},
    {'label_key': 'filter_vocal', 'value': 'Vocal'},
  ];

  @override
  Widget build(BuildContext context) {
    final notesAsync = ref.watch(notesProvider);
    final repository = ref.read(notesProvider.notifier);
    final colorScheme = Theme.of(context).colorScheme;
    final l10n = context.l10n(ref);

    return notesAsync.when(
      data: (data) {
        var favoriteNotes = data
            .where((note) => note.isFavorite && !note.isTrashed)
            .toList();

        if (_selectedFilter == 'Notes') {
          favoriteNotes = favoriteNotes
              .where((n) => n.type == NoteType.note)
              .toList();
        } else if (_selectedFilter == 'Checklists') {
          favoriteNotes = favoriteNotes
              .where((n) => n.type == NoteType.checklist)
              .toList();
        } else if (_selectedFilter == 'Vocal') {
          favoriteNotes = favoriteNotes
              .where((n) => n.type == NoteType.voice)
              .toList();
        }

        return Scaffold(
          backgroundColor: colorScheme.surface,
          appBar: AppBar(
            automaticallyImplyLeading: false,
            backgroundColor: colorScheme.surface,
            elevation: 0,
            titleSpacing: 18,
            title: Row(
              children: [
                Text(
                  l10n.translate('app_title'),
                  style: GoogleFonts.nunito(
                    color: colorScheme.onSurface,
                    fontSize: 30,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                Text(
                  'X',
                  style: GoogleFonts.nunito(
                    color: const Color(0xfff5b839),
                    fontSize: 33,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
            actions: [
              Padding(
                padding: const EdgeInsets.only(right: 16),
                child: Row(
                  children: [
                    IconButton(
                      onPressed: () {
                        var notesToSearch = data
                            .where((n) => n.isFavorite && !n.isTrashed)
                            .toList();
                        context.push('/search', extra: notesToSearch);
                      },
                      icon: Icon(
                        Icons.search_rounded,
                        color: colorScheme.onSurface,
                        size: 28,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          body: SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(
                        Icons.star_rounded,
                        color: Color(0xfff5b839),
                        size: 30,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        l10n.translate('favorites'),
                        style: GoogleFonts.nunito(
                          color: colorScheme.onSurface,
                          fontSize: 28,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    l10n.translate('favorites_subtitle'),
                    style: GoogleFonts.nunito(
                      color: colorScheme.onSurface.withAlpha(138),
                      fontSize: 17,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    height: 48,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      itemCount: filters.length,
                      separatorBuilder: (context, index) =>
                          const SizedBox(width: 12),
                      itemBuilder: (context, index) {
                        final filter = filters[index];
                        return FilterChipWidget(
                          label: l10n.translate(filter['label_key']!),
                          active: _selectedFilter == filter['value'],
                          onTap: () {
                            setState(() {
                              _selectedFilter = filter['value']!;
                            });
                          },
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 18),
                  Expanded(
                    child: favoriteNotes.isEmpty
                        ? Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.star_border_rounded,
                                  color: colorScheme.onSurface.withAlpha(66),
                                  size: 64,
                                ),
                                const SizedBox(height: 12),
                                Text(
                                  _selectedFilter == 'Tous'
                                      ? l10n.translate('no_notes')
                                      : l10n.translate('no_results'),
                                  style: GoogleFonts.nunito(
                                    fontSize: 16,
                                    color: colorScheme.onSurface.withAlpha(138),
                                  ),
                                ),
                              ],
                            ),
                          )
                        : GridView.builder(
                            itemCount: favoriteNotes.length,
                            gridDelegate:
                                const SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: 2,
                                  crossAxisSpacing: 14,
                                  mainAxisSpacing: 14,
                                  childAspectRatio: 0.84,
                                ),
                            itemBuilder: (context, index) {
                              return NoteCard(
                                note: favoriteNotes[index],
                                isInFavorites: true,
                              );
                            },
                          ),
                  ),
                ],
              ),
            ),
          ),
          floatingActionButton: Container(
            width: 64,
            height: 64,
            margin: const EdgeInsets.only(bottom: 18),
            child: FloatingActionButton(
              onPressed: () {
                showModalBottomSheet(
                  context: context,
                  backgroundColor: colorScheme.surface,
                  shape: const RoundedRectangleBorder(
                    borderRadius: BorderRadius.vertical(
                      top: Radius.circular(20),
                    ),
                  ),
                  builder: (BuildContext context) {
                    return Container(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: _types.map((noteTypeMap) {
                          return ListTile(
                            leading: Icon(
                              noteTypeMap['icon'] as IconData,
                              color: noteTypeMap['color'] as Color,
                            ),
                            title: Text(
                              l10n.translate(noteTypeMap['text_key'] as String),
                              style: GoogleFonts.nunito(
                                color: colorScheme.onSurface,
                              ),
                            ),
                            onTap: () {
                              NoteModel note = repository.createNewNote(
                                noteTypeMap['note_type'] as NoteType,
                              );
                              repository.addNote(note);
                              context.push('/note/${note.id}/edit');
                            },
                          );
                        }).toList(),
                      ),
                    );
                  },
                );
              },
              backgroundColor: const Color(0xfff5b839),
              shape: const CircleBorder(),
              child: const Icon(Icons.add, color: Colors.black87, size: 36),
            ),
          ),
          floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
        );
      },
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

class FilterChipWidget extends StatelessWidget {
  const FilterChipWidget({
    super.key,
    required this.label,
    required this.onTap,
    this.active = false,
  });

  final String label;
  final bool active;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
        decoration: BoxDecoration(
          color: active
              ? (isDark
                    ? const Color(0xfff5b839).withAlpha(40)
                    : const Color(0xfff5f0e9))
              : Colors.transparent,
          border: Border.all(
            color: active
                ? const Color(0xfff5b839)
                : colorScheme.onSurface.withAlpha(66),
            width: 1.2,
          ),
          borderRadius: BorderRadius.circular(18),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (active)
              Icon(
                Icons.check,
                size: 16,
                color: isDark ? const Color(0xfff5b839) : Colors.black87,
              )
            else
              const SizedBox.shrink(),
            if (active) const SizedBox(width: 6),
            Text(
              label,
              style: GoogleFonts.nunito(
                color: active && isDark
                    ? const Color(0xfff5b839)
                    : colorScheme.onSurface,
                fontSize: 14,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
