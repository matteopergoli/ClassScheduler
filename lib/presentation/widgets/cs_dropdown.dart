// lib/presentation/widgets/cs_dropdown.dart
//
// Typed dropdown that follows the app InputDecoration theme.
// Used in ConstraintFormScreen and anywhere else a styled
// dropdown is needed.

import 'package:flutter/material.dart';

class CsDropdown<T> extends StatelessWidget {
  final T? value;
  final String hint;
  final List<DropdownMenuItem<T>> items;
  final void Function(T?)? onChanged;
  final String? errorText;

  const CsDropdown({
    super.key,
    required this.value,
    required this.hint,
    required this.items,
    this.onChanged,
    this.errorText,
  });

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<T>(
      initialValue: value,
      hint: Text(hint),
      items: items,
      onChanged: onChanged,
      decoration: InputDecoration(errorText: errorText),
      isExpanded: true,
      icon: const Icon(Icons.keyboard_arrow_down_rounded),
    );
  }
}
