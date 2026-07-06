// lib/domain/scheduler/phase1_greedy.dart
//
// Phase 1: Most-Constrained-First (MCF) Greedy construction.
// Produces an initial schedule satisfying all hard constraints, or the
// best partial solution found with PartialViolations recorded.
//
// Algorithm steps (§8.2.1):
//   1. Pre-assign MUST-ASSIGN rules (HC-6)
//   2. Sort unresolved (c,s) pairs by slack ascending (MCF ordering)
//   3. For each pair, score candidate slots and assign the best
//   4. On deadlock: backtrack N=5 assignments, retry
//   5. Record any remaining shortfall as PartialViolations

import 'dart:math';
import '../../core/constants/app_constants.dart';
import 'schedule_state.dart';
import 'scheduler_input.dart';

// ── Result ────────────────────────────────────────────────────────────────────

typedef Phase1ProgressCallback = void Function(double fraction);

class Phase1Result {
  final ScheduleState state;
  final List<PartialViolation> violations;
  final int backtrackCount;

  const Phase1Result({
    required this.state,
    required this.violations,
    required this.backtrackCount,
  });
}

class PartialViolation {
  final int classroomIdx;
  final int subjectIdx;
  final int shortfall; // lessons that could not be assigned

  const PartialViolation({
    required this.classroomIdx,
    required this.subjectIdx,
    required this.shortfall,
  });
}

// ── Greedy builder ────────────────────────────────────────────────────────────

class Phase1Greedy {
  final SchedulerInput _input;
  final Random _rng;
  final Phase1ProgressCallback? _onProgress;
  int _backtrackCount = 0;
  static const _debugEnabled = false;

  Phase1Greedy(this._input, {Random? rng, Phase1ProgressCallback? onProgress})
      : _rng = rng ?? Random(42), // deterministic seed for debuggability
        _onProgress = onProgress;

  void _debug(String message) {
    if (!_debugEnabled) return;
    assert(() {
      print('[Phase1] $message');
      return true;
    }());
  }

  void _emitProgress(double fraction) {
    if (_onProgress != null) {
      _onProgress!(fraction.clamp(0.0, 1.0));
    }
  }

  Phase1Result build() {
    final state      = ScheduleState(_input);
    final violations = <PartialViolation>[];

    // Step 1 — Pre-assign MUST-ASSIGN ───────────────────────────────────────
    for (final ma in _input.mustAssign) {
      if (!state.canPlace(ma.c, ma.s, ma.d, ma.l)) continue;
      state.assign(ma.c, ma.s, ma.d, ma.l);
    }

    _debug('Starting Phase 1: mustAssign=${_input.mustAssign.length} pairs=${_input.numClassrooms * _input.numSubjects}');

    // Step 2 — Build ordered work list by MCF slack ─────────────────────────
    final pairs = _buildMcfOrder(state);
    _emitProgress(0.2); // 20% through Phase 1 (MCF ordering complete)

    // Step 3+4+5 — Assign remaining demand ──────────────────────────────────
    _assignAll(state, pairs, violations);
    _emitProgress(1.0); // 100% through Phase 1 (assignment complete)

    return Phase1Result(
      state:         state,
      violations:    violations,
      backtrackCount: _backtrackCount,
    );
  }

  // ── MCF ordering ─────────────────────────────────────────────────────────

  List<_WorkItem> _buildMcfOrder(ScheduleState state) {
    final C = _input.numClassrooms;
    final S = _input.numSubjects;

    final items = <_WorkItem>[];
    for (var c = 0; c < C; c++) {
      for (var s = 0; s < S; s++) {
        final demand = state.remaining(c, s);
        if (demand <= 0) continue;
        final available = state.availableSlots(c, s).length;
        final slack     = available - demand;
        items.add(_WorkItem(c: c, s: s, slack: slack, demand: demand));
      }
    }

    // Sort ascending by slack; ties broken by descending demand (§8.2.1 Step 2)
    items.sort((a, b) {
      final cmp = a.slack.compareTo(b.slack);
      return cmp != 0 ? cmp : b.demand.compareTo(a.demand);
    });

    return items;
  }

  // ── Assignment loop ───────────────────────────────────────────────────────

