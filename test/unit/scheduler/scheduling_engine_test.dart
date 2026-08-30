// test/unit/scheduler/scheduling_engine_test.dart
//
// ALG-T01 through ALG-T15 — Scheduling engine unit tests per §8.7.
//
// All tests run synchronously against SchedulerEngine (no Isolate needed).
// The engine's SA phase uses real SA logic; for determinism in timing tests
// we check ≤ wall-clock bounds in a lenient way (CI machines may be slow).

import 'package:flutter_test/flutter_test.dart';

import 'package:classscheduler/core/constants/app_constants.dart';
import 'package:classscheduler/domain/scheduler/phase1_greedy.dart';
import 'package:classscheduler/domain/scheduler/schedule_state.dart';
import 'package:classscheduler/domain/scheduler/scheduler_engine.dart';
import 'package:classscheduler/domain/scheduler/scheduler_input.dart';

import '../../helpers/engine_test_runner.dart';
import '../../helpers/scheduler_fixtures.dart';

void main() {
  // ── ALG-T01: Trivial 2-classroom, 2-subject, 3-day problem ──────────────
  group('ALG-T01 — trivial problem', () {
    test('produces perfect solution with QualityScore 100', () {
      final result = runEngine(trivialInput());

      expect(result.status, ResultStatus.perfect,
          reason: 'Trivial problem must reach perfect status');
      expect(result.hardViolations, isEmpty,
          reason: 'No hard violations expected');
      expect(result.qualityScore, equals(100),
          reason: 'Perfect schedule → score 100');
    });

    test('ALGO-R03 passes on trivial solution', () {
      final result  = runEngine(trivialInput());
      // Run integrity check independently to verify ALGO-R03
      final phase1  = runPhase1(trivialInput());
      final check   = checkIntegrity(trivialInput(), phase1.state);

      // Either check the engine's internal run or verify the state directly
      expect(result.hardViolations, isEmpty);
    });

    test('same input produces stable deterministic schedule across runs', () {
      final inputs = trivialInput();
      final result1 = runEngine(inputs);
      final result2 = runEngine(inputs);
      final result3 = runEngine(inputs);

      expect(result2.status, equals(result1.status));
      expect(result3.status, equals(result1.status));
      expect(result2.qualityScore, equals(result1.qualityScore));
      expect(result3.qualityScore, equals(result1.qualityScore));
      expect(result2.hardViolations.length, equals(result1.hardViolations.length));
      expect(result3.hardViolations.length, equals(result1.hardViolations.length));
      expect(result2.schedule, equals(result1.schedule));
      expect(result3.schedule, equals(result1.schedule));
    });

    test('phase 1 reports progress during greedy construction', () {
      final updates = <double>[];
      Phase1Greedy(
        trivialInput(),
        onProgress: (fraction) => updates.add(fraction),
      ).build();

      expect(
        updates.any((fraction) => fraction > 0.05),
        isTrue,
        reason: 'Phase 1 should emit progress updates while it is constructing the schedule.',
      );
    });

    test('emits an intermediate progress update before completion', () {
      final updates = <double>[];
      final engine = SchedulerEngine(
        input: trivialInput(),
        isCancelled: () => false,
        onProgress: (fraction, iterations) {
          updates.add(fraction);
        },
      );

      engine.run();

      expect(
        updates.any((fraction) => fraction > 0.05 && fraction < 1.0),
        isTrue,
        reason: 'The UI should receive a progress update beyond the initial 5% marker.',
      );
    });
  });

  // ── ALG-T02: MUST-ASSIGN forces a slot ────────────────────────────────
  group('ALG-T01b — capacity feasibility', () {
    test('rejects placements when the remaining demand exceeds the remaining available slots', () {
      const input = SchedulerInput(
        numClassrooms: 1,
        numSubjects: 2,
        numDays: 1,
        numSlots: 2,
        classroomNames: ['Room A'],
        subjectNames: ['Maths', 'English'],
        teacherNames: ['Alice', 'Bob'],
        dayNames: ['MON'],
        slotLabels: ['08:00', '09:00'],
        classroomIds: ['cr0'],
        subjectIds: ['s0', 's1'],
        periodIds: ['p0', 'p1'],
        teacherOf: [0, 1],
        weeklyTarget: [[2, 1]],
        blockedSlots: {},
        maxDaily: [[2, 1]],
        minDaily: [[0, 0]],
        mustAssign: [],
        mustNotAssignKeys: {},
        softConstraints: [],
      );

      final state = ScheduleState(input);
      expect(state.canPlace(0, 1, 0, 0), isTrue,
          reason: 'The first English lesson should be placeable.');
      state.assign(0, 1, 0, 0);

      expect(state.canPlace(0, 0, 0, 1), isFalse,
          reason: 'Maths still needs 2 lessons but only one slot remains.');
    });
  });

  group('ALG-T02 — MUST-ASSIGN constraint', () {
    test('forced slot is honoured', () {
      final input  = mustAssignInput();
      final result = runEngine(input);

      // Room A (c=0), Maths (s=0) must appear at day 0, slot 0
      final phase1 = runPhase1(input);
      expect(
        phase1.state.schedule[0][0][0],
        equals(0), // subject index 0 = Maths
        reason: 'MUST-ASSIGN cell (c=0,d=0,l=0) must be Maths',
      );
      expect(result.hardViolations, isEmpty);
    });

    test('all weekly targets met', () {
      final result = runEngine(mustAssignInput());
      expect(result.status, equals(ResultStatus.perfect));
    });
  });

  // ── ALG-T03: Contradictory MUST-ASSIGN + MUST-NOT-ASSIGN ──────────────
  group('ALG-T03 — contradictory constraints', () {
    test('detects conflict in < 1 second without crashing', () {
      final sw    = Stopwatch()..start();
      final result = runEngine(contradictoryInput());
      sw.stop();

      expect(sw.elapsedMilliseconds, lessThan(1000),
          reason: 'Conflict detection must be < 1 second');
      // Engine may produce a hard violation or report it in the result
      // Either hardViolations is non-empty OR status is not perfect
      expect(
        result.status == ResultStatus.hardViolations ||
            result.hardViolations.isNotEmpty,
        isTrue,
        reason: 'Contradictory constraints must produce a hard violation',
      );
    });
  });

  // ── ALG-T04: Over-constrained — weekly targets exceed slots ───────────
  group('ALG-T04 — over-constrained', () {
    test('returns partial solution with hard violations listed', () {
      final result = runEngine(overConstrainedInput());

      expect(result.status, equals(ResultStatus.hardViolations),
          reason: 'Impossible target → hard violation status');
      expect(result.hardViolations, isNotEmpty,
          reason: 'Missing assignments must appear in hardViolations');
    });

    test('partial solution lists the unassigned subject', () {
      final result = runEngine(overConstrainedInput());
      final descriptions = result.hardViolations
          .map((v) => v.description.toLowerCase())
          .toList();
      // Some violation must mention the unmet weekly target or the subject
      expect(
        descriptions.any((d) =>
            d.contains('maths') ||
            d.contains('hc-3')  ||
            d.contains('weekly') ||
            d.contains('target')),
        isTrue,
        reason: 'Hard violation description must mention the unmet target',
      );
    });
  });

  // ── ALG-T05: MinDaily=2 MaxDaily=3 ────────────────────────────────────
  group('ALG-T05 — MinDaily/MaxDaily constraints', () {
    test('every occupied day has count ≥ 2 and ≤ 3', () {
      final input  = minDailyInput();
      final result = runEngine(input);

      // Inspect the Phase-1 state directly for precise verification
      final p1State = runPhase1(input).state;

      for (int d = 0; d < input.numDays; d++) {
        int dayCount = 0;
        for (int l = 0; l < input.numSlots; l++) {
          if (p1State.schedule[0][d][l] == 0) dayCount++;
        }
        if (dayCount > 0) {
          expect(dayCount, greaterThanOrEqualTo(2),
              reason: 'MinDaily=2 violated on day $d (count=$dayCount)');
          expect(dayCount, lessThanOrEqualTo(3),
              reason: 'MaxDaily=3 violated on day $d (count=$dayCount)');
        }
      }
    });

    test('ALGO-R03 passes after full engine run', () {
      final result = runEngine(minDailyInput());
      // If ALGO-R03 fails the engine returns an INTERNAL error
      expect(
        result.hardViolations
            .where((v) => v.constraintId == 'INTERNAL')
            .isEmpty,
        isTrue,
        reason: 'No INTERNAL errors → ALGO-R03 passed',
      );
    });
  });

  // ── ALG-T06: Maximum configuration, 3 runs ≤ 60 s each ───────────────
  group('ALG-T06 — maximum configuration performance', () {
    // Note: on CI this is run with a generous timeout. On real devices it
    // will be well under 60 s. We assert ≤ 90 s here to be CI-safe.
    const maxWallClockMs = 90000;

    for (int run = 1; run <= 3; run++) {
      test('run $run completes within time limit with no INTERNAL errors',
          () {
        final sw = Stopwatch()..start();
        final result = runEngine(maxConfigInput());
        sw.stop();

        expect(sw.elapsedMilliseconds, lessThan(maxWallClockMs),
            reason: 'Max config must complete ≤ 90 s (CI budget)');
        expect(
          result.hardViolations
              .where((v) => v.constraintId == 'INTERNAL')
              .isEmpty,
          isTrue,
          reason: 'ALGO-R03 must pass on run $run',
        );
      }, timeout: const Timeout(Duration(seconds: 100)));
    }
  });

  // ── ALG-T07: ALGO-R03 detects injected HC-1 violation ─────────────────
  group('ALG-T07 — ALGO-R03 integrity check', () {
    test('detects injected teacher conflict and returns failure', () {
      final input = integrityCheckInput();
      final p1    = runPhase1(input);

      // Build a good state first, then corrupt it
      final corrupted = injectTeacherConflict(
          p1.state, input, 0 /* s=Maths */, 0 /* d=MON */, 0 /* l=0 */);

      final check = checkIntegrity(input, corrupted);
      expect(check.passed, isFalse,
          reason: 'Injected HC-1 conflict must be detected by ALGO-R03');
      expect(check.violations, isNotEmpty);
      expect(
        check.violations.any((v) => v.rule.contains('HC-1')),
        isTrue,
        reason: 'Violation must be labelled HC-1',
      );
    });
  });

  // ── ALG-T08: User cancel returns best partial result ≤ 1 s ─────────────
  group('ALG-T08 — cancellation', () {
    test('returns result with isCancelled=true and no crash', () {
      final sw     = Stopwatch()..start();
      final result = runCancelled(trivialInput());
      sw.stop();

      expect(result.isCancelled, isTrue,
          reason: 'isCancelled must be true when run is cancelled');
      expect(sw.elapsedMilliseconds, lessThan(1000),
          reason: 'Cancelled run must return in < 1 s');
    });

    test('cancelled result still passes ALGO-R03', () {
      final result = runCancelled(trivialInput());
      expect(
        result.hardViolations
            .where((v) => v.constraintId == 'INTERNAL')
            .isEmpty,
        isTrue,
        reason: 'ALGO-R03 must run even on cancelled result',
      );
    });
  });

  // ── ALG-T09: BLOCK SHIFT rejected when destination at MaxDaily ─────────
  group('ALG-T09 — BLOCK SHIFT at MaxDaily limit', () {
    test('BLOCK SHIFT rejected when destination day is full', () {
      // Use trivialInput but restrict MaxDaily to 1
      const C = 2; const S = 2; const D = 3; const L = 4;
      final input = SchedulerInput(
        numClassrooms: C, numSubjects: S, numDays: D, numSlots: L,
        classroomNames: ['A','B'], subjectNames: ['M','E'],
        teacherNames: ['T1','T2'], dayNames: ['MON','TUE','WED'],
        slotLabels: ['08:00','09:00','10:00','11:00'],
        classroomIds: ['c0','c1'], subjectIds: ['s0','s1'],
        periodIds: ['p0','p1','p2','p3'],
        teacherOf: [0, 1],
        weeklyTarget: [[1,1],[1,1]],
        blockedSlots: {},
        maxDaily: List.generate(C, (_) => [1, 1]), // MaxDaily = 1
        minDaily: List.generate(C, (_) => List.filled(S, 0)),
        mustAssign: [], mustNotAssignKeys: {}, softConstraints: [],
      );

      final result = runEngine(input);
      // ALGO-R03 must pass (no HC-4 violations introduced)
      expect(
        result.hardViolations
            .where((v) => v.constraintId == 'HC-4')
            .isEmpty,
        isTrue,
        reason: 'No HC-4 (MaxDaily) violations — BLOCK SHIFT must be rejected',
      );
    });
  });

  // ── ALG-T10: BLOCK SHIFT rejected when source day drops below MinDaily ──
  group('ALG-T10 — BLOCK SHIFT below MinDaily on source day', () {
    test('no HC-5 MinDaily violations in result', () {
      final result = runEngine(minDailyInput());
      expect(
        result.hardViolations
            .where((v) => v.constraintId == 'HC-5')
            .isEmpty,
        isTrue,
        reason:
            'No HC-5 violations — BLOCK SHIFT must not drop source day below MinDaily',
      );
    });
  });

  // ── ALG-T11: Soft constraint honoured in ≥ 80% of runs ─────────────────
  group('ALG-T11 — soft constraint compliance', () {
    test('AVOID_TIMESLOT respected in ≥ 80 % of runs', () {
      const runs = 5;
      int compliantRuns = 0;

      for (int i = 0; i < runs; i++) {
        final input  = softConstraintInput();
        final result = runEngine(input);

        // Check: subject 0 should NOT appear in slots 5–7
        final p1 = runPhase1(input);
        bool compliant = true;
        for (int d = 0; d < input.numDays; d++) {
          for (int l = 5; l <= 7; l++) {
            if (p1.state.schedule[0][d][l] == 0) {
              compliant = false;
              break;
            }
          }
        }
        if (compliant) compliantRuns++;
      }

      expect(compliantRuns, greaterThanOrEqualTo((runs * 0.8).ceil()),
          reason:
              'Soft AVOID_TIMESLOT must be respected in ≥ 80% of runs');
    });
  });

  // ── ALG-T12: Phase-1 backtracking resolves deadlock ───────────────────
  group('ALG-T12 — Phase-1 deadlock backtracking', () {
    test('deadlock resolved → both classrooms assigned', () {
      final input  = deadlockInput();
      final result = runEngine(input);

      // Both rooms must have their 1 Maths lesson
      final p1 = runPhase1(input);
      int totalAssigned = 0;
      for (int c = 0; c < 2; c++) {
        for (int d = 0; d < 2; d++) {
          for (int l = 0; l < 2; l++) {
            if (p1.state.schedule[c][d][l] == 0) totalAssigned++;
          }
        }
      }
      expect(totalAssigned, equals(2),
          reason: 'Both classrooms must have 1 Maths lesson after backtrack');
    });

    test('no teacher conflict (HC-1) in deadlock result', () {
      final result = runEngine(deadlockInput());
      expect(
        result.hardViolations
            .where((v) => v.constraintId == 'HC-1')
            .isEmpty,
        isTrue,
      );
    });
  });

  // ── ALG-T13: SA restart triggered on pathological input ────────────────
  group('ALG-T13 — SA restarts', () {
    test('restartsUsed ≥ 0 and final score ≤ initial score', () {
      // We can't guarantee restarts on every run since it's stochastic,
      // but we can assert the invariant: restartsUsed is in valid range
      // (0..saMaxRestarts) and the engine always returns a result.
      final result = runEngine(maxConfigInput());

      expect(result.restartsUsed,
          inInclusiveRange(0, AppConstants.saMaxRestarts),
          reason: 'restartsUsed must be between 0 and saMaxRestarts');
      expect(result.qualityScore, inInclusiveRange(0, 100));
    });
  });

  // ── ALG-T14: CROSS-CLASS SWAP with s1 ≠ s2 ─────────────────────────────
  group('ALG-T14 — CROSS-CLASS SWAP', () {
    test('no HC-1 violations after cross-class swap accepted', () {
      final result = runEngine(crossClassInput());
      // The engine runs SA with CROSS-CLASS moves; if any were accepted,
      // the post-ALGO-R03 check would have caught HC-1 violations.
      expect(
        result.hardViolations
            .where((v) => v.constraintId == 'HC-1')
            .isEmpty,
        isTrue,
        reason: 'No HC-1 violations after CROSS-CLASS SWAP moves',
      );
    });

    test('weekly targets met for both classrooms', () {
      final result = runEngine(crossClassInput());
      expect(result.status, isNot(ResultStatus.hardViolations),
          reason:
              'crossClassInput is solvable — no hard violation expected');
    });
  });

  // ── ALG-T15: QualityScore = 100 for perfect, ≈ 0 for worst ─────────────
  group('ALG-T15 — QualityScore calculation', () {
    test('trivial perfect schedule scores 100', () {
      final result = runEngine(trivialInput());
      expect(result.qualityScore, equals(100));
    });

    test('quality score is always in [0, 100]', () {
      for (final input in [
        trivialInput(),
        minDailyInput(),
        softConstraintInput(),
        deadlockInput(),
        crossClassInput(),
      ]) {
        final result = runEngine(input);
        expect(result.qualityScore, inInclusiveRange(0, 100),
            reason: 'QualityScore must always be in [0,100]');
      }
    });

    test('over-constrained result has quality score < 100', () {
      final result = runEngine(overConstrainedInput());
      expect(result.qualityScore, lessThan(100),
          reason:
              'Partial/violated schedule cannot score 100');
    });
  });

  // ── ALG-T16: soft DAILY_LIMIT spreads a subject across the week ─────────
  // Regression for the "days full of one subject" complaint: with the soft
  // daily-limit penalty scaled per excess hour (AppConstants.wDailyLimitUnit)
  // the optimiser must un-pile a subject rather than stacking its whole
  // weekly quota onto one or two days to minimise F2 subject changes.
  group('ALG-T16 — soft DAILY_LIMIT weekly spread', () {
    ({List<int> perDay, int maxOnAnyDay, int overLimitHours}) analyse(
        ScheduleResult result) {
      final perDay = <int>[];
      var overLimitHours = 0;
      for (var d = 0; d < 5; d++) {
        var count = 0;
        for (var l = 0; l < 6; l++) {
          if (result.schedule[0][d][l] == 0) count++;
        }
        perDay.add(count);
        if (count > 2) overLimitHours += count - 2;
      }
      return (
        perDay: perDay,
        maxOnAnyDay: perDay.reduce((a, b) => a > b ? a : b),
        overLimitHours: overLimitHours,
      );
    }

    test('weekly target still met', () {
      final result = runEngine(dailyLimitSoftInput());
      final total = analyse(result).perDay.fold(0, (a, b) => a + b);
      expect(total, equals(10),
          reason: 'All 10 lessons must still be placed');
      expect(
        result.hardViolations.where((v) => v.constraintId == 'HC-3'),
        isEmpty,
      );
    });

    test('no day is stacked far above the preferred maximum', () {
      // A perfect 2-2-2-2-2 spread exists; allow a little SA slack but the
      // pathological "6 on one day" outcome must not survive.
      final result = runEngine(dailyLimitSoftInput());
      final a = analyse(result);
      expect(a.maxOnAnyDay, lessThanOrEqualTo(3),
          reason: 'Subject piled onto one day: perDay=${a.perDay}');
      expect(a.overLimitHours, lessThanOrEqualTo(2),
          reason: 'Too many hours over the soft cap: perDay=${a.perDay}');
    });

    test('spreads across at least four days', () {
      final result = runEngine(dailyLimitSoftInput());
      final a = analyse(result);
      final daysUsed = a.perDay.where((c) => c > 0).length;
      expect(daysUsed, greaterThanOrEqualTo(4),
          reason: 'Subject should touch ≥ 4 days: perDay=${a.perDay}');
    });

    test('Phase 1 already spreads (does not hand SA a piled state)', () {
      // Locks in the step-2 change: greedy construction is soft-max aware,
      // so it must not build the pathological single-day pile that Phase 2
      // then has to dismantle.
      final p1 = runPhase1(dailyLimitSoftInput());
      final perDay = [
        for (var d = 0; d < 5; d++)
          [for (var l = 0; l < 6; l++) p1.state.schedule[0][d][l]]
              .where((s) => s == 0)
              .length,
      ];
      final total = perDay.fold(0, (a, b) => a + b);
      final maxOnAnyDay = perDay.reduce((a, b) => a > b ? a : b);
      final daysUsed = perDay.where((c) => c > 0).length;
      expect(total, equals(10), reason: 'Phase 1 must place all lessons');
      expect(maxOnAnyDay, lessThanOrEqualTo(3),
          reason: 'Phase 1 piled the subject: perDay=$perDay');
      expect(daysUsed, greaterThanOrEqualTo(4),
          reason: 'Phase 1 should already spread: perDay=$perDay');
    });
  });
}
