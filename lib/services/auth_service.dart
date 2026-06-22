// =============================================================================
// services/auth_service.dart
// Firebase Authentication — email/password sign-up, login, logout
// Assignment 5 — COMP 6910
// =============================================================================

import 'package:firebase_auth/firebase_auth.dart';
import '../models/auth_user.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // ── Stream ─────────────────────────────────────────────────────────────────
  /// Stream of auth state changes — emits AuthUser? on login/logout
  Stream<AuthUser?> get authStateChanges =>
      _auth.authStateChanges().map(_fromFirebaseUser);

  // ── Current user ──────────────────────────────────────────────────────────
  AuthUser? get currentUser => _fromFirebaseUser(_auth.currentUser);

  // ── Sign Up ───────────────────────────────────────────────────────────────
  /// Create a new account with email + password.
  /// Returns null on success; returns an error message string on failure.
  Future<String?> signUp({
    required String email,
    required String password,
    String? displayName,
  }) async {
    try {
      final credential = await _auth.createUserWithEmailAndPassword(
        email:    email.trim(),
        password: password,
      );
      // Update display name if provided
      if (displayName != null && displayName.trim().isNotEmpty) {
        await credential.user?.updateDisplayName(displayName.trim());
      }
      return null; // success
    } on FirebaseAuthException catch (e) {
      return _friendlyError(e.code);
    } catch (e) {
      return 'An unexpected error occurred. Please try again.';
    }
  }

  // ── Sign In ───────────────────────────────────────────────────────────────
  /// Sign in with email + password.
  /// Returns null on success; returns an error message string on failure.
  Future<String?> signIn({
    required String email,
    required String password,
  }) async {
    try {
      await _auth.signInWithEmailAndPassword(
        email:    email.trim(),
        password: password,
      );
      return null; // success
    } on FirebaseAuthException catch (e) {
      return _friendlyError(e.code);
    } catch (e) {
      return 'An unexpected error occurred. Please try again.';
    }
  }

  // ── Sign Out ──────────────────────────────────────────────────────────────
  Future<void> signOut() async {
    await _auth.signOut();
  }

  // ── Password Reset ────────────────────────────────────────────────────────
  /// Send a password reset email.
  /// Returns null on success; returns an error message on failure.
  Future<String?> sendPasswordResetEmail(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email.trim());
      return null;
    } on FirebaseAuthException catch (e) {
      return _friendlyError(e.code);
    } catch (e) {
      return 'Failed to send reset email. Please try again.';
    }
  }

  // ── Private helpers ───────────────────────────────────────────────────────
  AuthUser? _fromFirebaseUser(User? user) {
    if (user == null) return null;
    return AuthUser(
      uid:           user.uid,
      email:         user.email,
      displayName:   user.displayName,
      emailVerified: user.emailVerified,
    );
  }

  /// Convert Firebase error codes to user-friendly messages
  String _friendlyError(String code) {
    return switch (code) {
      'email-already-in-use'    => 'An account with this email already exists.',
      'invalid-email'           => 'Please enter a valid email address.',
      'weak-password'           => 'Password must be at least 6 characters.',
      'user-not-found'          => 'No account found with this email address.',
      'wrong-password'          => 'Incorrect password. Please try again.',
      'invalid-credential'      => 'Incorrect email or password. Please check and try again.',
      'user-disabled'           => 'This account has been disabled.',
      'too-many-requests'       => 'Too many attempts. Please try again later.',
      'network-request-failed'  => 'Network error. Check your connection.',
      'channel-error'           => 'Please fill in all fields.',
      _                         => 'Authentication failed (code: $code). Please try again.',
    };
  }
}