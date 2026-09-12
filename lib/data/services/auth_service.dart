import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:sign_in_with_apple/sign_in_with_apple.dart';

import 'analytics_service.dart';

class AuthException implements Exception {
  final String message;
  const AuthException(this.message);

  @override
  String toString() => message;
}

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final AnalyticsService _analytics = AnalyticsService();

  // OAuth *web* client ID of the Firebase project (from google-services.json,
  // client_type 3). Required on Android to obtain an idToken for Firebase when
  // the google-services Gradle plugin is not applied — without it Google
  // sign-in returns a null idToken and signInWithCredential fails.
  // A client ID is not a secret.
  static const String _googleServerClientId =
      '237070186843-dcff0lk2mikv6o2prk6fvlvlahbohhpk.apps.googleusercontent.com';

  final GoogleSignIn _googleSignIn = GoogleSignIn(
    serverClientId: kIsWeb ? null : _googleServerClientId,
  );

  Stream<User?> get authStateChanges => _auth.authStateChanges();

  User? get currentUser => _auth.currentUser;

  Future<UserCredential> signInWithEmail({required String email, required String password}) async {
    try {
      final credential = await _auth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
      await _logAuthEvent(credential, 'email');
      return credential;
    } on FirebaseAuthException catch (e) {
      throw AuthException('Firebase error: ${e.code} — ${e.message}');
    } catch (e) {
      throw AuthException('Unknown error: ${e.runtimeType} — $e');
    }
  }

  Future<UserCredential> registerWithEmail({required String email, required String password}) async {
    try {
      final credential = await _auth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
      await _logAuthEvent(credential, 'email');
      return credential;
    } on FirebaseAuthException catch (e) {
      throw AuthException('Firebase error: ${e.code} — ${e.message}');
    } catch (e) {
      throw AuthException('Unknown error: ${e.runtimeType} — $e');
    }
  }

  Future<UserCredential> signInWithGoogle() async {
    try {
      final googleUser = await _googleSignIn.signIn();
      if (googleUser == null) {
        throw const AuthException('Google sign-in was cancelled.');
      }
      final googleAuth = await googleUser.authentication;
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );
      final userCredential = await _auth.signInWithCredential(credential);
      await _logAuthEvent(userCredential, 'google');
      return userCredential;
    } on FirebaseAuthException catch (e) {
      throw AuthException('Firebase error: ${e.code} — ${e.message}');
    } catch (e) {
      throw AuthException('Unknown error: ${e.runtimeType} — $e');
    }
  }

  Future<UserCredential> signInWithApple() async {
    if (kIsWeb) {
      throw const AuthException('Apple Sign-In is not supported on Web.');
    }
    try {
      final appleCredential = await SignInWithApple.getAppleIDCredential(
        scopes: [
          AppleIDAuthorizationScopes.email,
          AppleIDAuthorizationScopes.fullName,
        ],
      );
      final oAuthCredential = OAuthProvider('apple.com').credential(
        idToken: appleCredential.identityToken,
        accessToken: appleCredential.authorizationCode,
      );
      final userCredential = await _auth.signInWithCredential(oAuthCredential);
      await _logAuthEvent(userCredential, 'apple');
      return userCredential;
    } on FirebaseAuthException catch (e) {
      throw AuthException('Firebase error: ${e.code} — ${e.message}');
    } catch (e) {
      throw AuthException('Unknown error: ${e.runtimeType} — $e');
    }
  }

  /// Logs `sign_up` on first-ever auth for this method, `login` otherwise —
  /// tells reach (installs) apart from returning users for the KPI dashboard.
  Future<void> _logAuthEvent(UserCredential credential, String method) {
    final isNewUser = credential.additionalUserInfo?.isNewUser ?? false;
    return isNewUser
        ? _analytics.logSignUp(method)
        : _analytics.logLogin(method);
  }

  Future<void> sendPasswordReset(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email.trim());
    } on FirebaseAuthException catch (e) {
      throw AuthException('Firebase error: ${e.code} — ${e.message}');
    } catch (e) {
      throw AuthException('Unknown error: ${e.runtimeType} — $e');
    }
  }

  Future<void> signOut() async {
    await _googleSignIn.signOut();
    await _auth.signOut();
  }

  Future<void> deleteAccount() async {
    try {
      await _auth.currentUser?.delete();
    } on FirebaseAuthException catch (e) {
      throw AuthException('Firebase error: ${e.code} — ${e.message}');
    } catch (e) {
      throw AuthException('Unknown error: ${e.runtimeType} — $e');
    }
  }
}
