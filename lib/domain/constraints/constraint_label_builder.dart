// lib/domain/constraints/constraint_label_builder.dart
//
// Converts a ConstraintModel into a plain-English sentence for display
// in the constraint list screen (FR-HC-04, FR-SC-03).
// All algorithm terminology is hidden from the user (§5.3).
//
// Examples:
//   MUST_ASSIGN   → "Maths must be scheduled in 1A on Monday at 09:00–10:00."
//                   (or "...between 09:00 and 11:00." when it spans a range)
//   MUST_NOT_ASSIGN → "Science must NOT be in 2B on Wednesday at 11:00–12:00."
//   AVOID_TIMESLOT  → "English should be avoided in the 14:00–15:00 slot on Friday."
//                     (classroom name prepended when scoped to one)
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
      case 'DAILY_LIMIT':
        return _dailyLimit(c);
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
    final subj = _subjectName(c.subjectId);
    final cls  = _classroomName(c.classroomId);
    final day  = _dayName(c.dayOfWeek);
    final time = _rangeTime(c.periodId, c.endPeriodId);
    return '$subj must be scheduled in $cls on $day at $time.';
  }

  String _mustNotAssign(ConstraintModel c) {
    final subj = _subjectName(c.subjectId);
    final cls  = _classroomName(c.classroomId);
    final day  = _dayName(c.dayOfWeek);
    final time = _rangeTime(c.periodId, c.endPeriodId);
    return '$subj must NOT be scheduled in $cls on $day at $time.';
  }

  String _avoidTimeslot(ConstraintModel c) {
    final subj  = _subjectName(c.subjectId);
    final cls   = c.classroomId != null ? ' in ${_classroomName(c.classroomId)}' : '';
    final day   = _dayName(c.dayOfWeek);
    final start = _periodTime(c.periodId);
    final end   = c.endPeriodId != null
        ? _periodEndTime(c.endPeriodId)
        : start;
    if (c.dayOfWeek != null) {
      return '$subj$cls should be avoided on $day between $start and $end.';
    }
    return '$subj$cls should be avoided between $start and $end.';
  }

  String _preferBlock(ConstraintModel c) {
    final subj = _subjectName(c.subjectId);
    final cls  = c.classroomId != null ? ' in ${_classroomName(c.classroomId)}' : '';
    if (c.dayOfWeek == null && c.periodId == null) {
      return '$subj$cls should be scheduled in consecutive slots when possible.';
    }
    final scope = c.periodId != null
        ? ' between ${_periodTime(c.periodId)} and '
            '${c.endPeriodId != null ? _periodEndTime(c.endPeriodId) : _periodTime(c.periodId)}'
        : '';
    final day = c.dayOfWeek != null ? ' on ${_dayName(c.dayOfWeek)}' : '';
    return '$subj$cls should be scheduled in consecutive slots when possible'
        '$day$scope.';
  }

  String _dailyLimit(ConstraintModel c) {
    final subj = _subjectName(c.subjectId);
    final cls  = _classroomName(c.classroomId);
    final min  = c.minHours;
    final max  = c.maxHours;
    if (min != null && min > 0 && max != null) {
      return '$subj in $cls should stay within $min–$max hours/day.';
    }
    if (max != null) {
      return '$subj in $cls should stay under $max hours/day.';
    }
    if (min != null && min > 0) {
      return '$subj in $cls should reach at least $min hours on days it\'s scheduled.';
    }
    return '$subj in $cls has a daily-hours preference.';
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

  String _periodStartTime(String? id) {
    if (id == null) return '?';
    final p = periods[id];
    return p != null ? p.startTime : id;
  }

  /// Single-slot phrasing ("09:00–10:00") when [endId] is null or the same
  /// slot as [startId]; range phrasing ("09:00 and 11:00") otherwise.
  String _rangeTime(String? startId, String? endId) {
    if (endId == null || endId == startId) return _periodTime(startId);
    return '${_periodStartTime(startId)} and ${_periodEndTime(endId)}';
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
