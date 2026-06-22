// =============================================================================
// widgets/auth_form_field.dart
// Reusable styled text field for login / signup forms
// =============================================================================

import 'package:flutter/material.dart';

class AuthFormField extends StatefulWidget {
  final TextEditingController controller;
  final String                label;
  final String                hint;
  final IconData              icon;
  final bool                  isPassword;
  final TextInputType         keyboardType;
  final String?               Function(String?)? validator;
  final void Function(String)? onChanged;

  const AuthFormField({
    super.key,
    required this.controller,
    required this.label,
    required this.hint,
    required this.icon,
    this.isPassword      = false,
    this.keyboardType    = TextInputType.text,
    this.validator,
    this.onChanged,
  });

  @override
  State<AuthFormField> createState() => _AuthFormFieldState();
}

class _AuthFormFieldState extends State<AuthFormField> {
  bool _obscure = true;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return TextFormField(
      controller:   widget.controller,
      obscureText:  widget.isPassword && _obscure,
      keyboardType: widget.keyboardType,
      onChanged:    widget.onChanged,
      validator:    widget.validator,
      decoration: InputDecoration(
        labelText: widget.label,
        hintText:  widget.hint,
        prefixIcon: Icon(widget.icon, color: scheme.primary),
        suffixIcon: widget.isPassword
            ? IconButton(
                icon: Icon(
                  _obscure ? Icons.visibility_off_outlined
                           : Icons.visibility_outlined,
                  color: Colors.grey,
                ),
                onPressed: () => setState(() => _obscure = !_obscure),
              )
            : null,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: scheme.primary, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: scheme.error),
        ),
        filled:     true,
        fillColor:  scheme.surfaceContainerHighest.withValues(alpha: 0.3),
        contentPadding: const EdgeInsets.symmetric(
            horizontal: 16, vertical: 16),
      ),
    );
  }
}
