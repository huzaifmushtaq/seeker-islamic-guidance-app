import 'dart:convert';

import 'package:flutter/services.dart';

import '../models/hadith_model.dart';

class HadithService {
  static const String _bukhariPath =
      'assets/hadith/by_book/the_9_books/bukhari.json';

  /// Loads all Hadith from Sahih al-Bukhari.
  Future<List<HadithModel>> loadBukhari() async {
    final jsonString = await rootBundle.loadString(_bukhariPath);

    final List<dynamic> jsonData = json.decode(jsonString);

    return jsonData
        .map((e) => HadithModel.fromMap(e as Map<String, dynamic>))
        .toList();
  }

  /// Returns one deterministic Hadith for today.
  ///
  /// The same Hadith will remain visible
  /// throughout the entire day.
  Future<HadithModel?> getTodayHadith() async {
    final hadiths = await loadBukhari();

    if (hadiths.isEmpty) {
      return null;
    }

    final now = DateTime.now();

    final startOfYear = DateTime(now.year, 1, 1);

    final dayOfYear = now.difference(startOfYear).inDays;

    final index = dayOfYear % hadiths.length;

    return hadiths[index];
  }
}
