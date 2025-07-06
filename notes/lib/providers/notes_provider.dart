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

  void startListening() {
    try {
      // Check if user is authenticated first
      final user = _auth.currentUser;
      if (user == null) {
        debugPrint('Cannot start listening: User not authenticated');
        _setError('User not authenticated');
        _setLoading(false);
        return;
      }

      _setLoading(true);
      _setError(null);

      debugPrint('Starting real-time listener for user: ${user.uid}');

      // Cancel any existing subscription
      _notesSubscription?.cancel();

      Query query =
          _firestore.collection('notes').where('userId', isEqualTo: user.uid);

      _notesSubscription = query.snapshots().listen(
        (QuerySnapshot querySnapshot) {
          debugPrint('Received ${querySnapshot.docs.length} documents from Firestore');
          
          _notes = querySnapshot.docs
              .map((doc) {
                try {
                  final data = doc.data() as Map<String, dynamic>;
                  debugPrint('Processing note document: ${doc.id} with data: $data');
                  return Note.fromMap(data, doc.id);
                } catch (e) {
                  debugPrint('Error parsing note ${doc.id}: $e');
                  return null;
                }
              })
              .where((note) => note != null)
              .cast<Note>()
              .toList();

          _notes.sort((a, b) => b.createdAt.compareTo(a.createdAt));

          debugPrint('Successfully loaded ${_notes.length} notes for user ${user.uid}');
          _setLoading(false);
        },
        onError: (error) {
          debugPrint('Error in notes stream: $error');
          _setError('Failed to sync notes. Please check your connection and try again.');
          _setLoading(false);
        },
      );
    } catch (e) {
      debugPrint('Error starting listener: $e');
      _setError('Failed to start real-time sync: $e');
      _setLoading(false);
    }
  }

  void stopListening() {
    _notesSubscription?.cancel();
    _notesSubscription = null;
  }

  Future<void> fetchNotes() async {
    startListening();
  }

  Future<bool> addNote(String title, String content) async {
    try {
      _setError(null);

      // Check if user is authenticated
      final user = _auth.currentUser;
      if (user == null) {
        debugPrint('Cannot add note: User not authenticated');
        _setError('User not authenticated');
        return false;
      }

      if (title.trim().isEmpty && content.trim().isEmpty) {
        _setError('Note cannot be empty');
        return false;
      }

      final now = DateTime.now();
      final noteData = {
        'title': title.trim(),
        'content': content.trim(),
        'userId': user.uid,
        'createdAt': now.toIso8601String(),
        'updatedAt': now.toIso8601String(),
      };

      debugPrint('Adding note for user: ${user.uid}');
      debugPrint('Note data: $noteData');

      final docRef = await _firestore.collection('notes').add(noteData);
      debugPrint('Note added successfully with ID: ${docRef.id}');

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

  // Test method to check if user can access Firestore
  Future<void> testFirestoreAccess() async {
    try {
      final user = _auth.currentUser;
      debugPrint('=== FIRESTORE ACCESS TEST ===');
      debugPrint('Current user: ${user?.uid}');
      debugPrint('User email: ${user?.email}');
      
      if (user == null) {
        debugPrint('ERROR: No authenticated user found');
        return;
      }

      // Try to read from the notes collection
      debugPrint('Attempting to read notes collection...');
      final snapshot = await _firestore
          .collection('notes')
          .where('userId', isEqualTo: user.uid)
          .get();
      
      debugPrint('Query successful! Found ${snapshot.docs.length} documents');
      for (var doc in snapshot.docs) {
        debugPrint('Document ${doc.id}: ${doc.data()}');
      }

      // Try to write a test document
      debugPrint('Attempting to write test document...');
      final testDoc = await _firestore.collection('notes').add({
        'title': 'Test Note',
        'content': 'This is a test note',
        'userId': user.uid,
        'createdAt': DateTime.now().toIso8601String(),
        'updatedAt': DateTime.now().toIso8601String(),
      });
      debugPrint('Test document created with ID: ${testDoc.id}');
      
      // Delete the test document
      await testDoc.delete();
      debugPrint('Test document deleted');
      
      debugPrint('=== FIRESTORE ACCESS TEST COMPLETED SUCCESSFULLY ===');
    } catch (e) {
      debugPrint('=== FIRESTORE ACCESS TEST FAILED ===');
      debugPrint('Error: $e');
    }
  }

  @override
  void dispose() {
    stopListening();
    super.dispose();
  }
}
