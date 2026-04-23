// test/unit/validation/constraint_validator_test.dart
//
// Unit tests for:
//   - ConstraintConflictDetector (FR-HC-03)
//   - DragDropValidator (FR-VIEW-04)
//   - SubjectValidator (FR-SUB-06)

import 'package:flutter_test/flutter_test.dart';

import 'package:classscheduler/data/models/app_models.dart';
import 'package:classscheduler/domain/constraints/constraint_conflict_detector.dart';
import 'package:classscheduler/domain/scheduler/drag_drop_validator.dart';
import 'package:classscheduler/domain/validation/subject_validator.dart';
// SubjectValidationError enum is re-exported from subject_validator.dart

// ── Fixtures ──────────────────────────────────────────────────────────────

const _schoolId = 'school1';
const _cr0      = 'cr0';
const _cr1      = 'cr1';
const _sub0     = 's0';
const _sub1     = 's1';
const _per0     = 'p0';
const _per1     = 'p1';
const _per2     = 'p2';

PeriodModel _lesson(String id, {int sort = 0}) => PeriodModel(
      id:        id,
      schoolId:  _schoolId,
      type:      'LESSON',
      name:      null,
      startTime: '0${sort + 8}:00',
      endTime:   '0${sort + 9}:00',
      sortOrder: sort,
      dayApplicability: null,
    );

ConstraintModel _mustAssign(String id, String cr, String sub,
        String day, String period) =>
    ConstraintModel(
      id:          id,
      schoolId:    _schoolId,
      kind:        'HARD',
      type:        'MUST_ASSIGN',
      classroomId: cr,
      subjectId:   sub,
      dayOfWeek:   day,
      periodId:    period,
      endPeriodId: null,
      weight:      'MEDIUM',
    );

ConstraintModel _mustNotAssign(String id, String cr, String sub,
        String day, String period) =>
    ConstraintModel(
      id:          id,
      schoolId:    _schoolId,
      kind:        'HARD',
      type:        'MUST_NOT_ASSIGN',
      classroomId: cr,
      subjectId:   sub,
      dayOfWeek:   day,
      periodId:    period,
      endPeriodId: null,
      weight:      'MEDIUM',
    );

SubjectModel _subject(String id, String teacher) => SubjectModel(
      id:          id,
      schoolId:    _schoolId,
      name:        id == _sub0 ? 'Maths' : 'English',
      teacherName: teacher,
      teacherId:   null,
      colourHex:   '#6C63FF',
    );

ClassroomSubjectModel _cs(String cr, String sub,
        {int weekly = 3, int min = 0, int max = 2}) =>
    ClassroomSubjectModel(
      classroomId:     cr,
      subjectId:       sub,
      weeklyTargetHours: weekly,
      minDailyHours:   min,
      maxDailyHours:   max,
    );

// ── ConstraintConflictDetector tests ─────────────────────────────────────

