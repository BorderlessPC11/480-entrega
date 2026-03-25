import 'package:flutter/material.dart';

class AuthTextField extends StatelessWidget {
  const AuthTextField({
    super.key,
    required this.controller,
    required this.label,
    this.hint,
    this.keyboardType = TextInputType.text,
    this.obscureText = false,
    this.textInputAction = TextInputAction.next,
    this.autofillHints,
    this.validator,
    this.onToggleObscure,
    this.showObscureToggle = false,
  });

  final TextEditingController controller;
  final String label;
  final String? hint;
  final TextInputType keyboardType;
  final bool obscureText;
  final TextInputAction textInputAction;
  final Iterable<String>? autofillHints;
  final String? Function(String?)? validator;
  final VoidCallback? onToggleObscure;
  final bool showObscureToggle;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      obscureText: obscureText,
      textInputAction: textInputAction,
      autofillHints: autofillHints,
      validator: validator,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        suffixIcon: showObscureToggle
            ? IconButton(
                onPressed: onToggleObscure,
                icon: Icon(
                  obscureText ? Icons.visibility_rounded : Icons.visibility_off_rounded,
                ),
                tooltip: obscureText ? 'Mostrar senha' : 'Ocultar senha',
              )
            : null,
      ),
    );
  }
}
