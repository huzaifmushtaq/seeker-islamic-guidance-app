import 'dart:convert';

import 'package:flutter/services.dart';

import '../models/hadith_model.dart';

class HadithReaderRepository {
  Future<List<HadithModel>> loadHadiths({
    required String collection,
    required int chapterId,
  }) async {
    final jsonString = await rootBundle.loadString(
      "assets/hadith/by_chapter/the_9_books/$collection/$chapterId.json",
    );

    final Map<String, dynamic> json = jsonDecode(jsonString);

    final List hadiths = json["hadiths"] ?? [];

    return hadiths
        .map((e) => HadithModel.fromMap(e as Map<String, dynamic>))
        .toList();
  }
}
