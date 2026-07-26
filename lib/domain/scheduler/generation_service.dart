// lib/domain/scheduler/generation_service.dart
//
// GenerationService is the single entry point called by the Schedule screen
// "Generate" button. It:
//   1. Loads all required Firestore data for the school
//   2. Runs pre-generation conflict detection (FR-HC-03)
//   3. Builds SchedulerInput via SchedulerInputBuilder
//   4. Spawns the scheduler isolate and streams progress
//   5. On success (ALGO-R03 passed): writes the ScheduleModel +
//      ScheduleCell documents to Firestore in a single batch (ALGO-R04)
//   6. On offline: saves to Firestore offline cache (FR-GEN-07)
//   7. Updates trialUsed flag if this was the user's free trial

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../../core/constants/app_constants.dart';
import '../../data/models/app_models.dart';
import '../../data/repositories/account_repository.dart';
import '../../data/repositories/constraint_repository.dart';
import '../../data/repositories/period_classroom_capacity_repositories.dart';
import '../../data/repositories/subject_repositories.dart';
import '../../data/services/subscription_service.dart';
import '../../providers/auth_providers.dart';
import '../constraints/constraint_conflict_detector.dart';
import 'scheduler_input.dart' as sched;
import 'scheduler_input_builder.dart';
import 'scheduler_isolate.dart';

// ── Generation state (drives the UI progress bar) ─────────────────────────

enum GenerationPhase {
  idle,
  loadingData,
  validating,
  generating,
  saving,
  done,
  error,
}

class GenerationState {
  final GenerationPhase phase;
  final double progress; // 0.0–1.0
  final int iterationsCompleted;
  final sched.ScheduleResult? result;
  final String? errorMessage;
  final List<ConflictResult> conflicts;

  const GenerationState({
    this.phase = GenerationPhase.idle,
    this.progress = 0.0,
    this.iterationsCompleted = 0,
    this.result,
    this.errorMessage,
    this.conflicts = const [],
  });

  GenerationState copyWith({
    GenerationPhase? phase,
    double? progress,
    int? iterationsCompleted,
    sched.ScheduleResult? result,
    String? errorMessage,
    List<ConflictResult>? conflicts,
  }) =>
      GenerationState(
        phase: phase ?? this.phase,
        progress: progress ?? this.progress,
        iterationsCompleted: iterationsCompleted ?? this.iterationsCompleted,
        result: result ?? this.result,
        errorMessage: errorMessage ?? this.errorMessage,
        conflicts: conflicts ?? this.conflicts,
      );
}

// ── Provider ──────────────────────────────────────────────────────────────

final generationServiceProvider =
    StateNotifierProvider.family<GenerationService, GenerationState, String>(
  (ref, schoolId) => GenerationService(ref, schoolId),
);

// ── Service ───────────────────────────────────────────────────────────────

class GenerationService extends StateNotifier<GenerationState> {
  final Ref _ref;
  final String _schoolId;
  SchedulerIsolateRunner? _runner;

  GenerationService(this._ref, this._schoolId) : super(const GenerationState());

  // ── Cancel ───────────────────────────────────────────────────────────────

  void cancel() => _runner?.cancel();

  // ── Main entry point ──────────────────────────────────────────────────────

