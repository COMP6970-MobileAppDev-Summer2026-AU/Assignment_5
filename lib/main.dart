// =============================================================================
// main.dart
// National Parks Explorer — COMP 6910 Assignment 5
// Firebase Authentication + NPS API
// Developer: Jahidul Arafat (JAJI)
// =============================================================================

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'providers/auth_provider.dart' as ap;
import 'providers/nationalparks_provider.dart';
import 'screens/auth_gate.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(
    MultiProvider(
      providers: [
        // Firebase auth state
        ChangeNotifierProvider(create: (_) => ap.AuthProvider()),
        // NPS parks state
        ChangeNotifierProvider(create: (_) => NationalParksProvider()),
      ],
      child: const NationalParksApp(),
    ),
  );
}

class NationalParksApp extends StatelessWidget {
  const NationalParksApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'National Parks Explorer',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.green.shade700,
          brightness: Brightness.light,
        ),
        useMaterial3: true,
      ),
      darkTheme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.green.shade700,
          brightness: Brightness.dark,
        ),
        useMaterial3: true,
      ),
      // AuthGate decides: show LoginScreen or IntroScreen based on auth state
      home: const AuthGate(),
    );
  }
}
