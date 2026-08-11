import 'dart:convert';

import 'package:flutter/services.dart';

import '../models/hadith_book_model.dart';

class HadithBookRepository {
  Future<List<HadithBookModel>> loadBooks({required String collection}) async {
    final jsonString = await rootBundle.loadString(
      "assets/hadith/by_book/the_9_books/$collection.json",
    );
    final Map<String, dynamic> json = jsonDecode(jsonString);

    final List chapters = json["chapters"] ?? [];

    return chapters.map((e) => HadithBookModel.fromMap(e)).toList();
  }
}
