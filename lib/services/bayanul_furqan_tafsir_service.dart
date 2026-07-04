import 'dart:convert';
import 'package:flutter/services.dart';

class BayanulFurqanTafsirService {
  Map<String, dynamic>? _tafsir;

  Future<Map<String, dynamic>> load() async {
    if (_tafsir != null) {
      return _tafsir!;
    }

    final jsonString = await rootBundle.loadString(
      'assets/quran/bayanulquran.json',
    );

    _tafsir = json.decode(jsonString);

    return _tafsir!;
  }
}