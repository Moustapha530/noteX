import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_quill/flutter_quill.dart' as quill;
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';
import 'package:note_x/note/model.dart';
import 'package:note_x/note/repository.dart';

class EditNotePage extends ConsumerStatefulWidget {
  final String noteId;

  const EditNotePage({
    super.key,
    required this.noteId,
  });

  @override
  ConsumerState<EditNotePage> createState() => _EditNotePageState();
}

class _EditNotePageState extends ConsumerState<EditNotePage> {
  late final TextEditingController _titleController;
  late final quill.QuillController _quillController;
  NoteModel? _note;

  late bool _isFavorite;
  late bool _isPinned;
  late String _id;

  final FocusNode _editorFocusNode = FocusNode();

  static const Color primaryColor = Color(0xFFFFB72B);
  static const Color backgroundColor = Color(0xFFFFFCF7);
  static const Color textColor = Color(0xFF252525);
  static const Color secondaryTextColor = Color(0xFF747474);

  @override
  void initState() {
    super.initState();
    // Initialize after the first frame so ref is fully available
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeNote();
    });
  }

  Future<void> _initializeNote() async {
    // Access the repository notifier correctly via Riverpod
    final repository = ref.read(notesProvider.notifier);
    
    var note = await repository.getNoteById(widget.noteId);
    if (note == null) {
      final newNote = repository.createNewNote(NoteType.note);
      await repository.addNote(newNote);
      note = newNote;
    }

    if (!mounted) return;

    _note = note;
    _titleController = TextEditingController(text: note.title);
    _isFavorite = note.isFavorite;
    _isPinned = note.pinned;
    _id = note.id;

    _quillController = quill.QuillController(
      document: _createDocument(note.content),
      selection: const TextSelection.collapsed(offset: 0),
    );

    setState(() {});
  }

  quill.Document _createDocument(String? content) {
    if (content == null || content.isEmpty) {
      return quill.Document();
    }

    try {
      final decoded = jsonDecode(content);
      if (decoded is List) {
        return quill.Document.fromJson(decoded);
      }
    } catch (_) {}

    return quill.Document()..insert(0, content);
  }

  void _saveNote() {
    if (_note == null) return;

    final title = _titleController.text.trim();

    if (title.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Veuillez donner un titre à votre note.'),
        ),
      );
      return;
    }

    final deltaJson = jsonEncode(
      _quillController.document.toDelta().toJson(),
    );

    final updatedNote = NoteModel(
      id: _id,
      title: title,
      content: deltaJson,
      checklist: _note!.checklist,
      imageUrl: _note!.imageUrl,
      lastModified: DateTime.now(),
      type: _note!.type,
      pinned: _isPinned,
      isFavorite: _isFavorite,
    );

    // Call update through Riverpod notifier
    ref.read(notesProvider.notifier).updateNote(updatedNote);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Note "${updatedNote.title}" enregistrée.',
          style: GoogleFonts.nunito(
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
        duration: Duration(seconds: 3), // How long it stays visible
      ),
    );
  }

  void _cancel() {
    context.pop();
  }

  void _toggleFavorite() {
    setState(() {
      _isFavorite = !_isFavorite;
    });
  }

  void _togglePinned() {
    setState(() {
      _isPinned = !_isPinned;
    });
  }

  Color _getAccentColor() {
    if (_note == null) return const Color(0xFFF5B839);

    switch (_note!.type) {
      case NoteType.note:
        return const Color(0xFFF5B839);
      case NoteType.checklist:
        return const Color(0xFF759B4A);
      case NoteType.voice:
        return const Color(0xFF4894B5);
      case NoteType.image:
        return const Color(0xFF8C7AD5);
    }
  }

  String _getTypeName() {
    if (_note == null) return 'Note';

    switch (_note!.type) {
      case NoteType.note:
        return 'Note';
      case NoteType.checklist:
        return 'Checklist';
      case NoteType.voice:
        return 'Note vocale';
      case NoteType.image:
        return 'Image';
    }
  }

  String _formatDate(DateTime date) {
    final months = [
      'janv.', 'févr.', 'mars', 'avr.', 'mai', 'juin',
      'juil.', 'août', 'sept.', 'oct.', 'nov.', 'déc.'
    ];

    return '${date.day} ${months[date.month - 1]} ${date.year} à '
        '${date.hour.toString().padLeft(2, '0')}:'
        '${date.minute.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    if (_note == null) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        backgroundColor: backgroundColor,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        leading: IconButton(
          onPressed: _cancel,
          icon: const Icon(Icons.arrow_back, color: textColor),
        ),
        titleSpacing: 0,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Modifier la note',
              style: GoogleFonts.nunito(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: textColor,
              ),
            ),
            Text(
              'Dernière modification',
              style: GoogleFonts.nunito(
                fontSize: 12,
                color: secondaryTextColor,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            onPressed: _toggleFavorite,
            icon: Icon(
              _isFavorite ? Icons.star : Icons.star_border,
              color: _isFavorite ? primaryColor : textColor,
            ),
          ),
          IconButton(
            onPressed: _togglePinned,
            icon: Icon(
              _isPinned ? Icons.push_pin : Icons.push_pin_outlined,
              color: _isPinned ? primaryColor : textColor,
            ),
          ),
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert, color: textColor),
            onSelected: (value) {
              if (value == 'delete') {
                _showDeleteDialog();
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'delete',
                child: Row(
                  children: [
                    Icon(Icons.delete_outline, color: Colors.red),
                    SizedBox(width: 10),
                    Text('Supprimer'),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(child: _buildEditor()),
            _buildFormattingToolbar(),
            _buildBottomActions(),
          ],
        ),
      ),
    );
  }

  Widget _buildEditor() {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 8, 16, 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
            child: Row(
              children: [
                Container(
                  width: 10,
                  height: 10,
                  decoration: BoxDecoration(
                    color: _getAccentColor(),
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 10),
                Text(
                  _getTypeName(),
                  style: GoogleFonts.nunito(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: textColor,
                  ),
                ),
                const SizedBox(width: 4),
                const Icon(
                  Icons.keyboard_arrow_down,
                  size: 18,
                  color: secondaryTextColor,
                ),
                const Spacer(),
                Text(
                  _formatDate(_note!.lastModified),
                  style: GoogleFonts.nunito(
                    fontSize: 11,
                    color: secondaryTextColor,
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1, indent: 20, endIndent: 20),
          TextField(
            controller: _titleController,
            style: GoogleFonts.nunito(
              fontSize: 25,
              fontWeight: FontWeight.w800,
              color: textColor,
            ),
            decoration: InputDecoration(
              hintText: 'Titre',
              hintStyle: GoogleFonts.nunito(
                fontSize: 25,
                fontWeight: FontWeight.w800,
                color: Colors.black26,
              ),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
            ),
            maxLines: 1,
          ),
          Expanded(
            child: quill.QuillEditor.basic(
              controller: _quillController,
              focusNode: _editorFocusNode,
              config: quill.QuillEditorConfig(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
                placeholder: 'Commencez à écrire...',
                customStyles: quill.DefaultStyles(
                  paragraph: quill.DefaultTextBlockStyle(
                    GoogleFonts.nunito(
                      fontSize: 17,
                      color: textColor,
                      height: 1.45,
                    ),
                    const quill.HorizontalSpacing(0, 0),
                    const quill.VerticalSpacing(4, 4),
                    const quill.VerticalSpacing(0, 0),
                    null,
                  ),
                  h1: quill.DefaultTextBlockStyle(
                    GoogleFonts.nunito(
                      fontSize: 28,
                      fontWeight: FontWeight.w800,
                      color: textColor,
                    ),
                    const quill.HorizontalSpacing(0, 0),
                    const quill.VerticalSpacing(8, 8),
                    const quill.VerticalSpacing(0, 0),
                    null,
                  ),
                  h2: quill.DefaultTextBlockStyle(
                    GoogleFonts.nunito(
                      fontSize: 23,
                      fontWeight: FontWeight.w700,
                      color: textColor,
                    ),
                    const quill.HorizontalSpacing(0, 0),
                    const quill.VerticalSpacing(6, 6),
                    const quill.VerticalSpacing(0, 0),
                    null,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFormattingToolbar() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.black.withAlpha(40)),
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            _formatButton(
              icon: Icons.format_bold,
              attribute: quill.Attribute.bold,
            ),
            _formatButton(
              icon: Icons.format_italic,
              attribute: quill.Attribute.italic,
            ),
            _formatButton(
              icon: Icons.format_underlined,
              attribute: quill.Attribute.underline,
            ),
            _formatButton(
              icon: Icons.strikethrough_s,
              attribute: quill.Attribute.strikeThrough,
            ),
            _divider(),
            _formatButton(
              icon: Icons.format_align_left,
              attribute: quill.Attribute.leftAlignment,
            ),
            _formatButton(
              icon: Icons.format_align_center,
              attribute: quill.Attribute.centerAlignment,
            ),
            _formatButton(
              icon: Icons.format_align_right,
              attribute: quill.Attribute.rightAlignment,
            ),
            _divider(),
            _formatButton(
              icon: Icons.format_list_bulleted,
              attribute: quill.Attribute.ul,
            ),
            _formatButton(
              icon: Icons.format_list_numbered,
              attribute: quill.Attribute.ol,
            ),
            _formatButton(
              icon: Icons.check_box_outlined,
              attribute: quill.Attribute.unchecked,
            ),
            _divider(),
            _headingButton(1),
            _headingButton(2),
            _headingButton(3),
            _divider(),
            IconButton(
              tooltip: 'Citation',
              onPressed: _toggleQuote,
              icon: const Icon(Icons.format_quote, size: 21),
            ),
          ],
        ),
      ),
    );
  }

  Widget _formatButton({
    required IconData icon,
    required quill.Attribute attribute,
  }) {
    return IconButton(
      tooltip: attribute.key,
      onPressed: () {
        _quillController.formatSelection(attribute);
      },
      icon: Icon(icon, size: 21),
    );
  }

  Widget _headingButton(int level) {
    return IconButton(
      tooltip: 'Titre $level',
      onPressed: () {
        final attribute = switch (level) {
          1 => quill.Attribute.h1,
          2 => quill.Attribute.h2,
          _ => quill.Attribute.h3,
        };

        _quillController.formatSelection(attribute);
      },
      icon: Text(
        'H$level',
        style: GoogleFonts.nunito(
          fontSize: 15,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }

  void _toggleQuote() {
    _quillController.formatSelection(quill.Attribute.blockQuote);
  }

  Widget _divider() {
    return Container(
      width: 1,
      height: 28,
      margin: const EdgeInsets.symmetric(horizontal: 5),
      color: Colors.black12,
    );
  }

  Widget _buildBottomActions() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 12),
      child: Row(
        children: [
          Expanded(
            child: OutlinedButton(
              onPressed: _cancel,
              style: OutlinedButton.styleFrom(
                minimumSize: const Size(double.infinity, 52),
                side: BorderSide(color: primaryColor.withAlpha(125)),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              child: Text(
                'Annuler',
                style: GoogleFonts.nunito(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: primaryColor,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: ElevatedButton(
              onPressed: _saveNote,
              style: ElevatedButton.styleFrom(
                backgroundColor: primaryColor,
                foregroundColor: textColor,
                elevation: 0,
                minimumSize: const Size(double.infinity, 52),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              child: Text(
                'Enregistrer',
                style: GoogleFonts.nunito(
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  color: textColor,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showDeleteDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Supprimer la note ?'),
          content: const Text(
            'Cette action déplacera la note vers la corbeille.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Annuler'),
            ),
            TextButton(
              onPressed: () {
                if (_note != null) {
                  ref.read(notesProvider.notifier).moveToTrash(_note!.id);
                }
                Navigator.pop(context); // Close the dialog
                context.pop(); // Navigate back to the previous screen
              },
              child: const Text(
                'Supprimer',
                style: TextStyle(color: Colors.red),
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  void dispose() {
    _titleController.dispose();
    _quillController.dispose();
    _editorFocusNode.dispose();
    super.dispose();
  }
}