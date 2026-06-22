// =============================================================================
// providers/auth_provider.dart
// Manages Firebase auth state across the entire app
// Assignment 5 — COMP 6910
// =============================================================================

import 'dart:async';
import 'package:flutter/material.dart';
import '../models/auth_user.dart';
import '../services/auth_service.dart';

enum AuthState { unknown, authenticated, unauthenticated }

class AuthProvider extends ChangeNotifier {
  final AuthService _authService = AuthService();

  AuthState   _state    = AuthState.unknown;
  AuthUser?   _user;
  String?     _error;
  bool        _loading  = false;
  StreamSubscription<AuthUser?>? _subscription;

  // ── Getters ──────────────────────────────────────────────────────────────
  AuthState get state    => _state;
  AuthUser? get user     => _user;
  String?   get error    => _error;
  bool      get loading  => _loading;
  bool      get isLoggedIn => _state == AuthState.authenticated;

  // ── Constructor ───────────────────────────────────────────────────────────
  AuthProvider() {
    _subscription = _authService.authStateChanges.listen(_onAuthChanged);
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }

  // ── Auth state listener ───────────────────────────────────────────────────
  void _onAuthChanged(AuthUser? user) {
    _user  = user;
    _state = user != null
        ? AuthState.authenticated
        : AuthState.unauthenticated;
    notifyListeners();
  }

  // ── Sign Up ───────────────────────────────────────────────────────────────
  Future<bool> signUp({
    required String email,
    required String password,
    String? displayName,
  }) async {
    if (!_validateFields(email, password)) return false;

    _setLoading(true);
    final err = await _authService.signUp(
      email:       email,
      password:    password,
      displayName: displayName,
    );
    _setLoading(false);

    if (err != null) {
      _error = err;
      notifyListeners();
      return false;
    }
    _error = null;
    return true;
  }

  // ── Sign In ───────────────────────────────────────────────────────────────
  Future<bool> signIn({
    required String email,
    required String password,
  }) async {
    if (!_validateFields(email, password)) return false;

    _setLoading(true);
    final err = await _authService.signIn(email: email, password: password);
    _setLoading(false);

    if (err != null) {
      _error = err;
      notifyListeners();
      return false;
    }
    _error = null;
    return true;
  }

  // ── Sign Out ──────────────────────────────────────────────────────────────
  Future<void> signOut() async {
    await _authService.signOut();
    _error = null;
    notifyListeners();
  }

  // ── Password Reset ────────────────────────────────────────────────────────
  Future<String?> sendPasswordReset(String email) async {
    if (email.trim().isEmpty) return 'Please enter your email address.';
    return _authService.sendPasswordResetEmail(email);
  }

  // ── Clear error ───────────────────────────────────────────────────────────
  void clearError() {
    _error = null;
    notifyListeners();
  }

  // ── Private helpers ───────────────────────────────────────────────────────
  void _setLoading(bool value) {
    _loading = value;
    notifyListeners();
  }

  bool _validateFields(String email, String password) {
    if (email.trim().isEmpty) {
      _error = 'Please enter your email address.';
      notifyListeners();
      return false;
    }
    if (password.isEmpty) {
      _error = 'Please enter your password.';
      notifyListeners();
      return false;
    }
    if (password.length < 6) {
      _error = 'Password must be at least 6 characters.';
      notifyListeners();
      return false;
    }
    _error = null;
    return true;
  }
}
