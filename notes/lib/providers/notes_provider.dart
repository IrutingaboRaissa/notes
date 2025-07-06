import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:async';
import '../models/note.dart';

class NotesProvider with ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  List<Note> _notes = [];
  bool _isLoading = false;
  String? _lastError;
  StreamSubscription<QuerySnapshot>? _notesSubscription;

  List<Note> get notes => _notes;
  bool get isLoading => _isLoading;
  String? get lastError => _lastError;

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  void _setError(String? error) {
    _lastError = error;
    notifyListeners();
  }

  String get _userId {
    final user = _auth.currentUser;
    if (user == null) throw Exception('User not authenticated');
    return user.uid;
  }

  // Start listening to real-time updates
  void startListening() {
    try {
      _setLoading(true);
      _setError(null);

      debugPrint('Starting real-time listener for user: $_userId');

      // Cancel any existing subscription
      _notesSubscription?.cancel();

      // Start with a simple query without orderBy to avoid index issues
      Query query =
          _firestore.collection('notes').where('userId', isEqualTo: _userId);

      _notesSubscription = query.snapshots().listen(
        (QuerySnapshot querySnapshot) {
          _notes = querySnapshot.docs
              .map((doc) =>
                  Note.fromMap(doc.data() as Map<String, dynamic>, doc.id))
              .toList();

          // Always sort locally to ensure proper order
          _notes.sort((a, b) => b.createdAt.compareTo(a.createdAt));

          debugPrint(
              'Real-time update: ${_notes.length} notes for user $_userId');

          _setLoading(false);
        },
        onError: (error) {
          debugPrint('Error in notes stream: $error');
          // Don't show error to user for index issues, just use fallback
          if (!error.toString().contains('failed-precondition')) {
            _setError('Failed to sync notes. Please try again.');
          }
          _setLoading(false);
        },
      );
    } catch (e) {
      debugPrint('Error starting listener: $e');
      _setError('Failed to start real-time sync: $e');
      _setLoading(false);
    }
  }

  // Stop listening to real-time updates
  void stopListening() {
    _notesSubscription?.cancel();
    _notesSubscription = null;
  }

  Future<void> fetchNotes() async {
    // Use real-time listener instead of one-time fetch
    startListening();
  }

  Future<bool> addNote(String title, String content) async {
    try {
      _setError(null);

      if (title.trim().isEmpty && content.trim().isEmpty) {
        _setError('Note cannot be empty');
        return false;
      }

      final now = DateTime.now();
      final noteData = {
        'title': title.trim(),
        'content': content.trim(),
        'userId': _userId,
        'createdAt': now.toIso8601String(),
        'updatedAt': now.toIso8601String(),
      };

      debugPrint('Adding note for user: $_userId');
      debugPrint('Note data: $noteData');

      await _firestore.collection('notes').add(noteData);

      debugPrint('Note added successfully - real-time listener will update UI');

      return true;
    } catch (e) {
      debugPrint('Error adding note: $e');
      _setError('Failed to add note: $e');
      return false;
    }
  }

  Future<bool> updateNote(String id, String title, String content) async {
    try {
      _setError(null);

      if (title.trim().isEmpty && content.trim().isEmpty) {
        _setError('Note cannot be empty');
        return false;
      }

      final now = DateTime.now();
      final updateData = {
        'title': title.trim(),
        'content': content.trim(),
        'updatedAt': now.toIso8601String(),
      };

      await _firestore.collection('notes').doc(id).update(updateData);

      debugPrint(
          'Updated note with ID: $id - real-time listener will update UI');
      return true;
    } catch (e) {
      debugPrint('Error updating note: $e');
      _setError('Failed to update note: $e');
      return false;
    }
  }

  Future<bool> deleteNote(String id) async {
    try {
      _setError(null);

      await _firestore.collection('notes').doc(id).delete();

      debugPrint(
          'Deleted note with ID: $id - real-time listener will update UI');
      return true;
    } catch (e) {
      debugPrint('Error deleting note: $e');
      _setError('Failed to delete note: $e');
      return false;
    }
  }

  void clearError() {
    _setError(null);
  }

  @override
  void dispose() {
    stopListening();
    super.dispose();
  }
}
