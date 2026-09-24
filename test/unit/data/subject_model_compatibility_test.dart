import 'package:flutter_test/flutter_test.dart';
import 'package:classscheduler/data/models/app_models.dart';

void main() {
  test('old subject documents default teacher daily limits to zero', () {
    final subject = SubjectModel.fromJson({
      'id': 'subject-1',
      'schoolId': 'school-1',
      'name': 'Maths',
      'teacherName': 'Alice',
      'teacherId': null,
      'colourHex': '#000000',
    });

    expect(subject.minDailyTeacherHours, 0);
    expect(subject.maxDailyTeacherHours, 0);
    expect(subject.minWeeklyTeacherHours, 0);
    expect(subject.maxWeeklyTeacherHours, 0);
  });

  test('new teacher daily limits round-trip through Firestore JSON', () {
    const subject = SubjectModel(
      id: 'subject-1',
      schoolId: 'school-1',
      name: 'Maths',
      teacherName: 'Alice',
      minWeeklyTeacherHours: 8,
      maxWeeklyTeacherHours: 20,
      minDailyTeacherHours: 2,
      maxDailyTeacherHours: 5,
      colourHex: '#000000',
    );

    final restored = SubjectModel.fromJson(subject.toJson());

    expect(restored.minDailyTeacherHours, 2);
    expect(restored.maxDailyTeacherHours, 5);
    expect(restored.minWeeklyTeacherHours, 8);
    expect(restored.maxWeeklyTeacherHours, 20);
  });
}