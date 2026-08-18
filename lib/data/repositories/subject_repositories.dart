// lib/data/repositories/subject_repositories.dart
//
// Contains SubjectRepository and ClassroomSubjectRepository in one file.
// All imports are at the top as Dart requires.

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:classscheduler/providers/auth_providers.dart';

import '../../core/constants/app_constants.dart';
import '../models/app_models.dart';
import 'base_repository.dart';

// ── SubjectRepository ────────────────────────────────────────────────────────

final subjectRepositoryProvider =
    Provider.family<SubjectRepository, String>((ref, schoolId) =>
        SubjectRepository(
            uid: ref.watch(currentUserProvider)!.uid, schoolId: schoolId));

class SubjectRepository extends BaseRepository {
  final String uid;
  final String schoolId;
  SubjectRepository({required this.uid, required this.schoolId});

  get _col => subCol(uid, schoolId, AppConstants.fsSubjects);

  Stream<List<SubjectModel>> watchAll() => streamCollection(
        ref: _col,
        fromJson: (data, id) => SubjectModel.fromJson({...data, 'id': id}),
        queryBuilder: (q) => q.orderBy('name'),
      );

  Future<List<SubjectModel>> fetchAll() => fetchCollection(
        ref: _col,
        fromJson: (data, id) => SubjectModel.fromJson({...data, 'id': id}),
        queryBuilder: (q) => q.orderBy('name'),
      );

  Future<SubjectModel> save(SubjectModel subject) async {
    final id = subject.id.isEmpty ? newId(_col) : subject.id;
    final s  = subject.copyWith(id: id, schoolId: schoolId);
    await _col.doc(id).set(s.toJson());
    return s;
  }

  Future<void> delete(String subjectId) =>
      _col.doc(subjectId).delete();
}

// ── ClassroomSubjectRepository ───────────────────────────────────────────────

final classroomSubjectRepositoryProvider =
    Provider.family<ClassroomSubjectRepository, String>((ref, schoolId) =>
        ClassroomSubjectRepository(
            uid: ref.watch(currentUserProvider)!.uid, schoolId: schoolId));

class ClassroomSubjectRepository extends BaseRepository {
  final String uid;
  final String schoolId;
  ClassroomSubjectRepository({required this.uid, required this.schoolId});

  get _col => subCol(uid, schoolId, AppConstants.fsClassroomSubjects);

  /// Streams ALL classroom–subject assignments for this school.
  /// Used by Step 4 so the UI refreshes automatically after any save/delete.
  Stream<List<ClassroomSubjectModel>> watchAll() => streamCollection(
        ref: _col,
        fromJson: (data, id) =>
            ClassroomSubjectModel.fromJson({...data, 'id': id}),
      );

  Stream<List<ClassroomSubjectModel>> watchForClassroom(
          String classroomId) =>
      streamCollection(
        ref: _col,
        fromJson: (data, id) =>
            ClassroomSubjectModel.fromJson({...data, 'id': id}),
        queryBuilder: (q) =>
            q.where('classroomId', isEqualTo: classroomId),
      );

  Future<List<ClassroomSubjectModel>> fetchForClassroom(
      String classroomId) =>
      fetchCollection(
        ref: _col,
        fromJson: (data, id) =>
            ClassroomSubjectModel.fromJson({...data, 'id': id}),
        queryBuilder: (q) =>
            q.where('classroomId', isEqualTo: classroomId),
      );

  Future<List<ClassroomSubjectModel>> fetchAll() => fetchCollection(
        ref: _col,
        fromJson: (data, id) =>
            ClassroomSubjectModel.fromJson({...data, 'id': id}),
      );

  Future<ClassroomSubjectModel> save(ClassroomSubjectModel cs) async {
    final id    = cs.id.isEmpty ? newId(_col) : cs.id;
    final model = cs.copyWith(id: id);
    await _col.doc(id).set(model.toJson());
    return model;
  }

  /// Saves several assignments in one batch — used when a hard daily limit
  /// is applied to "all classrooms" a subject is taught in at once.
  Future<void> saveMany(List<ClassroomSubjectModel> assignments) async {
    final batch = db.batch();
    for (final cs in assignments) {
      final id = cs.id.isEmpty ? newId(_col) : cs.id;
      batch.set(_col.doc(id), cs.copyWith(id: id).toJson());
    }
    await batch.commit();
  }

  Future<void> delete(String id) => _col.doc(id).delete();

  Future<void> deleteForSubject(String subjectId) async {
    final snap =
        await _col.where('subjectId', isEqualTo: subjectId).get();
    final batch = db.batch();
    for (final d in snap.docs) {
      batch.delete(d.reference);
    }
    await batch.commit();
  }

  Future<void> deleteForClassroom(String classroomId) async {
    final snap =
        await _col.where('classroomId', isEqualTo: classroomId).get();
    final batch = db.batch();
    for (final d in snap.docs) {
      batch.delete(d.reference);
    }
    await batch.commit();
  }

  /// FR-SUB-03: teacher aggregate hours across all classrooms.
  Future<Map<String, int>> teacherAggregateHours(
      List<SubjectModel> subjects) async {
    final allCs      = await fetchAll();
    final subjectMap = {for (final s in subjects) s.id: s};
    final Map<String, int> totals = {};
    for (final cs in allCs) {
      final subject = subjectMap[cs.subjectId];
      if (subject == null) continue;
      totals[subject.teacherName] =
          (totals[subject.teacherName] ?? 0) + cs.weeklyTargetHours;
    }
    return totals;
  }
}
