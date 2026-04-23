// lib/domain/scheduler/integrity_checker.dart
//
// ALGO-R03: After Phase 2, perform a full independent scan of the final
// schedule re-checking every HC-1 through HC-8 from scratch.
// This is completely separate from the incremental tracking structures
// used during generation — it reads only the raw schedule array.
//
// Any violation found here is a critical implementation bug.
// The generation fails with a detailed error; the existing saved
// schedule is NOT modified (ALGO-R03, ALGO-R04).

import 'schedule_state.dart';
import 'scheduler_input.dart';

class IntegrityCheckResult {
  final bool passed;
  final List<IntegrityViolation> violations;
  const IntegrityCheckResult({required this.passed, required this.violations});
}

class IntegrityViolation {
  final String rule;        // e.g. 'HC-1'
  final String description; // plain English — for crash reports / logs
  const IntegrityViolation({required this.rule, required this.description});
}

class IntegrityChecker {
  final SchedulerInput _input;

  const IntegrityChecker(this._input);

  IntegrityCheckResult check(ScheduleState state) {
    final violations = <IntegrityViolation>[];

    final C = _input.numClassrooms;
    final S = _input.numSubjects;
    final D = _input.numDays;
    final L = _input.numSlots;

    // ── Rebuild teacher slot occupancy from scratch ────────────────────────
    // Map: (teacherIdx, dayIdx, slotIdx) → classroomIdx
    final teacherSlot = <int, int>{};

    // ── HC-8: single subject per slot per classroom ────────────────────────
    // (implicit: schedule array is single-valued, no check needed beyond
    //  validating that values are in range)

    // ── HC-1, HC-2, HC-4, HC-5 via single pass ────────────────────────────
    // Also collect weekly counts for HC-3 and daily counts for HC-4/5.

    // weeklyCount[c][s] = total lessons assigned
    final weeklyCount = List.generate(C, (_) => List<int>.filled(S, 0));
    // dailyCount[c][s][d] = lessons on that day
    final dailyCount  = List.generate(
        C, (_) => List.generate(S, (_) => List<int>.filled(D, 0)));
    // dailyTotal[c][d] = total lessons in classroom on that day
    final dailyTotal  = List.generate(C, (_) => List<int>.filled(D, 0));

    for (var c = 0; c < C; c++) {
      for (var d = 0; d < D; d++) {
        for (var l = 0; l < L; l++) {
          final s = state.schedule[c][d][l];
          if (s == kFree) continue;

          // Range check
          if (s < 0 || s >= S) {
            violations.add(IntegrityViolation(
              rule: 'HC-8',
              description: 'Schedule[$c][$d][$l] = $s is out of range.',
            ));
            continue;
          }

          weeklyCount[c][s]++;
          dailyCount[c][s][d]++;
          dailyTotal[c][d]++;

          // HC-1: teacher conflict
          final t   = _input.teacherOf[s];
          final key = SchedulerInput.teacherSlotKey(t, d, l);
          if (teacherSlot.containsKey(key)) {
            final otherC = teacherSlot[key]!;
            violations.add(IntegrityViolation(
              rule: 'HC-1',
              description:
                  'Teacher "${_input.teacherNames[t]}" is assigned to '
                  'classroom "${_input.classroomNames[c]}" AND '
                  '"${_input.classroomNames[otherC]}" '
                  'on ${_input.dayNames[d]} slot ${_input.slotLabels[l]}.',
            ));
          } else {
            teacherSlot[key] = c;
          }

          // HC-7: MUST-NOT-ASSIGN
          if (_input.mustNotAssignKeys
              .contains(SchedulerInput.cellKey(c, s, d, l))) {
            violations.add(IntegrityViolation(
              rule: 'HC-7',
              description:
                  '"${_input.subjectNames[s]}" is assigned to '
                  '"${_input.classroomNames[c]}" on '
                  '${_input.dayNames[d]} ${_input.slotLabels[l]}, '
                  'but a MUST-NOT-ASSIGN constraint forbids it.',
            ));
          }
        }
      }
    }

    // ── HC-2: daily capacity ───────────────────────────────────────────────
    // Also check that no lesson was placed in a blocked slot.
    for (var c = 0; c < C; c++) {
      for (var d = 0; d < D; d++) {
        final cap = _input.activeSlotCount(c, d);
        if (dailyTotal[c][d] > cap) {
          violations.add(IntegrityViolation(
            rule: 'HC-2',
            description:
                '"${_input.classroomNames[c]}" has ${dailyTotal[c][d]} '
                'lessons on ${_input.dayNames[d]}, exceeding capacity $cap.',
          ));
        }
        // Check for assignments in blocked slots
        for (var l = 0; l < L; l++) {
          if (_input.isBlocked(c, d, l) &&
              state.schedule[c][d][l] != kFree) {
            violations.add(IntegrityViolation(
              rule: 'HC-2',
              description:
                  '"${_input.classroomNames[c]}" has a lesson in a '
                  'blocked slot on ${_input.dayNames[d]} slot $l.',
            ));
          }
        }
      }
    }

    // ── HC-3: weekly target ────────────────────────────────────────────────
    for (var c = 0; c < C; c++) {
      for (var s = 0; s < S; s++) {
        final target = _input.weeklyTarget[c][s];
        if (target == 0) continue;
        if (weeklyCount[c][s] != target) {
          violations.add(IntegrityViolation(
            rule: 'HC-3',
            description:
                '"${_input.subjectNames[s]}" in '
                '"${_input.classroomNames[c]}" has '
                '${weeklyCount[c][s]} lessons but target is $target.',
          ));
        }
      }
    }

    // ── HC-4: MaxDaily ────────────────────────────────────────────────────
    for (var c = 0; c < C; c++) {
      for (var s = 0; s < S; s++) {
        final max = _input.maxDaily[c][s];
        for (var d = 0; d < D; d++) {
          if (dailyCount[c][s][d] > max) {
            violations.add(IntegrityViolation(
              rule: 'HC-4',
              description:
                  '"${_input.subjectNames[s]}" in '
                  '"${_input.classroomNames[c]}" has '
                  '${dailyCount[c][s][d]} lessons on '
                  '${_input.dayNames[d]}, exceeding MaxDaily $max.',
            ));
          }
        }
      }
    }

    // ── HC-5: MinDaily ────────────────────────────────────────────────────
    for (var c = 0; c < C; c++) {
      for (var s = 0; s < S; s++) {
        final min = _input.minDaily[c][s];
        if (min == 0) continue;
        for (var d = 0; d < D; d++) {
          final count = dailyCount[c][s][d];
          // Valid: count == 0 (absent) OR count >= min
          if (count > 0 && count < min) {
            violations.add(IntegrityViolation(
              rule: 'HC-5',
              description:
                  '"${_input.subjectNames[s]}" in '
                  '"${_input.classroomNames[c]}" has $count lesson(s) on '
                  '${_input.dayNames[d]}, below MinDaily $min. '
                  'It must appear 0 or at least $min times per day.',
            ));
          }
        }
      }
    }

    // ── HC-6: MUST-ASSIGN ─────────────────────────────────────────────────
    for (final ma in _input.mustAssign) {
      final assigned = state.schedule[ma.c][ma.d][ma.l];
      if (assigned != ma.s) {
        violations.add(IntegrityViolation(
          rule: 'HC-6',
          description:
              'MUST-ASSIGN: "${_input.subjectNames[ma.s]}" must be in '
              '"${_input.classroomNames[ma.c]}" on '
              '${_input.dayNames[ma.d]} ${_input.slotLabels[ma.l]}, '
              'but slot contains '
              '${assigned == kFree ? "nothing" : '"${_input.subjectNames[assigned]}"'}.',
        ));
      }
    }

    return IntegrityCheckResult(
      passed:     violations.isEmpty,
      violations: violations,
    );
  }
}
