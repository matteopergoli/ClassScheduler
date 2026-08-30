// test/helpers/scheduler_fixtures.dart
//
// Reusable SchedulerInput builders for all ALG-T and AC scheduling tests.
// Each factory method returns a fully-specified SchedulerInput so individual
// tests can focus on assertion, not setup.

import 'package:classscheduler/domain/scheduler/scheduler_input.dart';

// ── Trivial: 2 classrooms, 2 subjects, 3 days, 4 slots (ALG-T01) ──────────

SchedulerInput trivialInput() {
  const C = 2; // classrooms
  const S = 2; // subjects
  const D = 3; // days
  const L = 4; // slots per day

  return SchedulerInput(
    numClassrooms: C,
    numSubjects:   S,
    numDays:       D,
    numSlots:      L,
    classroomNames: ['Room A', 'Room B'],
    subjectNames:   ['Maths', 'English'],
    teacherNames:   ['Alice', 'Bob'],
    dayNames:       ['MON', 'TUE', 'WED'],
    slotLabels:     ['08:00', '09:00', '10:00', '11:00'],
    classroomIds:   ['cr0', 'cr1'],
    subjectIds:     ['s0', 's1'],
    periodIds:      ['p0', 'p1', 'p2', 'p3'],
    // Different teachers per subject → no HC-1 conflict possible
    teacherOf:      [0, 1],
    // Each classroom gets 1 Maths + 1 English per week  (×2 classrooms)
    weeklyTarget: [
      [1, 1], // Room A: 1 Maths, 1 English
      [1, 1], // Room B: 1 Maths, 1 English
    ],
    blockedSlots: {},
    maxDaily:      List.generate(C, (_) => List.filled(S, L)),
    minDaily:      List.generate(C, (_) => List.filled(S, 0)),
    mustAssign:         [],
    mustNotAssignKeys:  {},
    softConstraints:    [],
  );
}

// ── MUST-ASSIGN: forces Room A Maths to Mon slot 0 (ALG-T02) ──────────────

SchedulerInput mustAssignInput() {
  final base = trivialInput();
  return SchedulerInput(
    numClassrooms: base.numClassrooms,
    numSubjects:   base.numSubjects,
    numDays:       base.numDays,
    numSlots:      base.numSlots,
    classroomNames: base.classroomNames,
    subjectNames:   base.subjectNames,
    teacherNames:   base.teacherNames,
    dayNames:       base.dayNames,
    slotLabels:     base.slotLabels,
    classroomIds:   base.classroomIds,
    subjectIds:     base.subjectIds,
    periodIds:      base.periodIds,
    teacherOf:      base.teacherOf,
    weeklyTarget:   base.weeklyTarget,
    blockedSlots:   base.blockedSlots,
    maxDaily:       base.maxDaily,
    minDaily:       base.minDaily,
    mustAssign: [
      const MustAssign(0, 0, 0, 0), // Room A, Maths, Mon, slot 0
    ],
    mustNotAssignKeys: {},
    softConstraints: [],
  );
}

// ── Contradictory constraints: MUST-ASSIGN + MUST-NOT-ASSIGN (ALG-T03) ────

SchedulerInput contradictoryInput() {
  final base = trivialInput();
  final mustNotKey = SchedulerInput.cellKey(0, 0, 0, 0);
  return SchedulerInput(
    numClassrooms: base.numClassrooms,
    numSubjects:   base.numSubjects,
    numDays:       base.numDays,
    numSlots:      base.numSlots,
    classroomNames: base.classroomNames,
    subjectNames:   base.subjectNames,
    teacherNames:   base.teacherNames,
    dayNames:       base.dayNames,
    slotLabels:     base.slotLabels,
    classroomIds:   base.classroomIds,
    subjectIds:     base.subjectIds,
    periodIds:      base.periodIds,
    teacherOf:      base.teacherOf,
    weeklyTarget:   base.weeklyTarget,
    blockedSlots:   base.blockedSlots,
    maxDaily:       base.maxDaily,
    minDaily:       base.minDaily,
    mustAssign: [
      const MustAssign(0, 0, 0, 0), // MUST-ASSIGN Room A, Maths, Mon, slot 0
    ],
    mustNotAssignKeys: {mustNotKey}, // MUST-NOT-ASSIGN same cell → conflict
    softConstraints: [],
  );
}

// ── Over-constrained: weekly targets exceed available slots (ALG-T04) ─────

