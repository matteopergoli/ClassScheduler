// lib/domain/scheduler/drag_drop_validator.dart
//
// FR-VIEW-04: When the user drags a lesson cell to a different slot,
// all hard constraints are validated in real time. Illegal moves are
// rejected with a message identifying the specific violated constraint.
//
// This validator works on the already-loaded cell data (not the full
// SchedulerInput) so it can run synchronously on the UI thread during
// drag operations.

import '../../data/models/app_models.dart';

// ── Result type ──────────────────────────────────────────────────────────────

class DragValidationResult {
  final bool allowed;
  final String? violationMessage; // plain English, null if allowed

  const DragValidationResult.allowed()
      : allowed = true,
        violationMessage = null;

  const DragValidationResult.rejected(String message)
      : allowed = false,
        violationMessage = message;
}

// ── Validator ────────────────────────────────────────────────────────────────

class DragDropValidator {
  /// Validates whether moving [sourceCell] to [targetCell] is legal.
  ///
  /// [allCells]        — all ScheduleCellModels for the current schedule
  /// [subjects]        — all subjects (for teacher-name lookup)
  /// [classroomSubjects] — all classroom–subject assignments (for MaxDaily/MinDaily)
  /// [dailyCapacities] — all DayCapacity records
  /// [periods]         — all LESSON periods (for ordering context)
  /// [activeDayCodes]  — ordered list of active day strings
  static DragValidationResult validate({
    required ScheduleCellModel      sourceCell,
    required ScheduleCellModel      targetCell,
    required List<ScheduleCellModel> allCells,
    required List<SubjectModel>      subjects,
    required List<ClassroomSubjectModel> classroomSubjects,
    required List<DayCapacityModel>  dailyCapacities,
    required List<PeriodModel>       periods,
    required List<String>            activeDayCodes,
  }) {
    final movingSubjectId = sourceCell.subjectId;
    if (movingSubjectId == null) {
      return const DragValidationResult.rejected(
          'Cannot move a free slot.');
    }

    final subjectById = {for (final s in subjects) s.id: s};
    final movingSubject = subjectById[movingSubjectId];
    if (movingSubject == null) {
      return const DragValidationResult.rejected('Subject not found.');
    }

    // ── HC-8: target must be free ─────────────────────────────────────────
    // (Unless it's a swap within same classroom — handled by swapCells)
    if (targetCell.subjectId != null &&
        targetCell.classroomId != sourceCell.classroomId) {
      return const DragValidationResult.rejected(
          'That slot is already occupied by another subject.');
    }

    final targetDayCode = _dayCodeFromCellId(targetCell.id, activeDayCodes);
    final sourceDayCode = _dayCodeFromCellId(sourceCell.id, activeDayCodes);

    // ── HC-1: teacher conflict ─────────────────────────────────────────────
    // Check no other classroom has the moving subject's teacher at
    // (targetDay, targetPeriod) — unless it's the source cell being vacated.
    final teacherName = movingSubject.teacherName;
    for (final cell in allCells) {
      if (cell.id == sourceCell.id)   continue; // source vacated
      if (cell.id == targetCell.id)   continue; // destination being filled
      if (cell.subjectId == null)     continue;
      final cellSubject = subjectById[cell.subjectId!];
      if (cellSubject == null)        continue;
      if (cellSubject.teacherName != teacherName) continue;
      // Same teacher — check if same (day, period) as target
      if (cell.periodId == targetCell.periodId &&
          _dayCodeFromCellId(cell.id, activeDayCodes) == targetDayCode) {
        return DragValidationResult.rejected(
            '${movingSubject.teacherName} already has a lesson in '
            '"${_classroomNameHint(cell.classroomId)}" at this time slot.');
      }
    }

    // ── HC-2: daily capacity + blocked-slot check at destination ────────
    final targetClassroomId = targetCell.classroomId;
    final targetDayIdx = activeDayCodes.indexOf(targetDayCode ?? '');
    if (targetDayIdx >= 0) {
      final dcRecord = dailyCapacities
          .where((dc) =>
              dc.classroomId == targetClassroomId &&
              dc.dayOfWeek   == targetDayCode)
          .firstOrNull;

      // Capacity = number of active (non-blocked) slots.
      // Falls back to total lesson periods if no record exists.
      final cap = dcRecord?.activeSlots.length ?? periods.length;

      // Reject if the target period itself is blocked.
      if (dcRecord != null) {
        final targetPeriodIdx =
            periods.indexWhere((p) => p.id == targetCell.periodId);
        if (targetPeriodIdx >= 0 &&
            !dcRecord.activeSlots.contains(targetPeriodIdx)) {
          return DragValidationResult.rejected(
              'That slot is blocked for this classroom on '
              '${_dayLabel(targetDayCode)}.');
        }
      }

      final currentCount = allCells
          .where((c) =>
              c.classroomId == targetClassroomId &&
              c.subjectId   != null &&
              c.id          != sourceCell.id &&
              _dayCodeFromCellId(c.id, activeDayCodes) == targetDayCode)
          .length;

      // Only increment if moving to a different day
      final addingLesson = sourceDayCode != targetDayCode ||
                           sourceCell.classroomId != targetClassroomId;
      if (addingLesson && currentCount >= cap) {
        return DragValidationResult.rejected(
            'Moving here would exceed the daily lesson capacity '
            'for this classroom on ${_dayLabel(targetDayCode)}.');
      }
    }

    // ── HC-4: MaxDaily at destination ─────────────────────────────────────
    final cs = classroomSubjects
        .where((x) =>
            x.classroomId == targetClassroomId &&
            x.subjectId   == movingSubjectId)
        .firstOrNull;

    if (cs != null && targetDayCode != null) {
      final countOnTargetDay = allCells
          .where((c) =>
              c.classroomId == targetClassroomId &&
              c.subjectId   == movingSubjectId &&
              c.id          != sourceCell.id &&
              _dayCodeFromCellId(c.id, activeDayCodes) == targetDayCode)
          .length;

      if (countOnTargetDay >= cs.maxDailyHours) {
        return DragValidationResult.rejected(
            '${movingSubject.name} would exceed its maximum of '
            '${cs.maxDailyHours} lesson(s) per day on '
            '${_dayLabel(targetDayCode)}.');
      }
    }

    return const DragValidationResult.allowed();
  }

  // ── Helpers ───────────────────────────────────────────────────────────────

  /// Cell IDs are formatted as '{classroomId}_{dayCode}_{slotIdx}'.
  /// Extract the dayCode from the ID.
  static String? _dayCodeFromCellId(
      String cellId, List<String> activeDayCodes) {
    for (final day in activeDayCodes) {
      if (cellId.contains('_${day}_')) return day;
    }
    return null;
  }

  static String _classroomNameHint(String classroomId) =>
      classroomId.length > 8
          ? '${classroomId.substring(0, 8)}…'
          : classroomId;

  static String _dayLabel(String? code) {
    const map = {
      'MON': 'Monday', 'TUE': 'Tuesday', 'WED': 'Wednesday',
      'THU': 'Thursday', 'FRI': 'Friday',
      'SAT': 'Saturday', 'SUN': 'Sunday',
    };
    return code != null ? (map[code] ?? code) : 'this day';
  }
}

extension _FirstOrNull<T> on Iterable<T> {
  T? get firstOrNull {
    final it = iterator;
    return it.moveNext() ? it.current : null;
  }
}
