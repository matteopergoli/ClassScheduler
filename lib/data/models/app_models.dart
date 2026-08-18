// lib/data/models/app_models.dart
//
// All Firestore entity models.  Each class maps 1:1 to a Firestore document.
// Generated code (*.freezed.dart, *.g.dart) is produced by:
//   flutter pub run build_runner build --delete-conflicting-outputs
//
// IMPORTANT: run build_runner after any schema change.

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'app_models.freezed.dart';
part 'app_models.g.dart';

// ─── Timestamp converter ───────────────────────────────────────────────────
class TimestampConverter implements JsonConverter<DateTime, Object?> {
  const TimestampConverter();
  @override
  DateTime fromJson(Object? value) {
    if (value is Timestamp) return value.toDate();
    if (value is DateTime) return value;
    return DateTime.now();
  }

  @override
  Object? toJson(DateTime dt) => Timestamp.fromDate(dt);
}

class NullableTimestampConverter
    implements JsonConverter<DateTime?, Object?> {
  const NullableTimestampConverter();
  @override
  DateTime? fromJson(Object? value) {
    if (value is Timestamp) return value.toDate();
    if (value is DateTime) return value;
    return null;
  }

  @override
  Object? toJson(DateTime? dt) =>
      dt == null ? null : Timestamp.fromDate(dt);
}

// ─── Account (/users/{uid}/account) ───────────────────────────────────────
@freezed
class AccountModel with _$AccountModel {
  const factory AccountModel({
    required bool trialUsed,
    @NullableTimestampConverter() DateTime? trialUsedAt,
    @TimestampConverter() required DateTime createdAt,
  }) = _AccountModel;

  factory AccountModel.fromJson(Map<String, dynamic> json) =>
      _$AccountModelFromJson(json);
}

// ─── School ────────────────────────────────────────────────────────────────
@freezed
class SchoolModel with _$SchoolModel {
  const factory SchoolModel({
    required String id,
    required String name,
    String? description,
    @TimestampConverter() required DateTime createdAt,
    @TimestampConverter() required DateTime updatedAt,
  }) = _SchoolModel;

  factory SchoolModel.fromJson(Map<String, dynamic> json) =>
      _$SchoolModelFromJson(json);
}

// ─── Period ────────────────────────────────────────────────────────────────
/// type values: 'LESSON' | 'BREAK'
/// dayApplicability: null in v1.0 (all active days).
///   In v2.0: List<String> of day codes e.g. ['MON','TUE'] (§7.2)
@freezed
class PeriodModel with _$PeriodModel {
  const factory PeriodModel({
    required String id,
    required String schoolId,
    required String type, // 'LESSON' | 'BREAK'
    String? name,         // required for BREAK, optional for LESSON
    required String startTime, // 'HH:mm'
    required String endTime,   // 'HH:mm'
    required int sortOrder,
    List<String>? dayApplicability, // null = all days (v1.0)
  }) = _PeriodModel;

  factory PeriodModel.fromJson(Map<String, dynamic> json) =>
      _$PeriodModelFromJson(json);
}

// ─── DayCapacity ───────────────────────────────────────────────────────────
/// Document ID: '{classroomId}_{dayOfWeek}' e.g. 'abc123_MON'
///
/// activeSlots — ordered list of 0-based lesson-slot indices that are
/// available for assignment on this day.  e.g. [0,1,3,4] means slots 0,1
/// are active, slot 2 is blocked, slots 3,4 are active.
///
/// Backwards compatibility: legacy documents that stored maxLessons (int)
/// instead of activeSlots are handled by [DayCapacityModel.fromLegacy].
/// The repository's fromJson always calls fromLegacy so old data is
/// silently migrated on read without a Firestore write.
@freezed
class DayCapacityModel with _$DayCapacityModel {
  const factory DayCapacityModel({
    required String      schoolId,
    required String      classroomId,
    required String      dayOfWeek,    // 'MON'|'TUE'|'WED'|'THU'|'FRI'|'SAT'|'SUN'
    required List<int>   activeSlots,  // ordered, 0-based lesson-slot indices
  }) = _DayCapacityModel;

  /// Standard Firestore deserialisation — new schema only.
  /// Use [fromLegacy] when reading from Firestore so old documents are
  /// handled gracefully.
  factory DayCapacityModel.fromJson(Map<String, dynamic> json) =>
      _$DayCapacityModelFromJson(json);

