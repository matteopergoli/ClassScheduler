// lib/data/repositories/period_classroom_capacity_repositories.dart
//
// Contains three repositories in one file to match the single-file
// delivery format. Imports are all at the top as Dart requires.

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:classscheduler/providers/auth_providers.dart';

import '../../core/constants/app_constants.dart';
import '../models/app_models.dart';
import 'base_repository.dart';

// ── PeriodRepository ─────────────────────────────────────────────────────────

final periodRepositoryProvider = Provider.family<PeriodRepository, String>(
    (ref, schoolId) => PeriodRepository(
        uid: ref.watch(currentUserProvider)!.uid, schoolId: schoolId));

class PeriodRepository extends BaseRepository {
  final String uid;
  final String schoolId;
  PeriodRepository({required this.uid, required this.schoolId});

  get _col => subCol(uid, schoolId, AppConstants.fsPeriods);

  Stream<List<PeriodModel>> watchAll() => streamCollection(
        ref: _col,
        fromJson: (data, id) => PeriodModel.fromJson({...data, 'id': id}),
        queryBuilder: (q) => q.orderBy('sortOrder'),
      );

  Future<List<PeriodModel>> fetchAll() => fetchCollection(
        ref: _col,
        fromJson: (data, id) => PeriodModel.fromJson({...data, 'id': id}),
        queryBuilder: (q) => q.orderBy('sortOrder'),
      );

  Future<PeriodModel> save(PeriodModel period) async {
    final id = period.id.isEmpty ? newId(_col) : period.id;
    final p  = period.copyWith(id: id, schoolId: schoolId);
    await _col.doc(id).set(p.toJson());
    return p;
  }

  Future<void> delete(String periodId) => _col.doc(periodId).delete();

  Future<void> reorder(List<PeriodModel> ordered) async {
    final batch = db.batch();
    for (var i = 0; i < ordered.length; i++) {
      batch.update(_col.doc(ordered[i].id), {'sortOrder': i});
    }
    await batch.commit();
  }
}

// ── ClassroomRepository ──────────────────────────────────────────────────────

final classroomRepositoryProvider =
    Provider.family<ClassroomRepository, String>((ref, schoolId) =>
        ClassroomRepository(
            uid: ref.watch(currentUserProvider)!.uid, schoolId: schoolId));

class ClassroomRepository extends BaseRepository {
  final String uid;
  final String schoolId;
  ClassroomRepository({required this.uid, required this.schoolId});

  get _col => subCol(uid, schoolId, AppConstants.fsClassrooms);

  Stream<List<ClassroomModel>> watchAll() => streamCollection(
        ref: _col,
        fromJson: (data, id) => ClassroomModel.fromJson({...data, 'id': id}),
        queryBuilder: (q) => q.orderBy('sortOrder'),
      );

  Future<List<ClassroomModel>> fetchAll() => fetchCollection(
        ref: _col,
        fromJson: (data, id) => ClassroomModel.fromJson({...data, 'id': id}),
        queryBuilder: (q) => q.orderBy('sortOrder'),
      );

  Future<ClassroomModel> save(ClassroomModel classroom) async {
    final id = classroom.id.isEmpty ? newId(_col) : classroom.id;
    final c  = classroom.copyWith(id: id, schoolId: schoolId);
    await _col.doc(id).set(c.toJson());
    return c;
  }

  Future<void> rename(String classroomId, String newName) =>
      _col.doc(classroomId).update({'name': newName.trim()});

  Future<void> delete(String classroomId) =>
      _col.doc(classroomId).delete();

  Future<int> count() async {
    final snap = await _col.count().get();
    return snap.count ?? 0;
  }
}

// ── DayCapacityRepository ────────────────────────────────────────────────────

final dayCapacityRepositoryProvider =
    Provider.family<DayCapacityRepository, String>((ref, schoolId) =>
        DayCapacityRepository(
            uid: ref.watch(currentUserProvider)!.uid, schoolId: schoolId));

class DayCapacityRepository extends BaseRepository {
  final String uid;
  final String schoolId;
  DayCapacityRepository({required this.uid, required this.schoolId});

  get _col => subCol(uid, schoolId, AppConstants.fsDayCapacities);

  String _docId(String classroomId, String day) =>
      DayCapacityModel.docId(classroomId, day);

  // ── Manual Firestore serialisation for DayCapacityModel ──────────────────
  // We bypass the freezed-generated toJson/fromJson entirely so that the
  // repository works correctly even before build_runner is re-run after the
  // maxLessons → activeSlots schema change.  The Firestore document format is:
  //   { schoolId, classroomId, dayOfWeek, activeSlots: [0,1,2,...] }
  // Legacy documents (maxLessons: int, no activeSlots) are handled by
  // _modelFromData().

  static DayCapacityModel _modelFromData(Map<String, dynamic> data) =>
      DayCapacityModel.fromLegacy(data);

  static Map<String, dynamic> _modelToData(DayCapacityModel m) => {
    'schoolId':    m.schoolId,
    'classroomId': m.classroomId,
    'dayOfWeek':   m.dayOfWeek,
    'activeSlots': m.activeSlots,   // List<int> — Firestore stores as array
  };

  Stream<List<DayCapacityModel>> watchAll() => streamCollection(
        ref: _col,
        fromJson: (data, _) => _modelFromData(data),
      );

  Future<List<DayCapacityModel>> fetchAll() => fetchCollection(
        ref: _col,
        fromJson: (data, _) => _modelFromData(data),
      );

  Future<List<DayCapacityModel>> fetchForClassroom(
      String classroomId) async {
    final snap = await _col
        .where('classroomId', isEqualTo: classroomId)
        .get();
    return snap.docs
        .map((d) => _modelFromData(d.data() as Map<String, dynamic>))
        .toList();
  }

  Future<void> set({
    required String      classroomId,
    required String      dayOfWeek,
    required List<int>   activeSlots,
  }) async {
    final model = DayCapacityModel(
      schoolId:    schoolId,
      classroomId: classroomId,
      dayOfWeek:   dayOfWeek,
      activeSlots: activeSlots,
    );
    await _col.doc(_docId(classroomId, dayOfWeek)).set(_modelToData(model));
  }

  Future<void> setAll({
    required String                    classroomId,
    required Map<String, List<int>>    dayToSlots,
  }) async {
    final batch = db.batch();
    dayToSlots.forEach((day, slots) {
      final model = DayCapacityModel(
        schoolId:    schoolId,
        classroomId: classroomId,
        dayOfWeek:   day,
        activeSlots: slots,
      );
      batch.set(_col.doc(_docId(classroomId, day)), _modelToData(model));
    });
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
}
