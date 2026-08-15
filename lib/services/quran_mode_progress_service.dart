import 'package:shared_preferences/shared_preferences.dart';

enum QuranMode {
  arabic,
  tarjuma,
  tafsir,
}

class QuranProgress {
  final int surah;
  final int ayah;
  final int? page;

  const QuranProgress({
    required this.surah,
    required this.ayah,
    this.page,
  });
}

class QuranModeProgressService {
  String _prefix(QuranMode mode) {
    switch (mode) {
      case QuranMode.arabic:
        return 'quran_arabic';

      case QuranMode.tarjuma:
        return 'quran_tarjuma';

      case QuranMode.tafsir:
        return 'quran_tafsir';
    }
  }

  Future<void> saveProgress({
    required QuranMode mode,
    required int surah,
    required int ayah,
    int? page,
  }) async {
    final prefs =
        await SharedPreferences.getInstance();

    final prefix = _prefix(mode);

    await prefs.setInt(
      '${prefix}_surah',
      surah,
    );

    await prefs.setInt(
      '${prefix}_ayah',
      ayah,
    );

    if (page != null) {
      await prefs.setInt(
        '${prefix}_page',
        page,
      );
    }
  }

  Future<QuranProgress?> getProgress(
    QuranMode mode,
  ) async {
    final prefs =
        await SharedPreferences.getInstance();

    final prefix = _prefix(mode);

    final surah = prefs.getInt(
      '${prefix}_surah',
    );

    final ayah = prefs.getInt(
      '${prefix}_ayah',
    );

    if (surah == null || ayah == null) {
      return null;
    }

    return QuranProgress(
      surah: surah,
      ayah: ayah,
      page: prefs.getInt(
        '${prefix}_page',
      ),
    );
  }
}