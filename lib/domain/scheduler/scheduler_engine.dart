// lib/domain/scheduler/scheduler_engine.dart
//
// Top-level orchestrator called inside the Dart Isolate.
// Runs Phase 1 → Phase 2 → ALGO-R03 → result reporting.
// Wrapped in a top-level try/catch per ALGO-R05.

import 'integrity_checker.dart';
import 'phase1_greedy.dart';
import 'phase2_sa.dart';
import 'result_reporter.dart';
import 'schedule_state.dart';
import 'scheduler_input.dart';

class SchedulerEngine {
  final SchedulerInput     _input;
  final CancelCheck        _isCancelled;
  final ProgressCallback   _onProgress;

  SchedulerEngine({
    required SchedulerInput   input,
    required CancelCheck      isCancelled,
    required ProgressCallback onProgress,
  })  : _input       = input,
        _isCancelled = isCancelled,
        _onProgress  = onProgress;

  ScheduleResult run() {
    final stopwatch = Stopwatch()..start();
    try {
      return _runInternal(stopwatch);
    } catch (e, st) {
      // ALGO-R05: never crash — return a clean error result
      return ScheduleResult(
        schedule:            _emptySchedule(),
        status:              ResultStatus.hardViolations,
        isCancelled:         false,
        teacherFreeHours:    0,
        subjectChanges:      0,
        softPenalty:         0,
        qualityScore:        0,
        hardViolations: [
          ConstraintViolation(
            constraintId: 'INTERNAL',
            description:  'Unexpected error during generation: $e\n$st',
            suggestion:   'Please report this bug. Your previous schedule '
                          'has not been modified.',
            isHard: true,
          ),
        ],
        softViolations:      [],
        computationTime:     stopwatch.elapsed,
        iterationsCompleted: 0,
        restartsUsed:        0,
      );
    }
  }

  ScheduleResult _runInternal(Stopwatch stopwatch) {
    // ── Phase 1: MCF Greedy ──────────────────────────────────────────────
    final phase1 = Phase1Greedy(_input);
    final p1Result = phase1.build();

    // ── Phase 2: Simulated Annealing ─────────────────────────────────────
    final sa = Phase2SA(
      input:       _input,
      isCancelled: _isCancelled,
      onProgress:  _onProgress,
    );

    final cancelled = _isCancelled();
    ScheduleState finalState;

    if (!cancelled) {
      finalState = sa.optimise(p1Result.state);
    } else {
      finalState = p1Result.state;
    }

    // ── ALGO-R03: post-generation integrity check ────────────────────────
    final checker         = IntegrityChecker(_input);
    final integrityResult = checker.check(finalState);

    // If integrity check found a bug, return error without writing to Firestore
    if (!integrityResult.passed) {
      return ScheduleResult(
        schedule:            finalState.schedule,
        status:              ResultStatus.hardViolations,
        isCancelled:         cancelled,
        teacherFreeHours:    0,
        subjectChanges:      0,
        softPenalty:         0,
        qualityScore:        0,
        hardViolations: integrityResult.violations.map((v) =>
          ConstraintViolation(
            constraintId: v.rule,
            description:  '[INTEGRITY BUG] ${v.description}',
            suggestion:   'This is an implementation error. '
                          'Your previous schedule has not been modified. '
                          'Please report this issue.',
            isHard: true,
          )).toList(),
        softViolations:      [],
        computationTime:     stopwatch.elapsed,
        iterationsCompleted: sa.iterationsCompleted,
        restartsUsed:        sa.restartsUsed,
      );
    }

    // ── Build final result ───────────────────────────────────────────────
    final reporter = ResultReporter(input: _input, sa: sa);
    return reporter.buildResult(
      finalState:           finalState,
      integrityResult:      integrityResult,
      partialViolations:    p1Result.violations,
      isCancelled:          cancelled,
      computationTime:      stopwatch.elapsed,
      iterationsCompleted:  sa.iterationsCompleted,
      restartsUsed:         sa.restartsUsed,
    );
  }

  List<List<List<int>>> _emptySchedule() => List.generate(
    _input.numClassrooms,
    (_) => List.generate(
      _input.numDays,
      (_) => List.filled(_input.numSlots, kFree),
    ),
  );
}
