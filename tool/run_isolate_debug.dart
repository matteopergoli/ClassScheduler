import 'package:classscheduler/domain/scheduler/scheduler_input.dart';
import 'package:classscheduler/domain/scheduler/scheduler_isolate.dart';
import 'package:classscheduler/domain/scheduler/scheduler_input_builder.dart';
import 'package:classscheduler/domain/models.dart';

// This script spawns the same isolate used by the app and streams progress.
// It builds a minimal SchedulerInput like the app would.

void main() async {
  final input = SchedulerInput(
    numClassrooms: 2,
    numSubjects: 2,
    numDays: 3,
    numSlots: 4,
    classroomNames: ['Room A', 'Room B'],
    subjectNames: ['Maths', 'English'],
    teacherNames: ['Alice', 'Bob'],
    dayNames: ['MON', 'TUE', 'WED'],
    slotLabels: ['08:00', '09:00', '10:00', '11:00'],
    classroomIds: ['cr0', 'cr1'],
    subjectIds: ['s0', 's1'],
    periodIds: ['p0','p1','p2','p3'],
    teacherOf: [0,1],
    weeklyTarget: [ [1,1], [1,1] ],
    blockedSlots: {},
    maxDaily: List.generate(2, (_) => List.filled(2, 4)),
    minDaily: List.generate(2, (_) => List.filled(2, 0)),
    mustAssign: [],
    mustNotAssignKeys: {},
    softConstraints: [],
  );

  final runner = SchedulerIsolateRunner();
  runner.progressStream.listen((p) => print('UI prog: ${p.fraction} it=${p.iterationsCompleted}'));
  final res = await runner.run(input);
  print('Result: status=${res.status} quality=${res.qualityScore} iter=${res.iterationsCompleted}');
}
