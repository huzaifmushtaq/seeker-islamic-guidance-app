import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

import 'firestore_service.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirestoreService _firestoreService = FirestoreService();

  User? get currentUser => _auth.currentUser;

  Stream<User?> get authStateChanges => _auth.authStateChanges();

  Future<String?> register({
    required String name,
    required String email,
    required String password,
  }) async {
    try {
      final credential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      final user = credential.user;

      if (user == null) {
        return "Account could not be created. Please try again.";
      }

      await _firestoreService.createUser(
        uid: user.uid,
        name: name,
        email: email,
      );

      try {
        await user.sendEmailVerification();
        debugPrint("Verification email request accepted.");
      } on FirebaseAuthException catch (e) {
        debugPrint("Verification email error: ${e.code}");
        debugPrint(e.message);
        return "Account created, but the verification email could not be sent. ${_emailActionErrorMessage(e)}";
      } catch (e) {
        debugPrint(e.toString());
        return "Account created, but the verification email could not be sent. Please use Resend Email on the verification screen.";
      }

      return null;
    } on FirebaseAuthException catch (e) {
      return _authErrorMessage(e);
    } catch (e) {
      debugPrint(e.toString());
      return "Something went wrong. Please try again.";
    }
  }

  Future<String?> login({
    required String email,
    required String password,
  }) async {
    try {
      await _auth.signInWithEmailAndPassword(email: email, password: password);

      return null;
    } on FirebaseAuthException catch (e) {
      return _authErrorMessage(e);
    } catch (e) {
      debugPrint(e.toString());
      return "Something went wrong. Please try again.";
    }
  }

  Future<void> logout() async {
    await _auth.signOut();
  }

  Future<String?> resetPassword(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
      debugPrint("Password reset email request accepted.");
      return null;
    } on FirebaseAuthException catch (e) {
      debugPrint("Password reset email error: ${e.code}");
      debugPrint(e.message);
      return _emailActionErrorMessage(e);
    } catch (e) {
      debugPrint(e.toString());
      return "Unable to send password reset email. Please try again.";
    }
  }

  String _authErrorMessage(FirebaseAuthException e) {
    switch (e.code) {
      case "email-already-in-use":
        return "Email already exists.";
      case "weak-password":
        return "Password is too weak.";
      case "invalid-email":
        return "Invalid email address.";
      case "user-not-found":
      case "wrong-password":
      case "invalid-credential":
        return "Invalid email or password.";
      case "network-request-failed":
        return "Network error. Please check your connection and try again.";
      case "too-many-requests":
        return "Too many requests. Please wait a while and try again.";
      case "user-disabled":
        return "This account has been disabled.";
      default:
        return e.message ?? "Authentication failed. Please try again.";
    }
  }

  String _emailActionErrorMessage(FirebaseAuthException e) {
    switch (e.code) {
      case "invalid-email":
        return "Invalid email address.";
      case "missing-email":
        return "Please enter your email address.";
      case "network-request-failed":
        return "Network error. Please check your connection and try again.";
      case "too-many-requests":
        return "Too many requests. Please wait a while and try again.";
      case "user-disabled":
        return "This account has been disabled.";
      default:
        return e.message ?? "Please try again later.";
    }
  }
}
