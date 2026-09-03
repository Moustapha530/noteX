import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:note_x/pages/note.dart';

class AllNotes extends StatelessWidget {
  AllNotes({super.key});

  final List<NoteModel> notes = [
    NoteModel(
      title: 'Idées de projet',
      content: 'Une application de prise de notes minimaliste avec synchronisation cloud...',
      creationDate: DateTime(2024, 8, 10, 10, 28),
      type: NoteType.note,
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
    NoteModel(
      title: 'Note rapide',
      content: 'Ne pas oublier d\'appeler maman ce soir.',
      creationDate: DateTime(2024, 8, 27),
      type: NoteType.note,
      pinned: true,
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
      title: 'Voyage',
      imageUrl: 'https://images.unsplash.com/photo-1501785888041-af3ef285b470',
      creationDate: DateTime(2024, 8, 26),
      type: NoteType.image,
      isFavorite: true,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xfff5f3f1),
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: const Color(0xfff5f3f1),
        elevation: 0,
        titleSpacing: 18,
        title: Row(
          children: [
            Icon(
              Icons.notes,
              color: Color(0xfff5b839),
              size: 30,
            ),
            Text(
              'Toutes les notes',
              style: GoogleFonts.nunito(
                  color: Colors.black87,
                  fontSize: 30,
                  fontWeight: FontWeight.bold
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
          if (active)
            const Icon(
              Icons.check,
              size: 16,
              color: Colors.black87,
            )
          else
            const SizedBox.shrink(),
          if (active) const SizedBox(width: 6),
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