  void _assignAll(
    ScheduleState state,
    List<_WorkItem> pairs,
    List<PartialViolation> violations,
  ) {
    var i = 0;
    var completed = 0;
    var loopCount = 0;
    final totalPairs = pairs.length;
    final totalPairsDouble = totalPairs == 0 ? 1.0 : totalPairs.toDouble();
    // Hard cap: each pair gets at most 200 attempts before we give up on it.
    final maxLoopIterations = totalPairs * 200 + 200;
    // History for backtracking: list of (c, d, l) assignments in order
    final history = <(int, int, int)>[];

    while (i < pairs.length) {
      loopCount++;

      // Safety valve: if we've looped more than the cap, record remaining
      // pairs as violations and bail out rather than spinning forever.
      if (loopCount > maxLoopIterations) {
        print('[Phase1] WARNING: loop cap reached ($loopCount). Recording remaining violations.');
        for (var j = i; j < pairs.length; j++) {
          final rem = state.remaining(pairs[j].c, pairs[j].s);
          if (rem > 0) {
            violations.add(PartialViolation(
              classroomIdx: pairs[j].c,
              subjectIdx: pairs[j].s,
              shortfall: rem,
            ));
          }
        }
        break;
      }

      if (loopCount % 20 == 0 && totalPairs > 0) {
        final progressFraction = (i / totalPairsDouble).clamp(0.0, 1.0);
        _emitProgress(0.2 + 0.8 * progressFraction);
      }

      final item = pairs[i];
      final c = item.c;
      final s = item.s;

      // How many more lessons does (c,s) still need?
      var remaining = state.remaining(c, s);
      if (remaining <= 0) {
        i++;
        if (totalPairs > 0) {
          _emitProgress(0.2 + 0.8 * (i / totalPairsDouble).clamp(0.0, 1.0));
        }
        continue;
      }

      // Score all available slots and pick the best
      final best = _pickBestSlot(state, c, s);

        if (best == null) {
        // Deadlock — try backtracking once
        _debug('Deadlock at pair c=$c s=$s remaining=$remaining i=$i history=${history.length}');
        final resolved = _backtrack(state, pairs, i, history);
        if (!resolved) {
          // Still stuck — record violation and move on
          print('[Phase1] deadlock unresolvable at c=$c s=$s remaining=${state.remaining(c, s)}');
          _debug('Unresolvable deadlock at c=$c s=$s remaining=${state.remaining(c, s)}');
          violations.add(PartialViolation(
            classroomIdx: c,
            subjectIdx:   s,
            shortfall:    state.remaining(c, s),
          ));
          i++;
        }
        // Whether or not backtrack resolved things, re-evaluate from current i
        continue;
      }

      state.assign(c, s, best.$1, best.$2);

      // HC-5 post-assignment check: if this day now has 1..(minDaily-1)
      // lessons and there are no more free slots on this day to reach minDaily,
      // the placement is irrecoverable — undo it and record a violation.
      final minD = _input.minDaily[c][s];
      if (minD > 0 && !state.satisfiesMinDaily(c, s, best.$1)) {
        final freeLeft = _countAvailableSubjectSlots(state, c, s, best.$1);
        final countNow = state.dailySubjectCount(c, s, best.$1);
        final needed   = minD - countNow;
        if (needed > freeLeft) {
          // Can't reach minDaily on this day — undo
          state.remove(c, best.$1, best.$2);
          violations.add(PartialViolation(
            classroomIdx: c,
            subjectIdx:   s,
            shortfall:    state.remaining(c, s),
          ));
          i++;
          continue;
        }
      }

      history.add((c, best.$1, best.$2));

      // Check if this pair is now complete
      if (state.remaining(c, s) <= 0) {
        i++;
        if (totalPairs > 0) {
          _emitProgress(0.2 + 0.8 * (i / totalPairsDouble).clamp(0.0, 1.0));
        }
      }
    }
  }

  // ── Slot scoring (§8.2.1 Step 4) ─────────────────────────────────────────
  //
  // HC-5 (MinDaily) is enforced here by a tentative assign+check+undo.
  // canPlace() cannot check HC-5 on its own because HC-5 depends on the
  // count *after* placement — we must actually assign to know if the day
  // will have 0 or >= minDaily lessons for this subject.

  (int, int)? _pickBestSlot(ScheduleState state, int c, int s) {
    final remaining = state.remaining(c, s);
    (int, int)? bestSlot;
    var bestScore = double.negativeInfinity;
    final minD = _input.minDaily[c][s];

    for (var d = 0; d < _input.numDays; d++) {
      for (var l = 0; l < _input.numSlots; l++) {
        if (!state.canPlace(c, s, d, l)) continue;

        // HC-5 tentative check: assign, verify, undo.
        // We need to know the count after this placement to enforce MinDaily.
        if (minD > 0) {
          state.assign(c, s, d, l);
          final ok = state.satisfiesMinDaily(c, s, d);
          if (!ok) {
            // Check if we can reach minDaily on this day later.
            // Count only the slots that are actually placeable for (c,s),
            // not just the raw free classroom slots.
            final currentCount = state.dailySubjectCount(c, s, d);
            final freeOnDay = _countAvailableSubjectSlots(state, c, s, d);
            state.remove(c, d, l);
            final needed = minD - currentCount;
            if (needed > freeOnDay) continue; // can't reach minDaily → skip
            // Otherwise allow it (more assignments may still fill the day)
          } else {
            state.remove(c, d, l);
          }
        }

        var score = 0.0;

        // +10 if adjacent to an existing same-subject slot (promotes blocks)
        if (_hasAdjacentSame(state, c, s, d, l)) score += 10;

        // +5 if teacher already has a lesson on that day (reduces F1 gaps)
        if (_subjectHasPartialMinDailyDay(state, c, s)) {
          final count = state.dailySubjectCount(c, s, d);
          if (count > 0 && count < minD) {
            // If this subject already has a partial day, prioritise completing it.
            score += 1000;
          } else {
            // Avoid placing elsewhere until the partial day is resolved.
            score -= 1000;
          }
        }

        if (_teacherBusyOnDay(state, s, d)) score += 5;

        // Subtract soft constraint penalty for AVOID_TIMESLOT violations
        score -= _softPenalty(s, d, l);

        // Tie-break: prefer earlier slots
        final tieBreak = -(d * _input.numSlots + l) * 0.001;
        score += tieBreak;

        if (score > bestScore) {
          bestScore = score;
          bestSlot  = (d, l);
        } else if ((score - bestScore).abs() < 1e-9 && _rng.nextBool()) {
          bestSlot = (d, l);
        }
      }
    }
    if (bestSlot == null) {
      _debug('No available slot for c=$c s=$s remaining=$remaining');
    }
    return bestSlot;
  }

