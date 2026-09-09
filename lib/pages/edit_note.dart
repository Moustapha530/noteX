import 'dart:convert';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_quill/flutter_quill.dart' as quill;
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';
import 'package:note_x/note/model.dart';
import 'package:note_x/note/repository.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:note_x/pages/settings/provider.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:note_x/l10n.dart';

class EditNotePage extends ConsumerStatefulWidget {
  final String noteId;

  const EditNotePage({super.key, required this.noteId});

  @override
  ConsumerState<EditNotePage> createState() => _EditNotePageState();
}

class _EditNotePageState extends ConsumerState<EditNotePage> {
  late final TextEditingController _titleController;
  late final quill.QuillController _quillController;
  NoteModel? _note;

  bool _isNewNote = false;
  bool _isFavorite = false;
  late String _id;
  late NoteType _selectedType;

  String _savedSnapshot = '';
  Timer? _autosaveTimer;
  bool _isLeaving = false;
  bool _isSummarizing = false;

  late stt.SpeechToText _speech;
  bool _isListening = false;

  final FocusNode _editorFocusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _speech = stt.SpeechToText();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeNote();
    });
  }

  Future<void> _initializeNote() async {
    final repository = ref.read(notesProvider.notifier);

    var note = await repository.getNoteById(widget.noteId);
    if (note == null) {
      _isNewNote = true;
      final newNote = NoteModel(id: widget.noteId, type: NoteType.note);
      await repository.addNote(newNote);
      note = newNote;
    }

    if (!mounted) return;

    _note = note;
    _titleController = TextEditingController(text: note.title);
    _isFavorite = note.isFavorite;
    _id = note.id;
    _selectedType = note.type;

    _quillController = quill.QuillController(
      document: _createDocument(note.content),
      selection: const TextSelection.collapsed(offset: 0),
    );
    _savedSnapshot = _currentSnapshot();
    _titleController.addListener(_scheduleAutosave);
    _quillController.addListener(_scheduleAutosave);
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

  String _currentSnapshot() {
    return jsonEncode({
      'title': _titleController.text.trim(),
      'content': _quillController.document.toDelta().toJson(),
      'isFavorite': _isFavorite,
      'type': _selectedType.name,
    });
  }

  bool get _hasUnsavedChanges => _currentSnapshot() != _savedSnapshot;

  void _scheduleAutosave() {
    if (!mounted || _note == null) return;

    _autosaveTimer?.cancel();
    _autosaveTimer = Timer(const Duration(milliseconds: 700), () {
      _saveNote();
    });
  }

  Future<bool> _saveNote({bool showSnackBar = false}) async {
    if (_note == null) return false;

    final title = _titleController.text.trim();
    final l10n = context.l10n(ref);

    if (title.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(l10n.translate('title_hint'))));
      return false;
    }

    final deltaJson = jsonEncode(_quillController.document.toDelta().toJson());

    final updatedNote = NoteModel(
      id: _id,
      title: title,
      content: deltaJson,
      checklist: _note!.checklist,
      lastModified: DateTime.now(),
      type: _selectedType,
      isFavorite: _isFavorite,
    );

    final isDark = Theme.of(context).brightness == Brightness.dark;

    await ref.read(notesProvider.notifier).updateNote(updatedNote);
    _savedSnapshot = _currentSnapshot();
    _note = updatedNote;

    if (showSnackBar && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            l10n
                .translate('note_saved')
                .replaceAll('{title}', updatedNote.title),
            style: GoogleFonts.nunito(
              color: isDark ? Colors.black87 : Colors.white,
              fontWeight: FontWeight.w600,
            ),
          ),
          duration: const Duration(seconds: 3),
        ),
      );
    }
    return true;
  }

  Future<void> _summarizeNote() async {
    final l10n = context.l10n(ref);
    final text = _quillController.document.toPlainText().trim();
    if (text.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(
        content: Text(
          l10n.translate('note_empty')
          )
        )
      );
      return;
    }

    setState(() => _isSummarizing = true);

    try {
      final apiKey = dotenv.get('GEMINI_API_KEY');
      final model = GenerativeModel(model: 'gemini-2.5-flash-lite', apiKey: apiKey);

      final prompt =
          'Can you summarize precisely that :\n\n$text';
      final response = await model.generateContent([Content.text(prompt)]);

      if (response.text != null && mounted) {
        _showSummaryDialog(response.text!);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error summarizing : $e')));
      }
    } finally {
      if (mounted) {
        setState(() => _isSummarizing = false);
      }
    }
  }

  void _showSummaryDialog(String summary) {
    if (!mounted) return;
    final colorScheme = Theme.of(context).colorScheme;
    final textColor = colorScheme.onSurface;
    final l10n = context.l10n(ref);

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: colorScheme.surface,
          title: Text(
            l10n.translate('summary_title'),
            style: GoogleFonts.nunito(
              fontWeight: FontWeight.w800,
              color: textColor,
            ),
          ),
          content: SingleChildScrollView(
            child: Text(summary, style: GoogleFonts.nunito(color: textColor)),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(l10n.translate('close')),
            ),
            TextButton(
              onPressed: () {
                final index = _quillController.selection.baseOffset;
                final position = index >= 0
                    ? index
                    : _quillController.document.length;
                _quillController.document.insert(
                  position,
                  '\n\n--- ${l10n.translate('summary_title')} ---\n$summary\n\n',
                );
                Navigator.pop(context);
              },
              child: Text(l10n.translate('insert_in_note')),
            ),
          ],
        );
      },
    );
  }

  void _toggleDictation() async {
    if (!_isListening) {
      bool available = await _speech.initialize(
        onError: (errorNotification) => ScaffoldMessenger.of(context,)
                                        .showSnackBar(
                                          SnackBar(
                                            content: Text('Error summarizing : $errorNotification')
                                          )
                                        ),
      );
      if (available) {
        setState(() => _isListening = true);
        _speech.listen(
          onResult: (val) {
            if (val.finalResult) {
              final index = _quillController.selection.baseOffset;
              final position = index >= 0
                  ? index
                  : _quillController.document.length;

              _quillController.document.insert(
                position,
                '${val.recognizedWords} ',
              );
              _quillController.updateSelection(
                TextSelection.collapsed(
                  offset: position + val.recognizedWords.length + 1,
                ),
                quill.ChangeSource.local,
              );

              setState(() => _isListening = false);
            }
          },
        );
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Speech recognition unavailable.')),
          );
        }
      }
    } else {
      setState(() => _isListening = false);
      _speech.stop();
    }
  }

  Future<void> _handleExit() async {
    if (_isLeaving) return;

    _autosaveTimer?.cancel();
    if (!_hasUnsavedChanges) {
      _isLeaving = true;
      if (mounted) context.pop();
      return;
    }

    final l10n = context.l10n(ref);
    final decision = await showDialog<String>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(l10n.translate('save_changes')),
        content: Text(l10n.translate('save_changes_desc')),
        actions: [
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              TextButton(
                onPressed: () => Navigator.pop(dialogContext, 'cancel'),
                child: Text(l10n.translate('cancel')),
              ),
              SizedBox(width: 3,),
              TextButton(
                onPressed: () => Navigator.pop(dialogContext, 'discard'),
                child: Text(l10n.translate('discard')),
              ),
              SizedBox(width: 3,),
              FilledButton(
                onPressed: () => Navigator.pop(dialogContext, 'save'),
                child: Text(l10n.translate('save')),
              ),
            ],
          )
        ],
      ),
    );

    if (!mounted || decision == null || decision == 'cancel') return;

    if (decision == 'save') {
      final saved = await _saveNote();
      if (!saved || !mounted) return;
    } else if (_isNewNote) {
      await ref.read(notesProvider.notifier).deleteNotePermanently(_id);
    }

    _isLeaving = true;
    if (mounted) context.pop();
  }

  void _toggleFavorite() {
    setState(() {
      _isFavorite = !_isFavorite;
    });
    _scheduleAutosave();
  }

  Color _getAccentColor([NoteType? type]) {
    final targetType = type ?? _selectedType;
    switch (targetType) {
      case NoteType.note:
        return const Color(0xFFF5B839);
      case NoteType.checklist:
        return const Color(0xFF759B4A);
      case NoteType.voice:
        return const Color(0xFF4894B5);
    }
  }

  String _getTypeName(L10n l10n, [NoteType? type]) {
    final targetType = type ?? _selectedType;
    switch (targetType) {
      case NoteType.note:
        return l10n.translate('filter_notes');
      case NoteType.checklist:
        return l10n.translate('checklist');
      case NoteType.voice:
        return l10n.translate('voice_note');
    }
  }

  String _formatDate(DateTime date, L10n l10n) {
    final months = l10n.months;

    return '${date.day} ${months[date.month - 1]} ${date.year} à '
        '${date.hour.toString().padLeft(2, '0')}:'
        '${date.minute.toString().padLeft(2, '0')}';
  }

  void _showTypeSelectionSheet() {
    final colorScheme = Theme.of(context).colorScheme;
    final textColor = colorScheme.onSurface;
    final primaryColor = colorScheme.primary;
    final l10n = context.l10n(ref);

    showModalBottomSheet(
      context: context,
      backgroundColor: colorScheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 8,
                  ),
                  child: Text(
                    'Change note type',
                    style: GoogleFonts.nunito(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      color: textColor,
                    ),
                  ),
                ),
                Divider(color: colorScheme.onSurface.withAlpha(25)),
                ...NoteType.values.map((type) {
                  final isSelected = type == _selectedType;
                  return ListTile(
                    leading: Container(
                      width: 12,
                      height: 12,
                      decoration: BoxDecoration(
                        color: _getAccentColor(type),
                        shape: BoxShape.circle,
                      ),
                    ),
                    title: Text(
                      _getTypeName(l10n, type),
                      style: GoogleFonts.nunito(
                        fontSize: 16,
                        fontWeight: isSelected
                            ? FontWeight.w800
                            : FontWeight.w600,
                        color: textColor,
                      ),
                    ),
                    trailing: isSelected
                        ? Icon(Icons.check, color: primaryColor)
                        : null,
                    onTap: () {
                      setState(() {
                        _selectedType = type;
                      });
                      _scheduleAutosave();
                      Navigator.pop(context);
                    },
                  );
                }),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_note == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final colorScheme = Theme.of(context).colorScheme;
    final textColor = colorScheme.onSurface;
    final secondaryTextColor = colorScheme.onSurface.withAlpha(153);
    final l10n = context.l10n(ref);

    return PopScope<void>(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop) _handleExit();
      },
      child: Scaffold(
        backgroundColor: colorScheme.surface,
        appBar: AppBar(
          backgroundColor: colorScheme.surface,
          elevation: 0,
          surfaceTintColor: Colors.transparent,
          leading: IconButton(
            onPressed: _handleExit,
            icon: Icon(Icons.arrow_back, color: textColor),
          ),
          titleSpacing: 0,
          title: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                l10n.translate('edit_note'),
                style: GoogleFonts.nunito(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: textColor,
                ),
              ),
              Text(
                l10n.translate('last_modified'),
                style: GoogleFonts.nunito(
                  fontSize: 12,
                  color: secondaryTextColor,
                ),
              ),
            ],
          ),
          actions: [            
            PopupMenuButton<String>(
              icon: Icon(Icons.more_vert, color: textColor),
              onSelected: (value) {
                switch (value) {
                  case 'summarize':
                    _summarizeNote();
                    break;
                  case 'favorite':
                    _toggleFavorite();
                    break;
                  case 'delete':
                    _showDeleteDialog();
                    break;
                  case 'read':
                    _readContent();
                    break;

                }
              },
              itemBuilder: (context) => [
                PopupMenuItem(
                  value: 'summarize',
                  enabled: !_isSummarizing,
                  child: Row(
                    children: [
                      _isSummarizing
                          ? const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Icon(Icons.auto_awesome),
                      const SizedBox(width: 10),
                      Text(l10n.translate('summarize_ia')),
                    ],
                  ),
                ),
                PopupMenuItem(
                  value: 'favorite',
                  child: Row(
                    children: [
                      Icon(_isFavorite ? Icons.star : Icons.star_border),
                      const SizedBox(width: 10),
                      Text(
                        _isFavorite
                            ? l10n.translate('remove_favorite')
                            : l10n.translate('favorites'),
                      ),
                    ],
                  ),
                ),
                PopupMenuItem(
                  value: 'read',
                  child: Row(
                    children: [
                      const Icon(Icons.volume_up_outlined),
                      const SizedBox(width: 10),
                      Text(l10n.translate('read')),
                    ],
                  ),
                ),
                PopupMenuItem(
                  value: 'delete',
                  child: Row(
                    children: [
                      const Icon(Icons.delete_outline, color: Colors.red),
                      const SizedBox(width: 10),
                      Text(l10n.translate('delete')),
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
              Expanded(child: _buildEditor(context)),
              if (_selectedType != NoteType.voice)
                _buildFormattingToolbar(context),
            ],
          ),
        ),
        floatingActionButton: _selectedType == NoteType.voice 
                            ? FloatingActionButton(
                              onPressed: _toggleDictation,
                              child: Icon(
                                  _isListening ? Icons.mic : Icons.mic_none,
                                  size: 30,
                                  color: _isListening ? Colors.red : null,
                                ),
                            ) : null,
        floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      ),
    );
  }

  Widget _buildEditor(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textColor = colorScheme.onSurface;
    final secondaryTextColor = textColor.withAlpha(153);
    final l10n = context.l10n(ref);
    final settings = ref.watch(settingsProvider);

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 8, 16, 8),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
            child: Row(
              children: [
                InkWell(
                  borderRadius: BorderRadius.circular(8),
                  onTap: _showTypeSelectionSheet,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 4,
                      vertical: 2,
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
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
                          _getTypeName(l10n),
                          style: GoogleFonts.nunito(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: textColor,
                          ),
                        ),
                        const SizedBox(width: 4),
                        Icon(
                          Icons.keyboard_arrow_down,
                          size: 18,
                          color: secondaryTextColor,
                        ),
                      ],
                    ),
                  ),
                ),
                const Spacer(),
                Text(
                  _formatDate(_note!.lastModified, l10n),
                  style: GoogleFonts.nunito(
                    fontSize: 11,
                    color: secondaryTextColor,
                  ),
                ),
              ],
            ),
          ),
          Divider(
            height: 1,
            indent: 20,
            endIndent: 20,
            color: colorScheme.onSurface.withAlpha(25),
          ),
          TextField(
            controller: _titleController,
            style: GoogleFonts.nunito(
              fontSize: 25,
              fontWeight: FontWeight.w800,
              color: textColor,
            ),
            decoration: InputDecoration(
              hintText: l10n.translate('title_hint'),
              hintStyle: GoogleFonts.nunito(
                fontSize: 25,
                fontWeight: FontWeight.w800,
                color: textColor.withAlpha(66),
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
                placeholder: l10n.translate('content_placeholder'),
                customStyles: quill.DefaultStyles(
                  paragraph: quill.DefaultTextBlockStyle(
                    GoogleFonts.nunito(
                      fontSize: settings.fontSize,
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

  Widget _buildFormattingToolbar(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: colorScheme.onSurface.withAlpha(40)),
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
            if (_selectedType == NoteType.note) ...[
              _divider(context),
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
              _divider(context),
              _formatButton(
                icon: Icons.format_list_bulleted,
                attribute: quill.Attribute.ul,
              ),
              _formatButton(
                icon: Icons.format_list_numbered,
                attribute: quill.Attribute.ol,
              ),
              _divider(context),
              _headingButton(1),
              _headingButton(2),
              _headingButton(3),
              _divider(context),
              IconButton(
                tooltip: 'Citation',
                onPressed: _toggleQuote,
                icon: const Icon(Icons.format_quote, size: 21),
              ),
            ],
            if (_selectedType == NoteType.checklist) ...[
              _divider(context),
              _formatButton(
                icon: Icons.check_box_outlined,
                attribute: quill.Attribute.unchecked,
              ),
            ],
          ],
        ),
      ),
    );
  }

  bool _isAlreadyFormatted(quill.Attribute attribute) {
    final style = _quillController.getSelectionStyle();
    return style.attributes[attribute.key] != null;
  }

  Widget _formatButton({
    required IconData icon,
    required quill.Attribute attribute,
  }) {
    return IconButton(
      tooltip: attribute.key,
      onPressed: () {
        if (_isAlreadyFormatted(attribute)){
          _quillController.formatSelection(quill.Attribute.clone(attribute, null));
          return;
        }
        _quillController.formatSelection(attribute);
      },
      icon: Icon(
        icon,
        size: 21,
        color: Theme.of(context).colorScheme.onSurface,
      ),
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
          color: Theme.of(context).colorScheme.onSurface,
        ),
      ),
    );
  }

  void _toggleQuote() {
    if (_isAlreadyFormatted(quill.Attribute.blockQuote)){
      _quillController.formatSelection(quill.Attribute.clone(quill.Attribute.blockQuote, null));
      return;
    }
    _quillController.formatSelection(quill.Attribute.blockQuote);
  }

  Widget _divider(BuildContext context) {
    return Container(
      width: 1,
      height: 28,
      margin: const EdgeInsets.symmetric(horizontal: 5),
      color: Theme.of(context).colorScheme.onSurface.withAlpha(25),
    );
  }

  void _showDeleteDialog() {
    final colorScheme = Theme.of(context).colorScheme;
    final textColor = colorScheme.onSurface;
    final l10n = context.l10n(ref);

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: colorScheme.surface,
          title: Text(
            l10n.translate('delete_note_q'),
            style: GoogleFonts.nunito(
              color: textColor,
              fontWeight: FontWeight.bold,
            ),
          ),
          content: Text(
            l10n.translate('delete_note_desc'),
            style: GoogleFonts.nunito(color: textColor.withAlpha(179)),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(l10n.translate('cancel')),
            ),
            TextButton(
              onPressed: () {
                if (_note != null) {
                  ref.read(notesProvider.notifier).moveToTrash(_note!.id);
                }
                Navigator.pop(context);
                context.pop();
              },
              child: Text(
                l10n.translate('delete'),
                style: const TextStyle(color: Colors.red),
              ),
            ),
          ],
        );
      },
    );
  }

  void _readContent(){

  }

  @override
  void dispose() {
    _autosaveTimer?.cancel();
    _titleController.removeListener(_scheduleAutosave);
    _quillController.removeListener(_scheduleAutosave);
    _titleController.dispose();
    _quillController.dispose();
    _editorFocusNode.dispose();
    _speech.cancel();
    super.dispose();
  }
}