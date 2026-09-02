import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:note_x/pages/note.dart';

class RecyclePage extends StatelessWidget {
  RecyclePage({super.key});

  final List<NoteModel> recycledNotes = [
    NoteModel(
      title: 'Idées de projet',
      content: 'Une application de prise de notes minimaliste avec synchronisation cloud...',
      creationDate: DateTime(2024, 8, 10, 10, 28),
      type: NoteType.idea,
      pinned: true,
      isFavorite: true,
    ),
    NoteModel(
      title: 'Liste de courses',
      checklist: ['Pain', 'Lait', 'Œufs', 'Pommes', 'Café'],
      creationDate: DateTime(2024, 8, 9),
      type: NoteType.checklist,
      pinned: false,
      isFavorite: true,
    ),
    NoteModel(
      title: 'Citation du jour',
      content: '“Le succès, c’est d’aller d’échec en échec sans perdre son enthousiasme.”\n– Winston Churchill',
      creationDate: DateTime(2024, 8, 9),
      type: NoteType.voice,
      isFavorite: true,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: const Color(0xfff5f3f1),
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
              children: const [
                Icon(Icons.search_rounded, color: Colors.black87, size: 28),
                SizedBox(width: 14),
                Icon(Icons.more_vert_rounded, color: Colors.black87, size: 28),
              ],
            ),
          ),
        ],
      ),
      body: SafeArea(
          child: Padding(
            padding: EdgeInsetsGeometry.all(10),
            child: Column(
              children: [
                SizedBox(height: 8,),
                Row(
                  children: [
                    Icon(
                      Icons.delete_rounded,
                      color: Color(0xfff5b839),
                      size: 30
                    ),
                    SizedBox(width: 8,),
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
                SizedBox(height: 8,),
                Expanded(
                  child: GridView.builder(
                    itemCount: recycledNotes.length,
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 14,
                      mainAxisSpacing: 14,
                      childAspectRatio: 0.84,
                    ),
                    itemBuilder: (context, index) {
                      return NoteCard(note: recycledNotes[index]);
                    },
                  ),
                ),
              ],
            ),
          )
      ),
    );
  }
}