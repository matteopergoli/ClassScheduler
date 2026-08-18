// lib/domain/scheduler/phase2_sa.dart
//
// Phase 2: Simulated Annealing optimisation (§8.2.2).
//
// Objective: minimise F = w1·F1 + w2·F2 + w3·F3
//   F1 = teacher free hours (gap slots between first/last lesson per day)
//   F2 = subject changes per classroom per day (adjacent-slot transitions)
//   F3 = total weighted soft constraint violations
//
// Move operators (with probabilities):
//   SWAP            40% — swap two lessons within the same classroom
//   RELOCATE        30% — move one lesson to a free slot
//   CROSS-CLASS     20% — swap different subjects between two classrooms
//   BLOCK SHIFT     10% — move a block of consecutive same-subject lessons

import 'dart:math';
import '../../core/constants/app_constants.dart';
import 'schedule_state.dart';
import 'scheduler_input.dart';

typedef CancelCheck = bool Function();
typedef ProgressCallback = void Function(double fraction, int iterations);

class Phase2SA {
  final SchedulerInput _input;
  final CancelCheck    _isCancelled;
  final ProgressCallback _onProgress;
  final Random         _rng;
  static const _debugEnabled = false;

  void _debug(String message) {
    if (!_debugEnabled) return;
    assert(() {
      print('[Phase2] $message');
      return true;
    }());
  }

  int _iterationsCompleted = 0;
  int _restartsUsed        = 0;

  Phase2SA({
    required SchedulerInput input,
    required CancelCheck isCancelled,
    required ProgressCallback onProgress,
    Random? rng,
  })  : _input       = input,
        _isCancelled = isCancelled,
        _onProgress  = onProgress,
        _rng         = rng ?? Random(42);

  int get iterationsCompleted => _iterationsCompleted;
  int get restartsUsed        => _restartsUsed;

  // ── Entry point ───────────────────────────────────────────────────────────

