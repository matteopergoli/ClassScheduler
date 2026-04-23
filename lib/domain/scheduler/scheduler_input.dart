// lib/domain/scheduler/scheduler_input.dart
//
// SchedulerInput is the complete, self-contained description of a scheduling
// problem. It is built from Firestore models by SchedulerInputBuilder and
// passed into the Dart Isolate as a single serialisable object.
//
// All string IDs are converted to compact integer indices here so that the
// core algorithm works entirely with flat integer arrays (§8.6.1).

// ── Index constants ──────────────────────────────────────────────────────────

/// Sentinel: slot is unassigned (free).
const int kFree = -1;

// ── Immutable problem description ────────────────────────────────────────────

class SchedulerInput {
  // ── Dimensions ─────────────────────────────────────────────────────────
  final int numClassrooms; // |C|
  final int numSubjects;   // |S|  (includes a virtual "free" subject at index -1)
  final int numDays;       // |D|
  final int numSlots;      // |L| — lesson slots per day (same count every day)

  // ── Human-readable labels (for result reporting only) ──────────────────
  final List<String> classroomNames; // index → name
  final List<String> subjectNames;   // index → name
  final List<String> teacherNames;   // index → teacherName (one per subject)
  final List<String> dayNames;       // index → 'MON', 'TUE', …
  final List<String> slotLabels;     // index → 'HH:mm–HH:mm'

  // ── Firestore ID ↔ index maps (for writing ScheduleCells back) ─────────
  final List<String> classroomIds; // index → Firestore classroom ID
  final List<String> subjectIds;   // index → Firestore subject ID
  final List<String> periodIds;    // index → Firestore LESSON period ID
                                   // (same ordering as slotLabels)

  // ── Teacher index per subject (HC-1) ───────────────────────────────────
  // teacherOf[s] = teacher index t, where t is shared across subjects
  // taught by the same person.
  final List<int> teacherOf; // length = numSubjects

  // ── Weekly targets HC-3: weeklyTarget[c][s] ────────────────────────────
  // 0 means subject s is not assigned to classroom c.
  final List<List<int>> weeklyTarget;

  // ── Blocked slots HC-2: slotBlocked set ────────────────────────────────
  // Contains packed keys for every (c, d, l) triplet that is NOT available
  // for assignment.  A slot is available iff its key is absent from this set.
  // This replaces the old dailyCapacity[c][d] int and the firstLesson[c][d]
  // int, supporting arbitrary per-day gaps anywhere in the schedule.
  //
  // Key packing: slotBlockedKey(c, d, l) — uses the same formula as cellKey
  // but without the subject dimension (s is always 0 conceptually).
  //
  // dailyCapacity[c][d] (the COUNT of available slots) is derived on demand
  // via activeSlotCount(c, d).
  final Set<int> blockedSlots;

  // ── Per-subject daily limits ────────────────────────────────────────────
  // maxDaily[c][s] — HC-4
  // minDaily[c][s] — HC-5 (0 = disabled)
  final List<List<int>> maxDaily;
  final List<List<int>> minDaily;

  // ── Pre-assigned slots (MUST-ASSIGN HC-6) ──────────────────────────────
  // List of (classroomIdx, subjectIdx, dayIdx, slotIdx) tuples.
  final List<MustAssign> mustAssign;

  // ── Forbidden slots (MUST-NOT-ASSIGN HC-7) ─────────────────────────────
  // Stored as a Set for O(1) lookup: key = _key(c, s, d, l).
  final Set<int> mustNotAssignKeys;

  // ── Soft constraints ────────────────────────────────────────────────────
  final List<SoftConstraintInput> softConstraints;

  const SchedulerInput({
    required this.numClassrooms,
    required this.numSubjects,
    required this.numDays,
    required this.numSlots,
    required this.classroomNames,
    required this.subjectNames,
    required this.teacherNames,
    required this.dayNames,
    required this.slotLabels,
    required this.classroomIds,
    required this.subjectIds,
    required this.periodIds,
    required this.teacherOf,
    required this.weeklyTarget,
    required this.blockedSlots,
    required this.maxDaily,
    required this.minDaily,
    required this.mustAssign,
    required this.mustNotAssignKeys,
    required this.softConstraints,
  });

