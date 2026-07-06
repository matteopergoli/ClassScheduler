import 'package:classscheduler/domain/scheduler/scheduler_engine.dart';
import 'package:classscheduler/domain/scheduler/scheduler_input.dart';
import 'package:classscheduler/domain/scheduler/schedule_state.dart';
import '../test/helpers/scheduler_fixtures.dart';

void main() {
  final input = mustAssignInput();
  final state = ScheduleState(input);
  print('canPlace=${state.canPlace(0, 0, 0, 0)}');
  print('remaining=${state.remaining(0, 0)}');
  print('activeSlots=${input.activeSlotCount(0, 0)}');
  print('maxDaily=${input.maxDaily[0][0]}');
  print('teacherfree=${state.isTeacherFree(0, 0, 0)}');
  print('slotFree=${state.checkHC8(0,0,0)}');
  final engine = SchedulerEngine(
    input: input,
    isCancelled: () => false,
    onProgress: (fraction, iterations) {},
  );
  final result = engine.run();
  print('status=${result.status}');
  print('quality=${result.qualityScore}');
  print('hard=${result.hardViolations.length}');
  for (final v in result.hardViolations) {
    print('${v.constraintId}: ${v.description}');
  }
  print('schedule:');
  for (var c = 0; c < input.numClassrooms; c++) {
    for (var d = 0; d < input.numDays; d++) {
      print('c$c d$d ${result.schedule[c][d]}');
    }
  }
}