  ScheduleState optimise(ScheduleState initial) {
    var current      = initial.clone();
    var best         = current.clone();
    var bestScore    = _score(best);
    final initialScore = bestScore;

    var T                = AppConstants.saInitialTemp.toDouble();
    var noImprovCount    = 0;
    _restartsUsed        = 0;
    _iterationsCompleted = 0;

    final stopwatch = Stopwatch()..start();
    print('[Phase2] Starting optimisation; initial score=$bestScore');
    print('[Phase2] SA params: T=$T saMinTemp=${AppConstants.saMinTemp} saMaxIterations=${AppConstants.saMaxIterations} saMaxWallSecs=${AppConstants.saMaxWallSecs}');

    // Emit initial progress marker for Phase 2
    _onProgress(0.35, 0);

    print('[Phase2] entering loop condition: ${T > AppConstants.saMinTemp}');
    final progressUpdateInterval =
        max(1, AppConstants.saMaxIterations ~/ 1000);
    var loopCount = 0;

    // Outer cycle loop ───────────────────────────────────────────────────
    // A full T0→Tmin cooling cycle can complete in far fewer iterations
    // than saMaxIterations / saMaxWallSecs allow (e.g. ~28k iterations for
    // the default T0=500, alpha=0.9997, Tmin=0.1 — a couple of seconds).
    // On tight / zero-slack problems that require a rare combination like
    // BLOCK SHIFT + FILL to escape a MinDaily deadlock, one short cycle is
    // often not enough. Previously the stagnation-based restart inside the
    // loop (triggered by saNoImprovementLimit) could never fire because
    // the whole cycle finished before reaching that count, so optimise()
    // just returned early with most of the time/iteration budget unused.
    //
    // Fix: keep reheating and re-annealing from the best-known state until
    // we genuinely exhaust the wall-clock budget, the iteration cap, or the
    // restart allowance — not just until one cooling cycle finishes.
    while (_iterationsCompleted < AppConstants.saMaxIterations &&
           stopwatch.elapsed.inSeconds < AppConstants.saMaxWallSecs) {
      if (_isCancelled()) break;

      while (T > AppConstants.saMinTemp &&
             _iterationsCompleted < AppConstants.saMaxIterations &&
             stopwatch.elapsed.inSeconds < AppConstants.saMaxWallSecs) {
        loopCount++;
        if (loopCount <= 5 || loopCount % 10000 == 0) {
          _debug('SA loop iteration $loopCount: T=$T iterations=$_iterationsCompleted');
        }

        // Cancellation check every configured interval (ALGO-R06)
        if (_iterationsCompleted % AppConstants.saCancelCheckInterval == 0 &&
            _isCancelled()) break;

        // Progress report every smaller interval so Phase 2 shows movement.
        if (_iterationsCompleted < 20 ||
            _iterationsCompleted % progressUpdateInterval == 0) {
          final iterationCount = _iterationsCompleted + 1;
          final earlyRamp = min(1.0, iterationCount / 1000.0);
          final laterRamp = iterationCount / AppConstants.saMaxIterations;
          final progress = 0.35 + 0.40 * earlyRamp + 0.20 * laterRamp;
          _onProgress(progress.clamp(0.35, 0.95), iterationCount);
        }

        // Stagnation-triggered reheat within a cycle (kept for long cycles
        // on larger problems where a single cycle runs for a long time).
        if (noImprovCount >= AppConstants.saNoImprovementLimit &&
            _restartsUsed < AppConstants.saMaxRestarts) {
          current = best.clone();
          T = AppConstants.saInitialTemp.toDouble(); // full reheat
          noImprovCount = 0;
          _restartsUsed++;
        }

        // Apply a random move
        final candidate = _applyMove(current);
        if (candidate == null) {
          _iterationsCompleted++;
          T *= AppConstants.saCoolingRate;
          continue;
        }

        final delta = _score(candidate) - _score(current);

        if (delta < 0 || _rng.nextDouble() < exp(-delta / T)) {
          current = candidate;
          if (_score(current) < bestScore) {
            best         = current.clone();
            bestScore    = _score(best);
            noImprovCount = 0;
          } else {
            noImprovCount++;
          }
        } else {
          noImprovCount++;
        }

        T *= AppConstants.saCoolingRate;
        _iterationsCompleted++;
      }

      // Inner cycle ended. If it cooled out naturally (T <= Tmin) rather
      // than hitting a hard stop (cancel/time/iteration cap), and budget
      // plus restart allowance remain, reheat from the best-known state
      // and anneal again.
      if (_isCancelled()) break;
      if (_iterationsCompleted >= AppConstants.saMaxIterations) break;
      if (stopwatch.elapsed.inSeconds >= AppConstants.saMaxWallSecs) break;
      if (_restartsUsed >= AppConstants.saMaxRestarts) break;

      current = best.clone();
      T = AppConstants.saInitialTemp.toDouble();
      noImprovCount = 0;
      _restartsUsed++;
    }

    print('[Phase2] SA loop exited after $loopCount iterations: T=$T iterations=$_iterationsCompleted restarts=$_restartsUsed');

    // Emit at least a 0.50 progress to show we did Phase 2, even if fast
    _onProgress(0.50, _iterationsCompleted);
    print('[Phase2] SA emitted final progress 0.50');

    return best;
  }

  // ── Scoring ───────────────────────────────────────────────────────────────

  int _score(ScheduleState state) {
    return AppConstants.wMissingLesson    * _missingLessons(state) +
           AppConstants.wTeacherFreeHours * f1(state) +
           AppConstants.wSubjectChanges   * f2(state) +
           f3(state);
  }

  /// Count of lessons still required across all (classroom, subject) pairs.
  int _missingLessons(ScheduleState state) {
    var total = 0;
    for (var c = 0; c < _input.numClassrooms; c++)
      for (var s = 0; s < _input.numSubjects; s++) {
        final r = state.remaining(c, s);
        if (r > 0) total += r;
      }
    return total;
  }

