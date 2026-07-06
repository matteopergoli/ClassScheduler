// lib/domain/scheduler/result_reporter.dart
//
// Converts the final ScheduleState + integrity check results into a
// ScheduleResult object ready for the UI and Firestore persistence.
//
// Computes:
//   - F1 (teacher free hours), F2 (subject changes), F3 (soft penalty)
//   - Quality Score 0–100 (§8.4.3)
//   - ResultStatus: perfect / softViolationsOnly / hardViolations
//   - Plain-language ConstraintViolation list for hard + soft violations

import '../../core/constants/app_constants.dart';
import 'integrity_checker.dart';
import 'phase1_greedy.dart';
import 'phase2_sa.dart';
import 'schedule_state.dart';
import 'scheduler_input.dart';

class ResultReporter {
  final SchedulerInput _input;
  final Phase2SA       _sa;

  const ResultReporter({
    required SchedulerInput input,
    required Phase2SA sa,
  })  : _input = input,
        _sa    = sa;

  ScheduleResult buildResult({
    required ScheduleState    finalState,
    required IntegrityCheckResult integrityResult,
    required List<PartialViolation> partialViolations,
    required bool             isCancelled,
    required Duration         computationTime,
    required int              iterationsCompleted,
    required int              restartsUsed,
  }) {
    // ── Raw scores ──────────────────────────────────────────────────────────
    final f1 = _sa.f1(finalState);
    final f2 = _sa.f2(finalState);
    final f3 = _sa.f3(finalState);
    final f  = AppConstants.wTeacherFreeHours * f1 +
               AppConstants.wSubjectChanges   * f2 +
               f3;

    // ── Quality score (§8.4.3) ─────────────────────────────────────────────
    final fWorst = _sa.worstCaseScore();
    var quality = fWorst > 0
        ? (100 * (1 - f / fWorst)).round().clamp(0, 100)
        : 100;

    final hardPenalty = integrityResult.violations.length * 10 +
        partialViolations.fold(0, (sum, v) => sum + v.shortfall * 5);
    quality = (quality - hardPenalty).toInt().clamp(0, 100);

    // ── Hard violations ────────────────────────────────────────────────────
    final hardViolations = <ConstraintViolation>[];

    // From ALGO-R03 integrity check
    for (final iv in integrityResult.violations) {
      hardViolations.add(ConstraintViolation(
        constraintId: iv.rule,
        description:  iv.description,
        suggestion:   _suggestionFor(iv.rule),
        isHard:       true,
      ));
    }

    // From Phase 1 partial violations (unmet weekly targets)
    for (final pv in partialViolations) {
      final cName = _input.classroomNames[pv.classroomIdx];
      final sName = _input.subjectNames[pv.subjectIdx];
      hardViolations.add(ConstraintViolation(
        constraintId: 'HC-3',
        description:
            '"$sName" in "$cName" is missing ${pv.shortfall} '
            'lesson${pv.shortfall == 1 ? '' : 's'} to meet the weekly target.',
        suggestion:
            'Reduce the weekly target for "$sName" in "$cName", '
            'add more lesson slots, or relax other constraints.',
        isHard: true,
      ));
    }

    // ── Soft violations ────────────────────────────────────────────────────
    final softViolations = _buildSoftViolations(finalState);

    // ── Status ──────────────────────────────────────────────────────────────
    final ResultStatus status;
    if (hardViolations.isEmpty && softViolations.isEmpty) {
      status = ResultStatus.perfect;
    } else if (hardViolations.isEmpty) {
      status = ResultStatus.softViolationsOnly;
    } else {
      status = ResultStatus.hardViolations;
    }

    return ScheduleResult(
      schedule:             finalState.schedule,
      status:               status,
      isCancelled:          isCancelled,
      teacherFreeHours:     f1,
      subjectChanges:       f2,
      softPenalty:          f3,
      qualityScore:         quality,
      hardViolations:       hardViolations,
      softViolations:       softViolations,
      computationTime:      computationTime,
      iterationsCompleted:  iterationsCompleted,
      restartsUsed:         restartsUsed,
    );
  }

