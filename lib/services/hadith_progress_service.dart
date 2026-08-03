import 'package:shared_preferences/shared_preferences.dart';

class HadithProgressService {
  static const _collection = "hadith_collection";
  static const _chapter = "hadith_chapter";
  static const _index = "hadith_index";
  static const _title = "hadith_title";

  Future<void> saveProgress({
    required String collection,
    required int chapterId,
    required int index,
    required String title,
  }) async {
    final prefs =
        await SharedPreferences.getInstance();

    await prefs.setString(
        _collection, collection);

    await prefs.setInt(
        _chapter, chapterId);

    await prefs.setInt(
        _index, index);

    await prefs.setString(
        _title, title);
  }

  Future<Map<String, dynamic>?> loadProgress()
      async {
    final prefs =
        await SharedPreferences.getInstance();

    if (!prefs.containsKey(_collection)) {
      return null;
    }

    return {
      "collection":
          prefs.getString(_collection),
      "chapter":
          prefs.getInt(_chapter),
      "index":
          prefs.getInt(_index),
      "title":
          prefs.getString(_title),
    };
  }

  Future<void> clear() async {
    final prefs =
        await SharedPreferences.getInstance();

    await prefs.remove(_collection);
    await prefs.remove(_chapter);
    await prefs.remove(_index);
    await prefs.remove(_title);
  }
}