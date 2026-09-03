import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart' as quill;
import 'package:google_fonts/google_fonts.dart';

import 'package:note_x/pages/note.dart';

class EditNotePage extends StatefulWidget {
  final NoteModel note;

  const EditNotePage({
    super.key,
    required this.note,
  });

  @override
  State<EditNotePage> createState() => _EditNotePageState();
}

class _EditNotePageState extends State<EditNotePage> {
  late final TextEditingController _titleController;
  late final quill.QuillController _quillController;

  late bool _isFavorite;
  late bool _isPinned;

  final FocusNode _editorFocusNode = FocusNode();

  // ------------------------------------------------------------
  // Colors
  // ------------------------------------------------------------

  static const Color primaryColor = Color(0xFFFFB72B);
  static const Color backgroundColor = Color(0xFFFFFCF7);
  static const Color textColor = Color(0xFF252525);
  static const Color secondaryTextColor = Color(0xFF747474);

  @override
  void initState() {
    super.initState();

    _titleController = TextEditingController(
      text: widget.note.title,
    );

    _isFavorite = widget.note.isFavorite;
    _isPinned = widget.note.pinned;

    _quillController = quill.QuillController(
      document: _createDocument(widget.note.content),
      selection: const TextSelection.collapsed(offset: 0),
    );
  }

  // ------------------------------------------------------------
  // Create the editor document
  // ------------------------------------------------------------

  quill.Document _createDocument(String? content) {
    if (content == null || content.isEmpty) {
      return quill.Document();
    }

    /*
     * We try to interpret content as a Quill Delta JSON.
     *
     * If it isn't valid JSON, we assume that it is normal
     * plain text from an old NoteModel.
     */
    try {
      final decoded = jsonDecode(content);

      if (decoded is List) {
        return quill.Document.fromJson(decoded);
      }
    } catch (_) {
      // Content is normal text.
    }

    return quill.Document()..insert(0, content);
  }

  // ------------------------------------------------------------
  // Save
  // ------------------------------------------------------------

