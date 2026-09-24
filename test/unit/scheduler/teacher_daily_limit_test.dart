import 'package:flutter_test/flutter_test.dart';
import 'package:classscheduler/data/models/app_models.dart';
import 'package:classscheduler/domain/scheduler/schedule_state.dart';
import 'package:classscheduler/domain/scheduler/scheduler_input_builder.dart';

void main() {
  test('teacher daily maximum applies across classrooms', () {
    final subjects = [
      const SubjectModel(
        id: 'maths',
        schoolId: 'school',
        name: 'Maths',
        teacherName: 'Alice',
        maxDailyTeacherHours: 1,
        colourHex: '#000000',
      ),
      const SubjectModel(
        id: 'science',
        schoolId: 'school',
        name: 'Science',
        teacherName: 'Alice',
        maxDailyTeacherHours: 1,
        colourHex: '#FFFFFF',
      ),
    ];
    final input = SchedulerInputBuilder.build(
      activeDayCodes: const ['MON', 'TUE'],
      lessonPeriods: const [
        PeriodModel(
          id: 'p0',
          schoolId: 'school',
          type: 'LESSON',
          startTime: '08:00',
          endTime: '09:00',
          sortOrder: 0,
        ),
        PeriodModel(
          id: 'p1',
          schoolId: 'school',
          type: 'LESSON',
          startTime: '09:00',
          endTime: '10:00',
          sortOrder: 1,
        ),
      ],
      classrooms: const [
        ClassroomModel(
          id: 'class-a', schoolId: 'school', name: 'A', sortOrder: 0),
        ClassroomModel(
          id: 'class-b', schoolId: 'school', name: 'B', sortOrder: 1),
      ],
      subjects: subjects,
      classroomSubjects: const [
        ClassroomSubjectModel(
          id: 'a-maths',
          classroomId: 'class-a',
          subjectId: 'maths',
          weeklyTargetHours: 1,
          maxDailyHours: 2,
        ),
        ClassroomSubjectModel(
          id: 'b-science',
          classroomId: 'class-b',
          subjectId: 'science',
          weeklyTargetHours: 1,
          maxDailyHours: 2,
        ),
      ],
      dayCapacities: const [],
      constraints: const [],
    );

    expect(input.maxDailyTeacher, [1]);

    final state = ScheduleState(input);
    state.assign(0, 0, 0, 0);

    expect(state.canPlace(1, 1, 0, 1), isFalse);
    expect(state.canPlace(1, 1, 1, 1), isTrue);
  });

  test('teacher daily minimum is zero-or-minimum across classrooms', () {
    final subject = const SubjectModel(
      id: 'maths',
      schoolId: 'school',
      name: 'Maths',
      teacherName: 'Alice',
      minDailyTeacherHours: 2,
      colourHex: '#000000',
    );
    final input = SchedulerInputBuilder.build(
      activeDayCodes: const ['MON'],
      lessonPeriods: const [
        PeriodModel(
          id: 'p0', schoolId: 'school', type: 'LESSON',
          startTime: '08:00', endTime: '09:00', sortOrder: 0),
        PeriodModel(
          id: 'p1', schoolId: 'school', type: 'LESSON',
          startTime: '09:00', endTime: '10:00', sortOrder: 1),
      ],
      classrooms: const [
        ClassroomModel(
          id: 'class-a', schoolId: 'school', name: 'A', sortOrder: 0),
        ClassroomModel(
          id: 'class-b', schoolId: 'school', name: 'B', sortOrder: 1),
      ],
      subjects: [subject],
      classroomSubjects: const [
        ClassroomSubjectModel(
          id: 'a-maths', classroomId: 'class-a', subjectId: 'maths',
          weeklyTargetHours: 1, maxDailyHours: 1),
        ClassroomSubjectModel(
          id: 'b-maths', classroomId: 'class-b', subjectId: 'maths',
          weeklyTargetHours: 1, maxDailyHours: 1),
      ],
      dayCapacities: const [],
      constraints: const [],
    );

    expect(input.minDailyTeacher, [2]);
    final state = ScheduleState(input);
    expect(state.satisfiesAllTeacherMinDaily(), isTrue);
    state.assign(0, 0, 0, 0);
    expect(state.satisfiesAllTeacherMinDaily(), isFalse);
    state.assign(1, 0, 0, 1);
    expect(state.satisfiesAllTeacherMinDaily(), isTrue);
  });
}
