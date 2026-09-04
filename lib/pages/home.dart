import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:note_x/note/model.dart';
import 'package:note_x/note/card.dart';
import 'package:note_x/note/repository.dart';

class HomePage extends ConsumerWidget {
  HomePage({super.key});

  final actions = [
    {
      'bg_color': const Color(0x17f5b839),
      'color': const Color(0xfff5b839),
      'text': 'Nouvelle note',
      'icon': Icons.note_add_outlined,
      'note_type': NoteType.note
    },
    {
      'bg_color': const Color(0x17759b4a),
      'color': const Color(0xff759b4a),
      'text': 'Checklist',
      'icon': Icons.check_box_outlined,
      'note_type': NoteType.checklist
    },
    {
      'bg_color': const Color(0x178c7ad5),
      'color': const Color(0xff8c7ad5),
      'text': 'Image note',
      'icon': Icons.image_outlined,
      'note_type': NoteType.image
    },
    {
      'bg_color': const Color(0x174894b5),
      'color': const Color(0xff4894b5),
      'text': 'Note vocal',
      'icon': Icons.mic_outlined,
      'note_type': NoteType.voice
    },
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notesAsync = ref.watch(notesProvider);
    final repository = ref.read(notesProvider.notifier);

    return notesAsync.when(
      data: (notes) => Scaffold(
        backgroundColor: const Color(0xfffdfaf8),
        appBar: AppBar(
          backgroundColor: const Color(0xfffdfaf8),
          elevation: 0,
          title: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: const [
                  Text(
                    'note',
                    style: TextStyle(
                        color: Colors.black87,
                        fontSize: 30,
                        fontWeight: FontWeight.bold),
                  ),
                  Text(
                    'X',
                    style: TextStyle(
                        color: Color(0xfff9c35e),
                        fontSize: 33,
                        fontWeight: FontWeight.bold),
                  )
                ],
              ),
              Text(
                'Vos pensées, organisées avec simplicité',
                style: GoogleFonts.nunito(
                    color: Colors.black45,
                    fontSize: 12,
                    fontWeight: FontWeight.w500),
              )
            ],
          ),
          actions: [
            Padding(
              padding: const EdgeInsets.only(right: 10),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.search_rounded, color: Colors.black87, size: 26),
                    onPressed: () {
                      final nonTrashedNotes = notes.where((n) => !n.isTrashed).toList();
                      context.push('/search', extra: nonTrashedNotes);
                    },
                  ),
                  const SizedBox(width: 4),
                  IconButton(
                    onPressed: () {
                      context.push('/settings');
                    }, 
                    icon: const Icon(
                      Icons.settings_outlined,
                      color: Colors.black87,
                      size: 26,
                    )
                  )
                ],
              ),
            )
          ],
        ),
        body: Column(
          children: [
            SizedBox(
              height: 100,
              child: ListView.separated(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                scrollDirection: Axis.horizontal,
                itemBuilder: (context, index) => InkWell(
                  onTap: () {
                    NoteModel note = repository.createNewNote(actions[index]['note_type'] as NoteType);
                    repository.addNote(note);
                    context.push('/note/${note.id}/edit');
                  },
                  borderRadius: BorderRadius.circular(12),
                  child: Container(
                    width: 110,
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      color: actions[index]['bg_color'] as Color,
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          actions[index]['icon'] as IconData,
                          color: actions[index]['color'] as Color,
                          size: 28,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          actions[index]['text'] as String,
                          textAlign: TextAlign.center,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: GoogleFonts.nunito(
                            color: Colors.black87,
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                separatorBuilder: (context, index) => const SizedBox(width: 10),
                itemCount: actions.length,
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
                            const Icon(
                              Icons.timer_outlined,
                              color: Colors.black87,
                              size: 16,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              'Notes récentes',
                              style: GoogleFonts.nunito(
                                color: Colors.black87,
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
                                'Voir tout',
                                style: GoogleFonts.nunito(
                                  color: Colors.black87,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              const Icon(
                                Icons.arrow_forward_ios_outlined,
                                color: Colors.black87,
                                size: 12,
                              ),
                            ],
                          )
                        )
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
                          if (notes.where((n) => !n.isTrashed).isEmpty) {
                            return Center(
                              child: Text(
                                'Aucune note disponible.',
                                style: GoogleFonts.nunito(
                                  fontSize: 16,
                                  color: Colors.black54,
                                ),
                              ),
                            );
                          }
                          final activeNotes = notes.where((n) => !n.isTrashed).toList();
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
              shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
              ),
              builder: (BuildContext context) {
                return Container(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: actions.map((action) {
                      return ListTile(
                        leading: Icon(action['icon'] as IconData, color: action['color'] as Color),
                        title: Text(action['text'] as String),
                        onTap: () {
                          NoteModel note = repository.createNewNote(action['note_type'] as NoteType);
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
      loading: () => const Center(
        child: CircularProgressIndicator(),
      ),
    );
  }
}