import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:note_x/note/card.dart';
import 'package:note_x/note/repository.dart';

class TrashPage extends ConsumerWidget {
  const TrashPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notesAsync = ref.watch(notesProvider);

    return Scaffold(
      backgroundColor: const Color(0xfffdfaf8),
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: const Color(0xfffdfaf8),
        elevation: 0,
        titleSpacing: 18,
        title: Row(
          children: [
            Text(
              'note',
              style: GoogleFonts.nunito(
                color: Colors.black87,
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
                notesAsync.when(
                  data: (notes) {
                    final trashedNotes = notes.where((n) => n.isTrashed).toList();
                    return IconButton(
                      onPressed: () {
                        context.push('/search', extra: trashedNotes);
                      },
                      icon : Icon(
                          Icons.search_rounded,
                          color: Colors.black87,
                          size: 28
                      ),
                    );
                  },
                  loading: () => CircularProgressIndicator(),
                  error: (error, stackTrace) => IconButton(
                    onPressed: () {},
                    icon : Icon(
                      Icons.search_rounded,
                      color: Colors.black87,
                      size: 28
                    ),
                  ),
                )
              ],
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(
                    Icons.delete_rounded,
                    color: Color(0xfff5b839),
                    size: 30,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Corbeille',
                    style: GoogleFonts.nunito(
                      color: Colors.black87,
                      fontSize: 28,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Expanded(
                child: notesAsync.when(
                  data: (notes) {
                    final trashedNotes = notes.where((note) => note.isTrashed).toList();

                    if (trashedNotes.isEmpty) {
                      return Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.delete_outline_rounded,
                              size: 64,
                              color: Colors.black26,
                            ),
                            const SizedBox(height: 12),
                            Text(
                              'La corbeille est vide',
                              style: GoogleFonts.nunito(
                                fontSize: 18,
                                fontWeight: FontWeight.w700,
                                color: Colors.black54,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Les notes supprimées apparaîtront ici',
                              style: GoogleFonts.nunito(
                                fontSize: 13,
                                color: Colors.black38,
                              ),
                            ),
                          ],
                        ),
                      );
                    }

                    return GridView.builder(
                      itemCount: trashedNotes.length,
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        crossAxisSpacing: 14,
                        mainAxisSpacing: 14,
                        childAspectRatio: 0.84,
                      ),
                      itemBuilder: (context, index) {
                        return NoteCard(note: trashedNotes[index], isInTrash: true);
                      },
                    );
                  },
                  loading: () => const Center(
                    child: CircularProgressIndicator(),
                  ),
                  error: (error, _) => Center(
                    child: Text(
                      'Erreur : $error',
                      style: const TextStyle(color: Colors.red),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}