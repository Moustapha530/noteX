import 'dart:convert';
import 'dart:io';
import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path_provider/path_provider.dart';
import 'package:note_x/note/model.dart';
import 'package:uuid/uuid.dart';

final notesProvider =
    AsyncNotifierProvider<NoteRepository, List<NoteModel>>(
  NoteRepository.new,
);

class NoteRepository extends AsyncNotifier<List<NoteModel>> {
  static const String _fileName = 'notes.noteX';
  static const Uuid _uuid = Uuid();

  @override
  Future<List<NoteModel>> build() async {
    return await loadNotes();
  }

  Future<Directory> _getNotesDirectory() async {
    final appDirectory = await getApplicationDocumentsDirectory();
    final notesDirectory = Directory('${appDirectory.path}/NoteX');

    if (!await notesDirectory.exists()) {
      await notesDirectory.create(recursive: true);
    }

    return notesDirectory;
  }

  Future<File> _getNotesFile() async {
    final directory = await _getNotesDirectory();
    return File('${directory.path}/$_fileName');
  }

  Future<List<NoteModel>> loadNotes() async {
    final file = await _getNotesFile();

    if (!await file.exists()) {
      return [];
    }

    try {
      final jsonString = await file.readAsString();

      if (jsonString.trim().isEmpty) {
        return [];
      }

      final Map<String, dynamic> data = jsonDecode(jsonString);
      final List<dynamic> notesJson = data['notes'] ?? [];

      return notesJson
          .map((json) => NoteModel.fromJson(json))
          .toList();
    } catch (e) {
      throw Exception('Failed to load notes: $e');
    }
  }

  Future<void> saveNotes(List<NoteModel> notes) async {
    final file = await _getNotesFile();

    final data = {
      'version': 1,
      'notes': notes.map((note) => note.toJson()).toList(),
    };

    final jsonString =
        const JsonEncoder.withIndent('  ').convert(data);

    await file.writeAsString(jsonString, flush: true);
  }

  NoteModel createNewNote(NoteType type) {
    return NoteModel(
      id: _uuid.v4(),
      type: type,
    );
  }

  Future<void> addNote(NoteModel note) async {
    final currentNotes = await future;
    final List<NoteModel> notes = [...currentNotes, note];

    state = AsyncData(notes);
    await saveNotes(notes);
  }

  Future<NoteModel?> getNoteById(String id) async {
    final notes = await future;

    for (final note in notes) {
      if (note.id == id) {
        return note;
      }
    }

    return null;
  }

  Future<void> updateNote(NoteModel updatedNote) async {
    final currentNotes = await future;
    final List<NoteModel> notes = [...currentNotes];

    final index = notes.indexWhere((note) => note.id == updatedNote.id);

    if (index == -1) {
      throw Exception('Cannot update note: ${updatedNote.id} was not found.');
    }

    notes[index] = updatedNote;
    state = AsyncData(notes);
    await saveNotes(notes);
  }

  Future<void> moveToTrash(String id) async {
    final currentNotes = await future;
    final index = currentNotes.indexWhere((note) => note.id == id);

    if (index != -1) {
      final updatedNote = NoteModel(
        id: currentNotes[index].id,
        title: currentNotes[index].title,
        content: currentNotes[index].content,
        checklist: currentNotes[index].checklist,
        imageUrl: currentNotes[index].imageUrl,
        lastModified: DateTime.now(),
        type: currentNotes[index].type,
        pinned: false, // Unpin when trashed
        isFavorite: currentNotes[index].isFavorite,
        isTrashed: true,
      );

      await updateNote(updatedNote);
    }
  }

  Future<void> restoreFromTrash(String id) async {
    final currentNotes = await future;
    final index = currentNotes.indexWhere((note) => note.id == id);

    if (index != -1) {
      final updatedNote = NoteModel(
        id: currentNotes[index].id,
        title: currentNotes[index].title,
        content: currentNotes[index].content,
        checklist: currentNotes[index].checklist,
        imageUrl: currentNotes[index].imageUrl,
        lastModified: DateTime.now(),
        type: currentNotes[index].type,
        pinned: currentNotes[index].pinned,
        isFavorite: currentNotes[index].isFavorite,
        isTrashed: false,
      );

      await updateNote(updatedNote);
    }
  }

  Future<void> deleteNotePermanently(String id) async {
    final currentNotes = await future;
    final List<NoteModel> notes = [...currentNotes];

    notes.removeWhere((note) => note.id == id);

    state = AsyncData(notes);
    await saveNotes(notes);
  }

  Future<void> deleteAllNotes() async {
    state = const AsyncData([]);
    final file = await _getNotesFile();

    if (await file.exists()) {
      await file.delete();
    }
  }
}