  /// Reads a Firestore document that may be in either the old schema
  /// (maxLessons: int) or the new schema (activeSlots: List<int>).
  /// Old documents are converted: activeSlots = [0, 1, …, maxLessons-1].
  /// [totalLessonSlots] is only needed for the legacy path.
  static DayCapacityModel fromLegacy(
    Map<String, dynamic> data, {
    int? totalLessonSlots,
  }) {
    if (data.containsKey('activeSlots')) {
      // New schema. Firestore always returns arrays as List<dynamic>,
      // so we cast each element to int manually instead of relying on
      // the freezed-generated fromJson which expects List<int> directly.
      final raw = data['activeSlots'];
      final List<int> slots = raw is List
          ? raw.map((e) => (e as num).toInt()).toList()
          : <int>[];
      return DayCapacityModel(
        schoolId:    data['schoolId']    as String,
        classroomId: data['classroomId'] as String,
        dayOfWeek:   data['dayOfWeek']   as String,
        activeSlots: slots,
      );
    }
    // Legacy schema (document has maxLessons: int, no activeSlots field).
    // Use maxLessons directly — it was a valid count when written.
    // Optionally clamp to totalLessonSlots if the caller provides it.
    final maxLessons = (data['maxLessons'] as int?) ?? 0;
    final count = totalLessonSlots != null
        ? maxLessons.clamp(0, totalLessonSlots)
        : maxLessons;
    return DayCapacityModel(
      schoolId:    data['schoolId']    as String,
      classroomId: data['classroomId'] as String,
      dayOfWeek:   data['dayOfWeek']   as String,
      activeSlots: List<int>.generate(count, (i) => i),
    );
  }

  /// Derives the Firestore document ID from classroomId and dayOfWeek.
  static String docId(String classroomId, String dayOfWeek) =>
      '${classroomId}_${dayOfWeek}';
}

// ─── Classroom ─────────────────────────────────────────────────────────────
@freezed
class ClassroomModel with _$ClassroomModel {
  const factory ClassroomModel({
    required String id,
    required String schoolId,
    required String name,
    required int sortOrder,
  }) = _ClassroomModel;

  factory ClassroomModel.fromJson(Map<String, dynamic> json) =>
      _$ClassroomModelFromJson(json);
}

// ─── Subject ───────────────────────────────────────────────────────────────
/// teacherId is null in v1.0 (reserved for v2.0 multi-teacher).
@freezed
class SubjectModel with _$SubjectModel {
  const factory SubjectModel({
    required String id,
    required String schoolId,
    required String name,
    required String teacherName,
    String? teacherId,   // null in v1.0; FK to Teacher collection in v2.0
    required String colourHex, // e.g. '#6C63FF'
  }) = _SubjectModel;

  factory SubjectModel.fromJson(Map<String, dynamic> json) =>
      _$SubjectModelFromJson(json);
}

// ─── ClassroomSubject ──────────────────────────────────────────────────────
/// Per-classroom, per-subject weekly targets and daily limits.
@freezed
class ClassroomSubjectModel with _$ClassroomSubjectModel {
  const factory ClassroomSubjectModel({
    required String id,          // Firestore doc ID
    required String classroomId,
    required String subjectId,
    required int weeklyTargetHours,
    @Default(0) int minDailyHours, // 0 = disabled
    required int maxDailyHours,
  }) = _ClassroomSubjectModel;

  factory ClassroomSubjectModel.fromJson(Map<String, dynamic> json) =>
      _$ClassroomSubjectModelFromJson(json);
}

