import 'package:shared_preferences/shared_preferences.dart';

import '../models/last_read_model.dart';

class ReadingProgressService {
  static const _pageKey = 'last_read_page';
  static const _surahKey = 'last_read_surah';
  static const _ayahKey = 'last_read_ayah';

  Future<void> saveLastRead({
    required int page,
    required int surah,
    required int ayah,
  }) async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.setInt(_pageKey, page);
    await prefs.setInt(_surahKey, surah);
    await prefs.setInt(_ayahKey, ayah);
  }

  Future<LastReadModel?> getLastRead() async {
    final prefs = await SharedPreferences.getInstance();

    final page = prefs.getInt(_pageKey);
    final surah = prefs.getInt(_surahKey);
    final ayah = prefs.getInt(_ayahKey);

    if (page == null || surah == null || ayah == null) {
      return null;
    }

    return LastReadModel(page: page, surah: surah, ayah: ayah);
  }

  Future<void> clearLastRead() async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.remove(_pageKey);
    await prefs.remove(_surahKey);
    await prefs.remove(_ayahKey);
  }
}
