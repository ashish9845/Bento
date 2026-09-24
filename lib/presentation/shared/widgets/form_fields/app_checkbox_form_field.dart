import 'package:flutter/material.dart';
import 'package:reactive_forms/reactive_forms.dart';

class AppCheckboxFormField extends StatelessWidget {
  final String formControlName;
  final String label;
  const AppCheckboxFormField({super.key, required this.formControlName, required this.label});
  @override
  Widget build(BuildContext context) {
    return ReactiveCheckboxListTile(
      formControlName: formControlName,
      title: Text(label),
      controlAffinity: ListTileControlAffinity.leading,
    );
  }
}
