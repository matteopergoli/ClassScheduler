// lib/domain/validation/subject_validator.dart
//
// FR-SUB-06: Validates ClassroomSubject assignment fields before saving.
// All three error conditions must produce plain-language messages (§5.3).

import '../../data/models/app_models.dart';

enum SubjectValidationError {
  minGtMax,
  maxDaysInsufficient,
  weeklyExceedsSlots,
  weeklyMustBePositive,
}

class SubjectValidationResult {
  final bool isValid;
  final List<SubjectValidationError> errors;
  const SubjectValidationResult._(this.isValid, this.errors);
  factory SubjectValidationResult.ok() =>
      const SubjectValidationResult._(true, []);
  factory SubjectValidationResult.fail(List<SubjectValidationError> errs) =>
      SubjectValidationResult._(false, errs);
}

class SubjectValidator {
  /// Validates a ClassroomSubject assignment.
  ///
  /// [activeDayCount]   — number of active school days (e.g. 5 for Mon–Fri)
  /// [totalLessonSlots] — total LESSON slots available for this classroom
  ///                      across the whole week (sum of H[c,d] for all d)
  static SubjectValidationResult validate({
    required int weeklyTarget,
    required int minDaily,
    required int maxDaily,
    required int activeDayCount,
    required int totalLessonSlots,
  }) {
    final errors = <SubjectValidationError>[];

    // Rule 1: weekly target must be > 0
    if (weeklyTarget <= 0) {
      errors.add(SubjectValidationError.weeklyMustBePositive);
    }

    // Rule 2: MinDaily ≤ MaxDaily (when MinDaily > 0)
    if (minDaily > 0 && minDaily > maxDaily) {
      errors.add(SubjectValidationError.minGtMax);
    }

    // Rule 3: MaxDaily × activeDays ≥ weeklyTarget
    if (maxDaily * activeDayCount < weeklyTarget) {
      errors.add(SubjectValidationError.maxDaysInsufficient);
    }

    // Rule 4: weeklyTarget ≤ total available lesson slots
    if (weeklyTarget > totalLessonSlots) {
      errors.add(SubjectValidationError.weeklyExceedsSlots);
    }

    return errors.isEmpty
        ? SubjectValidationResult.ok()
        : SubjectValidationResult.fail(errors);
  }

  /// Returns a localisation key string for each error.
  /// The UI resolves these against AppLocalizations.
  static String errorKey(SubjectValidationError error) {
    switch (error) {
      case SubjectValidationError.minGtMax:
        return 'validationMinGtMax';
      case SubjectValidationError.maxDaysInsufficient:
        return 'validationMaxDaysInsufficient';
      case SubjectValidationError.weeklyExceedsSlots:
        return 'validationWeeklyExceedsSlots';
      case SubjectValidationError.weeklyMustBePositive:
        return 'validationWeeklyMustBePositive';
    }
  }
}

// ── Feasibility estimator (FR-SUB-04) ─────────────────────────────────────────
//
// Computes a per-CLASSROOM weekly feasibility check:
//
//   available[c] = total active lesson slots for classroom c across the week
//                  (sum of activeSlots.length over all active days)
//   needed[c]    = sum of weeklyTargetHours for all subjects assigned to c
//   slack[c]     = available[c] − needed[c]
//
// A per-day breakdown would be misleading because weekly targets are not
// pinned to specific days — the same 20 weekly lessons could legally all
// fall on Monday if constraints permit. The only meaningful question is
// whether the classroom has enough total slots in the week to fit all
// its assigned subjects.
//
// A slack < 0 means there are not enough lessons to fill the timetable slots.
//
//   needed    = slots that MUST be filled = sum of active slots from Step 3
//   available = lessons that CAN fill them = sum of weeklyTargetHours (Step 4)
//   slack     = available - needed
//               > 0 → more lessons than slots (some lessons unschedulable — also bad)
//               = 0 → perfect fit
//               < 0 → fewer lessons than slots (timetable will have empty slots)

class FeasibilityClassroom {
  final String classroomId;
  final String classroomName;
  final int    needed;    // slots to fill: sum of active slots from Step 3
  final int    available; // lessons to place: sum of weeklyTargetHours from Step 4
  // slack = available - needed
  // negative → not enough lessons to fill the timetable (error)
  int  get slack      => available - needed;
  bool get isCritical => slack < 0;

  const FeasibilityClassroom({
    required this.classroomId,
    required this.classroomName,
    required this.needed,
    required this.available,
  });
}

// Keep FeasibilityDay as a thin alias so the call site in step4 that passes
// dayCapacities to FeasibilityEstimator.estimate() still compiles unchanged.
// It is no longer used directly by the UI — _FeasibilityPanel now uses
// FeasibilityClassroom rows instead.
@Deprecated('Use FeasibilityEstimator.estimateByClassroom instead')
class FeasibilityDay {
  final String dayCode;
  final int available;
  final int needed;
  int  get slack      => available - needed;
  bool get isCritical => slack < 0;
  const FeasibilityDay({
    required this.dayCode,
    required this.available,
    required this.needed,
  });
}

class FeasibilityEstimator {
  /// Per-classroom weekly feasibility check.
  ///
  /// [classroomNames]   — Map<classroomId, name>
  /// [totalSlotsByClassroom] — Map<classroomId, total active slots across week>
  ///                           (already computed in Step 4 screen with fallback)
  /// [classroomSubjects]— all ClassroomSubject assignments
  static List<FeasibilityClassroom> estimateByClassroom({
    required Map<String, String> classroomNames,
    required Map<String, int>    totalSlotsByClassroom,
    required List<ClassroomSubjectModel> classroomSubjects,
  }) {
    // Group weekly demand by classroom
    final Map<String, int> neededByClassroom = {};
    for (final cs in classroomSubjects) {
      neededByClassroom[cs.classroomId] =
          (neededByClassroom[cs.classroomId] ?? 0) + cs.weeklyTargetHours;
    }

    // Build one row per classroom that has either slots or demand
    final allClassroomIds = {
      ...totalSlotsByClassroom.keys,
      ...neededByClassroom.keys,
    };

    return allClassroomIds.map((id) {
      return FeasibilityClassroom(
        classroomId:   id,
        classroomName: classroomNames[id] ?? id,
        needed:        totalSlotsByClassroom[id] ?? 0, // slots to fill (Step 3)
        available:     neededByClassroom[id]     ?? 0, // lessons to place (Step 4)
      );
    }).toList()
      ..sort((a, b) => a.classroomName.compareTo(b.classroomName));
  }

  /// Legacy per-day estimate — kept for API compatibility but no longer used
  /// by the UI. Replaced by [estimateByClassroom].
  @Deprecated('Use estimateByClassroom instead')
  static List<FeasibilityDay> estimate({
    required Map<String, Map<String, int>> dayCapacities,
    required List<ClassroomSubjectModel> classroomSubjects,
    required List<String> activeDays,
  }) {
    final int activeDayCount = activeDays.length;
    if (activeDayCount == 0) return [];
    final int totalWeeklyDemand =
        classroomSubjects.fold(0, (sum, cs) => sum + cs.weeklyTargetHours);
    final double dailyDemandApprox = totalWeeklyDemand / activeDayCount;
    return activeDays.map((day) {
      int available = 0;
      dayCapacities.forEach((classroomId, dayMap) {
        available += dayMap[day] ?? 0;
      });
      // ignore: deprecated_member_use_from_same_package
      return FeasibilityDay(
        dayCode: day, available: available,
        needed: dailyDemandApprox.ceil(),
      );
    }).toList();
  }
}
