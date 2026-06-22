// =============================================================================
// screens/login_screen.dart
// Firebase Email/Password Login
// Matches JAJI design language from Assignments 2–4
// =============================================================================

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart' as ap;
import '../widgets/auth_form_field.dart';
import 'intro_screen.dart';
import 'signup_screen.dart';
import 'forgot_password_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen>
    with SingleTickerProviderStateMixin {
  final _formKey    = GlobalKey<FormState>();
  final _emailCtrl  = TextEditingController();
  final _passCtrl   = TextEditingController();

  late AnimationController _animCtrl;
  late Animation<double>   _fadeAnim;
  late Animation<double>   _scaleAnim;

  @override
  void initState() {
    super.initState();
    _animCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );
    _fadeAnim  = CurvedAnimation(parent: _animCtrl, curve: Curves.easeIn);
    _scaleAnim = Tween<double>(begin: 0.88, end: 1.0).animate(
        CurvedAnimation(parent: _animCtrl, curve: Curves.elasticOut));
    _animCtrl.forward();
  }

  @override
  void dispose() {
    _animCtrl.dispose();
    _emailCtrl.dispose();
    _passCtrl.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    context.read<ap.AuthProvider>().clearError();
    if (!_formKey.currentState!.validate()) return;

    final success = await context.read<ap.AuthProvider>().signIn(
      email:    _emailCtrl.text,
      password: _passCtrl.text,
    );

    if (!mounted) return;

    if (success) {
      // Navigate to IntroScreen and clear the entire back stack
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const IntroScreen()),
            (route) => false,
      );
    } else {
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
  }

  @override
  Widget build(BuildContext context) {
    final prov   = context.watch<ap.AuthProvider>();
    final scheme = Theme.of(context).colorScheme;

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end:   Alignment.bottomCenter,
            colors: [
              scheme.primaryContainer,
              scheme.primaryContainer.withValues(alpha: 0.4),
              Colors.white.withValues(alpha: 0.9),
            ],
          ),
        ),
        child: SafeArea(
          child: FadeTransition(
            opacity: _fadeAnim,
            child: ScaleTransition(
              scale: _scaleAnim,
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(
                    horizontal: 28, vertical: 24),
                child: Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      const SizedBox(height: 32),

                      // ── App icon + name ──────────────────────────────
                      Icon(Icons.landscape_rounded,
                          size: 72, color: scheme.primary),
                      const SizedBox(height: 12),
                      Text('National Parks Explorer',
                          style: TextStyle(
                              fontSize: 26,
                              fontWeight: FontWeight.bold,
                              color: scheme.primary)),
                      const SizedBox(height: 4),
                      Text('Discover America\'s Wild Places',
                          style: TextStyle(
                              fontSize: 13,
                              color: scheme.primary.withValues(alpha: 0.7),
                              letterSpacing: 0.5)),

                      const SizedBox(height: 40),

                      // ── Login card ───────────────────────────────────
                      Container(
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.92),
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: scheme.primary.withValues(alpha: 0.1),
                              blurRadius: 20,
                              spreadRadius: 2,
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('Welcome back',
                                style: TextStyle(
                                    fontSize: 22,
                                    fontWeight: FontWeight.bold)),
                            const SizedBox(height: 4),
                            Text('Sign in to continue exploring',
                                style: TextStyle(
                                    color: Colors.grey.shade600,
                                    fontSize: 14)),

                            const SizedBox(height: 24),

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
                                if (!v.contains('@')) {
                                  return 'Enter a valid email';
                                }
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
                                if (v == null || v.isEmpty) {
                                  return 'Password is required';
                                }
                                if (v.length < 6) {
                                  return 'Minimum 6 characters';
                                }
                                return null;
                              },
                            ),

                            // Error message
                            if (prov.error != null) ...[
                              const SizedBox(height: 12),
                              _ErrorBanner(message: prov.error!),
                            ],

                            // Forgot password
                            Align(
                              alignment: Alignment.centerRight,
                              child: TextButton(
                                onPressed: () => Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (_) =>
                                      const ForgotPasswordScreen()),
                                ),
                                child: const Text('Forgot password?'),
                              ),
                            ),

                            // Sign In button
                            SizedBox(
                              width: double.infinity,
                              height: 52,
                              child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: scheme.primary,
                                  foregroundColor: Colors.white,
                                  shape: RoundedRectangleBorder(
                                      borderRadius:
                                      BorderRadius.circular(14)),
                                  elevation: 2,
                                ),
                                onPressed: prov.loading ? null : _login,
                                child: prov.loading
                                    ? const SizedBox(
                                    width: 22, height: 22,
                                    child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        color: Colors.white))
                                    : const Text('Sign In',
                                    style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16)),
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 24),

                      // ── Sign up link ─────────────────────────────────
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text("Don't have an account?",
                              style: TextStyle(color: Colors.grey.shade700)),
                          TextButton(
                            onPressed: () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (_) => const SignUpScreen()),
                            ),
                            child: const Text('Sign Up',
                                style: TextStyle(
                                    fontWeight: FontWeight.bold)),
                          ),
                        ],
                      ),

                      const SizedBox(height: 16),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ── Error banner ──────────────────────────────────────────────────────────────

class _ErrorBanner extends StatelessWidget {
  final String message;
  const _ErrorBanner({required this.message});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color:        Colors.red.shade50,
        borderRadius: BorderRadius.circular(10),
        border:       Border.all(color: Colors.red.shade200),
      ),
      child: Row(
        children: [
          Icon(Icons.error_outline, color: Colors.red.shade400, size: 18),
          const SizedBox(width: 8),
          Expanded(
            child: Text(message,
                style: TextStyle(
                    color: Colors.red.shade700, fontSize: 13)),
          ),
        ],
      ),
    );
  }
}