  /// F1: total teacher free-hour gaps.
  int f1(ScheduleState state) {
    var total = 0;
    final numTeachers = _input.teacherNames.length;
    for (var t = 0; t < numTeachers; t++) {
      for (var d = 0; d < _input.numDays; d++) {
        int first = -1, last = -1;
        for (var l = 0; l < _input.numSlots; l++) {
          if (!state.isTeacherFree(t, d, l)) {
            if (first == -1) first = l;
            last = l;
          }
        }
        if (first == -1) continue;
        // Count free slots between first and last
        for (var l = first + 1; l < last; l++) {
          if (state.isTeacherFree(t, d, l)) total++;
        }
      }
    }
    return total;
  }

  /// F2: adjacent subject-change transitions per classroom per day.
  int f2(ScheduleState state) {
    var total = 0;
    for (var c = 0; c < _input.numClassrooms; c++) {
      for (var d = 0; d < _input.numDays; d++) {
        for (var l = 0; l < _input.numSlots - 1; l++) {
          final curr = state.schedule[c][d][l];
          final next = state.schedule[c][d][l + 1];
          if (curr != kFree && next != kFree && curr != next) total++;
        }
      }
    }
    return total;
  }

  /// F3: weighted soft constraint violations.
  int f3(ScheduleState state) {
    var total = 0;
    for (final sc in _input.softConstraints) {
      switch (sc.type) {
        case SoftType.avoidTimeslot:
          total += _penaltyAvoidTimeslot(state, sc);
        case SoftType.preferBlock:
          total += _penaltyPreferBlock(state, sc);
        case SoftType.dailyLimit:
          total += _penaltyDailyLimit(state, sc);
      }
    }
    return total;
  }

  bool _isMustAssignSlot(int c, int d, int l) {
    for (final ma in _input.mustAssign) {
      if (ma.c == c && ma.d == d && ma.l == l) return true;
    }
    return false;
  }

  int _penaltyAvoidTimeslot(ScheduleState state, SoftConstraintInput sc) {
    var violations = 0;
    final start = sc.startSlotIdx ?? 0;
    final end   = sc.endSlotIdx   ?? (_input.numSlots - 1);
    for (var c = 0; c < _input.numClassrooms; c++) {
      final days = sc.dayIdx != null
          ? [sc.dayIdx!]
          : List.generate(_input.numDays, (i) => i);
      for (final d in days) {
        for (var l = start; l <= end; l++) {
          if (state.schedule[c][d][l] == sc.subjectIdx) violations++;
        }
      }
    }
    return violations * sc.weight;
  }

  int _penaltyPreferBlock(ScheduleState state, SoftConstraintInput sc) {
    // Penalise isolated (non-adjacent) occurrences of the subject
    var isolated = 0;
    final s = sc.subjectIdx;
    for (var c = 0; c < _input.numClassrooms; c++) {
      for (var d = 0; d < _input.numDays; d++) {
        for (var l = 0; l < _input.numSlots; l++) {
          if (state.schedule[c][d][l] != s) continue;
          final prevSame = l > 0 && state.schedule[c][d][l - 1] == s;
          final nextSame = l < _input.numSlots - 1 &&
                           state.schedule[c][d][l + 1] == s;
          if (!prevSame && !nextSame) isolated++;
        }
      }
    }
    return isolated * sc.weight;
  }

  /// Preference version of HC-4/HC-5 (see ClassroomSubjectModel for the hard
  /// equivalent): penalises, per day, having the subject present below its
  /// preferred minimum or above its preferred maximum. A day with zero
  /// lessons of the subject never counts against the minimum — only days
  /// where it *is* scheduled but falls short.
  int _penaltyDailyLimit(ScheduleState state, SoftConstraintInput sc) {
    final c = sc.classroomIdx;
    if (c == null) return 0;
    var violations = 0;
    for (var d = 0; d < _input.numDays; d++) {
      var count = 0;
      for (var l = 0; l < _input.numSlots; l++) {
        if (state.schedule[c][d][l] == sc.subjectIdx) count++;
      }
      final min = sc.softMinDaily;
      final max = sc.softMaxDaily;
      if (min != null && min > 0 && count > 0 && count < min) violations++;
      if (max != null && count > max) violations++;
    }
    return violations * sc.weight;
  }

