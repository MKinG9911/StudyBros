import 'package:flutter/material.dart';
import '../models/note_model.dart';
import '../services/hive_service.dart';

class NotesProvider with ChangeNotifier {
  final HiveService _hiveService = HiveService();
  List<Note> _notes = [];
  bool _isLoading = false;

  List<Note> get notes => _notes;
  bool get isLoading => _isLoading;

  Future<void> fetchNotes() async {
    _isLoading = true;
    notifyListeners();
    try {
      _notes = await _hiveService.getNotes();
      _notes.sort((a, b) {
        if (a.isFavorite && !b.isFavorite) return -1;
        if (!a.isFavorite && b.isFavorite) return 1;
        if (a.createdAt != null && b.createdAt != null) {
          return b.createdAt!.compareTo(a.createdAt!);
        }
        return 0;
      });
    } catch (e) {
      print(e);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> addNote(Note note) async {
    try {
      await _hiveService.addNote(note);
      await fetchNotes();
    } catch (e) {
      print(e);
    }
  }

  Future<void> updateNote(Note note) async {
    try {
      await note.save();
      await fetchNotes();
    } catch (e) {
      print(e);
    }
  }

  Future<void> toggleFavorite(Note note) async {
    try {
      note.isFavorite = !note.isFavorite;
      await note.save();
      await fetchNotes();
    } catch (e) {
      print(e);
    }
  }

  Future<void> deleteNote(String id) async {
    try {
      await _hiveService.deleteNote(id);
      await fetchNotes();
    } catch (e) {
      print(e);
    }
  }
}
