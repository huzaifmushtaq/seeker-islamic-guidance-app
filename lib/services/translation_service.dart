import 'dart:convert';
import 'package:flutter/services.dart';

class TranslationService {
  static final TranslationService instance =
      TranslationService._();

  TranslationService._();

  Map<String, dynamic>? _data;

  Future<void> load() async {
    if (_data != null) return;

    final jsonString = await rootBundle.loadString(
      'assets/quran/translation_en.json',
    );

    _data = json.decode(jsonString);
  }

  String verse(int surah, int ayah) {
    return _data?["$surah:$ayah"] ?? "";
  }
}