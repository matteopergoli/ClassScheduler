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
  static const _debugEnabled = true;

  // Cross-classroom teacher contention: a teacher's own weekly slack is
  // (total slots in the week) − (their combined committed hours across
  // ALL classrooms). Teachers with the least slack (e.g. shared across
  // multiple classrooms with tight targets, zero-slack exact-cover setups)
  // must be scheduled first, or they get boxed out by less-contended pairs.
  late final List<int> _teacherSlackBySubject = _computeTeacherSlacks();

  List<int> _computeTeacherSlacks() {
    final numTeachers = _input.teacherNames.length;
    final totalTeacherSlots = _input.numDays * _input.numSlots;
    final committed = List<int>.filled(numTeachers, 0);
    for (var c = 0; c < _input.numClassrooms; c++) {
      for (var s = 0; s < _input.numSubjects; s++) {
        committed[_input.teacherOf[s]] += _input.weeklyTarget[c][s];
      }
    }
    return List<int>.generate(_input.numSubjects,
        (s) => totalTeacherSlots - committed[_input.teacherOf[s]]);
  }

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

    // HC-5 repair loop: for zero-slack / tightly-coupled cases (shared
    // teachers across classrooms, exact weekly-target-to-capacity fits),
    // a single repair pass often just shifts the MinDaily-parity problem
    // to a different day rather than resolving it. Iterate the
    // remove-partial → re-greedy → displacement sequence until it
    // stabilises (no more shortfall change) or a small iteration cap.
    var previousShortfall = -1;
    for (var pass = 0; pass < 5; pass++) {
      _removePartialMinDailyViolations(state);
      final passPairs = _buildMcfOrder(state);
      if (passPairs.isNotEmpty) {
        _assignAll(state, passPairs, violations);
      }
      _removePartialMinDailyViolations(state);
      _repairWithDisplacement(state);
      _removePartialMinDailyViolations(state);
      _repairMinDailyChain(state);
      _removePartialMinDailyViolations(state);

      var shortfall = 0;
      for (var c = 0; c < _input.numClassrooms; c++) {
        for (var s = 0; s < _input.numSubjects; s++) {
          shortfall += state.remaining(c, s);
        }
      }
      _debug('Repair pass $pass: shortfall=$shortfall');
      if (shortfall == 0 || shortfall == previousShortfall) break;
      previousShortfall = shortfall;
    }

    // Reconcile: recompute violations from actual remaining demand.
    // The greedy loop may leave (c,s) pairs with remaining > 0 unrecorded
    // when backtracking re-sorts them to positions before the loop index.
    violations.clear();
    for (var c = 0; c < _input.numClassrooms; c++) {
      for (var s = 0; s < _input.numSubjects; s++) {
        final rem = state.remaining(c, s);
        if (rem > 0) {
          violations.add(PartialViolation(
            classroomIdx: c,
            subjectIdx:   s,
            shortfall:    rem,
          ));
        }
      }
    }

    // Diagnostic dump for any remaining shortfall: shows exactly which
    // days the affected subject is currently placed on, in EVERY classroom
    // it teaches (not just the one with the shortfall), plus its teacher's
    // combined free/busy slots for the affected classroom's days. Also
    // dumps the SAME breakdown for every OTHER subject sharing those
    // classrooms — the block-relocation repair's matching ceiling (e.g.
    // "4/5") means some other subject's own placement is the actual
    // blocker, and we need to see its schedule too to find out which one
    // and why. This is unconditional (not gated by _debugEnabled) so it
    // always surfaces in the run console when generation fails.
    if (violations.isNotEmpty) {
      print('[Phase1] === MinDaily/HC-3 shortfall diagnostic dump ===');
      final affectedSubjects = violations.map((v) => v.subjectIdx).toSet();
      final affectedClassrooms = violations.map((v) => v.classroomIdx).toSet();

      void dumpSubject(int s) {
        final teacherIdx = _input.teacherOf[s];
        print('[Phase1] Subject "${_input.subjectNames[s]}" '
            '(teacher "${_input.teacherNames[teacherIdx]}"):');
        for (var c = 0; c < _input.numClassrooms; c++) {
          final target = _input.weeklyTarget[c][s];
          if (target == 0) continue;
          final minD = _input.minDaily[c][s];
          final maxD = _input.maxDaily[c][s];
          final rem = state.remaining(c, s);
          final perDay = <String>[];
          for (var d = 0; d < _input.numDays; d++) {
            perDay.add('${_input.dayNames[d]}=${state.dailySubjectCount(c, s, d)}');
          }
          print('[Phase1]   classroom "${_input.classroomNames[c]}": '
              'target=$target minD=$minD maxD=$maxD remaining=$rem  '
              '[${perDay.join(", ")}]');
        }
        for (var c = 0; c < _input.numClassrooms; c++) {
          if (_input.weeklyTarget[c][s] == 0) continue;
          for (var d = 0; d < _input.numDays; d++) {
            final freeSlots = <int>[];
            for (var l = 0; l < _input.numSlots; l++) {
              if (state.isTeacherFree(teacherIdx, d, l)) freeSlots.add(l);
            }
            print('[Phase1]   teacher free slots on ${_input.dayNames[d]} '
                '(any classroom): $freeSlots');
          }
          break; // day list is the same regardless of which classroom c we read from
        }
      }

      for (final s in affectedSubjects) {
        dumpSubject(s);
      }

      print('[Phase1] --- other subjects sharing the affected classroom(s) ---');
      final otherSubjects = <int>{};
      for (final c in affectedClassrooms) {
        for (var s = 0; s < _input.numSubjects; s++) {
          if (affectedSubjects.contains(s)) continue;
          if (_input.weeklyTarget[c][s] > 0) otherSubjects.add(s);
        }
      }
      for (final s in otherSubjects) {
        dumpSubject(s);
      }
      print('[Phase1] === end diagnostic dump ===');
    }

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
        items.add(_WorkItem(
          c: c, s: s, slack: slack, demand: demand,
          teacherSlack: _teacherSlackBySubject[s],
        ));
      }
    }

    // Primary: least teacher-wide slack first (busiest / most shared
    // teacher across classrooms gets placed before it's boxed out).
    // Secondary: original MCF — ascending pair slack, ties by demand desc.
    items.sort((a, b) {
      final tCmp = a.teacherSlack.compareTo(b.teacherSlack);
      if (tCmp != 0) return tCmp;
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
        } else {
          // Backtrack re-sorted pairs; undone pairs may now be at positions
          // before i. Reset to the start so they are retried in the new order.
          i = 0;
        }
        // Whether or not backtrack resolved things, re-evaluate from current i
        continue;
      }

      state.assign(c, s, best.$1, best.$2);

      // HC-5 post-assignment check: if this day now has 1..(minDaily-1)
      // lessons and there are no more free slots on this day to reach minDaily,
      // undo the placement and retry — a different day will be chosen next time.
      final minD = _input.minDaily[c][s];
      if (minD > 0 && !state.satisfiesMinDaily(c, s, best.$1)) {
        final freeLeft = _countRawFreeSlotsOnDay(state, c, s, best.$1);
        final countNow = state.dailySubjectCount(c, s, best.$1);
        final needed   = minD - countNow;
        if (needed > freeLeft) {
          // Can't reach minDaily on this day — undo and retry same pair.
          // The HC-5 tentative check in _pickBestSlot will reject this slot.
          state.remove(c, best.$1, best.$2);
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

  // Slots scoring within this margin of the best are treated as
  // "comparably good" and picked among uniformly at random, rather than
  // only randomizing on an exact (1e-9) tie. The old exact-tie threshold
  // meant every one of Phase1's 40 retries (each with a different RNG
  // seed, see scheduler_engine.dart) walked the *identical* greedy path
  // whenever there was any clear best-scoring slot at each step — which is
  // almost always, since real inputs rarely produce exact float ties. For
  // tight/zero-slack cases that need a specific placement order to find
  // the (existing) feasible packing, that collapsed 40 "different" seeds
  // into 40 runs of the same deterministic failure. The margin is wide
  // enough to absorb the tie-break term (±~0.11 max, see below) without
  // conflating the +5/+10/±1000 heuristic bonuses, which still dominate.
  static const _slotScoreMargin = 1.5;

  (int, int)? _pickBestSlot(ScheduleState state, int c, int s) {
    final remaining = state.remaining(c, s);
    final minD = _input.minDaily[c][s];
    // Soft DAILY_LIMIT preferred max for (c,s), if any. Steers construction
    // toward a distributed week so Phase 2 doesn't start from a fully-piled
    // state that F2 (subject-change minimisation) then actively defends.
    final softMax = _softMaxDailyFor(c, s);
    final candidates = <(int, int, double)>[];

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
            final freeOnDay = _countRawFreeSlotsOnDay(state, c, s, d);
            state.remove(c, d, l);
            final needed = minD - currentCount;
            if (needed > freeOnDay) continue; // can't reach minDaily → skip
            // Otherwise allow it (more assignments may still fill the day)
          } else {
            state.remove(c, d, l);
          }
        }

        var score = 0.0;
        final dayCount = state.dailySubjectCount(c, s, d);

        // +10 if adjacent to an existing same-subject slot (promotes blocks),
        // but only while the day is still under its soft daily max — build a
        // block of the preferred size, don't stack the whole weekly quota.
        if (_hasAdjacentSame(state, c, s, d, l) &&
            (softMax == null || dayCount < softMax.max)) {
          score += 10;
        }

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

        // Escalating penalty once the day already holds >= the soft daily
        // max for this subject. Dwarfs the +10/+5 clustering bonuses so the
        // greedy spreads across days, but stays below the ±1000 MinDaily
        // term (HC-5 must never yield to a soft preference) — hence the cap.
        if (softMax != null && dayCount >= softMax.max) {
          final over = dayCount - softMax.max + 1;
          score -= (20.0 * softMax.weight * over).clamp(0.0, 900.0);
        }

        // Subtract soft constraint penalty for AVOID_TIMESLOT violations
        score -= _softPenalty(s, d, l);

        // Tie-break: prefer earlier slots
        final tieBreak = -(d * _input.numSlots + l) * 0.001;
        score += tieBreak;

        candidates.add((d, l, score));
      }
    }

    if (candidates.isEmpty) {
      _debug('No available slot for c=$c s=$s remaining=$remaining');
      return null;
    }

    final bestScore = candidates.fold(
        double.negativeInfinity, (best, e) => max(best, e.$3));
    final nearBest = candidates
        .where((e) => bestScore - e.$3 <= _slotScoreMargin)
        .toList();
    final (d, l, _) = nearBest[_rng.nextInt(nearBest.length)];
    return (d, l);
  }

  // Counts slots on day d that are physically available for (c,s) using
  // only local checks (HC-1/2/4/7/8) — NOT the global capacity check.
  // Used exclusively for HC-5 (minDaily) completability decisions.
  int _countRawFreeSlotsOnDay(ScheduleState state, int c, int s, int d) {
    var count = 0;
    for (var l = 0; l < _input.numSlots; l++) {
      if (_input.isBlocked(c, d, l))   continue;
      if (!state.checkHC8(c, d, l))    continue; // slot must be free
      if (!state.checkHC1(s, d, l))    continue; // teacher must be free
      if (!state.checkHC2(c, d))       continue; // classroom daily capacity
      if (!state.checkHC4(c, s, d))    continue; // max daily
      if (!state.checkHC7(c, s, d, l)) continue; // must-not-assign
      count++;
    }
    return count;
  }

  // Removes lessons from days where a subject has a partial minDaily count
  // (0 < count < minDaily) that can no longer be completed. This repairs
  // HC-5 violations left by the greedy pass so freed lessons can be
  // reassigned to valid days in the second pass.
  void _removePartialMinDailyViolations(ScheduleState state) {
    for (var c = 0; c < _input.numClassrooms; c++) {
      for (var s = 0; s < _input.numSubjects; s++) {
        final minD = _input.minDaily[c][s];
        if (minD <= 1) continue;
        for (var d = 0; d < _input.numDays; d++) {
          final count = state.dailySubjectCount(c, s, d);
          if (count == 0 || count >= minD) continue;
          // Partial day: check if we can still complete it.
          final needed    = minD - count;
          final freeSlots = _countRawFreeSlotsOnDay(state, c, s, d);
          if (freeSlots < needed) {
            // Can't complete — remove partial lessons so they can be
            // reassigned elsewhere in the second pass.
            for (var l = 0; l < _input.numSlots; l++) {
              if (state.schedule[c][d][l] == s) state.remove(c, d, l);
            }
          }
        }
      }
    }
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

  // ── Displacement repair ────────────────────────────────────────────────────
  //
  // For pairs that are nearly complete (remaining ≤ 3), try to insert the
  // missing lessons by displacing an occupying subject to a free slot, thereby
  // making room for the missing lesson. Handles deadlocks that backtracking
  // with N steps cannot resolve (e.g. when all free slots are occupied by
  // subjects that CAN be moved elsewhere).

  void _repairWithDisplacement(ScheduleState state) {
    for (var c = 0; c < _input.numClassrooms; c++) {
      for (var s = 0; s < _input.numSubjects; s++) {
        if (state.remaining(c, s) <= 0) continue;
        if (state.remaining(c, s) > 3) continue; // only for nearly-complete pairs
        while (state.remaining(c, s) > 0 &&
               _tryDisplacementPlace(state, c, s)) { /* placed one */ }
      }
    }
  }

  bool _tryDisplacementPlace(ScheduleState state, int c, int s) {
    final minD = _input.minDaily[c][s];

    // Step 1: direct placement (no displacement needed)
    for (var d = 0; d < _input.numDays; d++) {
      for (var l = 0; l < _input.numSlots; l++) {
        if (!state.canPlace(c, s, d, l)) continue;
        state.assign(c, s, d, l);
        if (minD > 1 && !state.satisfiesMinDaily(c, s, d)) {
          state.remove(c, d, l);
          continue;
        }
        return true;
      }
    }

    // Step 2: displacement — temporarily remove the occupant of each slot,
    // check if (c,s,d,l) becomes viable, then find a new home for the occupant.
    for (var d = 0; d < _input.numDays; d++) {
      for (var l = 0; l < _input.numSlots; l++) {
        final sp = state.schedule[c][d][l];
        if (sp == kFree) continue;
        final minDsp = _input.minDaily[c][sp];

        state.remove(c, d, l); // sp floating

        // Can s go here once sp is moved?
        if (!state.canPlace(c, s, d, l)) {
          state.assign(c, sp, d, l); // restore
          continue;
        }
        // Tentative HC-5 check for s
        state.assign(c, s, d, l);
        final sOk = minD <= 1 || state.satisfiesMinDaily(c, s, d);
        state.remove(c, d, l); // undo tentative
        if (!sOk) {
          state.assign(c, sp, d, l); // restore sp
          continue;
        }

        // Find a new slot for sp
        var displaced = false;
        outer:
        for (var d2 = 0; d2 < _input.numDays; d2++) {
          for (var l2 = 0; l2 < _input.numSlots; l2++) {
            if (state.schedule[c][d2][l2] != kFree) continue;
            if (!state.canPlace(c, sp, d2, l2)) continue;

            state.assign(c, sp, d2, l2);

            // HC-5 for sp: original day d and new day d2 must be valid
            if (minDsp > 1 && !state.satisfiesMinDaily(c, sp, d)) {
              state.remove(c, d2, l2); continue;
            }
            if (minDsp > 1 && !state.satisfiesMinDaily(c, sp, d2)) {
              state.remove(c, d2, l2); continue;
            }

            // Can s still go at (d, l) with sp at (d2, l2)?
            if (!state.canPlace(c, s, d, l)) {
              state.remove(c, d2, l2); continue;
            }
            state.assign(c, s, d, l);
            if (minD > 1 && !state.satisfiesMinDaily(c, s, d)) {
              state.remove(c, d, l);
              state.remove(c, d2, l2); continue;
            }
            displaced = true;
            break outer;
          }
        }

        if (!displaced) state.assign(c, sp, d, l); // restore sp
        if (displaced) return true;
      }
    }

    return false;
  }

  // ── MinDaily block-relocation repair ────────────────────────────────────
  //
  // Handles the "last-mile" MinDaily trap: a subject s has remaining < minD,
  // meaning the outstanding lesson(s) can only legally land on a day where s
  // currently has zero lessons — but placing them alone there would violate
  // MinDaily, and in a zero-slack schedule there's no spare free slot on
  // that day to complete the pair.
  //
  // A single-donor-slot chain isn't enough when EVERY day s appears on is
  // sitting at exactly minD (no day has a slot to spare on its own). This
  // repair instead relocates an ENTIRE day's block of s (any day with
  // count >= minD — donating all of it always leaves the source day valid,
  // since 0 is allowed) onto the target day, combined with the outstanding
  // new lesson(s), evicting as many occupants from the target day as
  // needed into the slots the whole block just vacated. This subsumes the
  // single-slot case (block of exactly minD, 0 or 1 evictions) while also
  // reaching multi-eviction cases a single donor slot never could.
  // All steps are validated with canPlace/satisfiesMinDaily before
  // committing; any failure fully rolls back before trying the next
  // candidate (target day, source day) combination.

  void _repairMinDailyChain(ScheduleState state) {
    for (var c = 0; c < _input.numClassrooms; c++) {
      for (var s = 0; s < _input.numSubjects; s++) {
        final minD = _input.minDaily[c][s];
        if (minD <= 1) continue;
        final remaining = state.remaining(c, s);
        if (remaining <= 0 || remaining >= minD) continue;

        for (var d = 0; d < _input.numDays; d++) {
          if (state.dailySubjectCount(c, s, d) != 0) continue;
          if (_tryMinDailyBlockRelocate(state, c, s, d, remaining)) break;
        }
      }
    }
  }

  bool _tryMinDailyBlockRelocate(
      ScheduleState state, int c, int s, int d, int remainingBefore) {
    final minD = _input.minDaily[c][s];
    final maxD = _input.maxDaily[c][s];
    print('[Phase1] BlockRelocate: trying target c=$c s=$s d=$d '
        'remaining=$remainingBefore minD=$minD maxD=$maxD');

    for (var sd = 0; sd < _input.numDays; sd++) {
      if (sd == d) continue;
      final blockCount = state.dailySubjectCount(c, s, sd);
      if (blockCount < minD) continue; // not a whole valid donor block

      final totalOnTarget = blockCount + remainingBefore;
      if (totalOnTarget > maxD) {
        print('[Phase1] BlockRelocate:   source=$sd block=$blockCount '
            'REJECT totalOnTarget=$totalOnTarget > maxD=$maxD');
        continue; // would exceed MaxDaily on target
      }

      final blockSlots = <int>[];
      for (var l = 0; l < _input.numSlots; l++) {
        if (state.schedule[c][sd][l] == s) blockSlots.add(l);
      }
      var blocked = false;
      for (final l in blockSlots) {
        if (_isMustAssignSlot(c, sd, l)) {
          blocked = true;
          break;
        }
      }
      if (blocked) {
        print('[Phase1] BlockRelocate:   source=$sd REJECT must-assign in block');
        continue;
      }

      final freeOnD = <int>[];
      for (var l = 0; l < _input.numSlots; l++) {
        if (state.schedule[c][d][l] == kFree && !_input.isBlocked(c, d, l)) {
          freeOnD.add(l);
        }
      }
      final shortfall = totalOnTarget - freeOnD.length;
      print('[Phase1] BlockRelocate:   source=$sd block=$blockCount '
          'totalOnTarget=$totalOnTarget freeOnD=${freeOnD.length} '
          'shortfall=$shortfall');
      if (shortfall > blockCount) {
        print('[Phase1] BlockRelocate:   source=$sd REJECT shortfall=$shortfall '
            '> blockCount=$blockCount');
        continue; // freed block can't cover it
      }

      // Remove the whole block from the source day (0 is always valid).
      for (final l in blockSlots) {
        state.remove(c, sd, l);
      }
      if (!state.satisfiesMinDaily(c, s, sd)) {
        print('[Phase1] BlockRelocate:   source=$sd REJECT donor day invalid '
            'after removal (should not happen)');
        for (final l in blockSlots) state.assign(c, s, sd, l);
        continue;
      }

      // Evict as many target-day occupants as needed into the freed slots.
      //
      // This is a bipartite matching problem (evictees × donor slots).
      // Greedy first-fit assignment can leave one evictee unmatched even
      // when a valid perfect matching exists — e.g. evictee A greedily
      // takes the only slot evictee B could have used, when B should have
      // taken it and A could have used a different slot. Use Kuhn's
      // augmenting-path algorithm instead, which always finds a maximum
      // matching if edges (occ, donorSlot) are validated correctly.
      final evictees = <(int subject, int slot)>[];
      for (var l = 0; l < _input.numSlots; l++) {
        final occ = state.schedule[c][d][l];
        if (occ == kFree || occ == s) continue;
        if (_isMustAssignSlot(c, d, l)) continue;
        evictees.add((occ, l));
      }

      final evictionsNeeded = shortfall > 0 ? shortfall : 0;
      final donorSlotsList = List<int>.from(blockSlots);

      // edgeOk(evicteeIdx, donorIdx): tentatively move occ to the donor
      // slot, check validity, then immediately undo — used only to probe
      // the edge, never left committed.
      bool edgeOk(int evicteeIdx, int donorIdx) {
        final (occ, srcSlot) = evictees[evicteeIdx];
        final donorSlot = donorSlotsList[donorIdx];
        state.remove(c, d, srcSlot);
        var ok = state.canPlace(c, occ, sd, donorSlot);
        if (ok) {
          state.assign(c, occ, sd, donorSlot);
          ok = state.satisfiesMinDaily(c, occ, d) &&
               state.satisfiesMinDaily(c, occ, sd);
          state.remove(c, sd, donorSlot);
        }
        state.assign(c, occ, d, srcSlot); // always restore after probing
        return ok;
      }

      final slotTaken = List<int>.filled(donorSlotsList.length, -1);

      bool tryMatch(int evicteeIdx, List<bool> visited) {
        for (var di = 0; di < donorSlotsList.length; di++) {
          if (visited[di]) continue;
          if (!edgeOk(evicteeIdx, di)) continue;
          visited[di] = true;
          if (slotTaken[di] == -1 || tryMatch(slotTaken[di], visited)) {
            slotTaken[di] = evicteeIdx;
            return true;
          }
        }
        return false;
      }

      var matchedCount = 0;
      final matchedEvictee = List<bool>.filled(evictees.length, false);
      for (var i = 0; i < evictees.length; i++) {
        if (tryMatch(i, List<bool>.filled(donorSlotsList.length, false))) {
          matchedCount++;
          matchedEvictee[i] = true;
        }
      }

      final evicted = <(int, int, int)>[]; // (subject, fromSlotOnD, toSlotOnSd)

      if (matchedCount < evictionsNeeded) {
        print('[Phase1] BlockRelocate:   source=$sd REJECT matching found '
            'only $matchedCount/$evictionsNeeded valid evictions on d=$d');
        for (var i = 0; i < evictees.length; i++) {
          final (occ, slot) = evictees[i];
          print('[Phase1] BlockRelocate:     evictee subject=$occ '
              '(from d=$d slot=$slot) matched=${matchedEvictee[i]}');
        }
        _rollbackBlockRelocate(state, c, s, sd, d, blockSlots, evicted, const []);
        continue;
      }

      // Commit the matching for real.
      for (var di = 0; di < donorSlotsList.length; di++) {
        final evicteeIdx = slotTaken[di];
        if (evicteeIdx == -1) continue;
        final (occ, srcSlot) = evictees[evicteeIdx];
        final donorSlot = donorSlotsList[di];
        state.remove(c, d, srcSlot);
        state.assign(c, occ, sd, donorSlot);
        evicted.add((occ, srcSlot, donorSlot));
      }


      // Place the relocated block + outstanding lesson(s) onto day d.
      final slotsOnD = <int>[];
      for (var l = 0; l < _input.numSlots; l++) {
        if (state.schedule[c][d][l] == kFree && !_input.isBlocked(c, d, l)) {
          slotsOnD.add(l);
        }
      }
      if (slotsOnD.length < totalOnTarget) {
        print('[Phase1] BlockRelocate:   source=$sd REJECT slotsOnD='
            '${slotsOnD.length} < totalOnTarget=$totalOnTarget after eviction');
        _rollbackBlockRelocate(state, c, s, sd, d, blockSlots, evicted, const []);
        continue;
      }

      final placedOnD = <int>[];
      var placeFailed = false;
      for (var i = 0; i < totalOnTarget; i++) {
        if (!state.canPlace(c, s, d, slotsOnD[i])) {
          placeFailed = true;
          print('[Phase1] BlockRelocate:   source=$sd REJECT canPlace failed '
              'for s=$s at d=$d slot=${slotsOnD[i]}');
          break;
        }
        state.assign(c, s, d, slotsOnD[i]);
        placedOnD.add(slotsOnD[i]);
      }

      if (placeFailed || !state.satisfiesMinDaily(c, s, d)) {
        if (!placeFailed) {
          print('[Phase1] BlockRelocate:   source=$sd REJECT final '
              'satisfiesMinDaily check failed on target d=$d');
        }
        _rollbackBlockRelocate(state, c, s, sd, d, blockSlots, evicted, placedOnD);
        continue;
      }

      _debug('MinDaily block relocation succeeded: c=$c s=$s source=$sd '
          '(block=$blockCount) -> target=$d (total=$totalOnTarget), '
          'evicted=${evicted.length}');
      return true;
    }

    return false;
  }

  void _rollbackBlockRelocate(
    ScheduleState state,
    int c,
    int s,
    int sd,
    int d,
    List<int> blockSlots,
    List<(int, int, int)> evicted,
    List<int> placedOnD,
  ) {
    for (final l in placedOnD) {
      state.remove(c, d, l);
    }
    for (final e in evicted) {
      final occ = e.$1, originalSlotOnD = e.$2, landedSlotOnSd = e.$3;
      state.remove(c, sd, landedSlotOnSd);
      state.assign(c, occ, d, originalSlotOnD);
    }
    for (final l in blockSlots) {
      state.assign(c, s, sd, l);
    }
  }

  bool _isMustAssignSlot(int c, int d, int l) {
    for (final ma in _input.mustAssign) {
      if (ma.c == c && ma.d == d && ma.l == l) return true;
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

  /// Most restrictive soft DAILY_LIMIT max for (c, s), with the weight of the
  /// constraint that set it, or null if no soft max applies. DAILY_LIMIT
  /// constraints always carry a classroomIdx, but tolerate a null scope too.
  ({int max, int weight})? _softMaxDailyFor(int c, int s) {
    int? best;
    var weight = 0;
    for (final sc in _input.softConstraints) {
      if (sc.type != SoftType.dailyLimit) continue;
      if (sc.subjectIdx != s) continue;
      if (sc.classroomIdx != null && sc.classroomIdx != c) continue;
      final m = sc.softMaxDaily;
      if (m == null) continue;
      if (best == null || m < best) {
        best = m;
        weight = sc.weight;
      }
    }
    final b = best;
    return b == null ? null : (max: b, weight: weight);
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
          teacherSlack: pairs[j].teacherSlack,
        );
      }
    }
    pairs.sort((a, b) {
      final tCmp = a.teacherSlack.compareTo(b.teacherSlack);
      if (tCmp != 0) return tCmp;
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
  final int c, s, slack, demand, teacherSlack;
  _WorkItem({required this.c, required this.s,
             required this.slack, required this.demand,
             required this.teacherSlack});
}
