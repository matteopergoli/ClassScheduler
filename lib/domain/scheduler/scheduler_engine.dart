// lib/domain/scheduler/scheduler_engine.dart
//
// Top-level orchestrator called inside the Dart Isolate.
// Runs Phase 1 → Phase 2 → ALGO-R03 → result reporting.
// Wrapped in a top-level try/catch per ALGO-R05.

import 'dart:math';
import 'dart:io';

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

  static const _debugEnabled = false;

  SchedulerEngine({
    required SchedulerInput   input,
    required CancelCheck      isCancelled,
    required ProgressCallback onProgress,
  })  : _input       = input,
        _isCancelled = isCancelled,
        _onProgress  = onProgress;

  void _debug(String message) {
    if (!_debugEnabled) return;
    assert(() {
      print('[SchedulerEngine] $message');
      return true;
    }());
  }

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
    void _trace(String m) {
      try {
        final f = File('${Directory.systemTemp.path.replaceAll('\\', '/')}/classscheduler_run.log');
        final line = '${DateTime.now().toIso8601String()} | $m\n';
        f.writeAsStringSync(line, mode: FileMode.append, flush: true);
      } catch (e) {
        // ignore
      }
    }

    _trace('runInternal start');
    _onProgress(0.05, 0);
    
    // ── Phase 1: MCF Greedy (multi-start for robustness) ────────────────
    _trace('phase1 starting');
    print('[SchedulerEngine] phase1 starting');
    final p1Result = _buildPhase1Result();
    print('[SchedulerEngine] phase1 completed: violations=${p1Result.violations.length} backtracks=${p1Result.backtrackCount}');
    _debug('Phase 1 result: violations=${p1Result.violations.length} backtracks=${p1Result.backtrackCount}');
    _trace('phase1 done violations=${p1Result.violations.length} backtracks=${p1Result.backtrackCount}');

    // Ensure clear milestone: Phase 1 is done, Phase 2 starting
    _onProgress(0.30, 0);
    _onProgress(0.35, 0);
    print('[SchedulerEngine] phase1 complete, entering Phase2');

    // ── Phase 2: Simulated Annealing ─────────────────────────────────────
    _trace('phase2 creating SA instance');
    final sa = Phase2SA(
      input:       _input,
      isCancelled: _isCancelled,
      onProgress:  _onProgress,
    );

    final cancelled = _isCancelled();
    ScheduleState finalState;

    if (!cancelled) {
      _trace('phase2 calling optimise()');
      print('[SchedulerEngine] calling Phase2 optimise');
      finalState = sa.optimise(p1Result.state);
      _trace('phase2 optimise() returned iterations=${sa.iterationsCompleted}');
      print('[SchedulerEngine] Phase2 optimise returned iterations=${sa.iterationsCompleted} restarts=${sa.restartsUsed}');
      _debug('Phase 2 completed: iterations=${sa.iterationsCompleted} restarts=${sa.restartsUsed}');
      _onProgress(0.70, sa.iterationsCompleted);
    } else {
      _trace('generation was cancelled');
      finalState = p1Result.state;
    }

    _trace('phase2 done, starting integrity check');
    _onProgress(0.95, sa.iterationsCompleted);

    // ── ALGO-R03: post-generation integrity check ────────────────────────
    final checker         = IntegrityChecker(_input);
    final integrityResult = checker.check(finalState);
    _trace('integrity check done violations=${integrityResult.violations.length}');

    // Only HC-1 (teacher conflict) and HC-7 (must-not-assign) are true
    // implementation bugs that must block saving.
    // HC-2 (capacity), HC-3 (weekly target), HC-4 (max daily), HC-5 (min daily)
    // can all arise from partial solutions or over-constrained problems and are
    // surfaced to the user as regular hard violations in the result panel.
    const _partialRules = {'HC-2', 'HC-3', 'HC-4', 'HC-5'};
    final trueBugs = integrityResult.violations
        .where((v) => !_partialRules.contains(v.rule))
        .toList();

    // Partial failures: shown to user as hard violations, schedule still saved.
    final softFailures = integrityResult.violations
        .where((v) => _partialRules.contains(v.rule))
        .toList();

    if (trueBugs.isNotEmpty) {
      // True bug: show detailed description so user/developer can diagnose.
      final allViolations = [
        ...trueBugs.map((v) => ConstraintViolation(
          constraintId: v.rule,
          description:  '[INTEGRITY BUG] ${v.description}',
          suggestion:   'This is an implementation error. '
                        'Your previous schedule has not been modified. '
                        'Please report this issue.',
          isHard: true,
        )),
        ...softFailures.map((v) => ConstraintViolation(
          constraintId: v.rule,
          description:  v.description,
          suggestion:   'Reduce weekly targets or add more lesson slots.',
          isHard: true,
        )),
      ];
      _onProgress(1.0, sa.iterationsCompleted);
      return ScheduleResult(
        schedule:            finalState.schedule,
        status:              ResultStatus.hardViolations,
        isCancelled:         cancelled,
        teacherFreeHours:    0,
        subjectChanges:      0,
        softPenalty:         0,
        qualityScore:        0,
        hardViolations:      allViolations,
        softViolations:      [],
        computationTime:     stopwatch.elapsed,
        iterationsCompleted: sa.iterationsCompleted,
        restartsUsed:        sa.restartsUsed,
      );
    }

    // ── Build final result ───────────────────────────────────────────────
    final reporter = ResultReporter(input: _input, sa: sa);
    _onProgress(1.0, sa.iterationsCompleted);
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

  Phase1Result _buildPhase1Result() {
    // Zero-slack / exact-cover configurations (weekly targets that sum
    // exactly to available capacity, especially with teachers shared
    // across classrooms) need many more randomized attempts to find a
    // feasible ordering. 6 was too few — raised to 40.
    const retries = 40;
    Phase1Result bestResult = Phase1Greedy(
      _input,
      rng: Random(42),
      onProgress: (fraction) => _onProgress(0.05 + 0.30 * fraction, 0),
    ).build();
    var bestCost = _phase1ResultCost(bestResult);
    _debug('Phase1 trial 0: cost=$bestCost violations=${bestResult.violations.length}');

    if (bestResult.violations.isEmpty) {
      return bestResult;
    }

    for (var i = 1; i < retries; i++) {
      final result = Phase1Greedy(
        _input,
        rng: Random(42 + i),
        onProgress: (fraction) => _onProgress(0.05 + 0.30 * fraction, 0),
      ).build();
      final cost = _phase1ResultCost(result);
      _debug('Phase1 trial $i: cost=$cost violations=${result.violations.length}');
      if (result.violations.isEmpty) {
        _debug('Phase1 found feasible result on trial $i');
        return result;
      }
      if (cost < bestCost) {
        bestResult = result;
        bestCost = cost;
      }
    }

    _debug('Phase1 best result after retries: cost=$bestCost violations=${bestResult.violations.length}');
    return bestResult;
  }

  int _phase1ResultCost(Phase1Result result) {
    return result.violations.fold(0, (sum, v) => sum + v.shortfall);
  }

  List<List<List<int>>> _emptySchedule() => List.generate(
    _input.numClassrooms,
    (_) => List.generate(
      _input.numDays,
      (_) => List.filled(_input.numSlots, kFree),
    ),
  );
}
