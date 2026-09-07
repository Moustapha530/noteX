import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:note_x/note/card.dart';
import 'package:note_x/note/model.dart';
import 'package:note_x/l10n.dart';

class SearchNotePage extends ConsumerStatefulWidget {
  final List<NoteModel> notes;

  const SearchNotePage({
    super.key,
    required this.notes,
  });

  @override
  ConsumerState<SearchNotePage> createState() => _SearchNotePageState();
}

class _SearchNotePageState extends ConsumerState<SearchNotePage> {
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
    final colorScheme = Theme.of(context).colorScheme;
    final l10n = context.l10n(ref);

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: AppBar(
        backgroundColor: colorScheme.surface,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: colorScheme.onSurface),
          onPressed: () => Navigator.pop(context),
        ),
        title: TextField(
          controller: _searchController,
          autofocus: true,
          onChanged: _onSearchChanged,
          style: GoogleFonts.nunito(
            color: colorScheme.onSurface,
            fontSize: 18,
          ),
          decoration: InputDecoration(
            hintText: l10n.translate('search_hint'),
            hintStyle: GoogleFonts.nunito(
              color: colorScheme.onSurface.withAlpha(115),
              fontSize: 18,
            ),
            border: InputBorder.none,
          ),
        ),
        actions: [
          if (_searchController.text.isNotEmpty)
            IconButton(
              icon: Icon(Icons.clear, color: colorScheme.onSurface),
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
                    l10n.translate('no_results'),
                    style: GoogleFonts.nunito(
                      fontSize: 16,
                      color: colorScheme.onSurface.withAlpha(138),
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
