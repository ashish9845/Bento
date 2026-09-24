import 'package:flutter/material.dart';
import 'package:reactive_forms/reactive_forms.dart';

class AppTextFormField extends StatelessWidget {
  final String formControlName;
  final String label;
  final bool obscureText;
  final TextInputType keyboardType;
  final Map<String, String Function(Object)>? validationMessages;

  const AppTextFormField({
    super.key,
    required this.formControlName,
    required this.label,
    this.obscureText = false,
    this.keyboardType = TextInputType.text,
    this.validationMessages,
  });

  @override
  Widget build(BuildContext context) {
    return ReactiveTextField<String>(
      formControlName: formControlName,
      obscureText: obscureText,
      keyboardType: keyboardType,
      decoration: InputDecoration(labelText: label, border: const OutlineInputBorder(), contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14)),
      validationMessages: validationMessages ??
          {
            ValidationMessage.required: (_) => 'Required',
            ValidationMessage.email: (_) => 'Invalid email',
          },
    );
  }
}