SchedulerInput overConstrainedInput() {
  // 1 classroom, 1 subject, 1 day, 2 slots — but weekly target = 5
  return const SchedulerInput(
    numClassrooms: 1,
    numSubjects:   1,
    numDays:       1,
    numSlots:      2,
    classroomNames: ['Room A'],
    subjectNames:   ['Maths'],
    teacherNames:   ['Alice'],
    dayNames:       ['MON'],
    slotLabels:     ['08:00', '09:00'],
    classroomIds:   ['cr0'],
    subjectIds:     ['s0'],
    periodIds:      ['p0', 'p1'],
    teacherOf:      [0],
    weeklyTarget:   [[5]], // impossible: only 2 slots available
    blockedSlots:  {},
    maxDaily:       [[5]],
    minDaily:       [[0]],
    mustAssign:        [],
    mustNotAssignKeys: {},
    softConstraints:   [],
  );
}

// ── MinDaily=2 MaxDaily=3 (ALG-T05) ────────────────────────────────────────
// 1 classroom, 1 subject, 3 days, 4 slots per day
// weeklyTarget = 6 (2 per day across 3 days)

SchedulerInput minDailyInput() {
  return const SchedulerInput(
    numClassrooms: 1,
    numSubjects:   1,
    numDays:       3,
    numSlots:      4,
    classroomNames: ['Room A'],
    subjectNames:   ['Maths'],
    teacherNames:   ['Alice'],
    dayNames:       ['MON', 'TUE', 'WED'],
    slotLabels:     ['08:00', '09:00', '10:00', '11:00'],
    classroomIds:   ['cr0'],
    subjectIds:     ['s0'],
    periodIds:      ['p0', 'p1', 'p2', 'p3'],
    teacherOf:      [0],
    weeklyTarget:   [[6]],
    blockedSlots:  {},
    maxDaily:       [[3]], // HC-4
    minDaily:       [[2]], // HC-5
    mustAssign:        [],
    mustNotAssignKeys: {},
    softConstraints:   [],
  );
}

// ── SOFT CONSTRAINT: avoid Maths after slot 5 (ALG-T11) ───────────────────

SchedulerInput softConstraintInput() {
  // 1 classroom, 1 subject, 3 days, 8 slots
  return SchedulerInput(
    numClassrooms: 1,
    numSubjects:   1,
    numDays:       3,
    numSlots:      8,
    classroomNames: ['Room A'],
    subjectNames:   ['English'],
    teacherNames:   ['Alice'],
    dayNames:       ['MON', 'TUE', 'WED'],
    slotLabels: [
      '08:00','09:00','10:00','11:00',
      '12:00','13:00','14:00','15:00',
    ],
    classroomIds:  ['cr0'],
    subjectIds:    ['s0'],
    periodIds: ['p0','p1','p2','p3','p4','p5','p6','p7'],
    teacherOf:     [0],
    weeklyTarget:  [[3]], // 3 lessons per week
    blockedSlots: {},
    maxDaily:      [[8]],
    minDaily:      [[0]],
    mustAssign:        [],
    mustNotAssignKeys: {},
    softConstraints: [
      // Avoid slots 5–7 (14:00 onward) for subject 0
      const SoftConstraintInput(
        type:         SoftType.avoidTimeslot,
        subjectIdx:   0,
        dayIdx:       null, // any day
        startSlotIdx: 5,
        endSlotIdx:   7,
        weight:       10,
      ),
    ],
  );
}

// ── SOFT DAILY_LIMIT: spread a subject across the week (ALG-T16) ───────────
// 1 classroom, 1 subject, 5 days, 6 slots. weeklyTarget = 10, hard MaxDaily
// = 6 (so piling is *possible*), but a soft DAILY_LIMIT prefers ≤ 2 per day.
// A perfect spread (2 per day × 5 days) exists with zero violations, so the
// optimiser should reach it rather than stacking 6 on one day to minimise
// F2 subject changes.

SchedulerInput dailyLimitSoftInput() {
  return SchedulerInput(
    numClassrooms: 1,
    numSubjects:   1,
    numDays:       5,
    numSlots:      6,
    classroomNames: ['Room A'],
    subjectNames:   ['Maths'],
    teacherNames:   ['Alice'],
    dayNames:       ['MON', 'TUE', 'WED', 'THU', 'FRI'],
    slotLabels: [
      '08:00', '09:00', '10:00', '11:00', '12:00', '13:00',
    ],
    classroomIds:  ['cr0'],
    subjectIds:    ['s0'],
    periodIds:     ['p0', 'p1', 'p2', 'p3', 'p4', 'p5'],
    teacherOf:     [0],
    weeklyTarget:  [[10]],
    blockedSlots: {},
    maxDaily:      [[6]], // hard cap loose enough to allow a lopsided week
    minDaily:      [[0]],
    mustAssign:        [],
    mustNotAssignKeys: {},
    softConstraints: [
      // Prefer at most 2 Maths per day (high weight).
      const SoftConstraintInput(
        type:         SoftType.dailyLimit,
        subjectIdx:   0,
        weight:       10,
        classroomIdx: 0,
        softMaxDaily: 2,
      ),
    ],
  );
}

