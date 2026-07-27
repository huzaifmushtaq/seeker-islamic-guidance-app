import 'package:shared_preferences/shared_preferences.dart';

enum TafsirType {
  bayanulFurqan,
  ibnKathir,
}

class TafsirPreferencesService {
  static const _key = "selected_tafsir";

  Future<void> setSelectedTafsir(
    TafsirType type,
  ) async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.setString(
      _key,
      type.name,
    );
  }

  Future<TafsirType> getSelectedTafsir() async {
    final prefs = await SharedPreferences.getInstance();

    final value = prefs.getString(_key);

    if (value == null) {
      return TafsirType.bayanulFurqan;
    }

    return TafsirType.values.firstWhere(
      (e) => e.name == value,
      orElse: () => TafsirType.bayanulFurqan,
    );
  }
}