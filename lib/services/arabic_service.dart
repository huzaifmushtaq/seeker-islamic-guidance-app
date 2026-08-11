import 'dart:convert';
import 'package:flutter/services.dart';

class ArabicService {
  Map<String, dynamic>? _verses;

  Future<Map<String, dynamic>> load() async {
    if (_verses != null) {
      return _verses!;
    }

    final jsonString = await rootBundle.loadString('assets/quran/uthmani.json');

    _verses = json.decode(jsonString);

    return _verses!;
  }
}
