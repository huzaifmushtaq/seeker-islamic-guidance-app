import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'firestore_service.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirestoreService _firestoreService = FirestoreService();

  User? get currentUser => _auth.currentUser;

  Stream<User?> get authStateChanges =>
      _auth.authStateChanges();

  Future<String?> register({
    required String name,
    required String email,
    required String password,
  }) async {
    try {
      UserCredential credential =
          await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      await _firestoreService.createUser(
        uid: credential.user!.uid,
        name: name,
        email: email,
      );

      try {
        await credential.user!.sendEmailVerification();

        debugPrint(
            "✅ Verification email sent successfully.");
      } on FirebaseAuthException catch (e) {
        debugPrint(
            "❌ Verification Error: ${e.code}");
        debugPrint(e.message);
      } catch (e) {
        debugPrint(e.toString());
      }

      return null;
    } on FirebaseAuthException catch (e) {
      switch (e.code) {
        case "email-already-in-use":
          return "Email already exists.";

        case "weak-password":
          return "Password is too weak.";

        case "invalid-email":
          return "Invalid email address.";

        default:
          return e.message;
      }
    }
  }

  Future<String?> login({
    required String email,
    required String password,
  }) async {
    try {
      await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      return null;
    } on FirebaseAuthException catch (e) {
      switch (e.code) {
        case "user-not-found":
          return "No account found.";

        case "wrong-password":
          return "Incorrect password.";

        case "invalid-credential":
          return "Invalid email or password.";

        case "invalid-email":
          return "Invalid email address.";

        default:
          return e.message;
      }
    }
  }

  Future<void> logout() async {
    await _auth.signOut();
  }

  Future<String?> resetPassword(
      String email) async {
    try {
      await _auth.sendPasswordResetEmail(
        email: email,
      );

      debugPrint(
          "✅ Password reset email sent.");

      return null;
    } on FirebaseAuthException catch (e) {
      debugPrint(
          "❌ Password Reset Error: ${e.code}");
      debugPrint(e.message);

      return e.message;
    } catch (e) {
      debugPrint(e.toString());
      return e.toString();
    }
  }
}