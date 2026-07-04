
class VerseModel {
  final int surah;
  final int ayah;

  final String arabic;

  final String kashmiriTranslation;
  final String bayanulFurqanTranslation;

  final String bayanulFurqanTafsir;
  final String ibnKathirTafsir;

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