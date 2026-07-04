import '../models/verse_model.dart';
import '../services/arabic_service.dart';
import '../services/translation_service.dart';

class QuranRepository {
  QuranRepository._();

  static final QuranRepository _instance =
      QuranRepository._();

  factory QuranRepository() => _instance;

  final ArabicService _arabic = ArabicService();
  final TranslationService _translation = TranslationService();

  final Map<int, List<VerseModel>> _cache = {};

 Future<List<VerseModel>> loadSurah(
  int surah,
  int verses,
) async {

  if (_cache.containsKey(surah)) {
    return _cache[surah]!;
  }

  final arabic = await _arabic.load();
  final translation = await _translation.load();

  final List<VerseModel> result = [];

  for (int ayah = 1; ayah <= verses; ayah++) {

    final key = "$surah:$ayah";

    result.add(
      VerseModel(
        ayah: ayah,

        arabic: arabic[key]?["text"] ?? "",

        translation:
            translation[key]?["t"] ?? "",
      ),
    );
  }

  _cache[surah] = result;

  return result;
}
}