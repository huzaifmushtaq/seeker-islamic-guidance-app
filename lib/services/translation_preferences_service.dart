import 'package:shared_preferences/shared_preferences.dart';

enum TranslationType { kashmiri, bayanulFurqan }

class TranslationPreferencesService {
  static const _key = "selected_translation";

  Future<void> setSelectedTranslation(TranslationType type) async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.setString(_key, type.name);
  }

  Future<TranslationType> getSelectedTranslation() async {
    final prefs = await SharedPreferences.getInstance();

    final value = prefs.getString(_key);

    if (value == null) {
      return TranslationType.kashmiri;
    }

    return TranslationType.values.firstWhere(
      (e) => e.name == value,
      orElse: () => TranslationType.kashmiri,
    );
  }
}
