class SurahModel {
  final int id;
  final String name;
  final String nameSimple;
  final String nameArabic;
  final String revelationPlace;
  final int versesCount;

  const SurahModel({
    required this.id,
    required this.name,
    required this.nameSimple,
    required this.nameArabic,
    required this.revelationPlace,
    required this.versesCount,
  });

  factory SurahModel.fromJson(Map<String, dynamic> json) {
    return SurahModel(
      id: json["id"],
      name: json["name"],
      nameSimple: json["name_simple"],
      nameArabic: json["name_arabic"],
      revelationPlace: json["revelation_place"],
      versesCount: json["verses_count"],
    );
  }
}