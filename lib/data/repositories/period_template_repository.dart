// lib/data/repositories/period_template_repository.dart
//
// CRUD for user-owned period templates.
// Firestore path: /users/{uid}/periodTemplates/{templateId}
//
// Templates are user-scoped (not school-scoped) — available across all schools.

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:classscheduler/providers/auth_providers.dart';

import '../models/period_template_model.dart';
import 'base_repository.dart';

// ── Providers ─────────────────────────────────────────────────────────────────

final periodTemplateRepositoryProvider =
    Provider<PeriodTemplateRepository>((ref) {
  final uid = ref.watch(currentUserProvider)!.uid;
  return PeriodTemplateRepository(uid: uid);
});

final periodTemplatesStreamProvider =
    StreamProvider<List<PeriodTemplateModel>>((ref) {
  return ref.watch(periodTemplateRepositoryProvider).watchAll();
});

// ── Repository ────────────────────────────────────────────────────────────────

class PeriodTemplateRepository extends BaseRepository {
  final String uid;

  PeriodTemplateRepository({required this.uid});

  get _col => db
      .collection('users')
      .doc(uid)
      .collection('periodTemplates');

  // ── Read ───────────────────────────────────────────────────────────────────

  Stream<List<PeriodTemplateModel>> watchAll() => streamCollection(
        ref: _col,
        fromJson: (data, id) =>
            PeriodTemplateModel.fromJson(data, id),
        queryBuilder: (q) => q.orderBy('createdAt'),
      );

  // ── Write ──────────────────────────────────────────────────────────────────

  Future<PeriodTemplateModel> save(PeriodTemplateModel template) async {
    final now = DateTime.now();
    final id  = template.id.isEmpty ? _col.doc().id : template.id;
    final t   = template.copyWith(
      id:        id,
      updatedAt: now,
      createdAt: template.id.isEmpty ? now : template.createdAt,
    );
    await _col.doc(id).set(t.toJson());
    return t;
  }

  Future<void> delete(String templateId) =>
      _col.doc(templateId).delete();
}