  Future<void> generate({required String scheduleName}) async {
    state = const GenerationState(phase: GenerationPhase.loadingData);

    try {
      // ── 0. Subscription / trial gate ────────────────────────────────────
      final account = await _ref.read(accountRepositoryProvider).fetchAccount();
      final trialAlreadyUsed = account?.trialUsed ?? false;
      final subStateValue = _ref.read(subscriptionServiceProvider);
      final hasSubscription = subStateValue.value?.isActive ?? false;

      if (trialAlreadyUsed && !hasSubscription && !kDebugMode) {
        state = state.copyWith(
          phase: GenerationPhase.error,
          errorMessage: 'Subscription required. Your free trial has been used. '
              'Subscribe to generate new schedules.',
        );
        return;
      }

      // ── 1. Load all data ────────────────────────────────────────────────
      final uid = _ref.read(currentUserProvider)!.uid;

      final periods =
          await _ref.read(periodRepositoryProvider(_schoolId)).fetchAll();
      final classrooms =
          await _ref.read(classroomRepositoryProvider(_schoolId)).fetchAll();
      final subjects =
          await _ref.read(subjectRepositoryProvider(_schoolId)).fetchAll();
      final classroomSubjects = await _ref
          .read(classroomSubjectRepositoryProvider(_schoolId))
          .fetchAll();
      final dayCapacities =
          await _ref.read(dayCapacityRepositoryProvider(_schoolId)).fetchAll();
      final constraints =
          await _ref.read(constraintRepositoryProvider(_schoolId)).fetchAll();

      // ── 2. Derive active days ─────────────────────────────────────────────
      // FIX: Derive active days from dayCapacity records first, then fall back
      // to the default weekdays. This ensures the scheduler knows exactly which
      // days have been configured in Step 3.
      final activeDays = _deriveActiveDays(classrooms, dayCapacities, periods);

      if (activeDays.isEmpty) {
        state = state.copyWith(
          phase: GenerationPhase.error,
          errorMessage: 'No active school days found. '
              'Please configure periods in Setup → Step 1.',
        );
        return;
      }

      // ── 3. Pre-generation conflict detection (FR-HC-03) ─────────────────
      state = state.copyWith(phase: GenerationPhase.validating);

      final lessonPeriods = periods.where((p) => p.type == 'LESSON').toList()
        ..sort((a, b) => a.sortOrder.compareTo(b.sortOrder));

      if (lessonPeriods.isEmpty) {
        state = state.copyWith(
          phase: GenerationPhase.error,
          errorMessage: 'No lesson slots defined. '
              'Please add lesson slots in Setup → Step 1.',
        );
        return;
      }

      if (classrooms.isEmpty) {
        state = state.copyWith(
          phase: GenerationPhase.error,
          errorMessage: 'No classrooms defined. '
              'Please add classrooms in Setup → Step 2.',
        );
        return;
      }

      if (classroomSubjects.isEmpty) {
        state = state.copyWith(
          phase: GenerationPhase.error,
          errorMessage: 'No subjects assigned to classrooms. '
              'Please assign subjects in Setup → Step 4.',
        );
        return;
      }

      final Map<String, List<PeriodModel>> lessonsByDay = {};
      for (final d in activeDays) {
        lessonsByDay[d] = lessonPeriods;
      }

      final conflicts = ConstraintConflictDetector.detect(
        hardConstraints: constraints.where((c) => c.kind == 'HARD').toList(),
        periods: periods,
        subjects: subjects,
        classroomSubjects: classroomSubjects,
        lessonPeriodsPerDay: lessonsByDay,
      );

      if (conflicts.isNotEmpty) {
        state = state.copyWith(
          phase: GenerationPhase.error,
          conflicts: conflicts,
          errorMessage: '${conflicts.length} constraint conflict'
              '${conflicts.length == 1 ? '' : 's'} must be resolved '
              'before generating.',
        );
        return;
      }

      // ── 4. Build scheduler input ────────────────────────────────────────
      final input = SchedulerInputBuilder.build(
        activeDayCodes: activeDays,
        lessonPeriods: lessonPeriods,
        classrooms: classrooms,
        subjects: subjects,
        classroomSubjects: classroomSubjects,
        dayCapacities: dayCapacities,
        constraints: constraints,
      );

      // ── 5. Run scheduler isolate ────────────────────────────────────────
      state = state.copyWith(phase: GenerationPhase.generating, progress: 0.0);

      _runner = SchedulerIsolateRunner();
      _runner!.progressStream.listen((p) {
        state = state.copyWith(
          progress: p.fraction,
          iterationsCompleted: p.iterationsCompleted,
        );
      });

      final result = await _runner!.run(input);

      // ── 6. Save to Firestore (ALGO-R04) ─────────────────────────────────
      if (result.hardViolations.any((v) =>
          v.constraintId == 'INTERNAL' ||
          v.description.startsWith('[INTEGRITY'))) {
        state = state.copyWith(
          phase: GenerationPhase.error,
          result: result,
          errorMessage: 'Internal integrity check failed. '
              'Your previous schedule has not been modified.',
        );
        return;
      }

      state = state.copyWith(phase: GenerationPhase.saving, progress: 1.0);

      await _persistResult(
        uid: uid,
        input: input,
        result: result,
        scheduleName: scheduleName,
        periods: lessonPeriods,
        activeDays: activeDays,
      );

      // ── 7. Consume trial if applicable ───────────────────────────────────
      final accountData =
          await _ref.read(accountRepositoryProvider).fetchAccount();
      final trialUsed = accountData?.trialUsed ?? false;
      if (!trialUsed && !kDebugMode) {
        await _ref.read(accountRepositoryProvider).consumeTrial();
      }

      state = state.copyWith(
        phase: GenerationPhase.done,
        result: result,
      );
    } catch (e) {
      state = state.copyWith(
        phase: GenerationPhase.error,
        errorMessage: e.toString(),
      );
    } finally {
      _runner?.dispose();
      _runner = null;
    }
  }

  // ── Firestore persistence (ALGO-R04) ──────────────────────────────────────

