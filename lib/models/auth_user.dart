// =============================================================================
// models/auth_user.dart
// Lightweight wrapper around FirebaseUser for the app
// =============================================================================

class AuthUser {
  final String uid;
  final String? email;
  final String? displayName;
  final bool   emailVerified;

  const AuthUser({
    required this.uid,
    this.email,
    this.displayName,
    this.emailVerified = false,
  });

  /// Display-friendly name: displayName → email prefix → 'Explorer'
  String get greeting {
    if (displayName != null && displayName!.isNotEmpty) {
      return displayName!;
    }
    if (email != null && email!.contains('@')) {
      return email!.split('@').first;
    }
    return 'Explorer';
  }

  @override
  String toString() => 'AuthUser(uid: $uid, email: $email)';
}
