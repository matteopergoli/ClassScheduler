// lib/domain/scheduler/scheduler_input_builder.dart
//
// Converts the raw Firestore model objects into a compact SchedulerInput
// with integer indices. Called on the UI isolate before spawning the
// scheduler isolate — all Firestore I/O must be complete before this runs.

import '../../core/constants/app_constants.dart';
import '../../data/models/app_models.dart';
import 'scheduler_input.dart';

class SchedulerInputBuilder {
  /// Build a [SchedulerInput] from fully-loaded Firestore collections.
  ///
  /// [activeDayCodes]   — ordered list of active day strings, e.g. ['MON',…,'FRI']
  /// [lessonPeriods]    — LESSON-type periods, sorted by sortOrder
  /// [classrooms]       — all classrooms for the school
  /// [subjects]         — all subjects for the school
  /// [classroomSubjects]— all classroom–subject assignment records
  /// [dayCapacities]    — all DayCapacity records
  /// [constraints]      — all constraints (hard + soft)
  static SchedulerInput build({
    required List<String>               activeDayCodes,
    required List<PeriodModel>          lessonPeriods,
    required List<ClassroomModel>       classrooms,
    required List<SubjectModel>         subjects,
    required List<ClassroomSubjectModel> classroomSubjects,
    required List<DayCapacityModel>     dayCapacities,
    required List<ConstraintModel>      constraints,
  }) {
    final C = classrooms.length;
    final S = subjects.length;
    final D = activeDayCodes.length;
    final L = lessonPeriods.length;

    // ── Index maps ─────────────────────────────────────────────────────────
    final classroomIdx = {for (var i = 0; i < C; i++) classrooms[i].id: i};
    final subjectIdx   = {for (var i = 0; i < S; i++) subjects[i].id:   i};
    final dayIdx       = {for (var i = 0; i < D; i++) activeDayCodes[i]: i};
    final periodIdx    = {for (var i = 0; i < L; i++) lessonPeriods[i].id: i};

    // ── Teacher indices ────────────────────────────────────────────────────
    // Multiple subjects taught by the same teacher share one teacher index.
    final teacherNameToIdx = <String, int>{};
    final teacherNames     = <String>[];
    final teacherOf        = List<int>.filled(S, 0);
    for (var s = 0; s < S; s++) {
      final name = subjects[s].teacherName;
      if (!teacherNameToIdx.containsKey(name)) {
        teacherNameToIdx[name] = teacherNames.length;
        teacherNames.add(name);
      }
      teacherOf[s] = teacherNameToIdx[name]!;
    }

    // ── Weekly targets ─────────────────────────────────────────────────────
    final weeklyTarget = List.generate(C, (_) => List<int>.filled(S, 0));
    final maxDaily     = List.generate(C, (_) => List<int>.filled(S, L));
    final minDaily     = List.generate(C, (_) => List<int>.filled(S, 0));

    for (final cs in classroomSubjects) {
      final c = classroomIdx[cs.classroomId];
      final s = subjectIdx[cs.subjectId];
      if (c == null || s == null) continue;
      weeklyTarget[c][s] = cs.weeklyTargetHours;
      maxDaily[c][s]     = cs.maxDailyHours;
      minDaily[c][s]     = cs.minDailyHours;
    }

    // ── Blocked slots ──────────────────────────────────────────────────────
    // Build the blockedSlots set: a key is added for every (c, d, l) that
    // is NOT in the classroom's activeSlots list for that day.
    // Default (no DayCapacity record): all slots are active — nothing blocked.
    final blockedSlots = <int>{};
    for (final dc in dayCapacities) {
      final c = classroomIdx[dc.classroomId];
      final d = dayIdx[dc.dayOfWeek];
      if (c == null || d == null) continue;
      final active = dc.activeSlots.toSet();
      for (var l = 0; l < L; l++) {
        if (!active.contains(l)) {
          blockedSlots.add(SchedulerInput.slotBlockedKey(c, d, l));
        }
      }
    }

    // ── MUST-ASSIGN ────────────────────────────────────────────────────────
    final mustAssignList = <MustAssign>[];
    for (final con in constraints) {
      if (con.type != 'MUST_ASSIGN') continue;
      final c = classroomIdx[con.classroomId];
      final s = subjectIdx[con.subjectId];
      final d = dayIdx[con.dayOfWeek];
      final l = periodIdx[con.periodId];
      if (c == null || s == null || d == null || l == null) continue;
      mustAssignList.add(MustAssign(c, s, d, l));
    }

    // ── MUST-NOT-ASSIGN ────────────────────────────────────────────────────
    final mustNotKeys = <int>{};
    for (final con in constraints) {
      if (con.type != 'MUST_NOT_ASSIGN') continue;
      final c = classroomIdx[con.classroomId];
      final s = subjectIdx[con.subjectId];
      final d = dayIdx[con.dayOfWeek];
      final l = periodIdx[con.periodId];
      if (c == null || s == null || d == null || l == null) continue;
      mustNotKeys.add(SchedulerInput.cellKey(c, s, d, l));
    }

    // ── Soft constraints ───────────────────────────────────────────────────
    final softList = <SoftConstraintInput>[];
    for (final con in constraints) {
      if (con.kind != 'SOFT') continue;
      final s = subjectIdx[con.subjectId];
      if (s == null) continue;

      final weight = switch (con.weight) {
        'HIGH'   => AppConstants.softWeightHigh,
        'LOW'    => AppConstants.softWeightLow,
        _        => AppConstants.softWeightMedium,
      };

      if (con.type == 'AVOID_TIMESLOT') {
        final d    = con.dayOfWeek != null ? dayIdx[con.dayOfWeek] : null;
        final lStart = periodIdx[con.periodId];
        final lEnd   = periodIdx[con.endPeriodId];
        if (lStart == null || lEnd == null) continue;
        softList.add(SoftConstraintInput(
          type:         SoftType.avoidTimeslot,
          subjectIdx:   s,
          dayIdx:       d,
          startSlotIdx: lStart,
          endSlotIdx:   lEnd,
          weight:       weight,
        ));
      } else if (con.type == 'PREFER_BLOCK') {
        softList.add(SoftConstraintInput(
          type:       SoftType.preferBlock,
          subjectIdx: s,
          weight:     weight,
        ));
      }
    }

    return SchedulerInput(
      numClassrooms:    C,
      numSubjects:      S,
      numDays:          D,
      numSlots:         L,
      classroomNames:   classrooms.map((c) => c.name).toList(),
      subjectNames:     subjects.map((s) => s.name).toList(),
      teacherNames:     teacherNames,
      dayNames:         activeDayCodes,
      slotLabels:       lessonPeriods
          .map((p) => '${p.startTime}–${p.endTime}')
          .toList(),
      classroomIds:     classrooms.map((c) => c.id).toList(),
      subjectIds:       subjects.map((s) => s.id).toList(),
      periodIds:        lessonPeriods.map((p) => p.id).toList(),
      teacherOf:        teacherOf,
      weeklyTarget:     weeklyTarget,
      blockedSlots:     blockedSlots,
      maxDaily:         maxDaily,
      minDaily:         minDaily,
      mustAssign:       mustAssignList,
      mustNotAssignKeys: mustNotKeys,
      softConstraints:  softList,
    );
  }
}
