import 'dart:convert';

import 'package:flutter/services.dart';

import '../models/surah_model.dart';

import '../models/juz_model.dart';
List<JuzModel>? _juzCache;
Future<List<JuzModel>> loadJuzs() async {
  if (_juzCache != null) return _juzCache!;

  final jsonString = await rootBundle.loadString(
    'assets/quran/metadata/juz_list.json',
  );

  final Map<String, dynamic> json = jsonDecode(jsonString);

  _juzCache = json.values
      .map((e) => JuzModel.fromJson(e))
      .toList();

  return _juzCache!;
}

class QuranService {
  List<SurahModel>? _cache;

  Future<List<SurahModel>> loadSurahs() async {
    if (_cache != null) return _cache!;

    final jsonString = await rootBundle.loadString(
      'assets/quran/metadata/surah_names.json',
    );

    final Map<String, dynamic> json = jsonDecode(jsonString);

    _cache = json.values
        .map((e) => SurahModel.fromJson(e))
        .toList();

    return _cache!;
  }
}