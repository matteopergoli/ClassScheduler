// lib/data/repositories/account_repository.dart
//
// Manages the /users/{uid}/account/data document.
// trialUsed is stored in Firestore (not device-local) to prevent
// reset via reinstallation (FR-TRIAL-02).

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:classscheduler/providers/auth_providers.dart';
import '../models/app_models.dart';
import '../../core/constants/app_constants.dart';
import 'base_repository.dart';

final accountRepositoryProvider = Provider<AccountRepository>(
    (ref) => AccountRepository(uid: ref.watch(currentUserProvider)!.uid));

class AccountRepository extends BaseRepository {
  final String uid;
  AccountRepository({required this.uid});

  DocumentReference get _ref => db
      .collection(AppConstants.fsUsers)
      .doc(uid)
      .collection(AppConstants.fsAccount)
      .doc('data');

  Stream<AccountModel?> watchAccount() => _ref.snapshots().map((snap) {
        if (!snap.exists) return null;
        return AccountModel.fromJson(snap.data() as Map<String, dynamic>);
      });

  Future<AccountModel?> fetchAccount() async {
    final snap = await _ref.get();
    if (!snap.exists) return null;
    return AccountModel.fromJson(snap.data() as Map<String, dynamic>);
  }

  /// Returns true if the trial has been used already.
  Future<bool> isTrialUsed(String uid) async {
    final account = await fetchAccount();
    return account?.trialUsed ?? false;
  }

  /// Alias for consumeTrial() — called by GenerationService.
  Future<void> markTrialUsed(String uid) => consumeTrial();

  /// Marks the trial as consumed (FR-TRIAL-02).
  /// Stored in Firestore — cannot be reset by reinstalling the app.
  Future<void> consumeTrial() async {
    await _ref.update({
      'trialUsed': true,
      'trialUsedAt': Timestamp.fromDate(DateTime.now()),
    });
  }
}

// ── Riverpod provider that exposes trial status reactively ────────────────────
final accountStreamProvider = StreamProvider<AccountModel?>((ref) {
  return ref.watch(accountRepositoryProvider).watchAccount();
});

final trialUsedProvider = Provider<bool>((ref) {
  final account = ref.watch(accountStreamProvider);
  return account.when(data: (a) => a?.trialUsed ?? false, loading: () => false, error: (_, __) => false);
});
