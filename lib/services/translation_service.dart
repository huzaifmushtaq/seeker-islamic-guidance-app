import 'dart:convert';
import 'package:flutter/services.dart';

class TranslationService {
  Map<String, dynamic>? _translations;

  Future<Map<String, dynamic>> load() async {
    if (_translations != null) {
      return _translations!;
    }

    final jsonString = await rootBundle.loadString(
      'assets/quran/kashmiri.json',
    );

    _translations = json.decode(jsonString);

    return _translations!;
  }
}