// ─── Constraint ────────────────────────────────────────────────────────────
/// kind: 'HARD' | 'SOFT'
/// type: 'MUST_ASSIGN' | 'MUST_NOT_ASSIGN' | 'AVOID_TIMESLOT' | 'PREFER_BLOCK'
///     | 'DAILY_LIMIT'
/// Inapplicable fields are stored as null (see §3.6 note).
///
/// DAILY_LIMIT (SOFT only) is a preference version of the hard daily-hours
/// limit already carried unconditionally on ClassroomSubjectModel
/// (minDailyHours/maxDailyHours, HC-4/HC-5). A HARD daily limit is edited
/// directly on that assignment; a SOFT one is a ConstraintModel like any
/// other soft rule, penalised (not blocked) by the scheduler — see
/// SoftType.dailyLimit in scheduler_input.dart.
@freezed
class ConstraintModel with _$ConstraintModel {
  const factory ConstraintModel({
    required String id,
    required String schoolId,
    required String kind,   // 'HARD' | 'SOFT'
    required String type,   // 'MUST_ASSIGN' | 'MUST_NOT_ASSIGN' |
                            // 'AVOID_TIMESLOT' | 'PREFER_BLOCK' | 'DAILY_LIMIT'
    String? classroomId,
    String? subjectId,
    String? dayOfWeek,
    String? periodId,
    String? endPeriodId,    // AVOID_TIMESLOT only
    String? weight,         // 'LOW' | 'MEDIUM' | 'HIGH' (SOFT only)
    int? minHours,          // DAILY_LIMIT only (0/null = no minimum)
    int? maxHours,          // DAILY_LIMIT only
  }) = _ConstraintModel;

  factory ConstraintModel.fromJson(Map<String, dynamic> json) =>
      _$ConstraintModelFromJson(json);
}

// ─── Schedule ──────────────────────────────────────────────────────────────
/// resultStatus: 'PERFECT' | 'SOFT_VIOLATIONS' | 'HARD_VIOLATIONS'
@freezed
class ScheduleModel with _$ScheduleModel {
  const factory ScheduleModel({
    required String id,
    required String schoolId,
    required String name,
    @TimestampConverter() required DateTime generatedAt,
    @Default(false) bool isCancelled,
    @Default(false) bool isManuallyEdited,
    required String resultStatus, // 'PERFECT'|'SOFT_VIOLATIONS'|'HARD_VIOLATIONS'
    @Default(0) int hardViolationCount,
    @Default(0) int softViolationCount,
    @Default(0) int qualityScore,   // 0-100
    @Default(0) int teacherFreeHours,
    @Default(0) int subjectChanges,
  }) = _ScheduleModel;

  factory ScheduleModel.fromJson(Map<String, dynamic> json) =>
      _$ScheduleModelFromJson(json);
}

// ─── ScheduleCell ──────────────────────────────────────────────────────────
/// periodId references a LESSON Period only (never a BREAK).
/// subjectId is null for a free slot.
@freezed
class ScheduleCellModel with _$ScheduleCellModel {
  const factory ScheduleCellModel({
    required String id,
    required String scheduleId,
    required String classroomId,
    required String periodId,    // LESSON Period Firestore ID
    String? subjectId,           // null = free slot
    @Default(false) bool isViolation,
    String? violationDescription,
  }) = _ScheduleCellModel;

  factory ScheduleCellModel.fromJson(Map<String, dynamic> json) =>
      _$ScheduleCellModelFromJson(json);
}

// ─── Day codes helper ──────────────────────────────────────────────────────
abstract class DayCode {
  static const String mon = 'MON';
  static const String tue = 'TUE';
  static const String wed = 'WED';
  static const String thu = 'THU';
  static const String fri = 'FRI';
  static const String sat = 'SAT';
  static const String sun = 'SUN';

  static const List<String> weekdays = [mon, tue, wed, thu, fri];
  static const List<String> all      = [mon, tue, wed, thu, fri, sat, sun];

  static int sortIndex(String code) => all.indexOf(code);
}

// ─── Constraint type / kind enums ─────────────────────────────────────────
abstract class ConstraintKind {
  static const String hard = 'HARD';
  static const String soft = 'SOFT';
}

abstract class ConstraintType {
  static const String mustAssign    = 'MUST_ASSIGN';
  static const String mustNotAssign = 'MUST_NOT_ASSIGN';
  static const String avoidTimeslot = 'AVOID_TIMESLOT';
  static const String preferBlock   = 'PREFER_BLOCK';
}

abstract class ConstraintWeight {
  static const String low    = 'LOW';
  static const String medium = 'MEDIUM';
  static const String high   = 'HIGH';
}

abstract class PeriodType {
  static const String lesson = 'LESSON';
  static const String breakSlot = 'BREAK';
}

abstract class ResultStatus {
  static const String perfect        = 'PERFECT';
  static const String softViolations = 'SOFT_VIOLATIONS';
  static const String hardViolations = 'HARD_VIOLATIONS';
}
