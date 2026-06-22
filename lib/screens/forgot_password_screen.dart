// =============================================================================
// screens/forgot_password_screen.dart
// Send password reset email via Firebase Auth
// =============================================================================

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart' as ap;
import '../widgets/auth_form_field.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _emailCtrl = TextEditingController();
  bool  _sent      = false;
  bool  _loading   = false;
  String? _error;

  @override
  void dispose() {
    _emailCtrl.dispose();
    super.dispose();
  }

  Future<void> _send() async {
    final email = _emailCtrl.text.trim();
    if (email.isEmpty) {
      setState(() => _error = 'Please enter your email address.');
      return;
    }
    if (!email.contains('@')) {
      setState(() => _error = 'Please enter a valid email address.');
      return;
    }

    setState(() { _loading = true; _error = null; });

    final err = await context.read<ap.AuthProvider>()
        .sendPasswordReset(email);

    setState(() {
      _loading = false;
      // For security, always show success even if email not found —
      // this prevents email enumeration attacks.
      // If there's a network/format error, show it; otherwise succeed silently.
      if (err != null &&
          err.contains('network') ||
          err != null && err.contains('valid email')) {
        _error = err;
      } else {
        _sent = true; // show success regardless
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(title: const Text('Reset Password')),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: _sent ? _successView(context, scheme) : _formView(scheme),
        ),
      ),
    );
  }

  Widget _formView(ColorScheme scheme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Forgot your password?',
            style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: scheme.primary)),
        const SizedBox(height: 8),
        Text(
          'Enter your email and we\'ll send you a link to reset your password.',
          style: TextStyle(color: Colors.grey.shade600, fontSize: 14),
        ),
        const SizedBox(height: 28),
        AuthFormField(
          controller:  _emailCtrl,
          label:       'Email',
          hint:        'you@example.com',
          icon:        Icons.email_outlined,
          keyboardType: TextInputType.emailAddress,
        ),
        if (_error != null) ...[
          const SizedBox(height: 12),
          Text(_error!,
              style: TextStyle(color: scheme.error, fontSize: 13)),
        ],
        const SizedBox(height: 24),
        SizedBox(
          width: double.infinity,
          height: 52,
          child: ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: scheme.primary,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14)),
            ),
            onPressed: _loading ? null : _send,
            icon: _loading
                ? const SizedBox(
                width: 18, height: 18,
                child: CircularProgressIndicator(
                    strokeWidth: 2, color: Colors.white))
                : const Icon(Icons.send_outlined),
            label: Text(_loading ? 'Sending…' : 'Send Reset Link',
                style: const TextStyle(
                    fontWeight: FontWeight.bold, fontSize: 16)),
          ),
        ),
      ],
    );
  }

  Widget _successView(BuildContext context, ColorScheme scheme) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.mark_email_read_outlined,
              size: 72, color: scheme.primary),
          const SizedBox(height: 20),
          const Text('Reset Link Sent!',
              style: TextStyle(
                  fontSize: 22, fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          Text(
            'If an account exists for\n${_emailCtrl.text.trim()}\nyou will receive a reset link shortly.\n\nCheck your spam folder too.',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.grey.shade600, fontSize: 14),
          ),
          const SizedBox(height: 32),
          OutlinedButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Back to Login'),
          ),
        ],
      ),
    );
  }
}