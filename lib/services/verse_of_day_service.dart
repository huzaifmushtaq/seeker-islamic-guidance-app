import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/verse_of_day_model.dart';

class VerseOfDayService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<VerseOfDayModel?> getVerseOfTheDay() async {
    try {
      final doc = await _firestore
          .collection("daily_content")
          .doc("verse_of_the_day")
          .get();

      if (!doc.exists) return null;

      return VerseOfDayModel.fromMap(doc.data()!);
    } catch (e) {
      return null;
    }
  }
}