// lib/data/repositories/constraint_set_repository.dart
//
// Named, savable/switchable snapshots of a school's Hard+Soft constraints —
// see ConstraintSetModel doc comment (lib/data/models/app_models.dart) for
// the storage-shape rationale. All documents live under
// /users/{uid}/schools/{schoolId}/constraintSets/.
//
// Applying a saved set back onto the live collection spans two different
// repositories (ConstraintRepository.replaceAll for the constraints
// themselves, ClassroomSubjectRepository.saveMany for HARD daily limits) —
// that orchestration lives in the UI layer (constraint_set_sheet.dart),
// same as constraint_form_screen.dart already coordinates those same two
// repositories for a single constraint's HARD daily limit.

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:classscheduler/providers/auth_providers.dart';

import '../../core/constants/app_constants.dart';
import '../models/app_models.dart';
import 'base_repository.dart';

// ── Provider ─────────────────────────────────────────────────────────────────

final constraintSetRepositoryProvider =
    Provider.family<ConstraintSetRepository, String>(
  (ref, schoolId) => ConstraintSetRepository(
    uid: ref.watch(currentUserProvider)!.uid,
    schoolId: schoolId,
  ),
);

// ── Repository ────────────────────────────────────────────────────────────────

class ConstraintSetRepository extends BaseRepository {
  final String uid;
  final String schoolId;

  ConstraintSetRepository({required this.uid, required this.schoolId});

  CollectionReference get _col =>
      subCol(uid, schoolId, AppConstants.fsConstraintSets);

  // ── Streams ──────────────────────────────────────────────────────────────

  /// All saved sets for the school, most recently saved first.
  Stream<List<ConstraintSetModel>> watchAll() => streamCollection(
        ref: _col,
        fromJson: _fromSnap,
        queryBuilder: (q) => q.orderBy('savedAt', descending: true),
      );

  // ── Writes ───────────────────────────────────────────────────────────────

  /// Saves the current constraints/daily-limits as a brand new named set.
  Future<ConstraintSetModel> create({
    required String name,
    required List<ConstraintModel> constraints,
    required List<Map<String, dynamic>> dailyLimits,
  }) async {
    final id = newId(_col);
    final model = ConstraintSetModel(
      id: id,
      schoolId: schoolId,
      name: name,
      savedAt: DateTime.now(),
      constraints: constraints.map((c) => c.toJson()).toList(),
      dailyLimits: dailyLimits,
    );
    await _col.doc(id).set(_toDoc(model));
    return model;
  }

  /// Overwrites an existing set's snapshot with the current constraints/
  /// daily-limits, bumping `savedAt` to reflect the update.
  Future<void> update(
    String setId, {
    required List<ConstraintModel> constraints,
    required List<Map<String, dynamic>> dailyLimits,
  }) async {
    await _col.doc(setId).update({
      'constraints': constraints.map((c) => c.toJson()).toList(),
      'dailyLimits': dailyLimits,
      'savedAt': Timestamp.fromDate(DateTime.now()),
    });
  }

  Future<void> rename(String setId, String newName) =>
      _col.doc(setId).update({'name': newName});

  Future<void> delete(String setId) => _col.doc(setId).delete();

  // ── Daily-limit snapshot helpers ───────────────────────────────────────
  //
  // Pure functions, not I/O — kept here since they're specific to this
  // model's storage shape, but callers do the actual reads/writes via
  // ClassroomSubjectRepository themselves.

  /// Builds the `dailyLimits` snapshot from the school's current
  /// classroom-subject assignments — every assignment is captured (not just
  /// ones with a customised limit) so a restore is a faithful rollback even
  /// for "no limit" states.
  static List<Map<String, dynamic>> snapshotDailyLimits(
    List<ClassroomSubjectModel> assignments,
  ) =>
      [
        for (final cs in assignments)
          {
            'classroomId': cs.classroomId,
            'subjectId': cs.subjectId,
            'minDailyHours': cs.minDailyHours,
            'maxDailyHours': cs.maxDailyHours,
          },
      ];

  /// Matches a saved `dailyLimits` snapshot back onto the school's current
  /// classroom-subject assignments by (classroomId, subjectId) — not by id,
  /// so a restore still works if the assignment doc was recreated since the
  /// set was saved. Entries whose pair no longer exists are skipped
  /// silently. Returns only the assignments that actually changed, ready
  /// for ClassroomSubjectRepository.saveMany(...).
  static List<ClassroomSubjectModel> resolveDailyLimits(
    List<Map<String, dynamic>> snapshot,
    List<ClassroomSubjectModel> currentAssignments,
  ) {
    final byKey = {
      for (final cs in currentAssignments) '${cs.classroomId}|${cs.subjectId}': cs,
    };
    final updates = <ClassroomSubjectModel>[];
    for (final entry in snapshot) {
      final key = '${entry['classroomId']}|${entry['subjectId']}';
      final cs = byKey[key];
      if (cs == null) continue;
      final min = entry['minDailyHours'] as int;
      final max = entry['maxDailyHours'] as int;
      if (cs.minDailyHours == min && cs.maxDailyHours == max) continue;
      updates.add(cs.copyWith(minDailyHours: min, maxDailyHours: max));
    }
    return updates;
  }

  // ── Serialisation helpers ────────────────────────────────────────────────

  static ConstraintSetModel _fromSnap(Map<String, dynamic> data, String id) =>
      ConstraintSetModel.fromJson({...data, 'id': id});

  static Map<String, dynamic> _toDoc(ConstraintSetModel s) => {
        'schoolId': s.schoolId,
        'name': s.name,
        'savedAt': Timestamp.fromDate(s.savedAt),
        'constraints': s.constraints,
        'dailyLimits': s.dailyLimits,
      };
}
