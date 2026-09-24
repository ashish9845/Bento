import 'package:flutter/material.dart';
import 'package:reactive_forms/reactive_forms.dart';

class AppDropdownFormField<T> extends StatelessWidget {
  final String formControlName;
  final String label;
  final List<DropdownMenuItem<T>> items;
  const AppDropdownFormField({super.key, required this.formControlName, required this.label, required this.items});
  @override
  Widget build(BuildContext context) {
    return ReactiveDropdownField<T>(
      formControlName: formControlName,
      decoration: InputDecoration(labelText: label, border: const OutlineInputBorder()),
      items: items,
    );
  }
}
