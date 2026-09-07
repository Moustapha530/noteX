import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';
import 'package:note_x/note/card.dart';
import 'package:note_x/note/repository.dart';

import 'package:note_x/l10n.dart';

class AllNotes extends ConsumerWidget {
  const AllNotes({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notesAsync = ref.watch(notesProvider);
    final colorScheme = Theme.of(context).colorScheme;
    final l10n = context.l10n(ref);

    return notesAsync.when(
      data: (notes) {
        return Scaffold(
          backgroundColor: colorScheme.surface,
          appBar: AppBar(
            leading: IconButton(
              icon: Icon(Icons.arrow_back, color: colorScheme.onSurface),
              onPressed: () => context.pop(),
            ),
            backgroundColor: colorScheme.surface,
            elevation: 0,
            titleSpacing: 0,
            title: Row(
              children: [
                const Icon(Icons.notes, color: Color(0xfff5b839), size: 30),
                const SizedBox(width: 8),
                Text(
                  l10n.translate('all_notes'),
                  style: GoogleFonts.nunito(
                    color: colorScheme.onSurface,
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
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
                      icon: Icon(
                        Icons.search_rounded,
                        color: colorScheme.onSurface,
                        size: 28,
                      ),
                      onPressed: () {
                        context.push('/search', extra: notes);
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
          body: notes.where((n) => !n.isTrashed).isEmpty
              ? Center(
                  child: Text(
                    l10n.translate('no_notes'),
                    style: GoogleFonts.nunito(
                      fontSize: 18,
                      color: colorScheme.onSurface.withAlpha(138),
                    ),
                  ),
                )
              : SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 18),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 8),
                        Text(
                          l10n.translate('all_notes_subtitle'),
                          style: GoogleFonts.nunito(
                            color: colorScheme.onSurface.withAlpha(138),
                            fontSize: 17,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 16),
                        SizedBox(
                          height: 48,
                          child: ListView(
                            scrollDirection: Axis.horizontal,
                            children: [
                              FilterChipWidget(
                                label: l10n.translate('filter_all'),
                                active: true,
                              ),
                              const SizedBox(width: 12),
                              FilterChipWidget(
                                label: l10n.translate('filter_notes'),
                              ),
                              const SizedBox(width: 12),
                              FilterChipWidget(
                                label: l10n.translate('filter_checklists'),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 18),
                        Expanded(
                          child: GridView.builder(
                            itemCount: notes.length,
                            gridDelegate:
                                const SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: 2,
                                  crossAxisSpacing: 14,
                                  mainAxisSpacing: 14,
                                  childAspectRatio: 0.84,
                                ),
                            itemBuilder: (context, index) {
                              return NoteCard(note: notes[index]);
                            },
                          ),
                        ),
                      ],
                    ),
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
  const FilterChipWidget({super.key, required this.label, this.active = false});

  final String label;
  final bool active;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
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
          if (active) ...[
            Icon(
              Icons.check,
              size: 16,
              color: isDark ? const Color(0xfff5b839) : Colors.black87,
            ),
            const SizedBox(width: 6),
          ],
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
    );
  }
}
