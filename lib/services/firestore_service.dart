import 'package:cloud_firestore/cloud_firestore.dart';

class FirestoreService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> createUser({
    required String uid,
    required String name,
    required String email,
  }) async {
    await _firestore.collection("users").doc(uid).set({
      "uid": uid,
      "name": name,
      "email": email,
      "profileImage": "",
      "streak": 0,
      "dhikrCount": 0,
      "lessonsCompleted": 0,
      "createdAt": FieldValue.serverTimestamp(),

      "progress": {"quran": 0, "books": 0, "classes": 0},

      "favorites": {"books": [], "audio": [], "duas": []},
    });
  }
}
