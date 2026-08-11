import '../models/verse_model.dart';
import '../services/arabic_service.dart';
import '../services/translation_service.dart';
import '../services/bayanul_furqan_translation_service.dart';
import '../services/bayanul_furqan_tafsir_service.dart';
import '../utils/quran_constants.dart';

class QuranRepository {
  QuranRepository._();

  static final QuranRepository _instance = QuranRepository._();

  factory QuranRepository() => _instance;

  final ArabicService _arabic = ArabicService();
  final TranslationService _translation = TranslationService();
  final BayanulFurqanTranslationService _bayanTranslation =
      BayanulFurqanTranslationService();
  final BayanulFurqanTafsirService _bayanTafsir = BayanulFurqanTafsirService();

  final Map<int, List<VerseModel>> _cache = {};

  Future<List<VerseModel>> loadSurah(int surah, int verses) async {
    if (_cache.containsKey(surah)) {
      return _cache[surah]!;
    }

    final arabic = await _arabic.load();
    final translation = await _translation.load();
    final bayanTranslation = await _bayanTranslation.load();
    final bayanTafsir = await _bayanTafsir.load();

    final List<VerseModel> result = [];

    for (int ayah = 1; ayah <= verses; ayah++) {
      final key = "$surah:$ayah";

      String tafsir = "";

      final tafsirValue = bayanTafsir[key];

      if (tafsirValue is Map<String, dynamic>) {
        tafsir = tafsirValue["text"] ?? "";
      } else if (tafsirValue is String) {
        final original = bayanTafsir[tafsirValue];

        if (original is Map<String, dynamic>) {
          tafsir = original["text"] ?? "";
        }
      }

      result.add(
        VerseModel(
          surah: surah,
          ayah: ayah,
          arabic: arabic[key]?["text"] ?? "",
          kashmiriTranslation: translation[key]?["t"] ?? "",
          bayanulFurqanTranslation: bayanTranslation[key]?["t"] ?? "",
          bayanulFurqanTafsir: tafsir,
          ibnKathirTafsir: "",
        ),
      );
    }

    _cache[surah] = result;

    return result;
  }

  Future<VerseModel?> loadVerse(int surah, int ayah) async {
    final verses = await loadSurah(surah, surahVerseCounts[surah - 1]);

    if (ayah < 1 || ayah > verses.length) {
      return null;
    }

    return verses[ayah - 1];
  }

  Future<List<VerseModel>> loadAllVerses() async {
    final List<VerseModel> allVerses = [];

    for (int surah = 1; surah <= 114; surah++) {
      final verses = await loadSurah(surah, surahVerseCounts[surah - 1]);

      allVerses.addAll(verses);
    }

    return allVerses;
  }
}
