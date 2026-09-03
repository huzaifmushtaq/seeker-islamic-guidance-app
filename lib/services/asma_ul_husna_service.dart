import 'package:shared_preferences/shared_preferences.dart';

class AsmaUlHusnaService {
  static const _learnedKey = 'asma_ul_husna_learned';
  static const _favoriteKey = 'asma_ul_husna_favorites';

  Future<Set<int>> loadLearned() async {
    final prefs = await SharedPreferences.getInstance();
    return (prefs.getStringList(_learnedKey) ?? [])
        .map(int.tryParse)
        .whereType<int>()
        .toSet();
  }

  Future<Set<int>> loadFavorites() async {
    final prefs = await SharedPreferences.getInstance();
    return (prefs.getStringList(_favoriteKey) ?? [])
        .map(int.tryParse)
        .whereType<int>()
        .toSet();
  }

  Future<void> setLearned(int number, bool value) async {
    final prefs = await SharedPreferences.getInstance();
    final values = (prefs.getStringList(_learnedKey) ?? [])
        .map(int.tryParse)
        .whereType<int>()
        .toSet();

    value ? values.add(number) : values.remove(number);
    await prefs.setStringList(
      _learnedKey,
      values.map((e) => e.toString()).toList(),
    );
  }

  Future<void> setFavorite(int number, bool value) async {
    final prefs = await SharedPreferences.getInstance();
    final values = (prefs.getStringList(_favoriteKey) ?? [])
        .map(int.tryParse)
        .whereType<int>()
        .toSet();

    value ? values.add(number) : values.remove(number);
    await prefs.setStringList(
      _favoriteKey,
      values.map((e) => e.toString()).toList(),
    );
  }
}
