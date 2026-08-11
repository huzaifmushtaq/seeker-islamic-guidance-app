import 'package:seeker/services/translation_preferences_service.dart';
import '../services/tafsir_preferences_service.dart';

class VerseModel {
  final int surah;
  final int ayah;

  final String arabic;

  final String kashmiriTranslation;
  final String bayanulFurqanTranslation;

  final String bayanulFurqanTafsir;
  final String ibnKathirTafsir;

  String translation(TranslationType type) {
    switch (type) {
      case TranslationType.kashmiri:
        return kashmiriTranslation;

      case TranslationType.bayanulFurqan:
        return bayanulFurqanTranslation;
    }
  }

  String tafsir(TafsirType type) {
    switch (type) {
      case TafsirType.bayanulFurqan:
        return bayanulFurqanTafsir;

      case TafsirType.ibnKathir:
        return ibnKathirTafsir;
    }
  }

  const VerseModel({
    required this.surah,
    required this.ayah,
    required this.arabic,
    required this.kashmiriTranslation,
    required this.bayanulFurqanTranslation,
    required this.bayanulFurqanTafsir,
    required this.ibnKathirTafsir,
  });
}