  int _countAvailableSubjectSlots(ScheduleState state, int c, int s, int d) {
    var count = 0;
    for (var l = 0; l < _input.numSlots; l++) {
      if (state.canPlace(c, s, d, l)) count++;
    }
    return count;
  }

  bool _subjectHasPartialMinDailyDay(ScheduleState state, int c, int s) {
    final minD = _input.minDaily[c][s];
    if (minD <= 1) return false;
    for (var d = 0; d < _input.numDays; d++) {
      final count = state.dailySubjectCount(c, s, d);
      if (count > 0 && count < minD) return true;
    }
    return false;
  }

  bool _hasAdjacentSame(ScheduleState state, int c, int s, int d, int l) {
    if (l > 0 && state.schedule[c][d][l - 1] == s) return true;
    if (l < _input.numSlots - 1 && state.schedule[c][d][l + 1] == s) {
      return true;
    }
    return false;
  }

  bool _teacherBusyOnDay(ScheduleState state, int s, int d) {
    final t = _input.teacherOf[s];
    for (var l = 0; l < _input.numSlots; l++) {
      if (!state.isTeacherFree(t, d, l)) return true;
    }
    return false;
  }

  double _softPenalty(int s, int d, int l) {
    var penalty = 0.0;
    for (final sc in _input.softConstraints) {
      if (sc.type != SoftType.avoidTimeslot) continue;
      if (sc.subjectIdx != s) continue;
      if (sc.dayIdx != null && sc.dayIdx != d) continue;
      final start = sc.startSlotIdx ?? 0;
      final end   = sc.endSlotIdx   ?? (_input.numSlots - 1);
      if (l >= start && l <= end) penalty += sc.weight;
    }
    return penalty;
  }

  // ── Limited backtracking (§8.2.1 Step 5) ─────────────────────────────────

  bool _backtrack(
    ScheduleState state,
    List<_WorkItem> pairs,
    int currentIdx,
    List<(int, int, int)> history,
  ) {
    const N = AppConstants.phase1BacktrackN;
    if (history.isEmpty) return false;

    // Undo up to N recent assignments that share the same teacher or classroom
    final item      = pairs[currentIdx];
    final deadTeacher = _input.teacherOf[item.s];
    final undone    = <(int, int, int)>[];
    var count       = 0;

    for (var h = history.length - 1; h >= 0 && count < N; h--) {
      final (hc, hd, hl) = history[h];
      final hs = state.schedule[hc][hd][hl];
      if (hs == kFree) continue;
      final sameClassroom = hc == item.c;
      final sameTeacher   = _input.teacherOf[hs] == deadTeacher;
      if (sameClassroom || sameTeacher) {
        state.remove(hc, hd, hl);
        history.removeAt(h);
        undone.add((hc, hd, hl));
        count++;
      }
    }

    _backtrackCount++;

    // Re-sort affected pairs by MCF
    final affectedCs = undone.map((t) => t.$1).toSet()..add(item.c);
    for (var j = 0; j < pairs.length; j++) {
      if (affectedCs.contains(pairs[j].c)) {
        final avail = state.availableSlots(pairs[j].c, pairs[j].s).length;
        final dem   = state.remaining(pairs[j].c, pairs[j].s);
        pairs[j] = _WorkItem(
          c: pairs[j].c,
          s: pairs[j].s,
          slack: avail - dem,
          demand: dem,
        );
      }
    }
    pairs.sort((a, b) {
      final cmp = a.slack.compareTo(b.slack);
      return cmp != 0 ? cmp : b.demand.compareTo(a.demand);
    });

    // Try placing the deadlocked pair again
    final retry = _pickBestSlot(state, item.c, item.s);
    return retry != null;
  }
}

// ── Work item ─────────────────────────────────────────────────────────────────

class _WorkItem {
  final int c, s, slack, demand;
  _WorkItem({required this.c, required this.s,
             required this.slack, required this.demand});
}
