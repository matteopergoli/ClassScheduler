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

    // ── Quality score (§8.4.3) ─────────────────────────────────────────────
    // Each dimension is normalised against its OWN worst case and then
    // averaged, rather than combining the raw weighted sums (w1*f1 + w2*f2
    // + f3) into a single ratio over a single combined worst case. F1's
    // worst case (every teacher idle in every slot of every day) and F2's
    // (every adjacent slot pair a different subject) are astronomically
    // larger than any real schedule ever reaches, so a combined denominator
    // let those two terms swamp F3 completely: the SA already drives real
    // f1/f2 close to zero, so f3 (the soft-constraint penalty) ended up a
    // rounding error next to the inflated f1Worst/f2Worst terms — a
    // schedule could violate every soft constraint and still round to a
    // quality score of 99 or 100. Averaging independent ratios instead
    // guarantees soft-constraint violations move the score by a real,
    // visible amount regardless of how compact the rest of the schedule is.
    final worst = _sa.worstCasePerDimension();
    final f1Ratio = worst.f1 > 0 ? f1 / worst.f1 : 0.0;
    final f2Ratio = worst.f2 > 0 ? f2 / worst.f2 : 0.0;
    final f3Ratio = worst.f3 > 0 ? f3 / worst.f3 : 0.0;
    final combinedRatio = (f1Ratio + f2Ratio + f3Ratio) / 3;
    var quality = (100 * (1 - combinedRatio)).round().clamp(0, 100);

    final hardPenalty = integrityResult.violations.length * 10 +
        partialViolations.fold(0, (sum, v) => sum + v.shortfall * 5);
    quality = (quality - hardPenalty).toInt().clamp(0, 100);

    // ── Hard violations ────────────────────────────────────────────────────
    final hardViolations = <ConstraintViolation>[];

    // From ALGO-R03 integrity check.
    // HC-3 (weekly target) is fully covered by partialViolations below;
    // skip it here to prevent duplicate entries in the violation list.
    for (final iv in integrityResult.violations) {
      if (iv.rule == 'HC-3') continue;
      hardViolations.add(ConstraintViolation(
        constraintId: iv.rule,
        description:  iv.description,
        suggestion:   _suggestionFor(iv.rule),
        isHard:       true,
      ));
    }

    // From Phase 1 partial violations (unmet weekly targets)
    for (final pv in partialViolations) {
      final c     = pv.classroomIdx;
      final s     = pv.subjectIdx;
      final cName = _input.classroomNames[c];
      final sName = _input.subjectNames[s];

      final target = _input.weeklyTarget[c][s];
      final minD   = _input.minDaily[c][s];
      final maxD   = _input.maxDaily[c][s];

      final suggestion = _hc3Suggestion(
          sName, cName, target, minD, maxD, c, s, finalState);

      hardViolations.add(ConstraintViolation(
        constraintId: 'HC-3',
        description:
            '"$sName" in "$cName" is missing ${pv.shortfall} '
            'lesson${pv.shortfall == 1 ? '' : 's'} to meet the weekly target.',
        suggestion: suggestion,
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
            final clsStr = sc.classroomIdx != null
                ? ' in "${_input.classroomNames[sc.classroomIdx!]}"'
                : '';
            final dayStr = sc.dayIdx != null
                ? ' on ${_input.dayNames[sc.dayIdx!]}'
                : '';
            final start  = _input.slotLabels[sc.startSlotIdx ?? 0];
            final end    = _input.slotLabels[
                sc.endSlotIdx ?? (_input.numSlots - 1)];
            violations.add(ConstraintViolation(
              constraintId: 'SC-AVOID',
              description:
                  '"$sName"$clsStr was placed$dayStr in the '
                  '$start–$end range $count time(s).',
              suggestion:
                  'Consider reducing the weekly target or adjusting '
                  'other constraints to free up earlier slots for "$sName".',
              isHard: false,
            ));
          }
        case SoftType.preferBlock:
          final count = _countIsolatedSlots(state, sc);
          if (count > 0) {
            final sName = _input.subjectNames[sc.subjectIdx];
            final clsStr = sc.classroomIdx != null
                ? ' in "${_input.classroomNames[sc.classroomIdx!]}"'
                : '';
            final dayStr = sc.dayIdx != null
                ? ' on ${_input.dayNames[sc.dayIdx!]}'
                : '';
            final rangeStr = sc.startSlotIdx != null
                ? ' (${_input.slotLabels[sc.startSlotIdx!]}–'
                    '${_input.slotLabels[sc.endSlotIdx ?? (_input.numSlots - 1)]})'
                : '';
            violations.add(ConstraintViolation(
              constraintId: 'SC-BLOCK',
              description:
                  '"$sName"$clsStr has $count isolated (non-consecutive) '
                  'lesson${count == 1 ? '' : 's'}$dayStr$rangeStr.',
              suggestion:
                  'Try re-generating — the optimiser may find a '
                  'better block arrangement.',
              isHard: false,
            ));
          }
        case SoftType.dailyLimit:
          final count = _countDailyLimitViolations(state, sc);
          if (count > 0) {
            final sName = _input.subjectNames[sc.subjectIdx];
            final cName = sc.classroomIdx != null
                ? _input.classroomNames[sc.classroomIdx!]
                : '?';
            violations.add(ConstraintViolation(
              constraintId: 'SC-DAILY-LIMIT',
              description:
                  '"$sName" in "$cName" falls outside its preferred daily '
                  'hours on $count day(s).',
              suggestion:
                  'Try re-generating, or widen the preferred daily range '
                  'for "$sName".',
              isHard: false,
            ));
          }
      }
    }
    return violations;
  }

  int _countDailyLimitViolations(ScheduleState state, SoftConstraintInput sc) {
    final c = sc.classroomIdx;
    if (c == null) return 0;
    var days = 0;
    for (var d = 0; d < _input.numDays; d++) {
      var count = 0;
      for (var l = 0; l < _input.numSlots; l++) {
        if (state.schedule[c][d][l] == sc.subjectIdx) count++;
      }
      final min = sc.softMinDaily;
      final max = sc.softMaxDaily;
      final under = min != null && min > 0 && count > 0 && count < min;
      final over  = max != null && count > max;
      if (under || over) days++;
    }
    return days;
  }

  int _countAvoidTimeslotViolations(
      ScheduleState state, SoftConstraintInput sc) {
    var count = 0;
    final start = sc.startSlotIdx ?? 0;
    final end   = sc.endSlotIdx   ?? (_input.numSlots - 1);
    final classrooms = sc.classroomIdx != null
        ? [sc.classroomIdx!]
        : List.generate(_input.numClassrooms, (i) => i);
    for (final c in classrooms) {
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

  int _countIsolatedSlots(ScheduleState state, SoftConstraintInput sc) {
    final s = sc.subjectIdx;
    final classrooms = sc.classroomIdx != null
        ? [sc.classroomIdx!]
        : List.generate(_input.numClassrooms, (i) => i);
    final days = sc.dayIdx != null
        ? [sc.dayIdx!]
        : List.generate(_input.numDays, (i) => i);
    final start = sc.startSlotIdx ?? 0;
    final end   = sc.endSlotIdx   ?? (_input.numSlots - 1);
    var isolated = 0;
    for (final c in classrooms) {
      for (final d in days) {
        for (var l = start; l <= end; l++) {
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

  /// Builds a context-aware suggestion for an HC-3 partial violation.
  ///
  /// Checks four root causes in priority order:
  ///   1. Arithmetic infeasibility: target not achievable with minD/maxD.
  ///   2. Teacher overlap: teacher is busy in other classrooms during every
  ///      free slot of this classroom.
  ///   3. Teacher fully booked: teacher has zero free slots anywhere.
  ///   4. MinDaily trap: canPlace passes but every valid slot would leave the
  ///      day's count below MinDaily, so FILL is always rejected.
  String _hc3Suggestion(
      String sName, String cName, int target, int minD, int maxD,
      int classroomIdx, int subjectIdx, ScheduleState finalState) {
    // ── 1. Arithmetic infeasibility ──────────────────────────────────────────
    if (minD > 0 && maxD >= minD) {
      final minDays = (target + maxD - 1) ~/ maxD;
      final maxDays = target ~/ minD;
      if (minDays > maxDays) {
        final suggested = _nearestFeasibleTarget(target, minD, maxD);
        final hint = suggested > 0
            ? ' Try setting the weekly target to $suggested.'
            : ' Try disabling MinDaily (set to 0) or adjusting MaxDaily.';
        return 'The weekly target ($target) for "$sName" in "$cName" cannot '
            'be achieved with MinDaily $minD and MaxDaily $maxD — no valid '
            'day distribution exists.$hint';
      }
    }

    final teacherIdx  = _input.teacherOf[subjectIdx];
    final teacherName = _input.teacherNames[teacherIdx];

    // ── 2. Teacher busy in other classrooms during all free slots ────────────
    var classroomHasFreeSlot       = false;
    var teacherAvailableAtFreeSlot = false;
    for (var d = 0; d < _input.numDays; d++) {
      for (var l = 0; l < _input.numSlots; l++) {
        if (finalState.schedule[classroomIdx][d][l] != kFree) continue;
        classroomHasFreeSlot = true;
        if (finalState.isTeacherFree(teacherIdx, d, l)) {
          teacherAvailableAtFreeSlot = true;
          break;
        }
      }
      if (teacherAvailableAtFreeSlot) break;
    }

    if (classroomHasFreeSlot && !teacherAvailableAtFreeSlot) {
      return 'Teacher "$teacherName" is committed to other classes during '
          'every free slot of "$cName". Reduce the total weekly lessons '
          'taught by "$teacherName" across all classrooms, or assign a '
          'different teacher to "$sName".';
    }

    // ── 3. Teacher has no free slots at all ───────────────────────────────────
    var teacherTotalFree = 0;
    for (var d = 0; d < _input.numDays; d++)
      for (var l = 0; l < _input.numSlots; l++)
        if (finalState.isTeacherFree(teacherIdx, d, l)) teacherTotalFree++;

    if (teacherTotalFree == 0) {
      return 'Teacher "$teacherName" has no available slots remaining '
          '— all their time is already committed. Reduce the total '
          'weekly lessons taught by "$teacherName", or assign a different '
          'teacher to "$sName".';
    }

    // ── 4. MinDaily trap ─────────────────────────────────────────────────────
    // canPlace() does not check MinDaily. Scan for slots where canPlace
    // returns true but placing would leave the day below MinDaily, causing
    // FILL to always return null.
    if (minD > 1) {
      var canPlaceAny        = false;
      var minDailyBlocksAll  = true;
      for (var d = 0; d < _input.numDays; d++) {
        for (var l = 0; l < _input.numSlots; l++) {
          if (!finalState.canPlace(classroomIdx, subjectIdx, d, l)) continue;
          canPlaceAny = true;
          final countAfter =
              finalState.dailySubjectCount(classroomIdx, subjectIdx, d) + 1;
          // satisfiesMinDaily: count must be 0 or >= minD
          if (countAfter == 0 || countAfter >= minD) {
            minDailyBlocksAll = false;
            break;
          }
        }
        if (!minDailyBlocksAll) break;
      }
      if (canPlaceAny && minDailyBlocksAll) {
        return 'Every available slot for "$sName" in "$cName" would create '
            'a day with fewer than MinDaily $minD lessons, which is not '
            'allowed. Try reducing the weekly target by 1, or set '
            'MinDaily to 0 to allow lone lessons.';
      }
    }

    // ── 5. Generic fallback ───────────────────────────────────────────────────
    return 'Reduce the weekly target for "$sName" in "$cName", '
        'add more lesson slots, or relax other constraints.';
  }

  /// Returns the nearest feasible weekly target ≤ [target] that can be
  /// achieved by distributing lessons with [minD]–[maxD] per active day.
  int _nearestFeasibleTarget(int target, int minD, int maxD) {
    for (var t = target - 1; t >= minD; t--) {
      final minDays = (t + maxD - 1) ~/ maxD;
      final maxDays = t ~/ minD;
      if (minDays <= maxDays) return t;
    }
    return 0;
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
