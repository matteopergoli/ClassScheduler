// test/unit/scheduler/scheduler_input_builder_test.dart
//
// Unit tests for SchedulerInputBuilder's constraint expansion, covering the
// two extensions added alongside unifying the constraint form's fields:
//   - MUST_ASSIGN / MUST_NOT_ASSIGN periodId..endPeriodId ranges are
//     expanded into one MustAssign/cell-key per covered slot.
//   - AVOID_TIMESLOT / PREFER_BLOCK optionally carry a classroomIdx scope.
//
// Exercises SchedulerInputBuilder.build() directly (not the full engine)
// since these are properties of the raw SchedulerInput it produces.

import 'package:flutter_test/flutter_test.dart';
import 'package:classscheduler/data/models/app_models.dart';
import 'package:classscheduler/domain/scheduler/scheduler_input.dart';
import 'package:classscheduler/domain/scheduler/scheduler_input_builder.dart';

void main() {
  // 1 classroom, 1 subject, 1 active day, 4 lesson periods.
  final classrooms = [
    const ClassroomModel(id: 'c1', schoolId: 's', name: 'Room A', sortOrder: 0),
  ];
  final subjects = [
    const SubjectModel(id: 'sub1', schoolId: 's', name: 'Maths',
        teacherName: 'Alice', colourHex: '#000000'),
  ];
  final classroomSubjects = [
    const ClassroomSubjectModel(id: 'cs1', classroomId: 'c1', subjectId: 'sub1',
        weeklyTargetHours: 4, maxDailyHours: 4),
  ];
  final periods = [
    const PeriodModel(id: 'p0', schoolId: 's', type: 'LESSON',
        startTime: '08:00', endTime: '09:00', sortOrder: 0),
    const PeriodModel(id: 'p1', schoolId: 's', type: 'LESSON',
        startTime: '09:00', endTime: '10:00', sortOrder: 1),
    const PeriodModel(id: 'p2', schoolId: 's', type: 'LESSON',
        startTime: '10:00', endTime: '11:00', sortOrder: 2),
    const PeriodModel(id: 'p3', schoolId: 's', type: 'LESSON',
        startTime: '11:00', endTime: '12:00', sortOrder: 3),
  ];
  const activeDays = ['MON'];

  SchedulerInput build(List<ConstraintModel> constraints) =>
      SchedulerInputBuilder.build(
        activeDayCodes: activeDays,
        lessonPeriods: periods,
        classrooms: classrooms,
        subjects: subjects,
        classroomSubjects: classroomSubjects,
        dayCapacities: const [],
        constraints: constraints,
      );

  group('MUST_ASSIGN / MUST_NOT_ASSIGN slot ranges', () {
    test('a range pre-assigns every covered slot, not just the start', () {
      final input = build([
        const ConstraintModel(
          id: 'k1', schoolId: 's', kind: 'HARD', type: 'MUST_ASSIGN',
          classroomId: 'c1', subjectId: 'sub1', dayOfWeek: 'MON',
          periodId: 'p1', endPeriodId: 'p3',
        ),
      ]);

      final coveredSlots = input.mustAssign.map((m) => m.l).toSet();
      expect(coveredSlots, {1, 2, 3});
      for (final m in input.mustAssign) {
        expect(m.c, 0);
        expect(m.s, 0);
        expect(m.d, 0);
      }
    });

    test('endPeriodId before periodId still covers the whole range', () {
      final input = build([
        const ConstraintModel(
          id: 'k2', schoolId: 's', kind: 'HARD', type: 'MUST_ASSIGN',
          classroomId: 'c1', subjectId: 'sub1', dayOfWeek: 'MON',
          periodId: 'p2', endPeriodId: 'p0',
        ),
      ]);

      expect(input.mustAssign.map((m) => m.l).toSet(), {0, 1, 2});
    });

    test('no endPeriodId behaves as a single forced slot (unchanged)', () {
      final input = build([
        const ConstraintModel(
          id: 'k3', schoolId: 's', kind: 'HARD', type: 'MUST_ASSIGN',
          classroomId: 'c1', subjectId: 'sub1', dayOfWeek: 'MON',
          periodId: 'p1',
        ),
      ]);

      expect(input.mustAssign, hasLength(1));
      expect(input.mustAssign.single.l, 1);
    });

    test('a MUST_NOT_ASSIGN range blocks every covered slot', () {
      final input = build([
        const ConstraintModel(
          id: 'k4', schoolId: 's', kind: 'HARD', type: 'MUST_NOT_ASSIGN',
          classroomId: 'c1', subjectId: 'sub1', dayOfWeek: 'MON',
          periodId: 'p0', endPeriodId: 'p1',
        ),
      ]);

      expect(input.mustNotAssignKeys, {
        SchedulerInput.cellKey(0, 0, 0, 0),
        SchedulerInput.cellKey(0, 0, 0, 1),
      });
    });
  });

  group('AVOID_TIMESLOT / PREFER_BLOCK classroom scope', () {
    test('AVOID_TIMESLOT scoped to a classroom carries that classroomIdx', () {
      final input = build([
        const ConstraintModel(
          id: 'k5', schoolId: 's', kind: 'SOFT', type: 'AVOID_TIMESLOT',
          classroomId: 'c1', subjectId: 'sub1', dayOfWeek: 'MON',
          periodId: 'p0', endPeriodId: 'p1', weight: 'MEDIUM',
        ),
      ]);

      expect(input.softConstraints, hasLength(1));
      expect(input.softConstraints.single.classroomIdx, 0);
    });

    test('PREFER_BLOCK with no classroom set applies to every classroom '
        '(classroomIdx null)', () {
      final input = build([
        const ConstraintModel(
          id: 'k6', schoolId: 's', kind: 'SOFT', type: 'PREFER_BLOCK',
          subjectId: 'sub1', weight: 'LOW',
        ),
      ]);

      expect(input.softConstraints, hasLength(1));
      expect(input.softConstraints.single.classroomIdx, isNull);
    });
  });
}
