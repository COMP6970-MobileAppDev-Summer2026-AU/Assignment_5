// =============================================================================
// main.dart
// National Parks Explorer — COMP 6910 Assignment 4
// Developer: Jahidul Arafat (JAJI)
// =============================================================================

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/nationalparks_provider.dart';
import 'screens/intro_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(
    ChangeNotifierProvider(
      create: (_) => NationalParksProvider(),
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
      home: const IntroScreen(),
    );
  }
}