  Future<void> _persistResult({
    required String uid,
    required sched.SchedulerInput input,
    required sched.ScheduleResult result,
    required String scheduleName,
    required List<PeriodModel> periods,
    required List<String> activeDays,
  }) async {
    final db = FirebaseFirestore.instance;

    final scheduleColRef = db
        .collection(AppConstants.fsUsers)
        .doc(uid)
        .collection(AppConstants.fsSchools)
        .doc(_schoolId)
        .collection(AppConstants.fsSchedules);

    final scheduleId = const Uuid().v4();
    final scheduleRef = scheduleColRef.doc(scheduleId);
    final cellsRef = scheduleRef.collection(AppConstants.fsScheduleCells);

    final scheduleDoc = {
      'id': scheduleId,
      'schoolId': _schoolId,
      'name': scheduleName,
      'generatedAt': FieldValue.serverTimestamp(),
      'isCancelled': result.isCancelled,
      'isManuallyEdited': false,
      'resultStatus': _statusString(result.status),
      'hardViolationCount': result.hardViolations.length,
      'softViolationCount': result.softViolations.length,
      'qualityScore': result.qualityScore,
      'teacherFreeHours': result.teacherFreeHours,
      'subjectChanges': result.subjectChanges,
    };

    await scheduleRef.set(scheduleDoc);

    final periodIdBySlot = {
      for (var i = 0; i < periods.length; i++) i: periods[i].id
    };
    final dayCodeByIdx = {
      for (var i = 0; i < activeDays.length; i++) i: activeDays[i]
    };

    final cellDocs = <Map<String, dynamic>>[];
    final cellIds = <String>[];

    for (var c = 0; c < input.numClassrooms; c++) {
      for (var d = 0; d < input.numDays; d++) {
        for (var l = 0; l < input.numSlots; l++) {
          final periodId = periodIdBySlot[l];
          if (periodId == null) continue;

          final sIdx = result.schedule[c][d][l];
          final cellId = '${input.classroomIds[c]}_${dayCodeByIdx[d]}_$l';
          final isViolation = result.hardViolations.any((v) {
            if (!v.description.contains(input.classroomNames[c])) return false;
            // HC-3 descriptions contain no day name — highlight empty cells of
            // the affected classroom to show where the missing lessons should go.
            if (v.constraintId == 'HC-3') return sIdx == sched.kFree;
            return v.description.contains(input.dayNames[d]);
          });

          cellIds.add(cellId);
          cellDocs.add({
            'scheduleId': scheduleId,
            'classroomId': input.classroomIds[c],
            'periodId': periodId,
            'subjectId':
                sIdx == sched.kFree ? null : input.subjectIds[sIdx],
            'isViolation': isViolation,
            'violationDescription': isViolation
                ? result.hardViolations
                    .where((v) =>
                        v.description.contains(input.classroomNames[c]))
                    .map((v) => v.description)
                    .join('; ')
                : null,
          });
        }
      }
    }

    const batchSize = 499;
    for (var start = 0; start < cellDocs.length; start += batchSize) {
      final end = (start + batchSize).clamp(0, cellDocs.length);
      final batch = db.batch();
      for (var i = start; i < end; i++) {
        batch.set(cellsRef.doc(cellIds[i]), cellDocs[i]);
      }
      await batch.commit();
    }
  }

  // ── _deriveActiveDays (FIXED) ─────────────────────────────────────────────
  //
  // Priority order:
  //   1. Days that appear in DayCapacity records (user explicitly configured)
  //   2. If NO capacity records exist at all (user skipped Step 3 entirely),
  //      fall back to the standard Mon–Fri default so generation can still run.
  //
  // This fixes the bug where classrooms whose Step-3 records only covered some
  // days caused the scheduler to silently drop lessons on unconfigured days,
  // producing HC-3 shortfalls that looked like algorithm bugs.
  List<String> _deriveActiveDays(
    List<ClassroomModel> classrooms,
    List<DayCapacityModel> capacities,
    List<PeriodModel> periods,
  ) {
    const ordered = ['MON', 'TUE', 'WED', 'THU', 'FRI', 'SAT', 'SUN'];

    // Collect all day codes that appear in any DayCapacity record
    final daysWithRecords = capacities.map((dc) => dc.dayOfWeek).toSet();

    if (daysWithRecords.isNotEmpty) {
      // Return only the days that have records, in calendar order
      return ordered.where(daysWithRecords.contains).toList();
    }

    // No capacity records at all — Step 3 was never visited.
    // Try to infer from period dayApplicability if set.
    final daysFromPeriods = <String>{};
    for (final p in periods) {
      if (p.dayApplicability != null && p.dayApplicability!.isNotEmpty) {
        daysFromPeriods.addAll(p.dayApplicability!);
      }
    }

    if (daysFromPeriods.isNotEmpty) {
      return ordered.where(daysFromPeriods.contains).toList();
    }

    // Ultimate fallback: standard school week
    return AppConstants.defaultActiveDays;
  }

  String _statusString(sched.ResultStatus s) {
    if (s == sched.ResultStatus.perfect) return 'PERFECT';
    if (s == sched.ResultStatus.softViolationsOnly) return 'SOFT_VIOLATIONS';
    return 'HARD_VIOLATIONS';
  }
}