// ── Maximum configuration: 10 classrooms, 10 subjects (ALG-T06) ───────────

SchedulerInput maxConfigInput() {
  const C = 10;
  const S = 10;
  const D = 5;
  const L = 8;

  // Subjects 0–4 share teacher 0 (same person teaches them all is intentional
  // stress test for HC-1). Subjects 5–9 have unique teachers 1–5.
  final teacherOf = [
    0, 1, 2, 3, 4, 5, 6, 7, 8, 9, // each subject gets own teacher
  ];

  // Each classroom gets 4 slots per subject per week (×10 subjects = 40 slots)
  // with 5 days × 8 slots = 40 capacity → exactly tight
  final weeklyTarget = List.generate(C,
      (_) => List.filled(S, 4));
  final maxDaily = List.generate(C,
      (_) => List.filled(S, 2)); // max 2 per day per subject
  final minDaily = List.generate(C,
      (_) => List.filled(S, 0));

  return SchedulerInput(
    numClassrooms: C,
    numSubjects:   S,
    numDays:       D,
    numSlots:      L,
    classroomNames: List.generate(C, (i) => 'Room ${i + 1}'),
    subjectNames:   List.generate(S, (i) => 'Subject ${i + 1}'),
    teacherNames:   List.generate(S, (i) => 'Teacher ${i + 1}'),
    dayNames:       ['MON', 'TUE', 'WED', 'THU', 'FRI'],
    slotLabels:     List.generate(L, (i) => '${8 + i}:00'),
    classroomIds:   List.generate(C, (i) => 'cr$i'),
    subjectIds:     List.generate(S, (i) => 's$i'),
    periodIds:      List.generate(L, (i) => 'p$i'),
    teacherOf:      teacherOf,
    weeklyTarget:   weeklyTarget,
    blockedSlots:  {},
    maxDaily:       maxDaily,
    minDaily:       minDaily,
    mustAssign:        [],
    mustNotAssignKeys: {},
    softConstraints:   [],
  );
}

// ── Injected HC-1 violation (for ALGO-R03 test, ALG-T07) ──────────────────
// Returns a trivial input but also exposes how to build a corrupted state.
// The actual state corruption is done in the test itself using ScheduleState.

SchedulerInput integrityCheckInput() => trivialInput();

// ── Phase-1 deadlock resolvable by backtracking (ALG-T12) ─────────────────
// Two classrooms share one teacher. The teacher can only teach 1 slot per day.
// If the greedy assigns both on the same slot, it must backtrack.

SchedulerInput deadlockInput() {
  // 2 classrooms, 1 subject (same teacher), 2 days, 2 slots
  // Target: 1 lesson per classroom per week
  return const SchedulerInput(
    numClassrooms: 2,
    numSubjects:   1,
    numDays:       2,
    numSlots:      2,
    classroomNames: ['Room A', 'Room B'],
    subjectNames:   ['Maths'],
    teacherNames:   ['Alice'],
    dayNames:       ['MON', 'TUE'],
    slotLabels:     ['08:00', '09:00'],
    classroomIds:   ['cr0', 'cr1'],
    subjectIds:     ['s0'],
    periodIds:      ['p0', 'p1'],
    teacherOf:      [0], // Both classrooms share teacher 0
    weeklyTarget:   [[1], [1]],
    blockedSlots:  {},
    maxDaily:       [[1], [1]],
    minDaily:       [[0], [0]],
    mustAssign:        [],
    mustNotAssignKeys: {},
    softConstraints:   [],
  );
}

// ── CROSS-CLASS SWAP: two classrooms two different subjects (ALG-T14) ──────

SchedulerInput crossClassInput() {
  // 2 classrooms, 2 subjects (different teachers), 3 days, 4 slots
  return SchedulerInput(
    numClassrooms: 2,
    numSubjects:   2,
    numDays:       3,
    numSlots:      4,
    classroomNames: ['Room A', 'Room B'],
    subjectNames:   ['Maths', 'English'],
    teacherNames:   ['Alice', 'Bob'],
    dayNames:       ['MON', 'TUE', 'WED'],
    slotLabels:     ['08:00', '09:00', '10:00', '11:00'],
    classroomIds:   ['cr0', 'cr1'],
    subjectIds:     ['s0', 's1'],
    periodIds:      ['p0', 'p1', 'p2', 'p3'],
    teacherOf:      [0, 1],
    weeklyTarget:   [[2, 2], [2, 2]],
    blockedSlots:  {},
    maxDaily:       List.generate(2, (_) => List.filled(2, 2)),
    minDaily:       List.generate(2, (_) => List.filled(2, 0)),
    mustAssign:        [],
    mustNotAssignKeys: {},
    softConstraints:   [],
  );
}
