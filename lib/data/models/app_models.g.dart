// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_models.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$AccountModelImpl _$$AccountModelImplFromJson(Map<String, dynamic> json) =>
    _$AccountModelImpl(
      trialUsed: json['trialUsed'] as bool,
      trialUsedAt:
          const NullableTimestampConverter().fromJson(json['trialUsedAt']),
      createdAt: const TimestampConverter().fromJson(json['createdAt']),
    );

Map<String, dynamic> _$$AccountModelImplToJson(_$AccountModelImpl instance) =>
    <String, dynamic>{
      'trialUsed': instance.trialUsed,
      'trialUsedAt':
          const NullableTimestampConverter().toJson(instance.trialUsedAt),
      'createdAt': const TimestampConverter().toJson(instance.createdAt),
    };

_$SchoolModelImpl _$$SchoolModelImplFromJson(Map<String, dynamic> json) =>
    _$SchoolModelImpl(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String?,
      createdAt: const TimestampConverter().fromJson(json['createdAt']),
      updatedAt: const TimestampConverter().fromJson(json['updatedAt']),
    );

Map<String, dynamic> _$$SchoolModelImplToJson(_$SchoolModelImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'description': instance.description,
      'createdAt': const TimestampConverter().toJson(instance.createdAt),
      'updatedAt': const TimestampConverter().toJson(instance.updatedAt),
    };

