import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:note_x/note/card.dart';
import 'package:note_x/note/model.dart';

class SearchNotePage extends StatefulWidget {
  final List<NoteModel> notes;

  const SearchNotePage({
    super.key,
    required this.notes,
  });

  @override
  State<SearchNotePage> createState() => _SearchNotePageState();
}

class _SearchNotePageState extends State<SearchNotePage> {
  final TextEditingController _searchController = TextEditingController();
  List<NoteModel> _filteredNotes = [];

  @override
  void initState() {
    super.initState();
    _filteredNotes = widget.notes;
  }

  void _onSearchChanged(String query) {
    setState(() {
      if (query.trim().isEmpty) {
        _filteredNotes = widget.notes;
      } else {
        _filteredNotes = widget.notes.where((note) {
          final titleMatch = note.title.toLowerCase().contains(query.toLowerCase());
          final plainContent = getPlainTextFromContent(note.content ?? '');
          final contentMatch = plainContent.toLowerCase().contains(query.toLowerCase());
          return titleMatch || contentMatch;
        }).toList();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xfff5f3f1),
      appBar: AppBar(
        backgroundColor: const Color(0xfff5f3f1),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black87),
          onPressed: () => Navigator.pop(context),
        ),
        title: TextField(
          controller: _searchController,
          autofocus: true,
          onChanged: _onSearchChanged,
          style: GoogleFonts.nunito(
            color: Colors.black87,
            fontSize: 18,
          ),
          decoration: InputDecoration(
            hintText: 'Rechercher une note...',
            hintStyle: GoogleFonts.nunito(
              color: Colors.black45,
              fontSize: 18,
            ),
            border: InputBorder.none,
          ),
        ),
        actions: [
          if (_searchController.text.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.clear, color: Colors.black87),
              onPressed: () {
                _searchController.clear();
                _onSearchChanged('');
              },
            ),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
          child: _filteredNotes.isEmpty
              ? Center(
                  child: Text(
                    'Aucun résultat trouvé.',
                    style: GoogleFonts.nunito(
                      fontSize: 16,
                      color: Colors.black54,
                    ),
                  ),
                )
              : GridView.builder(
                  itemCount: _filteredNotes.length,
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 14,
                    mainAxisSpacing: 14,
                    childAspectRatio: 0.84,
                  ),
                  itemBuilder: (context, index) {
                    return NoteCard(note: _filteredNotes[index]);
                  },
                ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
}