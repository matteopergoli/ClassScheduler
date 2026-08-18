// lib/presentation/widgets/cs_dropdown.dart
//
// Typed dropdown that follows the app InputDecoration theme.
// Used in ConstraintFormScreen and anywhere else a styled
// dropdown is needed.
//
// Deliberately stateless: `value` is always driven by the parent and fed
// straight into DropdownButton, with no internal shadow copy. An earlier
// version kept its own `_currentValue` in sync via didUpdateWidget — a
// second source of truth that's easy to desync from the parent state after
// a rebuild (e.g. triggered by an unrelated Firestore stream re-emission)
// and is unnecessary since DropdownButton is already a controlled widget.

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
    // Defensive de-dup: DropdownButton asserts that at most one item shares
    // the current value. Guard against it defensively in case upstream data
    // (e.g. a Firestore collection) ever contains duplicate IDs.
    final seen = <T>{};
    final safeItems = <DropdownMenuItem<T>>[];
    for (final item in items) {
      if (seen.add(item.value as T)) safeItems.add(item);
    }
    final safeValue = (value != null && seen.contains(value)) ? value : null;

    // A DropdownButton with an empty `items` list silently disables itself
    // (Flutter won't even open the menu on tap) — from the outside that's
    // indistinguishable from "broken". Say so explicitly instead, so an
    // empty upstream list (e.g. no subjects loaded yet, or none exist for
    // this school) is obvious rather than looking like an unresponsive tap.
    final isEmpty = safeItems.isEmpty;

    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(8),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<T>(
          value: safeValue,
          hint: Padding(
            padding: const EdgeInsets.only(left: 12),
            child: Text(
              isEmpty ? 'No options available' : hint,
              style: isEmpty
                  ? TextStyle(color: Theme.of(context).disabledColor)
                  : null,
            ),
          ),
          items: safeItems,
          onChanged: isEmpty ? null : onChanged,
          isExpanded: true,
          icon: const Padding(
            padding: EdgeInsets.only(right: 8),
            child: Icon(Icons.keyboard_arrow_down_rounded),
          ),
        ),
      ),
    );
  }
}