_$PeriodModelImpl _$$PeriodModelImplFromJson(Map<String, dynamic> json) =>
    _$PeriodModelImpl(
      id: json['id'] as String,
      schoolId: json['schoolId'] as String,
      type: json['type'] as String,
      name: json['name'] as String?,
      startTime: json['startTime'] as String,
      endTime: json['endTime'] as String,
      sortOrder: (json['sortOrder'] as num).toInt(),
      dayApplicability: (json['dayApplicability'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList(),
    );

Map<String, dynamic> _$$PeriodModelImplToJson(_$PeriodModelImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'schoolId': instance.schoolId,
      'type': instance.type,
      'name': instance.name,
      'startTime': instance.startTime,
      'endTime': instance.endTime,
      'sortOrder': instance.sortOrder,
      'dayApplicability': instance.dayApplicability,
    };

_$DayCapacityModelImpl _$$DayCapacityModelImplFromJson(
        Map<String, dynamic> json) =>
    _$DayCapacityModelImpl(
      schoolId: json['schoolId'] as String,
      classroomId: json['classroomId'] as String,
      dayOfWeek: json['dayOfWeek'] as String,
      activeSlots: (json['activeSlots'] as List<dynamic>)
          .map((e) => (e as num).toInt())
          .toList(),
    );

Map<String, dynamic> _$$DayCapacityModelImplToJson(
        _$DayCapacityModelImpl instance) =>
    <String, dynamic>{
      'schoolId': instance.schoolId,
      'classroomId': instance.classroomId,
      'dayOfWeek': instance.dayOfWeek,
      'activeSlots': instance.activeSlots,
    };

_$ClassroomModelImpl _$$ClassroomModelImplFromJson(Map<String, dynamic> json) =>
    _$ClassroomModelImpl(
      id: json['id'] as String,
      schoolId: json['schoolId'] as String,
      name: json['name'] as String,
      sortOrder: (json['sortOrder'] as num).toInt(),
    );

Map<String, dynamic> _$$ClassroomModelImplToJson(
        _$ClassroomModelImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'schoolId': instance.schoolId,
      'name': instance.name,
      'sortOrder': instance.sortOrder,
    };

_$SubjectModelImpl _$$SubjectModelImplFromJson(Map<String, dynamic> json) =>
    _$SubjectModelImpl(
      id: json['id'] as String,
      schoolId: json['schoolId'] as String,
      name: json['name'] as String,
      teacherName: json['teacherName'] as String,
      teacherId: json['teacherId'] as String?,
      colourHex: json['colourHex'] as String,
    );

Map<String, dynamic> _$$SubjectModelImplToJson(_$SubjectModelImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'schoolId': instance.schoolId,
      'name': instance.name,
      'teacherName': instance.teacherName,
      'teacherId': instance.teacherId,
      'colourHex': instance.colourHex,
    };

_$ClassroomSubjectModelImpl _$$ClassroomSubjectModelImplFromJson(
        Map<String, dynamic> json) =>
    _$ClassroomSubjectModelImpl(
      id: json['id'] as String,
      classroomId: json['classroomId'] as String,
      subjectId: json['subjectId'] as String,
      weeklyTargetHours: (json['weeklyTargetHours'] as num).toInt(),
      minDailyHours: (json['minDailyHours'] as num?)?.toInt() ?? 0,
      maxDailyHours: (json['maxDailyHours'] as num).toInt(),
    );

Map<String, dynamic> _$$ClassroomSubjectModelImplToJson(
        _$ClassroomSubjectModelImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'classroomId': instance.classroomId,
      'subjectId': instance.subjectId,
      'weeklyTargetHours': instance.weeklyTargetHours,
      'minDailyHours': instance.minDailyHours,
      'maxDailyHours': instance.maxDailyHours,
    };

_$ConstraintModelImpl _$$ConstraintModelImplFromJson(
        Map<String, dynamic> json) =>
    _$ConstraintModelImpl(
      id: json['id'] as String,
      schoolId: json['schoolId'] as String,
      kind: json['kind'] as String,
      type: json['type'] as String,
      classroomId: json['classroomId'] as String?,
      subjectId: json['subjectId'] as String?,
      dayOfWeek: json['dayOfWeek'] as String?,
      periodId: json['periodId'] as String?,
      endPeriodId: json['endPeriodId'] as String?,
      weight: json['weight'] as String?,
      minHours: (json['minHours'] as num?)?.toInt(),
      maxHours: (json['maxHours'] as num?)?.toInt(),
    );

Map<String, dynamic> _$$ConstraintModelImplToJson(
        _$ConstraintModelImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'schoolId': instance.schoolId,
      'kind': instance.kind,
      'type': instance.type,
      'classroomId': instance.classroomId,
      'subjectId': instance.subjectId,
      'dayOfWeek': instance.dayOfWeek,
      'periodId': instance.periodId,
      'endPeriodId': instance.endPeriodId,
      'weight': instance.weight,
      'minHours': instance.minHours,
      'maxHours': instance.maxHours,
    };

_$ConstraintSetModelImpl _$$ConstraintSetModelImplFromJson(
        Map<String, dynamic> json) =>
    _$ConstraintSetModelImpl(
      id: json['id'] as String,
      schoolId: json['schoolId'] as String,
      name: json['name'] as String,
      savedAt: const TimestampConverter().fromJson(json['savedAt']),
      constraints: (json['constraints'] as List<dynamic>?)
              ?.map((e) => e as Map<String, dynamic>)
              .toList() ??
          const [],
      dailyLimits: (json['dailyLimits'] as List<dynamic>?)
              ?.map((e) => e as Map<String, dynamic>)
              .toList() ??
          const [],
    );

Map<String, dynamic> _$$ConstraintSetModelImplToJson(
        _$ConstraintSetModelImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'schoolId': instance.schoolId,
      'name': instance.name,
      'savedAt': const TimestampConverter().toJson(instance.savedAt),
      'constraints': instance.constraints,
      'dailyLimits': instance.dailyLimits,
    };

_$ScheduleModelImpl _$$ScheduleModelImplFromJson(Map<String, dynamic> json) =>
    _$ScheduleModelImpl(
      id: json['id'] as String,
      schoolId: json['schoolId'] as String,
      name: json['name'] as String,
      generatedAt: const TimestampConverter().fromJson(json['generatedAt']),
      isCancelled: json['isCancelled'] as bool? ?? false,
      isManuallyEdited: json['isManuallyEdited'] as bool? ?? false,
      resultStatus: json['resultStatus'] as String,
      hardViolationCount: (json['hardViolationCount'] as num?)?.toInt() ?? 0,
      softViolationCount: (json['softViolationCount'] as num?)?.toInt() ?? 0,
      qualityScore: (json['qualityScore'] as num?)?.toInt() ?? 0,
      teacherFreeHours: (json['teacherFreeHours'] as num?)?.toInt() ?? 0,
      subjectChanges: (json['subjectChanges'] as num?)?.toInt() ?? 0,
    );

Map<String, dynamic> _$$ScheduleModelImplToJson(_$ScheduleModelImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'schoolId': instance.schoolId,
      'name': instance.name,
      'generatedAt': const TimestampConverter().toJson(instance.generatedAt),
      'isCancelled': instance.isCancelled,
      'isManuallyEdited': instance.isManuallyEdited,
      'resultStatus': instance.resultStatus,
      'hardViolationCount': instance.hardViolationCount,
      'softViolationCount': instance.softViolationCount,
      'qualityScore': instance.qualityScore,
      'teacherFreeHours': instance.teacherFreeHours,
      'subjectChanges': instance.subjectChanges,
    };

_$ScheduleCellModelImpl _$$ScheduleCellModelImplFromJson(
        Map<String, dynamic> json) =>
    _$ScheduleCellModelImpl(
      id: json['id'] as String,
      scheduleId: json['scheduleId'] as String,
      classroomId: json['classroomId'] as String,
      periodId: json['periodId'] as String,
      subjectId: json['subjectId'] as String?,
      isViolation: json['isViolation'] as bool? ?? false,
      violationDescription: json['violationDescription'] as String?,
    );

Map<String, dynamic> _$$ScheduleCellModelImplToJson(
        _$ScheduleCellModelImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'scheduleId': instance.scheduleId,
      'classroomId': instance.classroomId,
      'periodId': instance.periodId,
      'subjectId': instance.subjectId,
      'isViolation': instance.isViolation,
      'violationDescription': instance.violationDescription,
    };
