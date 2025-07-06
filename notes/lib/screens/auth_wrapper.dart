import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import 'auth_screen.dart';
import 'notes_screen_updated.dart';

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, authProvider, _) {
        debugPrint(
            'AuthWrapper - isAuthenticated: ${authProvider.isAuthenticated}');
        debugPrint('AuthWrapper - user: ${authProvider.user?.email}');
        debugPrint('AuthWrapper - lastError: ${authProvider.lastError}');

        if (authProvider.isAuthenticated) {
          debugPrint('Showing NotesScreen');
          return const NotesScreen();
        } else {
          debugPrint('Showing AuthScreen');
          return const AuthScreen();
        }
      },
    );
  }
}
