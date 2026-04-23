// test/helpers/fake_firebase.dart
//
// Provides a pre-configured FakeFirebaseFirestore instance and a
// ProviderContainer wired to use it for all repository providers.
// Used by all integration / acceptance tests so they never touch real Firebase.

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mockito/mockito.dart';

import 'package:classscheduler/data/services/auth_service.dart';

// ── Mock Firebase User ────────────────────────────────────────────────────

class MockUser extends Mock implements User {
  @override
  final String uid;
  MockUser(this.uid);
}

class MockFirebaseAuth extends Mock implements FirebaseAuth {
  final User _user;
  MockFirebaseAuth(this._user);

  @override
  User? get currentUser => _user;

  @override
  Stream<User?> authStateChanges() => Stream.value(_user);
}

// ── Test container factory ────────────────────────────────────────────────

const testUid = 'test-user-001';

/// Returns a [ProviderContainer] whose [FirebaseFirestore] and
/// [FirebaseAuth] are replaced with fakes.
///
/// All repositories read [currentUserProvider] which is overridden to
/// return our [MockUser].
ProviderContainer makeTestContainer({
  FakeFirebaseFirestore? fakeFirestore,
}) {
  final firestore = fakeFirestore ?? FakeFirebaseFirestore();
  final mockUser  = MockUser(testUid);
  final mockAuth  = MockFirebaseAuth(mockUser);

  return ProviderContainer(
    overrides: [
      // Override the auth provider so repositories get our test user
      currentUserProvider.overrideWith((ref) => mockUser),
      // Override Firestore instance used by base_repository.dart
      firestoreProvider.overrideWithValue(firestore),
    ],
  );
}

// ── Seed helpers ──────────────────────────────────────────────────────────

/// Seeds /users/{uid}/account with trialUsed=false so tests start clean.
Future<void> seedAccount(
  FakeFirebaseFirestore db, {
  bool trialUsed = false,
}) async {
  await db
      .collection('users')
      .doc(testUid)
      .collection('account')
      .doc('data')
      .set({
    'trialUsed':   trialUsed,
    'trialUsedAt': null,
    'createdAt':   Timestamp.now(),
  });
}
