// test/helpers/engine_test_runner.dart
//
// Runs SchedulerEngine synchronously (no Isolate) for unit tests.
// Also provides helpers for corrupting ScheduleState to test ALGO-R03.

import 'package:classscheduler/domain/scheduler/integrity_checker.dart';
import 'package:classscheduler/domain/scheduler/schedule_state.dart';
import 'package:classscheduler/domain/scheduler/scheduler_engine.dart';
import 'package:classscheduler/domain/scheduler/scheduler_input.dart';
import 'package:classscheduler/domain/scheduler/phase1_greedy.dart';

// ── Synchronous engine runner ─────────────────────────────────────────────

/// Runs the engine synchronously (on the test thread) and returns the result.
ScheduleResult runEngine(SchedulerInput input) {
  final engine = SchedulerEngine(
    input:       input,
    isCancelled: () => false,
    onProgress:  (fraction, iterations) {},
  );
  return engine.run();
}

/// Immediately-cancelled run (cancel flag true before engine starts).
ScheduleResult runCancelled(SchedulerInput input) {
  final engine = SchedulerEngine(
    input:       input,
    isCancelled: () => true,
    onProgress:  (fraction, iterations) {},
  );
  return engine.run();
}

/// Run Phase-1 only (no SA), returned as a Phase1Result.
Phase1Result runPhase1(SchedulerInput input) =>
    Phase1Greedy(input).build();

// ── Integrity helper ──────────────────────────────────────────────────────

/// Runs the ALGO-R03 independent check on [state].
IntegrityCheckResult checkIntegrity(
  SchedulerInput input,
  ScheduleState state,
) =>
    IntegrityChecker(input).check(state);

// ── State corruptor ───────────────────────────────────────────────────────

/// Returns a copy of [state] with a deliberate HC-1 teacher conflict:
/// forces subject [s] into classroom 0 AND classroom 1 at (d, l),
/// bypassing all HC checks so we can test ALGO-R03 detection.
ScheduleState injectTeacherConflict(
  ScheduleState state,
  SchedulerInput input,
  int s, int d, int l,
) {
  final corrupted = state.clone();

  // Clear slots first, then force-write directly into the schedule array
  // (schedule is a public List<List<List<int>>>)
  for (int c = 0; c < input.numClassrooms && c < 2; c++) {
    if (corrupted.schedule[c][d][l] != kFree) {
      corrupted.remove(c, d, l);
    }
  }

  // Directly write into the array — bypasses HC checks intentionally
  corrupted.schedule[0][d][l] = s;
  corrupted.schedule[1][d][l] = s;
  // Note: _teacherSlotMap now only maps to classroom 0 (the last assign),
  // which is the corrupted state we want the checker to detect.

  return corrupted;
}
