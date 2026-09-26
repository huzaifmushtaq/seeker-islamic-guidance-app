class KnowledgeCardModel {
  final String id;
  final String type;
  final String titleUrdu;
  final String? narrator;
  final String translationUrdu;
  final String primarySource;
  final List<String> otherReferences;
  final String authenticity;
  final String? authenticCode;
  final String keyLesson;
  final String todaysAction;
  final String reflection;
  final String? translationNote;

  const KnowledgeCardModel({
    required this.id,
    required this.type,
    required this.titleUrdu,
    required this.narrator,
    required this.translationUrdu,
    required this.primarySource,
    required this.otherReferences,
    required this.authenticity,
    required this.authenticCode,
    required this.keyLesson,
    required this.todaysAction,
    required this.reflection,
    required this.translationNote,
  });

  factory KnowledgeCardModel.fromJson(Map<String, dynamic> json) {
    return KnowledgeCardModel(
      id: (json['id'] ?? '').toString(),
      type: (json['type'] ?? '').toString().toLowerCase(),
      titleUrdu: (json['title_urdu'] ?? '').toString(),
      narrator: json['narrator']?.toString(),
      translationUrdu: (json['translation_urdu'] ?? '').toString(),

      primarySource: (json['primary_source'] ?? '').toString(),

      otherReferences:
          (json['other_references'] as List<dynamic>? ?? const [])
              .map((e) => e.toString())
              .where((e) => e.trim().isNotEmpty)
              .toList(growable: false),

      authenticity: (json['authenticity'] ?? '').toString(),

      authenticCode: json['authentic_code']?.toString(),

      keyLesson: (json['key_lesson'] ?? '').toString(),

      todaysAction: (json['todays_action'] ?? '').toString(),

      reflection: (json['reflection'] ?? '').toString(),

      translationNote: json['translation_note']?.toString(),
    );
  }

  bool get isQuran => type == 'quran';
  bool get isHadith => type == 'hadith';
  bool get isDua => type == 'dua';

  String get categoryUrdu {
    if (isQuran) return 'قرآنِ کریم';
    if (isHadith) return 'حدیثِ نبوی ﷺ';
    if (isDua) return 'دعا';
    return 'علم';
  }

  String get categoryEnglish {
    if (isQuran) return 'Quran';
    if (isHadith) return 'Hadith';
    if (isDua) return 'Dua';
    return 'Knowledge';
  }
}