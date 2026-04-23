// lib/domain/scheduler/schedule_state.dart
//
// In-memory schedule representation used by both Phase 1 and Phase 2.
// All tracking structures are kept in sync atomically with every assignment
// or removal, giving O(1) constraint checks as required by ALGO-R01/R02.
//
// Data layout (§8.6.1):
//   schedule[c][d][l]           = subjectIdx (kFree = -1)
//   teacherSlotMap[(t,d,l)]     = classroomIdx (or -1 = free)  — HC-1
//   dailySubjectCount[c][s][d]  = lessons assigned             — HC-4, HC-5
//   dailyClassroomCount[c][d]   = total lessons assigned        — HC-2

import 'scheduler_input.dart';

class ScheduleState {
  final SchedulerInput input;

  // ── Primary schedule array ─────────────────────────────────────────────
  // schedule[c][d][l] = subjectIdx or kFree
  late final List<List<List<int>>> schedule;

  // ── HC-1: teacher slot occupancy ──────────────────────────────────────
  // Key: SchedulerInput.teacherSlotKey(t, d, l) → classroomIdx or -1
  late final Map<int, int> _teacherSlotMap;

  // ── HC-4 / HC-5: daily subject counts ─────────────────────────────────
  // Flat array indexed by c*S*D + s*D + d
  late final List<int> _dailySubjectCount;

  // ── HC-2: daily classroom lesson totals ───────────────────────────────
  // Flat array indexed by c*D + d
  late final List<int> _dailyClassroomCount;

  // ── Remaining demand per (c, s) pair ──────────────────────────────────
  late final List<int> _remaining; // c*S + s

  final int _C, _S, _D, _L;

  ScheduleState(this.input)
      : _C = input.numClassrooms,
        _S = input.numSubjects,
        _D = input.numDays,
        _L = input.numSlots {
    _init();
  }

  void _init() {
    schedule = List.generate(
      _C, (_) => List.generate(_D, (_) => List.filled(_L, kFree)));

    _teacherSlotMap = {};

    _dailySubjectCount = List.filled(_C * _S * _D, 0);
    _dailyClassroomCount = List.filled(_C * _D, 0);

    _remaining = List.generate(
      _C * _S,
      (i) => input.weeklyTarget[i ~/ _S][i % _S],
    );
  }

  // ── Clone ──────────────────────────────────────────────────────────────
  // Copies the three flat arrays only — no deep object allocation (§8.6.1).
  ScheduleState clone() {
    final copy = ScheduleState._empty(input);
    for (var c = 0; c < _C; c++)
      for (var d = 0; d < _D; d++) {
        for (var l = 0; l < _L; l++) {
          copy.schedule[c][d][l] = schedule[c][d][l];
      }
        }
    copy._teacherSlotMap.addAll(_teacherSlotMap);
    copy._dailySubjectCount.setAll(0, _dailySubjectCount);
    copy._dailyClassroomCount.setAll(0, _dailyClassroomCount);
    copy._remaining.setAll(0, _remaining);
    return copy;
  }

  ScheduleState._empty(this.input)
      : _C = input.numClassrooms,
        _S = input.numSubjects,
        _D = input.numDays,
        _L = input.numSlots {
    _init();
  }

  // ── Index helpers ──────────────────────────────────────────────────────

  int _dscIdx(int c, int s, int d) => c * _S * _D + s * _D + d;
  int _dccIdx(int c, int d)        => c * _D + d;
  int _remIdx(int c, int s)        => c * _S + s;

  // ── Accessors ──────────────────────────────────────────────────────────

  int dailySubjectCount(int c, int s, int d) =>
      _dailySubjectCount[_dscIdx(c, s, d)];

  int dailyClassroomCount(int c, int d) =>
      _dailyClassroomCount[_dccIdx(c, d)];

  int remaining(int c, int s) => _remaining[_remIdx(c, s)];

  int? teacherAt(int t, int d, int l) {
    final k = SchedulerInput.teacherSlotKey(t, d, l);
    return _teacherSlotMap[k];
  }

