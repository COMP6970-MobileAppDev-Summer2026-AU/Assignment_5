// =============================================================================
// screens/signup_screen.dart
// Firebase Email/Password Sign Up with display name
// =============================================================================

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart' as ap;
import '../widgets/auth_form_field.dart';
import '../screens/intro_screen.dart';
import 'login_screen.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final _formKey     = GlobalKey<FormState>();
  final _nameCtrl    = TextEditingController();
  final _emailCtrl   = TextEditingController();
  final _passCtrl    = TextEditingController();
  final _confirmCtrl = TextEditingController();
  bool _signedUp     = false;

  @override
  void dispose() {
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    _passCtrl.dispose();
    _confirmCtrl.dispose();
    super.dispose();
  }

  Future<void> _signUp() async {
    context.read<ap.AuthProvider>().clearError();
    if (!_formKey.currentState!.validate()) return;

    final success = await context.read<ap.AuthProvider>().signUp(
      email:       _emailCtrl.text,
      password:    _passCtrl.text,
      displayName: _nameCtrl.text,
    );

    if (success) {
      if (!mounted) return;
      setState(() => _signedUp = true);
      // Brief pause so the user sees the success message
      await Future.delayed(const Duration(seconds: 2));
      if (!mounted) return;
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const IntroScreen()),
            (route) => false,
      );
    } else {
      if (!mounted) return;
      final err = context.read<ap.AuthProvider>().error;
      if (err != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content:         Text(err),
            behavior:        SnackBarBehavior.floating,
            backgroundColor: Colors.red.shade400,
          ),
        );
      }
    }
    // On success AuthGate redirects automatically via stream
  }

  @override
  Widget build(BuildContext context) {
    final prov   = context.watch<ap.AuthProvider>();
    final scheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Create Account'),
        centerTitle: false,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Join National Parks Explorer',
                    style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: scheme.primary)),
                const SizedBox(height: 4),
                Text('Create an account to start exploring',
                    style: TextStyle(
                        color: Colors.grey.shade600, fontSize: 14)),

                const SizedBox(height: 28),

                // Display name
                AuthFormField(
                  controller: _nameCtrl,
                  label:      'Full Name',
                  hint:       'Jahidul Arafat',
                  icon:       Icons.person_outlined,
                  onChanged:  (_) =>
                      context.read<ap.AuthProvider>().clearError(),
                  validator: (v) {
                    if (v == null || v.trim().isEmpty) {
                      return 'Please enter your name';
                    }
                    return null;
                  },
                ),

                const SizedBox(height: 16),

                // Email
                AuthFormField(
                  controller:  _emailCtrl,
                  label:       'Email',
                  hint:        'you@example.com',
                  icon:        Icons.email_outlined,
                  keyboardType: TextInputType.emailAddress,
                  onChanged:   (_) =>
                      context.read<ap.AuthProvider>().clearError(),
                  validator: (v) {
                    if (v == null || v.trim().isEmpty) {
                      return 'Email is required';
                    }
                    if (!v.contains('@')) return 'Enter a valid email';
                    return null;
                  },
                ),

                const SizedBox(height: 16),

                // Password
                AuthFormField(
                  controller: _passCtrl,
                  label:      'Password',
                  hint:       'At least 6 characters',
                  icon:       Icons.lock_outlined,
                  isPassword: true,
                  onChanged:  (_) =>
                      context.read<ap.AuthProvider>().clearError(),
                  validator: (v) {
                    if (v == null || v.isEmpty) return 'Password is required';
                    if (v.length < 6) return 'Minimum 6 characters';
                    return null;
                  },
                ),

                const SizedBox(height: 16),

                // Confirm password
                AuthFormField(
                  controller: _confirmCtrl,
                  label:      'Confirm Password',
                  hint:       'Re-enter your password',
                  icon:       Icons.lock_outline_rounded,
                  isPassword: true,
                  validator: (v) {
                    if (v != _passCtrl.text) {
                      return 'Passwords do not match';
                    }
                    return null;
                  },
                ),

                // Error banner
                if (prov.error != null) ...[
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color:        Colors.red.shade50,
                      borderRadius: BorderRadius.circular(10),
                      border:       Border.all(color: Colors.red.shade200),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.error_outline,
                            color: Colors.red.shade400, size: 18),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(prov.error!,
                              style: TextStyle(
                                  color: Colors.red.shade700, fontSize: 13)),
                        ),
                      ],
                    ),
                  ),
                ],

                const SizedBox(height: 24),

                // ── Success banner ───────────────────────────────────
                if (_signedUp) ...[
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color:        Colors.green.shade50,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.green.shade300),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.check_circle_outline,
                            color: Colors.green.shade600, size: 22),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Account created!',
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: Colors.green.shade800,
                                      fontSize: 14)),
                              Text(
                                'Welcome, ${_nameCtrl.text.trim()}. Taking you to the app…',
                                style: TextStyle(
                                    color: Colors.green.shade700,
                                    fontSize: 12),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(
                          width: 18, height: 18,
                          child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.green.shade600),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 14),
                ],

                // Sign Up button
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _signedUp
                          ? Colors.green.shade200
                          : scheme.primary,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14)),
                    ),
                    // Disabled when loading OR already signed up
                    onPressed: (prov.loading || _signedUp) ? null : _signUp,
                    child: prov.loading
                        ? const SizedBox(
                        width: 22, height: 22,
                        child: CircularProgressIndicator(
                            strokeWidth: 2, color: Colors.white))
                        : Text(
                        _signedUp ? 'Account Created!' : 'Create Account',
                        style: const TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 16)),
                  ),
                ),

                const SizedBox(height: 20),

                // Already have account
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text('Already have an account?',
                        style: TextStyle(color: Colors.grey.shade700)),
                    TextButton(
                      onPressed: () => Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                            builder: (_) => const LoginScreen()),
                      ),
                      child: const Text('Sign In',
                          style: TextStyle(fontWeight: FontWeight.bold)),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}