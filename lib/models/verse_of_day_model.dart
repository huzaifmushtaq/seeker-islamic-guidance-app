class VerseOfDayModel {
  final int surah;
  final int ayah;
  final bool enabled;

  const VerseOfDayModel({
    required this.surah,
    required this.ayah,
    required this.enabled,
  });

  factory VerseOfDayModel.fromMap(Map<String, dynamic> map) {
    return VerseOfDayModel(
      surah: map["surah"] ?? 1,
      ayah: map["ayah"] ?? 1,
      enabled: map["enabled"] ?? true,
    );
  }
}