  // ── Key packing ─────────────────────────────────────────────────────────
  // Encodes (c, s, d, l) into a single int for Set/Map lookups.
  // Dimensions are bounded: c<10, s<20, d<7, l<16 → fits in 32 bits.
  static int cellKey(int c, int s, int d, int l) =>
      c * 20 * 7 * 16 + s * 7 * 16 + d * 16 + l;

  static int teacherSlotKey(int t, int d, int l) =>
      t * 7 * 16 + d * 16 + l;

  // ── Blocked-slot helpers ─────────────────────────────────────────────────

  /// Pack (c, d, l) for blockedSlots lookup.
  /// Uses c<10, d<7, l<16 so fits in 11 bits.
  static int slotBlockedKey(int c, int d, int l) =>
      c * 7 * 16 + d * 16 + l;

  /// True if slot l is unavailable for classroom c on day d.
  bool isBlocked(int c, int d, int l) =>
      blockedSlots.contains(slotBlockedKey(c, d, l));

  /// Number of available (non-blocked) slots for classroom c on day d.
  int activeSlotCount(int c, int d) {
    int count = 0;
    for (var l = 0; l < numSlots; l++) {
      if (!isBlocked(c, d, l)) count++;
    }
    return count;
  }
}

// ── Sub-types ────────────────────────────────────────────────────────────────

class MustAssign {
  final int c, s, d, l;
  const MustAssign(this.c, this.s, this.d, this.l);
}

class SoftConstraintInput {
  final SoftType type;
  final int subjectIdx;
  final int? dayIdx;       // null = any day
  final int? startSlotIdx; // AVOID_TIMESLOT
  final int? endSlotIdx;   // AVOID_TIMESLOT
  final int weight;        // 1 / 5 / 10

  const SoftConstraintInput({
    required this.type,
    required this.subjectIdx,
    this.dayIdx,
    this.startSlotIdx,
    this.endSlotIdx,
    required this.weight,
  });
}

enum SoftType { avoidTimeslot, preferBlock }

// ── Progress and result messages (sent across Isolate boundary) ──────────────

class ProgressUpdate {
  final double fraction; // 0.0–1.0
  final int iterationsCompleted;
  const ProgressUpdate(this.fraction, this.iterationsCompleted);
}

class CancelMessage {
  const CancelMessage();
}

// ── Result status ────────────────────────────────────────────────────────────

enum ResultStatus { perfect, softViolationsOnly, hardViolations }

// ── Violation record ─────────────────────────────────────────────────────────

class ConstraintViolation {
  final String constraintId;   // e.g. 'HC-3'
  final String description;    // plain English
  final String? suggestion;
  final bool isHard;

  const ConstraintViolation({
    required this.constraintId,
    required this.description,
    this.suggestion,
    required this.isHard,
  });
}

// ── Schedule result (returned from Isolate) ──────────────────────────────────

class ScheduleResult {
  /// schedule[c][d][l] = subjectIdx, or kFree.
  final List<List<List<int>>> schedule;

  final ResultStatus status;
  final bool isCancelled;
  final int teacherFreeHours;  // F1
  final int subjectChanges;    // F2
  final int softPenalty;       // F3
  final int qualityScore;      // 0–100
  final List<ConstraintViolation> hardViolations;
  final List<ConstraintViolation> softViolations;
  final Duration computationTime;
  final int iterationsCompleted;
  final int restartsUsed;

  const ScheduleResult({
    required this.schedule,
    required this.status,
    required this.isCancelled,
    required this.teacherFreeHours,
    required this.subjectChanges,
    required this.softPenalty,
    required this.qualityScore,
    required this.hardViolations,
    required this.softViolations,
    required this.computationTime,
    required this.iterationsCompleted,
    required this.restartsUsed,
  });
}
