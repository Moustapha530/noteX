import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';
import 'package:note_x/note/card.dart';
import 'package:note_x/note/repository.dart';

class AllNotes extends ConsumerWidget {
  const AllNotes({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notesAsync = ref.watch(notesProvider);
    return notesAsync.when(
      data: (notes) {
        return Scaffold(
          backgroundColor: const Color(0xfff5f3f1),
          appBar: AppBar(
            leading: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.black87),
              onPressed: () => context.pop(),
            ),
            backgroundColor: const Color(0xfff5f3f1),
            elevation: 0,
            titleSpacing: 0,
            title: Row(
              children: [
                const Icon(
                  Icons.notes,
                  color: Color(0xfff5b839),
                  size: 30,
                ),
                const SizedBox(width: 8),
                Text(
                  'Toutes les notes',
                  style: GoogleFonts.nunito(
                    color: Colors.black87,
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
                      icon: const Icon(Icons.search_rounded, color: Colors.black87, size: 28),
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
                    'Aucune note enregistrée.',
                    style: GoogleFonts.nunito(fontSize: 18, color: Colors.black54),
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
                          'Toutes les notes enregistrées',
                          style: GoogleFonts.nunito(
                            color: Colors.black54,
                            fontSize: 17,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 16),
                        SizedBox(
                          height: 48,
                          child: ListView(
                            scrollDirection: Axis.horizontal,
                            children: const [
                              FilterChipWidget(label: 'Tous', active: true),
                              SizedBox(width: 12),
                              FilterChipWidget(label: 'Notes'),
                              SizedBox(width: 12),
                              FilterChipWidget(label: 'Checklists'),
                              SizedBox(width: 12),
                              FilterChipWidget(label: 'Images'),
                            ],
                          ),
                        ),
                        const SizedBox(height: 18),
                        Expanded(
                          child: GridView.builder(
                            itemCount: notes.length,
                            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
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
      loading: () => const Center(
        child: CircularProgressIndicator(),
      ),
    );
  }
}

class FilterChipWidget extends StatelessWidget {
  const FilterChipWidget({
    super.key,
    required this.label,
    this.active = false,
  });

  final String label;
  final bool active;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
      decoration: BoxDecoration(
        color: active ? const Color(0xfff5f0e9) : Colors.transparent,
        border: Border.all(color: Colors.black26, width: 1.2),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (active) ...[
            const Icon(
              Icons.check,
              size: 16,
              color: Colors.black87,
            ),
            const SizedBox(width: 6),
          ],
          Text(
            label,
            style: GoogleFonts.nunito(
              color: Colors.black87,
              fontSize: 14,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}