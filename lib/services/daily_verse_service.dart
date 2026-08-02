import '../models/verse_model.dart';
import '../repositories/quran_repository.dart';

class DailyVerseService {
  final QuranRepository _repository = QuranRepository();

  List<VerseModel>? _cache;

  Future<VerseModel> getTodaysVerse() async {
    if (_cache == null) {
      final allVerses = await _repository.loadAllVerses();

      _cache = allVerses.where((verse) {
        return verse.arabic.trim().length <= 85;
      }).toList();
    }

    final today = DateTime.now();

    final dayIndex = today
            .difference(DateTime(2026, 1, 1))
            .inDays %
        _cache!.length;

    return _cache![dayIndex];
  }
}