// lib/data/repositories/constraint_repository.dart
//
// FR-HC-04: Persist, stream, and delete hard + soft constraints.
// All documents live under /users/{uid}/schools/{schoolId}/constraints/.
// Nullable fields (classroomId, subjectId, etc.) follow the note in §3.6.3:
// inapplicable fields are stored as null — never omitted — so that
// Firestore queries can filter on them without index gaps.

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import 'package:classscheduler/providers/auth_providers.dart';

import '../../core/constants/app_constants.dart';
import '../models/app_models.dart';
import 'base_repository.dart';

// ── Provider ─────────────────────────────────────────────────────────────────

final constraintRepositoryProvider =
    Provider.family<ConstraintRepository, String>(
  (ref, schoolId) => ConstraintRepository(
    uid: ref.watch(currentUserProvider)!.uid,
    schoolId: schoolId,
  ),
);

// ── Repository ────────────────────────────────────────────────────────────────

class ConstraintRepository extends BaseRepository {
  final String uid;
  final String schoolId;

  ConstraintRepository({required this.uid, required this.schoolId});

  CollectionReference get _col =>
      subCol(uid, schoolId, AppConstants.fsConstraints);

  // ── Streams ──────────────────────────────────────────────────────────────

  /// All constraints for the school, ordered hard-first then by type.
  Stream<List<ConstraintModel>> watchAll() => streamCollection(
        ref: _col,
        fromJson: _fromSnap,
        queryBuilder: (q) => q
            .orderBy('kind', descending: false) // HARD before SOFT
            .orderBy('type', descending: false),
      );

  /// Only hard constraints — used by conflict detector.
  Stream<List<ConstraintModel>> watchHard() => streamCollection(
        ref: _col,
        fromJson: _fromSnap,
        queryBuilder: (q) =>
            q.where('kind', isEqualTo: 'HARD').orderBy('type'),
      );

  /// Only soft constraints.
  Stream<List<ConstraintModel>> watchSoft() => streamCollection(
        ref: _col,
        fromJson: _fromSnap,
        queryBuilder: (q) =>
            q.where('kind', isEqualTo: 'SOFT').orderBy('type'),
      );

  // ── Reads ────────────────────────────────────────────────────────────────

  Future<List<ConstraintModel>> fetchAll() => fetchCollection(
        ref: _col,
        fromJson: _fromSnap,
      );

  // ── Writes ───────────────────────────────────────────────────────────────

  Future<ConstraintModel> create(ConstraintModel constraint) async {
    final id    = const Uuid().v4();
    final model = constraint.copyWith(id: id, schoolId: schoolId);
    await _col.doc(id).set(_toDoc(model));
    return model;
  }

  Future<void> update(ConstraintModel constraint) async {
    await _col.doc(constraint.id).set(_toDoc(constraint));
  }

  /// Creates several constraints in one batch — used to expand an "all
  /// classrooms" / "all days" selection into one document per concrete
  /// (classroom, day) pair, since a single ConstraintModel can only ever
  /// target one of each.
  Future<void> createMany(List<ConstraintModel> constraints) async {
    final batch = db.batch();
    for (final c in constraints) {
      final id = const Uuid().v4();
      batch.set(_col.doc(id), _toDoc(c.copyWith(id: id, schoolId: schoolId)));
    }
    await batch.commit();
  }

  Future<void> delete(String constraintId) async {
    await _col.doc(constraintId).delete();
  }

  /// Deletes all constraints referencing a specific classroom.
  /// Called before a classroom is deleted (FR-CLS-02).
  Future<int> deleteForClassroom(String classroomId) async {
    final snap = await _col
        .where('classroomId', isEqualTo: classroomId)
        .get();
    final batch = db.batch();
    for (final doc in snap.docs) {
      batch.delete(doc.reference);
    }
    await batch.commit();
    return snap.docs.length;
  }

  /// Deletes all constraints referencing a specific subject.
  /// Called before a subject is deleted (FR-SUB-05).
  Future<int> deleteForSubject(String subjectId) async {
    final snap = await _col
        .where('subjectId', isEqualTo: subjectId)
        .get();
    final batch = db.batch();
    for (final doc in snap.docs) {
      batch.delete(doc.reference);
    }
    await batch.commit();
    return snap.docs.length;
  }

  // ── Serialisation helpers ────────────────────────────────────────────────

  static ConstraintModel _fromSnap(Map<String, dynamic> data, String id) =>
      ConstraintModel.fromJson({...data, 'id': id});

  /// Writes all fields explicitly — null fields are included so Firestore
  /// queries on nullable fields work correctly (§3.6.3 note).
  static Map<String, dynamic> _toDoc(ConstraintModel c) => {
        'schoolId':    c.schoolId,
        'kind':        c.kind,
        'type':        c.type,
        'classroomId': c.classroomId,
        'subjectId':   c.subjectId,
        'dayOfWeek':   c.dayOfWeek,
        'periodId':    c.periodId,
        'endPeriodId': c.endPeriodId,
        'weight':      c.weight,
        'minHours':    c.minHours,
        'maxHours':    c.maxHours,
      };
}