  // ── Soft violation details ─────────────────────────────────────────────────

  List<ConstraintViolation> _buildSoftViolations(ScheduleState state) {
    final violations = <ConstraintViolation>[];
    for (final sc in _input.softConstraints) {
      switch (sc.type) {
        case SoftType.avoidTimeslot:
          final count = _countAvoidTimeslotViolations(state, sc);
          if (count > 0) {
            final sName  = _input.subjectNames[sc.subjectIdx];
            final dayStr = sc.dayIdx != null
                ? ' on ${_input.dayNames[sc.dayIdx!]}'
                : '';
            final start  = _input.slotLabels[sc.startSlotIdx ?? 0];
            final end    = _input.slotLabels[
                sc.endSlotIdx ?? (_input.numSlots - 1)];
            violations.add(ConstraintViolation(
              constraintId: 'SC-AVOID',
              description:
                  '"$sName" was placed$dayStr in the '
                  '$start–$end range $count time(s).',
              suggestion:
                  'Consider reducing the weekly target or adjusting '
                  'other constraints to free up earlier slots for "$sName".',
              isHard: false,
            ));
          }
        case SoftType.preferBlock:
          final count = _countIsolatedSlots(state, sc.subjectIdx);
          if (count > 0) {
            final sName = _input.subjectNames[sc.subjectIdx];
            violations.add(ConstraintViolation(
              constraintId: 'SC-BLOCK',
              description:
                  '"$sName" has $count isolated (non-consecutive) '
                  'lesson${count == 1 ? '' : 's'}.',
              suggestion:
                  'Try re-generating — the optimiser may find a '
                  'better block arrangement.',
              isHard: false,
            ));
          }
      }
    }
    return violations;
  }

  int _countAvoidTimeslotViolations(
      ScheduleState state, SoftConstraintInput sc) {
    var count = 0;
    final start = sc.startSlotIdx ?? 0;
    final end   = sc.endSlotIdx   ?? (_input.numSlots - 1);
    for (var c = 0; c < _input.numClassrooms; c++) {
      final days = sc.dayIdx != null
          ? [sc.dayIdx!]
          : List.generate(_input.numDays, (i) => i);
      for (final d in days) {
        for (var l = start; l <= end; l++) {
          if (state.schedule[c][d][l] == sc.subjectIdx) count++;
        }
      }
    }
    return count;
  }

  int _countIsolatedSlots(ScheduleState state, int s) {
    var isolated = 0;
    for (var c = 0; c < _input.numClassrooms; c++) {
      for (var d = 0; d < _input.numDays; d++) {
        for (var l = 0; l < _input.numSlots; l++) {
          if (state.schedule[c][d][l] != s) continue;
          final prev = l > 0 && state.schedule[c][d][l - 1] == s;
          final next = l < _input.numSlots - 1 &&
                       state.schedule[c][d][l + 1] == s;
          if (!prev && !next) isolated++;
        }
      }
    }
    return isolated;
  }

  String _suggestionFor(String rule) {
    switch (rule) {
      case 'HC-1': return 'Check that no two classrooms share the same teacher at the same time. Review MUST-ASSIGN constraints.';
      case 'HC-2': return 'Reduce the weekly targets or increase the daily lesson capacity for the affected classroom.';
      case 'HC-3': return 'Ensure the total weekly targets do not exceed available lesson slots. Check the feasibility estimator.';
      case 'HC-4': return 'Reduce the weekly target or increase MaxDaily for the affected subject.';
      case 'HC-5': return 'Ensure MinDaily ≤ available lessons per day for the subject. Consider setting MinDaily to 0.';
      case 'HC-6': return 'Check that MUST-ASSIGN slots are not blocked by other hard constraints.';
      case 'HC-7': return 'Remove conflicting MUST-NOT-ASSIGN constraints, or adjust the weekly target.';
      default:     return 'Review the constraint configuration in the Constraints screen.';
    }
  }
}
