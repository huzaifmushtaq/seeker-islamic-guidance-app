class QuranAyah {
  final int id;
  final String verseKey;
  final int surah;
  final int ayah;
  final String text;

  const QuranAyah({
    required this.id,
    required this.verseKey,
    required this.surah,
    required this.ayah,
    required this.text,
  });

  factory QuranAyah.fromMap(Map<String, dynamic> map) {
    return QuranAyah(
      id: map['id'] as int,
      verseKey: map['verse_key'] as String,
      surah: map['surah'] as int,
      ayah: map['ayah'] as int,
      text: map['text'] as String,
    );
  }
}