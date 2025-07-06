import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AuthProvider with ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  User? _user;
  bool _isLoading = false;
  bool _isLogin = true; 
  String? _lastError;

  User? get user => _user;
  bool get isLoading => _isLoading;
  bool get isLogin => _isLogin;
  bool get isAuthenticated => _user != null;
  String? get lastError => _lastError;

  AuthProvider() {
    _auth.authStateChanges().listen((User? user) {
      _user = user;
      debugPrint('Auth state changed: ${user?.email}');
      notifyListeners();
    });
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  void toggleAuthMode() {
    _isLogin = !_isLogin;
    notifyListeners();
  }

  Future<String?> signInWithEmailAndPassword(
      String email, String password) async {
    try {
      _setLoading(true);
      _lastError = null;
      debugPrint('Attempting to sign in with: $email');

      final credential = await _auth.signInWithEmailAndPassword(
          email: email, password: password);

      debugPrint('Sign in successful: ${credential.user?.email}');
      return null;
    } on FirebaseAuthException catch (e) {
      debugPrint('Firebase Auth Error: ${e.code} - ${e.message}');
      _lastError = e.message;
      return e.message ?? 'An authentication error occurred';
    } catch (e) {
      debugPrint('General Error: $e');
      _lastError = e.toString();
      return 'An unexpected error occurred: $e';
    } finally {
      _setLoading(false);
    }
  }

  Future<String?> createUserWithEmailAndPassword(
      String email, String password) async {
    try {
      _setLoading(true);
      _lastError = null;
      debugPrint('Attempting to create user with: $email');

      final credential = await _auth.createUserWithEmailAndPassword(
          email: email, password: password);

      debugPrint('User creation successful: ${credential.user?.email}');
      return null;
    } on FirebaseAuthException catch (e) {
      debugPrint('Firebase Auth Error: ${e.code} - ${e.message}');
      _lastError = e.message;
      return e.message ?? 'An authentication error occurred';
    } catch (e) {
      debugPrint('General Error: $e');
      _lastError = e.toString();
      return 'An unexpected error occurred: $e';
    } finally {
      _setLoading(false);
    }
  }

  Future<void> signOut() async {
    try {
      await _auth.signOut();
      debugPrint('User signed out successfully');
    } catch (e) {
      debugPrint('Sign out error: $e');
    }
  }
}