  void _saveNote() {
    final title = _titleController.text.trim();

    if (title.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Veuillez donner un titre à votre note.'),
        ),
      );
      return;
    }

    /*
     * Convert the formatted document into a JSON string.
     *
     * This can be stored directly in NoteModel.content.
     */
    final deltaJson = jsonEncode(
      _quillController.document.toDelta().toJson(),
    );

    /*
     * Your current NoteModel has final fields, so we create
     * a new instance instead of modifying the existing one.
     */
    final updatedNote = NoteModel(
      title: title,
      content: deltaJson,
      checklist: widget.note.checklist,
      imageUrl: widget.note.imageUrl,
      creationDate: widget.note.creationDate,
      type: widget.note.type,
      pinned: _isPinned,
      isFavorite: _isFavorite,
    );

    Navigator.pop(context, updatedNote);
  }

  // ------------------------------------------------------------
  // Cancel
  // ------------------------------------------------------------

  void _cancel() {
    Navigator.pop(context);
  }

  // ------------------------------------------------------------
  // Toggle favorite
  // ------------------------------------------------------------

  void _toggleFavorite() {
    setState(() {
      _isFavorite = !_isFavorite;
    });
  }

  // ------------------------------------------------------------
  // Toggle pin
  // ------------------------------------------------------------

  void _togglePinned() {
    setState(() {
      _isPinned = !_isPinned;
    });
  }

  // ------------------------------------------------------------
  // Note type color
  // ------------------------------------------------------------

  Color _getAccentColor() {
    switch (widget.note.type) {
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
    switch (widget.note.type) {
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

  // ------------------------------------------------------------
  // Date
  // ------------------------------------------------------------

  String _formatDate(DateTime date) {
    final months = [
      'janv.',
      'févr.',
      'mars',
      'avr.',
      'mai',
      'juin',
      'juil.',
      'août',
      'sept.',
      'oct.',
      'nov.',
      'déc.',
    ];

    return '${date.day} ${months[date.month - 1]} '
        '${date.year} à '
        '${date.hour.toString().padLeft(2, '0')}:'
        '${date.minute.toString().padLeft(2, '0')}';
  }

  // ------------------------------------------------------------
  // Build
  // ------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,

      appBar: AppBar(
        backgroundColor: backgroundColor,
        elevation: 0,
        surfaceTintColor: Colors.transparent,

        leading: IconButton(
          onPressed: _cancel,
          icon: const Icon(
            Icons.arrow_back,
            color: textColor,
          ),
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
              _isFavorite
                  ? Icons.star
                  : Icons.star_border,
              color: _isFavorite
                  ? primaryColor
                  : textColor,
            ),
          ),

          IconButton(
            onPressed: _togglePinned,
            icon: Icon(
              _isPinned
                  ? Icons.push_pin
                  : Icons.push_pin_outlined,
              color: _isPinned
                  ? primaryColor
                  : textColor,
            ),
          ),

          PopupMenuButton<String>(
            icon: const Icon(
              Icons.more_vert,
              color: textColor,
            ),
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
                    Icon(
                      Icons.delete_outline,
                      color: Colors.red,
                    ),
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
            Expanded(
              child: _buildEditor(),
            ),

            _buildFormattingToolbar(),

            _buildBottomActions(),
          ],
        ),
      ),
    );
  }

  // ------------------------------------------------------------
  // Editor
  // ------------------------------------------------------------

  Widget _buildEditor() {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 8, 16, 8),

      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),

        border: Border.all(
          color: Colors.black.withAlpha(40),
        ),

        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(17),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),

      child: Column(
        children: [
          // ------------------------------------------
          // Note information
          // ------------------------------------------

          Padding(
            padding: const EdgeInsets.fromLTRB(
              20,
              16,
              20,
              8,
            ),

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
                  _formatDate(widget.note.creationDate),
                  style: GoogleFonts.nunito(
                    fontSize: 11,
                    color: secondaryTextColor,
                  ),
                ),
              ],
            ),
          ),

          const Divider(
            height: 1,
            indent: 20,
            endIndent: 20,
          ),

          // ------------------------------------------
          // Title
          // ------------------------------------------

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

              contentPadding: const EdgeInsets.fromLTRB(
                20,
                16,
                20,
                8,
              ),
            ),

            maxLines: 1,
          ),

          // ------------------------------------------
          // Rich text editor
          // ------------------------------------------

          Expanded(
            child: quill.QuillEditor.basic(
              controller: _quillController,
              focusNode: _editorFocusNode,

              config: quill.QuillEditorConfig(
                padding: const EdgeInsets.fromLTRB(
                  20,
                  8,
                  20,
                  20,
                ),

                placeholder: 'Commencez à écrire...',

                customStyles: quill.DefaultStyles(
                  paragraph: quill.DefaultTextBlockStyle(
                    GoogleFonts.nunito(
                      fontSize: 17,
                      color: textColor,
                      height: 1.45,
                    ),

                    const quill.HorizontalSpacing(
                      0,
                      0,
                    ),

                    const quill.VerticalSpacing(
                      4,
                      4,
                    ),

                    const quill.VerticalSpacing(
                      0,
                      0,
                    ),

                    null,
                  ),

                  h1: quill.DefaultTextBlockStyle(
                    GoogleFonts.nunito(
                      fontSize: 28,
                      fontWeight: FontWeight.w800,
                      color: textColor,
                    ),

                    const quill.HorizontalSpacing(
                      0,
                      0,
                    ),

                    const quill.VerticalSpacing(
                      8,
                      8,
                    ),

                    const quill.VerticalSpacing(
                      0,
                      0,
                    ),

                    null,
                  ),

                  h2: quill.DefaultTextBlockStyle(
                    GoogleFonts.nunito(
                      fontSize: 23,
                      fontWeight: FontWeight.w700,
                      color: textColor,
                    ),

                    const quill.HorizontalSpacing(
                      0,
                      0,
                    ),

                    const quill.VerticalSpacing(
                      6,
                      6,
                    ),

                    const quill.VerticalSpacing(
                      0,
                      0,
                    ),

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

  // ------------------------------------------------------------
  // Formatting toolbar
  // ------------------------------------------------------------

  Widget _buildFormattingToolbar() {
    return Container(
      margin: const EdgeInsets.symmetric(
        horizontal: 16,
      ),

      padding: const EdgeInsets.symmetric(
        horizontal: 8,
        vertical: 6,
      ),

      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),

        border: Border.all(
          color: Colors.black.withAlpha(40),
        ),
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
              icon: const Icon(
                Icons.format_quote,
                size: 21,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ------------------------------------------------------------
  // Formatting button
  // ------------------------------------------------------------

  Widget _formatButton({
    required IconData icon,
    required quill.Attribute attribute,
  }) {
    return IconButton(
      tooltip: attribute.key,

      onPressed: () {
        _quillController.formatSelection(attribute);
      },

      icon: Icon(
        icon,
        size: 21,
      ),
    );
  }

  // ------------------------------------------------------------
  // Heading button
  // ------------------------------------------------------------

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

  // ------------------------------------------------------------
  // Quote
  // ------------------------------------------------------------

  void _toggleQuote() {
    _quillController.formatSelection(
      quill.Attribute.blockQuote,
    );
  }

  // ------------------------------------------------------------
  // Toolbar divider
  // ------------------------------------------------------------

  Widget _divider() {
    return Container(
      width: 1,
      height: 28,
      margin: const EdgeInsets.symmetric(
        horizontal: 5,
      ),
      color: Colors.black12,
    );
  }

  // ------------------------------------------------------------
  // Bottom actions
  // ------------------------------------------------------------

  Widget _buildBottomActions() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        16,
        10,
        16,
        12,
      ),

      child: Row(
        children: [
          Expanded(
            child: OutlinedButton(
              onPressed: _cancel,

              style: OutlinedButton.styleFrom(
                minimumSize: const Size(
                  double.infinity,
                  52,
                ),

                side: BorderSide(
                  color: primaryColor.withAlpha(125),
                ),

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

                minimumSize: const Size(
                  double.infinity,
                  52,
                ),

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

  // ------------------------------------------------------------
  // Delete dialog
  // ------------------------------------------------------------

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
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('Annuler'),
            ),

            TextButton(
              onPressed: () {
                Navigator.pop(context);
                Navigator.pop(context, 'delete');
              },

              child: const Text(
                'Supprimer',
                style: TextStyle(
                  color: Colors.red,
                ),
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