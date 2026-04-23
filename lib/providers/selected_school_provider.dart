// lib/providers/selected_school_provider.dart
//
// Tracks the currently active school across all bottom-nav tabs.
// Set by the Schools screen when the user taps a school card.
// Read by Setup, Constraints, Schedule screens to know which school
// to operate on.

import 'package:flutter_riverpod/flutter_riverpod.dart';

final selectedSchoolIdProvider =
    StateProvider<String?>((ref) => null);