  // ── Worst-case score (for QualityScore denominator) ───────────────────────

  int worstCaseScore() {
    // F1 worst: every teacher has a gap in every slot on every day
    final numTeachers = _input.teacherNames.length;
    final f1Worst = numTeachers * _input.numDays * _input.numSlots;

    // F2 worst: every adjacent pair differs for every classroom every day
    final f2Worst = _input.numClassrooms *
                    _input.numDays *
                    (_input.numSlots - 1);

    // F3 worst: every soft constraint fully violated
    final f3Worst = _input.softConstraints.fold(
        0, (sum, sc) => sum + sc.weight * _input.numClassrooms * _input.numDays);

    return AppConstants.wTeacherFreeHours * f1Worst +
           AppConstants.wSubjectChanges   * f2Worst +
           f3Worst;
  }

  // ── Move operators ────────────────────────────────────────────────────────

  ScheduleState? _applyMove(ScheduleState state) {
    // When lessons are missing, bias heavily toward FILL so SA actively
    // tries to place them before optimising F1/F2/F3.
    if (_missingLessons(state) > 0) {
      final roll = _rng.nextDouble();
      if (roll < 0.50) return _moveFill(state);
      if (roll < 0.70) return _moveSwap(state);
      if (roll < 0.85) return _moveRelocate(state);
      if (roll < 0.95) return _moveCrossClass(state);
      return _moveBlockShift(state);
    }
    final roll = _rng.nextDouble();
    if (roll < 0.40) return _moveSwap(state);
    if (roll < 0.70) return _moveRelocate(state);
    if (roll < 0.90) return _moveCrossClass(state);
    return _moveBlockShift(state);
  }

  // ── SWAP (40%): swap two lessons within the same classroom ────────────────

  ScheduleState? _moveSwap(ScheduleState state) {
    final c  = _rng.nextInt(_input.numClassrooms);
    // Collect all assigned slots in this classroom
    final assigned = <(int, int)>[];
    for (var d = 0; d < _input.numDays; d++)
      for (var l = 0; l < _input.numSlots; l++) {
        if (state.schedule[c][d][l] != kFree) assigned.add((d, l));
      }

    if (assigned.length < 2) return null;

    // Pick two distinct slots
    final idxA = _rng.nextInt(assigned.length);
    var   idxB = _rng.nextInt(assigned.length);
    if (idxA == idxB) return null;

    final (d1, l1) = assigned[idxA];
    final (d2, l2) = assigned[idxB];
    final s1 = state.schedule[c][d1][l1];
    final s2 = state.schedule[c][d2][l2];
    if (s1 == s2) return null; // no-op

    // Validate: placing s2 at (c,d1,l1) and s1 at (c,d2,l2)
    if (_isMustAssignSlot(c, d1, l1) || _isMustAssignSlot(c, d2, l2)) {
      return null;
    }

    final candidate = state.clone();
    candidate.remove(c, d1, l1);
    candidate.remove(c, d2, l2);

    if (!candidate.canPlace(c, s2, d1, l1)) return null;
    if (!candidate.canPlace(c, s1, d2, l2)) return null;

    // HC-5 check: after swap, both days must satisfy MinDaily
    candidate.assign(c, s2, d1, l1);
    candidate.assign(c, s1, d2, l2);

    if (!candidate.satisfiesMinDaily(c, s1, d1)) return null;
    if (!candidate.satisfiesMinDaily(c, s1, d2)) return null;
    if (!candidate.satisfiesMinDaily(c, s2, d1)) return null;
    if (!candidate.satisfiesMinDaily(c, s2, d2)) return null;

    return candidate;
  }

  // ── RELOCATE (30%): move one lesson to a free slot ────────────────────────

