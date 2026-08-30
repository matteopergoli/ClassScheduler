// lib/presentation/constraints/constraint_data_providers.dart
//
// Shared Firestore stream providers for the Constraints tab (list screen +
// add/edit form). A single, shared instance per school ID — not one private
// copy per file — so both screens always see the exact same subjects,
// classrooms, periods, etc. Previously the form screen declared its own
// private copies of these providers; that duplication was harmless in
// principle (Riverpod would just open a second, independent Firestore
// listener) but made the two screens' data paths diverge for no reason,
// which is exactly the kind of thing worth ruling out when a screen shows
// empty dropdowns that another screen with "the same" data doesn't.

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/models/app_models.dart';
import '../../data/repositories/constraint_repository.dart';
import '../../data/repositories/constraint_set_repository.dart';
import '../../data/repositories/period_classroom_capacity_repositories.dart';
import '../../data/repositories/subject_repositories.dart';

/// Which school the Constraints tab is currently showing. Deliberately its
/// own provider rather than the app-wide `selectedSchoolIdProvider`: that
/// one gets silently auto-set to the first school as soon as the Schools
/// tab (the app's home screen) loads, which meant the "pick a school"
/// picker below never actually showed on first visit — a school was
/// already "selected" before the user ever got here. Set explicitly by the
/// picker itself, or by the "Constraints" shortcut on a school card.
final constraintsActiveSchoolProvider = StateProvider<String?>((ref) => null);

final constraintsListProvider =
    StreamProvider.family<List<ConstraintModel>, String>(
  (ref, schoolId) =>
      ref.watch(constraintRepositoryProvider(schoolId)).watchAll(),
);

/// Named, switchable snapshots of a school's Hard+Soft constraints — see
/// ConstraintSetModel (app_models.dart) and ConstraintSetSheet.
final constraintSetsProvider =
    StreamProvider.family<List<ConstraintSetModel>, String>(
  (ref, schoolId) =>
      ref.watch(constraintSetRepositoryProvider(schoolId)).watchAll(),
);

final constraintSubjectsProvider =
    StreamProvider.family<List<SubjectModel>, String>(
  (ref, schoolId) =>
      ref.watch(subjectRepositoryProvider(schoolId)).watchAll(),
);

final constraintClassroomsProvider =
    StreamProvider.family<List<ClassroomModel>, String>(
  (ref, schoolId) =>
      ref.watch(classroomRepositoryProvider(schoolId)).watchAll(),
);

final constraintPeriodsProvider =
    StreamProvider.family<List<PeriodModel>, String>(
  (ref, schoolId) =>
      ref.watch(periodRepositoryProvider(schoolId)).watchAll(),
);

final constraintClassroomSubjectsProvider =
    StreamProvider.family<List<ClassroomSubjectModel>, String>(
  (ref, schoolId) =>
      ref.watch(classroomSubjectRepositoryProvider(schoolId)).watchAll(),
);

final constraintDayCapacitiesProvider =
    StreamProvider.family<List<DayCapacityModel>, String>(
  (ref, schoolId) =>
      ref.watch(dayCapacityRepositoryProvider(schoolId)).watchAll(),
);
