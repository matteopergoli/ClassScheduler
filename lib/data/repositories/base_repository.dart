// lib/data/repositories/base_repository.dart
//
// Shared helpers used by every entity repository.
// Provides typed stream + future accessors and batched write support.

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:classscheduler/core/constants/app_constants.dart';

// Overridable Firestore provider — allows FakeFirebaseFirestore injection in tests
final firestoreProvider = Provider<FirebaseFirestore>(
  (ref) => FirebaseFirestore.instance,
);

abstract class BaseRepository {
  final FirebaseFirestore _db;

  BaseRepository({FirebaseFirestore? firestore})
      : _db = firestore ?? FirebaseFirestore.instance;

  FirebaseFirestore get db => _db;

  // ── Path helpers ──────────────────────────────────────────────────────────

  /// /users/{uid}
  DocumentReference userDoc(String uid) =>
      _db.collection(AppConstants.fsUsers).doc(uid);

  /// /users/{uid}/schools
  CollectionReference schoolsCol(String uid) =>
      userDoc(uid).collection(AppConstants.fsSchools);

  /// /users/{uid}/schools/{schoolId}
  DocumentReference schoolDoc(String uid, String schoolId) =>
      schoolsCol(uid).doc(schoolId);

  /// /users/{uid}/schools/{schoolId}/{sub}
  CollectionReference subCol(String uid, String schoolId, String sub) =>
      schoolDoc(uid, schoolId).collection(sub);

  // ── Typed stream helpers ──────────────────────────────────────────────────

  Stream<List<T>> streamCollection<T>({
    required CollectionReference ref,
    required T Function(Map<String, dynamic> data, String id) fromJson,
    Query Function(Query q)? queryBuilder,
  }) {
    Query q = ref;
    if (queryBuilder != null) q = queryBuilder(q);
    return q.snapshots().map((snap) => snap.docs
        .map((d) => fromJson(d.data() as Map<String, dynamic>, d.id))
        .toList());
  }

  Future<List<T>> fetchCollection<T>({
    required CollectionReference ref,
    required T Function(Map<String, dynamic> data, String id) fromJson,
    Query Function(Query q)? queryBuilder,
  }) async {
    Query q = ref;
    if (queryBuilder != null) q = queryBuilder(q);
    final snap = await q.get();
    return snap.docs
        .map((d) => fromJson(d.data() as Map<String, dynamic>, d.id))
        .toList();
  }

  Future<T?> fetchDocument<T>({
    required DocumentReference ref,
    required T Function(Map<String, dynamic> data, String id) fromJson,
  }) async {
    final snap = await ref.get();
    if (!snap.exists) return null;
    return fromJson(snap.data() as Map<String, dynamic>, snap.id);
  }

  /// Auto-generate a new document ID.
  String newId(CollectionReference ref) => ref.doc().id;
}