  ScheduleState? _moveRelocate(ScheduleState state) {
    final c = _rng.nextInt(_input.numClassrooms);

    // Pick a random assigned slot
    final assigned = <(int, int)>[];
    for (var d = 0; d < _input.numDays; d++)
      for (var l = 0; l < _input.numSlots; l++) {
        if (state.schedule[c][d][l] != kFree) assigned.add((d, l));
      }
    if (assigned.isEmpty) return null;

    final (srcD, srcL) = assigned[_rng.nextInt(assigned.length)];
    final s = state.schedule[c][srcD][srcL];

    // Pick a random free destination
    final free = <(int, int)>[];
    for (var d = 0; d < _input.numDays; d++)
      for (var l = 0; l < _input.numSlots; l++) {
        if (state.schedule[c][d][l] == kFree) free.add((d, l));
      }
    if (free.isEmpty) return null;

    final (dstD, dstL) = free[_rng.nextInt(free.length)];

    if (_isMustAssignSlot(c, srcD, srcL) || _isMustAssignSlot(c, dstD, dstL)) {
      return null;
    }

    final candidate = state.clone();
    candidate.remove(c, srcD, srcL);
    if (!candidate.canPlace(c, s, dstD, dstL)) return null;
    candidate.assign(c, s, dstD, dstL);

    // HC-5: source day must still satisfy MinDaily (0 or ≥ min)
    if (!candidate.satisfiesMinDaily(c, s, srcD)) return null;
    if (!candidate.satisfiesMinDaily(c, s, dstD)) return null;

    return candidate;
  }

  // ── CROSS-CLASS SWAP (20%): swap different subjects across classrooms ──────
  // (c1,s1,d,l) ↔ (c2,s2,d,l) where s1 ≠ s2 (§8.2.2)

  ScheduleState? _moveCrossClass(ScheduleState state) {
    if (_input.numClassrooms < 2) return null;

    final c1 = _rng.nextInt(_input.numClassrooms);
    var   c2 = _rng.nextInt(_input.numClassrooms);
    if (c1 == c2) return null;

    final d = _rng.nextInt(_input.numDays);
    final l = _rng.nextInt(_input.numSlots);

    final s1 = state.schedule[c1][d][l];
    final s2 = state.schedule[c2][d][l];

    // Both must be assigned and different (s1 == s2 is not a valid move)
    if (s1 == kFree || s2 == kFree || s1 == s2) return null;
    if (_isMustAssignSlot(c1, d, l) || _isMustAssignSlot(c2, d, l)) return null;

    final candidate = state.clone();
    candidate.remove(c1, d, l);
    candidate.remove(c2, d, l);

    // HC-1: teacher of s2 must be free in c1 at (d,l) and vice versa
    if (!candidate.canPlace(c1, s2, d, l)) {
      _debug('Cross-class move rejected: cannot place s2=$s2 into c1=$c1 d=$d l=$l');
      return null;
    }
    if (!candidate.canPlace(c2, s1, d, l)) {
      _debug('Cross-class move rejected: cannot place s1=$s1 into c2=$c2 d=$d l=$l');
      return null;
    }

    candidate.assign(c1, s2, d, l);
    candidate.assign(c2, s1, d, l);

    // HC-3: weekly target must still hold after the swap.
    if (candidate.remaining(c1, s2) < 0 ||
        candidate.remaining(c2, s1) < 0) {
      _debug('Cross-class HC-3 fail: c1=$c1 s2=$s2 rem=${candidate.remaining(c1, s2)} c2=$c2 s1=$s1 rem=${candidate.remaining(c2, s1)}');
      return null;
    }

    // HC-5 for both subjects in both classrooms on day d
    if (!candidate.satisfiesMinDaily(c1, s1, d)) return null;
    if (!candidate.satisfiesMinDaily(c1, s2, d)) return null;
    if (!candidate.satisfiesMinDaily(c2, s1, d)) return null;
    if (!candidate.satisfiesMinDaily(c2, s2, d)) return null;

    return candidate;
  }

  // ── BLOCK SHIFT (10%): move consecutive same-subject block to another day ──

