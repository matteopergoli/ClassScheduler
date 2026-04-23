import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:sign_in_with_apple/sign_in_with_apple.dart';

class AuthException implements Exception {
  final String message;
  const AuthException(this.message);

  @override
  String toString() => message;
}

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();

  Stream<User?> get authStateChanges => _auth.authStateChanges();

  User? get currentUser => _auth.currentUser;

  Future<UserCredential> signInWithEmail({required String email, required String password}) async {
    try {
      return await _auth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
    } on FirebaseAuthException catch (e) {
      throw AuthException('Firebase error: ${e.code} — ${e.message}');
    } catch (e) {
      throw AuthException('Unknown error: ${e.runtimeType} — $e');
    }
  }

  Future<UserCredential> registerWithEmail({required String email, required String password}) async {
    try {
      return await _auth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
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
      return await _auth.signInWithCredential(credential);
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
      return await _auth.signInWithCredential(oAuthCredential);
    } on FirebaseAuthException catch (e) {
      throw AuthException('Firebase error: ${e.code} — ${e.message}');
    } catch (e) {
      throw AuthException('Unknown error: ${e.runtimeType} — $e');
    }
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
