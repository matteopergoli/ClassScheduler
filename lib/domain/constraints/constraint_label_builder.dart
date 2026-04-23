// lib/domain/constraints/constraint_label_builder.dart
//
// Converts a ConstraintModel into a plain-English sentence for display
// in the constraint list screen (FR-HC-04, FR-SC-03).
// All algorithm terminology is hidden from the user (§5.3).
//
// Examples:
//   MUST_ASSIGN   → "Maths must be scheduled in 1A on Monday at 09:00–10:00."
//   MUST_NOT_ASSIGN → "Science must NOT be in 2B on Wednesday at 11:00–12:00."
//   AVOID_TIMESLOT  → "English should be avoided in the 14:00–15:00 slot on Friday."
//   PREFER_BLOCK    → "History should be scheduled in consecutive slots."

import '../../data/models/app_models.dart';

class ConstraintLabelBuilder {
  final Map<String, SubjectModel>  subjects;
  final Map<String, ClassroomModel> classrooms;
  final Map<String, PeriodModel>   periods;

  const ConstraintLabelBuilder({
    required this.subjects,
    required this.classrooms,
    required this.periods,
  });

  /// Returns the primary human-readable sentence for [c].
  String label(ConstraintModel c) {
    switch (c.type) {
      case 'MUST_ASSIGN':
        return _mustAssign(c);
      case 'MUST_NOT_ASSIGN':
        return _mustNotAssign(c);
      case 'AVOID_TIMESLOT':
        return _avoidTimeslot(c);
      case 'PREFER_BLOCK':
        return _preferBlock(c);
      default:
        return 'Unknown constraint type: ${c.type}';
    }
  }

  /// Returns a shorter subtitle (e.g. for card secondary line).
  String subtitle(ConstraintModel c) {
    if (c.kind == 'SOFT') {
      final w = _weightLabel(c.weight);
      return 'Soft · Priority: $w';
    }
    return 'Hard constraint';
  }

  // ── Private builders ──────────────────────────────────────────────────────

  String _mustAssign(ConstraintModel c) {
    final subj  = _subjectName(c.subjectId);
    final cls   = _classroomName(c.classroomId);
    final day   = _dayName(c.dayOfWeek);
    final time  = _periodTime(c.periodId);
    return '$subj must be scheduled in $cls on $day at $time.';
  }

  String _mustNotAssign(ConstraintModel c) {
    final subj  = _subjectName(c.subjectId);
    final cls   = _classroomName(c.classroomId);
    final day   = _dayName(c.dayOfWeek);
    final time  = _periodTime(c.periodId);
    return '$subj must NOT be scheduled in $cls on $day at $time.';
  }

  String _avoidTimeslot(ConstraintModel c) {
    final subj  = _subjectName(c.subjectId);
    final day   = _dayName(c.dayOfWeek);
    final start = _periodTime(c.periodId);
    final end   = c.endPeriodId != null
        ? _periodEndTime(c.endPeriodId)
        : start;
    if (c.dayOfWeek != null) {
      return '$subj should be avoided on $day between $start and $end.';
    }
    return '$subj should be avoided between $start and $end.';
  }

  String _preferBlock(ConstraintModel c) {
    final subj = _subjectName(c.subjectId);
    return '$subj should be scheduled in consecutive slots when possible.';
  }

  // ── Lookup helpers ────────────────────────────────────────────────────────

  String _subjectName(String? id) =>
      id != null ? (subjects[id]?.name ?? id) : 'Unknown subject';

  String _classroomName(String? id) =>
      id != null ? (classrooms[id]?.name ?? id) : 'Unknown class';

  String _periodTime(String? id) {
    if (id == null) return '?';
    final p = periods[id];
    return p != null ? '${p.startTime}–${p.endTime}' : id;
  }

  String _periodEndTime(String? id) {
    if (id == null) return '?';
    final p = periods[id];
    return p != null ? p.endTime : id;
  }

  String _dayName(String? code) {
    const map = {
      'MON': 'Monday',
      'TUE': 'Tuesday',
      'WED': 'Wednesday',
      'THU': 'Thursday',
      'FRI': 'Friday',
      'SAT': 'Saturday',
      'SUN': 'Sunday',
    };
    return code != null ? (map[code] ?? code) : 'any day';
  }

  String _weightLabel(String? weight) {
    switch (weight) {
      case 'HIGH':   return 'High';
      case 'MEDIUM': return 'Medium';
      case 'LOW':    return 'Low';
      default:       return 'Medium';
    }
  }
}