  ScheduleState? _moveBlockShift(ScheduleState state) {
    final c   = _rng.nextInt(_input.numClassrooms);
    final srcD = _rng.nextInt(_input.numDays);
    final dstD = _rng.nextInt(_input.numDays);
    if (srcD == dstD) return null;

    // Find a random block of consecutive same-subject lessons on srcD
    final block = _findRandomBlock(state, c, srcD);
    if (block == null) return null;

    final (s, startL, endL) = block;
    final blockLen = endL - startL + 1;

    // Check destination day has enough consecutive free slots
    final dstStart = _findFreeRun(state, c, dstD, blockLen);
    if (dstStart == null) return null;

    if (_isMustAssignSlot(c, srcD, startL) ||
        _isMustAssignSlot(c, srcD, endL) ||
        _isMustAssignSlot(c, dstD, dstStart!)) {
      return null;
    }

    final candidate = state.clone();

    // Remove from source
    for (var l = startL; l <= endL; l++) {
      candidate.remove(c, srcD, l);
    }

    // HC-2: destination day capacity after addition
    if (candidate.dailyClassroomCount(c, dstD) + blockLen >
        _input.activeSlotCount(c, dstD)) {
      return null;
    }

    // HC-4: MaxDaily on destination
    if (candidate.dailySubjectCount(c, s, dstD) + blockLen >
        _input.maxDaily[c][s]) {
      return null;
    }

    // HC-1: teacher free for all block slots on dstD
    for (var l = dstStart; l < dstStart + blockLen; l++) {
      if (!candidate.canPlace(c, s, dstD, l)) return null;
    }

    // Assign to destination
    for (var l = dstStart; l < dstStart + blockLen; l++) {
      candidate.assign(c, s, dstD, l);
    }

    // HC-5: source day must still satisfy MinDaily (after removal)
    if (!candidate.satisfiesMinDaily(c, s, srcD)) return null;
    // HC-5: destination day after addition
    if (!candidate.satisfiesMinDaily(c, s, dstD)) return null;

    return candidate;
  }

  // ── Block helpers ─────────────────────────────────────────────────────────

  (int, int, int)? _findRandomBlock(ScheduleState state, int c, int d) {
    // Collect all blocks on this day
    final blocks = <(int, int, int)>[];
    var l = 0;
    while (l < _input.numSlots) {
      final s = state.schedule[c][d][l];
      if (s == kFree) { l++; continue; }
      var end = l;
      while (end + 1 < _input.numSlots && state.schedule[c][d][end + 1] == s) {
        end++;
      }
      if (end > l) blocks.add((s, l, end)); // only blocks of length ≥ 2
      l = end + 1;
    }
    if (blocks.isEmpty) return null;
    return blocks[_rng.nextInt(blocks.length)];
  }

  int? _findFreeRun(ScheduleState state, int c, int d, int length) {
    // Find first run of [length] consecutive free slots on day d
    var run = 0;
    var start = 0;
    for (var l = 0; l < _input.numSlots; l++) {
      if (state.schedule[c][d][l] == kFree) {
        if (run == 0) start = l;
        run++;
        if (run >= length) return start;
      } else {
        run = 0;
      }
    }
    return null;
  }

  // ── FILL: place a missing lesson into a free valid slot ──────────────────

  ScheduleState? _moveFill(ScheduleState state) {
    // Collect (c, s) pairs that still need lessons placed
    final missing = <(int, int)>[];
    for (var c = 0; c < _input.numClassrooms; c++)
      for (var s = 0; s < _input.numSubjects; s++)
        if (state.remaining(c, s) > 0) missing.add((c, s));
    if (missing.isEmpty) return null;

    final (c, s) = missing[_rng.nextInt(missing.length)];

    // Find every slot where the lesson can legally be placed
    final available = <(int, int)>[];
    for (var d = 0; d < _input.numDays; d++)
      for (var l = 0; l < _input.numSlots; l++)
        if (state.canPlace(c, s, d, l)) available.add((d, l));
    if (available.isEmpty) return null;

    final (d, l) = available[_rng.nextInt(available.length)];
    final candidate = state.clone();
    candidate.assign(c, s, d, l);

    // HC-5: the destination day must satisfy MinDaily (0 or ≥ min) after
    // the placement, otherwise we introduce a new hard violation.
    if (!candidate.satisfiesMinDaily(c, s, d)) return null;

    return candidate;
  }
}
