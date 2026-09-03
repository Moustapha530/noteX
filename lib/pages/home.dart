import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:note_x/pages/note.dart';

class HomePage extends StatelessWidget {
  HomePage({super.key});

  final notes = [
    NoteModel(
      title: 'Idées de projet',
      content: 'Une application de prise de notes minimaliste avec synchronisation cloud...',
      creationDate: DateTime.now(),
      type: NoteType.note,
      pinned: true,
      isFavorite: true,
    ),
    NoteModel(
      title: 'Liste de courses',
      checklist: ['Pain', 'Lait', 'Œufs', 'Pommes', 'Café'],
      creationDate: DateTime.now().subtract(const Duration(days: 1)),
      type: NoteType.checklist,
      isFavorite: false,
    ),
    NoteModel(
      title: 'Citation du jour',
      content: '“Le succès, c’est d’aller d’échec en échec sans perdre son enthousiasme.”\n– Winston Churchill',
      creationDate: DateTime.now().subtract(const Duration(days: 1)),
      type: NoteType.voice,
      isFavorite: true,
    ),
    NoteModel(
      title: 'Rendez-vous',
      content: 'Vendredi 30 août à 15h00\nRéunion avec l\'équipe\nPréparer la présentation',
      creationDate: DateTime(2024, 8, 28),
      type: NoteType.note,
      pinned: true,
      isFavorite: true,
    ),
    NoteModel(
      title: 'Note rapide',
      content: 'Ne pas oublier d\'appeler maman ce soir.',
      creationDate: DateTime(2024, 8, 27),
      type: NoteType.note,
      isFavorite: true,
    ),
    NoteModel(
      title: 'Voyage',
      imageUrl: 'https://images.unsplash.com/photo-1464822759023-fed622ff2c3b',
      creationDate: DateTime(2024, 8, 26),
      type: NoteType.image,
      isFavorite: true,
    ),
  ];

  final actions = [
    {
      'bg_color': const Color(0x17f5b839),
      'color': const Color(0xfff5b839),
      'text': 'Nouvelle note',
      'icon': Icons.note_add_outlined
    },
    {
      'bg_color': const Color(0x17759b4a),
      'color': const Color(0xff759b4a),
      'text': 'Checklist',
      'icon': Icons.check_box_outlined
    },
    {
      'bg_color': const Color(0x178c7ad5),
      'color': const Color(0xff8c7ad5),
      'text': 'Image note',
      'icon': Icons.image_outlined
    },
    {
      'bg_color': const Color(0x174894b5),
      'color': const Color(0xff4894b5),
      'text': 'Note vocal',
      'icon': Icons.image_outlined
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xfffdfaf8),
      appBar: AppBar(
        backgroundColor: const Color(0xfffdfaf8),
        elevation: 0,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Text(
                  'note',
                  style: TextStyle(
                      color: Colors.black87,
                      fontSize: 30,
                      fontWeight: FontWeight.bold),
                ),
                const Text(
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
                const Icon(
                  Icons.search_rounded,
                  color: Colors.black87,
                  size: 26,
                ),
                const SizedBox(width: 7),
                const Icon(
                  Icons.more_vert_rounded,
                  color: Colors.black87,
                  size: 26,
                )
              ],
            ),
          )
        ],
      ),
      body: Column(
        children: [
          SizedBox(
            height: 95,
            child: ListView.separated(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              scrollDirection: Axis.horizontal,
              itemBuilder: (context, index) => Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
                width: 110,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  color: actions[index]['bg_color'] as Color,
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      actions[index]['icon'] as IconData,
                      color: actions[index]['color'] as Color,
                      size: 30,
                    ),
                    const SizedBox(height: 5),
                    Text(
                      actions[index]['text'] as String,
                      style: GoogleFonts.nunito(
                        color: Colors.black87,
                        fontSize: 10,
                        fontWeight: FontWeight.w400,
                      ),
                    )
                  ],
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
                      Row(
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
                      itemCount: notes.length,
                      itemBuilder: (context, index) {
                        return NoteCard(note: notes[index]);
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
        onPressed: () {},
        backgroundColor: const Color(0xfff9c35e),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(30),
        ),
        child: const Icon(Icons.add, color: Colors.black87, size: 30),
      ),
    );
  }
}
