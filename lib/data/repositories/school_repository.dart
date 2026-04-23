// lib/data/repositories/school_repository.dart

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:classscheduler/providers/auth_providers.dart';
import '../models/app_models.dart';
import 'base_repository.dart';

final schoolRepositoryProvider = Provider<SchoolRepository>(
    (ref) => SchoolRepository(uid: ref.watch(currentUserProvider)!.uid));

class SchoolRepository extends BaseRepository {
  final String uid;
  SchoolRepository({required this.uid});

  CollectionReference get _col => schoolsCol(uid);

  // ── Streams ───────────────────────────────────────────────────────────────

  Stream<List<SchoolModel>> watchAll() => streamCollection(
        ref: _col,
        fromJson: (data, id) => SchoolModel.fromJson({...data, 'id': id}),
        queryBuilder: (q) => q.orderBy('updatedAt', descending: true),
      );

  // ── Reads ─────────────────────────────────────────────────────────────────

  Future<SchoolModel?> fetch(String schoolId) => fetchDocument(
        ref: _col.doc(schoolId),
        fromJson: (data, id) => SchoolModel.fromJson({...data, 'id': id}),
      );

  // ── Writes ────────────────────────────────────────────────────────────────

  Future<SchoolModel> create({required String name, String? description}) async {
    final id  = newId(_col);
    final now = DateTime.now();
    final school = SchoolModel(
      id: id,
      name: name.trim(),
      description: description?.trim(),
      createdAt: now,
      updatedAt: now,
    );
    await _col.doc(id).set(school.toJson());
    return school;
  }

  Future<void> update(SchoolModel school) async {
    final updated = school.copyWith(updatedAt: DateTime.now());
    await _col.doc(school.id).set(updated.toJson());
  }

  Future<void> rename(String schoolId, String newName) async {
    await _col.doc(schoolId).update({
      'name': newName.trim(),
      'updatedAt': Timestamp.fromDate(DateTime.now()),
    });
  }

  /// Duplicates a school by copying its Firestore document only.
  /// Sub-collections (periods, classrooms, etc.) are copied by the caller
  /// or via a dedicated duplication flow in the UI.
  Future<SchoolModel> duplicate(SchoolModel original) async {
    final id  = newId(_col);
    final now = DateTime.now();
    final copy = original.copyWith(
      id: id,
      name: '${original.name} (copy)',
      createdAt: now,
      updatedAt: now,
    );
    await _col.doc(id).set(copy.toJson());
    return copy;
  }

  /// Deletes the school document. Sub-collection cleanup is handled by
  /// the caller (SchoolService) which performs a batched recursive delete.
  Future<void> delete(String schoolId) async {
    await _col.doc(schoolId).delete();
  }

  /// Updates the updatedAt timestamp (used after schedule generation).
  Future<void> touch(String schoolId) async {
    await _col.doc(schoolId).update({
      'updatedAt': Timestamp.fromDate(DateTime.now()),
    });
  }
}

// ── Convenience stream providers used by UI screens ──────────────────────────

final schoolsStreamProvider =
    StreamProvider<List<SchoolModel>>((ref) {
  final user = ref.watch(currentUserProvider);
  if (user == null) return const Stream.empty();
  return SchoolRepository(uid: user.uid).watchAll();
});
