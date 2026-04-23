// lib/domain/constraints/constraint_conflict_detector.dart
//
// FR-HC-03: Before generation, validate all user-defined hard constraints
// for internal consistency. Returns a list of ConflictResult objects —
// each with a plain-language description and a suggested resolution.
//
// Detected conflict types (per §3.6.2 FR-HC-03):
//   1. MUST-ASSIGN vs MUST-NOT-ASSIGN on the same (classroom, subject, day, slot)
//   2. MUST-ASSIGN targeting a Break Slot
//   3. MUST-ASSIGN where MinDaily[c,s] > 1 but only one lesson slot exists
//      that day for (c, s)  — teacher conflict edge case
//   4. Teacher conflicts: two MUST-ASSIGN rules force the same teacher into
//      the same (day, slot) across different classrooms

import '../../data/models/app_models.dart';

// ── Public types ─────────────────────────────────────────────────────────────

class ConflictResult {
  final String constraintIdA;
  final String? constraintIdB; // null for single-constraint violations
  final ConflictType type;
  final String description;   // plain English — shown directly in UI
  final String suggestion;    // corrective action hint

  const ConflictResult({
    required this.constraintIdA,
    this.constraintIdB,
    required this.type,
    required this.description,
    required this.suggestion,
  });

  bool get isBlocker => true; // all detected conflicts block generation
}

enum ConflictType {
  mustAssignVsMustNot,
  mustAssignOnBreakSlot,
  mustAssignMinDailyConflict,
  mustAssignTeacherConflict,
}

// ── Detector ─────────────────────────────────────────────────────────────────

