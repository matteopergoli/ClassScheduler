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
        _rng         = rng ?? Random();

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

    while (T > AppConstants.saMinTemp &&
           _iterationsCompleted < AppConstants.saMaxIterations &&
           stopwatch.elapsed.inSeconds < AppConstants.saMaxWallSecs) {

      // Cancellation check every 1000 iterations (ALGO-R06)
      if (_iterationsCompleted % 1000 == 0 && _isCancelled()) break;

      // Progress report every 5000 iterations
      if (_iterationsCompleted % 5000 == 0) {
        final progress = initialScore > 0
            ? (initialScore - bestScore) / (initialScore + 1e-9)
            : 0.0;
        _onProgress(progress.clamp(0.0, 1.0), _iterationsCompleted);
      }

      // Restart check
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

    return best;
  }

  // ── Scoring ───────────────────────────────────────────────────────────────

  int _score(ScheduleState state) {
    return AppConstants.wTeacherFreeHours * f1(state) +
           AppConstants.wSubjectChanges   * f2(state) +
           f3(state);
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
      }
    }
    return total;
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

    final candidate = state.clone();
    candidate.remove(c1, d, l);
    candidate.remove(c2, d, l);

    // HC-1: teacher of s2 must be free in c1 at (d,l) and vice versa
    if (!candidate.canPlace(c1, s2, d, l)) return null;
    if (!candidate.canPlace(c2, s1, d, l)) return null;

    candidate.assign(c1, s2, d, l);
    candidate.assign(c2, s1, d, l);

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
}
