// lib/domain/constraints/constraint_label_builder.dart
//
// Converts a ConstraintModel into a localised, plain-language sentence for
// display in the constraint list screen (FR-HC-04, FR-SC-03).
// All algorithm terminology is hidden from the user (§5.3).

import '../../data/models/app_models.dart';
import '../../l10n/generated/app_localizations.dart';

class ConstraintLabelBuilder {
  final Map<String, SubjectModel> subjects;
  final Map<String, ClassroomModel> classrooms;
  final Map<String, PeriodModel> periods;
  final AppLocalizations l10n;

  const ConstraintLabelBuilder({
    required this.subjects,
    required this.classrooms,
    required this.periods,
    required this.l10n,
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
        return l10n.clUnknownType(c.type);
    }
  }

  /// Returns a shorter subtitle (e.g. for card secondary line).
  String subtitle(ConstraintModel c) {
    if (c.kind == 'SOFT') {
      return l10n.clSubtitleSoft(_weightLabel(c.weight));
    }
    return l10n.clSubtitleHard;
  }

  // ── Private builders ──────────────────────────────────────────────────────

  String _mustAssign(ConstraintModel c) => l10n.clMustAssign(
        _subjectName(c.subjectId),
        _classroomName(c.classroomId),
        _dayName(c.dayOfWeek),
        _rangeTime(c.periodId, c.endPeriodId),
      );

  String _mustNotAssign(ConstraintModel c) => l10n.clMustNotAssign(
        _subjectName(c.subjectId),
        _classroomName(c.classroomId),
        _dayName(c.dayOfWeek),
        _rangeTime(c.periodId, c.endPeriodId),
      );

  String _avoidTimeslot(ConstraintModel c) {
    final subj = _subjectName(c.subjectId);
    final scope =
        c.classroomId != null ? l10n.clInClassroom(_classroomName(c.classroomId)) : '';
    final start = _periodTime(c.periodId);
    final end = c.endPeriodId != null ? _periodEndTime(c.endPeriodId) : start;
    if (c.dayOfWeek != null) {
      return l10n.clAvoidTimeslotDay(subj, scope, _dayName(c.dayOfWeek), start, end);
    }
    return l10n.clAvoidTimeslotNoDay(subj, scope, start, end);
  }

  String _preferBlock(ConstraintModel c) {
    final subj = _subjectName(c.subjectId);
    final scope =
        c.classroomId != null ? l10n.clInClassroom(_classroomName(c.classroomId)) : '';
    var detail = '';
    if (c.dayOfWeek != null || c.periodId != null) {
      final parts = <String>[];
      if (c.dayOfWeek != null) parts.add(_dayName(c.dayOfWeek));
      if (c.periodId != null) {
        final end = c.endPeriodId != null
            ? _periodEndTime(c.endPeriodId)
            : _periodTime(c.periodId);
        parts.add('${_periodStartTime(c.periodId)}–$end');
      }
      detail = ' (${parts.join(', ')})';
    }
    return l10n.clPreferBlock(subj, scope, detail);
  }

  String _dailyLimit(ConstraintModel c) {
    final subj = _subjectName(c.subjectId);
    final cls = _classroomName(c.classroomId);
    final min = c.minHours;
    final max = c.maxHours;
    if (min != null && min > 0 && max != null) {
      return l10n.clDailyLimitRange(subj, cls, min, max);
    }
    if (max != null) {
      return l10n.clDailyLimitMax(subj, cls, max);
    }
    if (min != null && min > 0) {
      return l10n.clDailyLimitMin(subj, cls, min);
    }
    return l10n.clDailyLimitGeneric(subj, cls);
  }

  // ── Lookup helpers ────────────────────────────────────────────────────────

  String _subjectName(String? id) =>
      id != null ? (subjects[id]?.name ?? id) : l10n.unknownSubject;

  String _classroomName(String? id) =>
      id != null ? (classrooms[id]?.name ?? id) : l10n.unknownClass;

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
  /// slot as [startId]; range phrasing ("09:00–11:00") otherwise.
  String _rangeTime(String? startId, String? endId) {
    if (endId == null || endId == startId) return _periodTime(startId);
    return '${_periodStartTime(startId)}–${_periodEndTime(endId)}';
  }

  String _dayName(String? code) {
    switch (code) {
      case 'MON': return l10n.dayLongMon;
      case 'TUE': return l10n.dayLongTue;
      case 'WED': return l10n.dayLongWed;
      case 'THU': return l10n.dayLongThu;
      case 'FRI': return l10n.dayLongFri;
      case 'SAT': return l10n.dayLongSat;
      case 'SUN': return l10n.dayLongSun;
      default: return code ?? l10n.clAnyDay;
    }
  }

  String _weightLabel(String? weight) {
    switch (weight) {
      case 'HIGH': return l10n.weightHigh;
      case 'LOW': return l10n.weightLow;
      default: return l10n.weightMedium;
    }
  }
}