class ConstraintConflictDetector {
  /// Run all conflict checks and return every violation found.
  ///
  /// [hardConstraints]    — all HARD constraints for the school
  /// [periods]            — ordered list of all periods (LESSON + BREAK)
  /// [subjects]           — all subjects (needed to resolve teacherName)
  /// [classroomSubjects]  — all classroom–subject assignments (for MinDaily check)
  /// [lessonPeriodsPerDay]— Map<dayCode, List<PeriodModel>> of LESSON-type periods
  ///                        available on each active day
  static List<ConflictResult> detect({
    required List<ConstraintModel> hardConstraints,
    required List<PeriodModel> periods,
    required List<SubjectModel> subjects,
    required List<ClassroomSubjectModel> classroomSubjects,
    required Map<String, List<PeriodModel>> lessonPeriodsPerDay,
  }) {
    final conflicts = <ConflictResult>[];

    // Index helpers
    final periodById  = {for (final p in periods) p.id: p};
    final subjectById = {for (final s in subjects) s.id: s};

    // Only MUST_ASSIGN and MUST_NOT_ASSIGN constraints carry the full
    // (classroomId, subjectId, dayOfWeek, periodId) tuple.
    final mustAssign    = hardConstraints
        .where((c) => c.type == 'MUST_ASSIGN').toList();
    final mustNotAssign = hardConstraints
        .where((c) => c.type == 'MUST_NOT_ASSIGN').toList();

    // ── Check 1: MUST-ASSIGN vs MUST-NOT-ASSIGN on the same cell ────────────
    for (final ma in mustAssign) {
      for (final mna in mustNotAssign) {
        if (_sameCell(ma, mna)) {
          final label = _cellLabel(ma, periodById, subjectById);
          conflicts.add(ConflictResult(
            constraintIdA: ma.id,
            constraintIdB: mna.id,
            type: ConflictType.mustAssignVsMustNot,
            description:
                'Conflict: "$label" is both required (MUST-ASSIGN) '
                'and forbidden (MUST-NOT-ASSIGN) at the same time.',
            suggestion:
                'Remove one of the two conflicting constraints for this slot.',
          ));
        }
      }
    }

    // ── Check 2: MUST-ASSIGN on a Break Slot ────────────────────────────────
    for (final ma in mustAssign) {
      if (ma.periodId == null) continue;
      final period = periodById[ma.periodId];
      if (period != null && period.type == 'BREAK') {
        final subj = subjectById[ma.subjectId]?.name ?? ma.subjectId ?? '?';
        final periodName = period.name ?? '${period.startTime}–${period.endTime}';
        conflicts.add(ConflictResult(
          constraintIdA: ma.id,
          type: ConflictType.mustAssignOnBreakSlot,
          description:
              '"$subj" is forced into "$periodName", which is a break slot. '
              'No subject can be assigned during a break.',
          suggestion:
              'Change the MUST-ASSIGN constraint to target a lesson slot, '
              'or remove it.',
        ));
      }
    }

    // ── Check 3: MUST-ASSIGN + MinDaily[c,s] > 1 but only 1 slot that day ──
    //
    // If a subject has MinDaily = 2 and only one MUST-ASSIGN exists for
    // that (classroom, subject, day), the algorithm would need to place
    // a second slot — but if only one lesson slot is available that day
    // the constraint is impossible to satisfy.
    for (final ma in mustAssign) {
      if (ma.classroomId == null || ma.subjectId == null ||
          ma.dayOfWeek == null) {
        continue;
      }

      // Find the ClassroomSubject assignment
      final cs = classroomSubjects.firstWhereOrNull(
        (x) => x.classroomId == ma.classroomId &&
               x.subjectId   == ma.subjectId,
      );
      if (cs == null || cs.minDailyHours <= 1) continue;

      // Count available lesson slots on that day
      final lessonSlots =
          (lessonPeriodsPerDay[ma.dayOfWeek] ?? []).length;
      if (lessonSlots < cs.minDailyHours) {
        final subj    = subjectById[ma.subjectId]?.name ?? '?';
        final cls     = ma.classroomId ?? '?';
        final day     = ma.dayOfWeek ?? '?';
        conflicts.add(ConflictResult(
          constraintIdA: ma.id,
          type: ConflictType.mustAssignMinDailyConflict,
          description:
              '"$subj" in "$cls" on $day has a minimum of '
              '${cs.minDailyHours} slots/day, but only $lessonSlots lesson '
              'slot(s) exist on that day — impossible to satisfy.',
          suggestion:
              'Reduce the minimum daily hours for "$subj" in "$cls", '
              'add more lesson slots on $day, or remove the MUST-ASSIGN constraint.',
        ));
      }
    }

    // ── Check 4: Teacher conflict — two MUST-ASSIGN force the same teacher
    //            into the same (day, slot) across different classrooms ───────
    //
    // Group MUST-ASSIGN by (teacherName, dayOfWeek, periodId).
    // If any group has more than one classroom → conflict.
    final Map<String, List<ConstraintModel>> teacherSlotMap = {};
    for (final ma in mustAssign) {
      if (ma.subjectId == null || ma.dayOfWeek == null ||
          ma.periodId == null) {
        continue;
      }
      final subject = subjectById[ma.subjectId];
      if (subject == null) continue;
      final key =
          '${subject.teacherName}__${ma.dayOfWeek}__${ma.periodId}';
      teacherSlotMap.putIfAbsent(key, () => []).add(ma);
    }

    for (final entry in teacherSlotMap.entries) {
      final group = entry.value;
      if (group.length < 2) continue;

      // Build readable description from the first two conflicting items
      final a       = group[0];
      final b       = group[1];
      final teacher = subjectById[a.subjectId]?.teacherName ?? '?';
      final period  = periodById[a.periodId];
      final timeStr = period != null
          ? '${period.startTime}–${period.endTime}'
          : a.periodId ?? '?';
      final dayStr  = a.dayOfWeek ?? '?';
      final clsA    = a.classroomId ?? '?';
      final clsB    = b.classroomId ?? '?';

      conflicts.add(ConflictResult(
        constraintIdA: a.id,
        constraintIdB: b.id,
        type: ConflictType.mustAssignTeacherConflict,
        description:
            'Teacher "$teacher" is forced into $dayStr at $timeStr by two '
            'different MUST-ASSIGN rules: "$clsA" and "$clsB". '
            'A teacher can only be in one classroom at a time.',
        suggestion:
            'Remove or reschedule one of the MUST-ASSIGN constraints so '
            '"$teacher" is not required in two classrooms simultaneously.',
      ));
    }

    return conflicts;
  }

  // ── Helpers ───────────────────────────────────────────────────────────────

  static bool _sameCell(ConstraintModel a, ConstraintModel b) =>
      a.classroomId == b.classroomId &&
      a.subjectId   == b.subjectId   &&
      a.dayOfWeek   == b.dayOfWeek   &&
      a.periodId    == b.periodId;

  static String _cellLabel(
    ConstraintModel c,
    Map<String, PeriodModel> periodById,
    Map<String, SubjectModel> subjectById,
  ) {
    final subj   = subjectById[c.subjectId]?.name ?? c.subjectId ?? '?';
    final cls    = c.classroomId ?? '?';
    final day    = c.dayOfWeek   ?? '?';
    final period = c.periodId != null ? periodById[c.periodId] : null;
    final time   = period != null
        ? '${period.startTime}–${period.endTime}'
        : c.periodId ?? '?';
    return '$subj in $cls on $day at $time';
  }
}

// ── Extension helper (Dart <3.0 compatible firstWhereOrNull) ─────────────────
extension _ListExt<T> on List<T> {
  T? firstWhereOrNull(bool Function(T) test) {
    for (final e in this) {
      if (test(e)) return e;
    }
    return null;
  }
}
