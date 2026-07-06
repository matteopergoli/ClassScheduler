import 'dart:async';
import 'package:classscheduler/domain/scheduler/scheduler_input.dart';
import 'package:classscheduler/domain/scheduler/scheduler_engine.dart';

void main() async {
  final sw = Stopwatch()..start();
  const C = 4;
  const S = 4;
  const D = 4;
  const L = 6;

  final teacherOf = List.generate(S, (i) => i % 3);
  final weeklyTarget = List.generate(C, (_) => List.generate(S, (i) => i == 0 ? 2 : 1));
  final maxDaily = List.generate(C, (_) => List.generate(S, (_) => 2));
  final minDaily = List.generate(C, (_) => List.generate(S, (_) => 0));

  final input = SchedulerInput(
    numClassrooms: C,
    numSubjects: S,
    numDays: D,
    numSlots: L,
    classroomNames: List.generate(C, (i) => 'Room $i'),
    subjectNames: List.generate(S, (i) => 'Subject $i'),
    teacherNames: ['T0', 'T1', 'T2'],
    dayNames: ['MON', 'TUE', 'WED', 'THU'],
    slotLabels: List.generate(L, (i) => 'P$i'),
    classroomIds: List.generate(C, (i) => 'cr$i'),
    subjectIds: List.generate(S, (i) => 's$i'),
    periodIds: List.generate(L, (i) => 'p$i'),
    teacherOf: teacherOf,
    weeklyTarget: weeklyTarget,
    blockedSlots: {},
    maxDaily: maxDaily,
    minDaily: minDaily,
    mustAssign: [],
    mustNotAssignKeys: {},
    softConstraints: [],
  );

  final engine = SchedulerEngine(
    input: input,
    isCancelled: () => false,
    onProgress: (fraction, iterations) {
      if (iterations % 1000 == 0) {
        print('progress=$fraction iterations=$iterations');
      }
    },
  );

  final result = engine.run();
  sw.stop();
  print('status=${result.status} quality=${result.qualityScore} violations=${result.hardViolations.length} iter=${result.iterationsCompleted} restarts=${result.restartsUsed} time=${sw.elapsed}');
}
