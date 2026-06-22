// =============================================================================
// screens/auth_gate.dart
// Initial route — checks Firebase auth state on app launch only.
// After launch, login/logout navigation is handled explicitly via
// Navigator.pushAndRemoveUntil in each screen.
// =============================================================================

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'login_screen.dart';
import 'intro_screen.dart';

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        // Still connecting to Firebase
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        // User is logged in → show main app
        if (snapshot.hasData && snapshot.data != null) {
          return const IntroScreen();
        }

        // No user → show login
        return const LoginScreen();
      },
    );
  }
}