  bool isTeacherFree(int t, int d, int l) =>
      !_teacherSlotMap.containsKey(
          SchedulerInput.teacherSlotKey(t, d, l));

  // ── Assign ─────────────────────────────────────────────────────────────
  // Places subject s into (c, d, l). Caller must have validated HC-1..8 first.

  void assign(int c, int s, int d, int l) {
    assert(schedule[c][d][l] == kFree, 'Slot ($c,$d,$l) already occupied');
    schedule[c][d][l] = s;

    final t = input.teacherOf[s];
    _teacherSlotMap[SchedulerInput.teacherSlotKey(t, d, l)] = c;

    _dailySubjectCount[_dscIdx(c, s, d)]++;
    _dailyClassroomCount[_dccIdx(c, d)]++;
    _remaining[_remIdx(c, s)]--;
  }

  // ── Remove ─────────────────────────────────────────────────────────────

  void remove(int c, int d, int l) {
    final s = schedule[c][d][l];
    if (s == kFree) return;
    schedule[c][d][l] = kFree;

    final t = input.teacherOf[s];
    _teacherSlotMap.remove(SchedulerInput.teacherSlotKey(t, d, l));

    _dailySubjectCount[_dscIdx(c, s, d)]--;
    _dailyClassroomCount[_dccIdx(c, d)]--;
    _remaining[_remIdx(c, s)]++;
  }

  // ── HC checks (O(1) each) ──────────────────────────────────────────────

  /// HC-1: teacher free at (d, l)?
  bool checkHC1(int s, int d, int l) {
    final t = input.teacherOf[s];
    return isTeacherFree(t, d, l);
  }

  /// HC-2: classroom c not over daily capacity after +1 on day d?
  /// Uses activeSlotCount derived from blockedSlots.
  bool checkHC2(int c, int d) =>
      dailyClassroomCount(c, d) < input.activeSlotCount(c, d);

  /// Returns true if slot l is blocked for classroom c on day d.
  bool isBlocked(int c, int d, int l) => input.isBlocked(c, d, l);

  /// HC-4: subject s in classroom c on day d not over MaxDaily after +1?
  bool checkHC4(int c, int s, int d) =>
      dailySubjectCount(c, s, d) < input.maxDaily[c][s];

  /// HC-5: slot (d,l) is not forbidden for (c,s) by MUST-NOT-ASSIGN.
  bool checkHC7(int c, int s, int d, int l) =>
      !input.mustNotAssignKeys
          .contains(SchedulerInput.cellKey(c, s, d, l));

  /// HC-8: slot (c,d,l) is free (only one subject per slot per classroom).
  bool checkHC8(int c, int d, int l) => schedule[c][d][l] == kFree;

  /// Combined pre-assignment check for a candidate placement.
  /// Returns true if all hard constraints allow placing s at (c,d,l).
  bool canPlace(int c, int s, int d, int l) {
    if (isBlocked(c, d, l))    return false; // slot blocked by user
    if (!checkHC8(c, d, l))    return false; // slot occupied
    if (!checkHC1(s, d, l))    return false; // teacher conflict
    if (!checkHC2(c, d))       return false; // daily capacity
    if (!checkHC4(c, s, d))    return false; // max daily
    if (!checkHC7(c, s, d, l)) return false; // must-not-assign
    return true;
  }

  /// HC-5 check: after assigning, does MinDaily hold?
  /// Call AFTER assign() to verify the day's count is valid.
  /// A day is valid if count == 0 (subject absent) or count >= MinDaily.
  bool satisfiesMinDaily(int c, int s, int d) {
    final min   = input.minDaily[c][s];
    if (min == 0) return true;
    final count = dailySubjectCount(c, s, d);
    return count == 0 || count >= min;
  }

  /// Returns list of all available (d, l) pairs for (c, s).
  List<(int, int)> availableSlots(int c, int s) {
    final slots = <(int, int)>[];
    for (var d = 0; d < _D; d++) {
      for (var l = 0; l < _L; l++) {
        if (canPlace(c, s, d, l)) slots.add((d, l));
      }
    }
    return slots;
  }
}