void main() {
group('ConstraintConflictDetector', () {
  final periods     = [_lesson(_per0, sort: 0), _lesson(_per1, sort: 1)];
  final classrooms  = [
    const ClassroomModel(id: _cr0, schoolId: _schoolId, name: 'A', sortOrder: 0),
    const ClassroomModel(id: _cr1, schoolId: _schoolId, name: 'B', sortOrder: 1),
  ];
  final subjects    = [
    _subject(_sub0, 'Alice'),
    _subject(_sub1, 'Bob'),
  ];
  final csAssigns   = [
    _cs(_cr0, _sub0), _cs(_cr0, _sub1),
    _cs(_cr1, _sub0), _cs(_cr1, _sub1),
  ];

  test('no conflicts with compatible constraints', () {
    final constraints = [
      _mustAssign('c1', _cr0, _sub0, 'MON', _per0),
      _mustAssign('c2', _cr1, _sub1, 'TUE', _per1),
    ];
    final conflicts = ConstraintConflictDetector.detect(
      hardConstraints:    constraints,
      periods:            periods,
      subjects:           subjects,
      classroomSubjects:  csAssigns,
      lessonPeriodsPerDay: {
        'MON': periods.where((p) => p.type == 'LESSON').toList(),
        'TUE': periods.where((p) => p.type == 'LESSON').toList(),
      },
    );
    expect(conflicts, isEmpty,
        reason: 'No overlapping constraints → no conflicts');
  });

  test('MUST-ASSIGN + MUST-NOT-ASSIGN on same cell → conflict', () {
    final constraints = [
      _mustAssign   ('c1', _cr0, _sub0, 'MON', _per0),
      _mustNotAssign('c2', _cr0, _sub0, 'MON', _per0),
    ];
    final conflicts = ConstraintConflictDetector.detect(
      hardConstraints:    constraints,
      periods:            periods,
      subjects:           subjects,
      classroomSubjects:  csAssigns,
      lessonPeriodsPerDay: {
        'MON': periods.where((p) => p.type == 'LESSON').toList(),
        'TUE': periods.where((p) => p.type == 'LESSON').toList(),
      },
    );
    expect(conflicts, isNotEmpty,
        reason: 'MUST-ASSIGN + MUST-NOT-ASSIGN on same cell must conflict');
    expect(
      conflicts.any((c) =>
          c.description.toLowerCase().contains('conflict') ||
          c.description.toLowerCase().contains('same cell') ||
          c.description.toLowerCase().contains('both')),
      isTrue,
    );
  });

  test('teacher conflict: two MUST-ASSIGN same teacher same slot', () {
    // Both classrooms must have _sub0 (same teacher Alice) at MON per0
    final constraints = [
      _mustAssign('c1', _cr0, _sub0, 'MON', _per0),
      _mustAssign('c2', _cr1, _sub0, 'MON', _per0),
    ];
    final conflicts = ConstraintConflictDetector.detect(
      hardConstraints:    constraints,
      periods:            periods,
      subjects:           subjects,
      classroomSubjects:  csAssigns,
      lessonPeriodsPerDay: {
        'MON': periods.where((p) => p.type == 'LESSON').toList(),
        'TUE': periods.where((p) => p.type == 'LESSON').toList(),
      },
    );
    expect(conflicts, isNotEmpty,
        reason: 'Same teacher forced into two classrooms at same time');
  });

  test('MUST-ASSIGN to a break slot → conflict', () {
    const breakPeriod = PeriodModel(
      id: 'break1', schoolId: _schoolId, type: 'BREAK',
      name: 'Morning Break', startTime: '10:00', endTime: '10:15',
      sortOrder: 2, dayApplicability: null,
    );
    final allPeriods = [...periods, breakPeriod];
    final constraints = [
      _mustAssign('c1', _cr0, _sub0, 'MON', 'break1'),
    ];
    final conflicts = ConstraintConflictDetector.detect(
      hardConstraints:    constraints,
      periods:            allPeriods,
      subjects:           subjects,
      classroomSubjects:  csAssigns,
      lessonPeriodsPerDay: {
        'MON': allPeriods.where((p) => p.type == 'LESSON').toList(),
      },
    );
    expect(conflicts, isNotEmpty,
        reason: 'MUST-ASSIGN to a break slot must be flagged');
  });
});

// ── DragDropValidator tests ───────────────────────────────────────────────

group('DragDropValidator', () {
  final subjects = [
    _subject(_sub0, 'Alice'),
    _subject(_sub1, 'Alice'), // same teacher → HC-1 can fire
  ];

  ScheduleCellModel cell(
    String id,
    String classroomId,
    String periodId,
    String? subjectId,
  ) =>
      ScheduleCellModel(
        id:                   id,
        scheduleId:           'sched1',
        classroomId:          classroomId,
        periodId:             periodId,
        subjectId:            subjectId,
        isViolation:          false,
        violationDescription: null,
      );

  test('moving to free slot is allowed', () {
    final source = cell('${_cr0}_MON_0', _cr0, _per0, _sub0);
    final target = cell('${_cr0}_TUE_1', _cr0, _per1, null); // free
    final allCells = [source, target];

    final result = DragDropValidator.validate(
      sourceCell:         source,
      targetCell:         target,
      allCells:           allCells,
      subjects:           subjects,
      classroomSubjects:  [],
      dailyCapacities:    [],
      periods:            [_lesson(_per0), _lesson(_per1)],
      activeDayCodes:     ['MON', 'TUE', 'WED', 'THU', 'FRI'],
    );

    expect(result.allowed, isTrue);
  });

  test('HC-1 teacher conflict → rejected with message', () {
    // Source: cr0, Maths (Alice), MON, p0
    // Conflict: cr1 already has English (also Alice) at TUE, p0
    final source    = cell('${_cr0}_MON_0', _cr0, _per0, _sub0);
    final conflict  = cell('${_cr1}_TUE_0', _cr1, _per0, _sub1);
    final target    = cell('${_cr0}_TUE_0', _cr0, _per0, null);
    final allCells  = [source, conflict, target];

    final result = DragDropValidator.validate(
      sourceCell:         source,
      targetCell:         target,
      allCells:           allCells,
      subjects:           subjects,
      classroomSubjects:  [],
      dailyCapacities:    [],
      periods:            [_lesson(_per0), _lesson(_per1)],
      activeDayCodes:     ['MON', 'TUE', 'WED', 'THU', 'FRI'],
    );

    expect(result.allowed, isFalse,
        reason: 'Alice cannot teach two classrooms simultaneously');
    expect(result.violationMessage, isNotNull);
    expect(result.violationMessage!.toLowerCase(),
        contains('alice'),
        reason: 'Error message must name the teacher');
  });

  test('moving null (free) source → rejected', () {
    final source = cell('${_cr0}_MON_0', _cr0, _per0, null);
    final target = cell('${_cr0}_TUE_1', _cr0, _per1, null);

    final result = DragDropValidator.validate(
      sourceCell:         source,
      targetCell:         target,
      allCells:           [source, target],
      subjects:           subjects,
      classroomSubjects:  [],
      dailyCapacities:    [],
      periods:            [_lesson(_per0), _lesson(_per1)],
      activeDayCodes:     ['MON', 'TUE', 'WED', 'THU', 'FRI'],
    );

    expect(result.allowed, isFalse,
        reason: 'Cannot drag a free slot');
  });

  test('HC-4 MaxDaily exceeded → rejected', () {
    final source = cell('${_cr0}_MON_0', _cr0, _per0, _sub0);
    // Simulate cr0 already has MaxDaily=1 Maths on TUE
    final existingOnTue = cell('${_cr0}_TUE_1', _cr0, _per1, _sub0);
    final target        = cell('${_cr0}_TUE_2', _cr0, _per2, null);

    final csAssigns = [
      const ClassroomSubjectModel(
        classroomId:       _cr0,
        subjectId:         _sub0,
        weeklyTargetHours: 2,
        minDailyHours:     0,
        maxDailyHours:     1, // max 1 per day
      ),
    ];

    final result = DragDropValidator.validate(
      sourceCell:         source,
      targetCell:         target,
      allCells:           [source, existingOnTue, target],
      subjects:           subjects,
      classroomSubjects:  csAssigns,
      dailyCapacities:    [],
      periods:            [_lesson(_per0), _lesson(_per1), _lesson(_per2)],
      activeDayCodes:     ['MON', 'TUE', 'WED', 'THU', 'FRI'],
    );

    expect(result.allowed, isFalse,
        reason: 'MaxDaily=1 already met → move must be rejected');
  });
});

// ── SubjectValidator tests ────────────────────────────────────────────────

group('SubjectValidator — FR-SUB-06', () {
  test('MinDaily > MaxDaily → invalid', () {
    final result = SubjectValidator.validate(
      weeklyTarget:     4,
      minDaily:         3,
      maxDaily:         2, // min > max → invalid
      activeDayCount:   5,
      totalLessonSlots: 20,
    );
    expect(result.isValid, isFalse);
    expect(result.errors, isNotEmpty);
  });

  test('MaxDaily × activeDays < weeklyTarget → invalid', () {
    final result = SubjectValidator.validate(
      weeklyTarget:     10,
      minDaily:         0,
      maxDaily:         1, // 1 × 5 days = 5 < 10 → impossible
      activeDayCount:   5,
      totalLessonSlots: 40,
    );
    expect(result.isValid, isFalse);
    expect(
      result.errors.any((e) =>
          e.toString().toLowerCase().contains('max') ||
          e == SubjectValidationError.maxDaysInsufficient),
      isTrue,
    );
  });

  test('weeklyTarget > totalLessonSlots → invalid', () {
    final result = SubjectValidator.validate(
      weeklyTarget:     25,
      minDaily:         0,
      maxDaily:         5,
      activeDayCount:   5,
      totalLessonSlots: 20, // only 20 slots in week
    );
    expect(result.isValid, isFalse);
  });

  test('valid assignment passes', () {
    final result = SubjectValidator.validate(
      weeklyTarget:     4,
      minDaily:         1,
      maxDaily:         2,
      activeDayCount:   5,
      totalLessonSlots: 30,
    );
    expect(result.isValid, isTrue);
    expect(result.errors, isEmpty);
  });
});
}
