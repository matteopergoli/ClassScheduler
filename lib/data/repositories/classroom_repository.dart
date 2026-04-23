import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/app_models.dart';
import '../../core/constants/app_constants.dart';

final classroomRepositoryProvider = Provider.family<ClassroomRepository, String>((ref, schoolId) {
  return ClassroomRepository(schoolId: schoolId);
});

class ClassroomRepository {
  final String schoolId;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  ClassroomRepository({required this.schoolId});

  CollectionReference<Map<String, dynamic>> get _collection => _firestore
      .collection(AppConstants.fsUsers)
      .doc('CURRENT_USER_ID') // Nota: Idealmente passa l'UID dall'authService
      .collection(AppConstants.fsSchools)
      .doc(schoolId)
      .collection(AppConstants.fsClassrooms);

  Stream<List<ClassroomModel>> watchAll() {
    return _collection
        .orderBy('sortOrder')
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => ClassroomModel.fromJson({...doc.data(), 'id': doc.id}))
            .toList());
  }

  Future<void> save(ClassroomModel classroom) async {
    await _collection.doc(classroom.id).set(classroom.toJson());
  }

  Future<void> delete(String id) async {
    await _collection.doc(id).delete();
  }
}