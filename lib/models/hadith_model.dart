class HadithModel {
  final int id;
  final int idInBook;
  final int bookId;
  final int chapterId;

  final String arabic;
  final String narrator;
  final String english;

  const HadithModel({
    required this.id,
    required this.idInBook,
    required this.bookId,
    required this.chapterId,
    required this.arabic,
    required this.narrator,
    required this.english,
  });

  factory HadithModel.fromMap(Map<String, dynamic> map) {
    final english = map["english"] as Map<String, dynamic>? ?? {};

    return HadithModel(
      id: map["id"] ?? 0,
      idInBook: map["idInBook"] ?? 0,
      bookId: map["bookId"] ?? 0,
      chapterId: map["chapterId"] ?? 0,
      arabic: map["arabic"] ?? "",
      narrator: english["narrator"] ?? "",
      english: (map["english"]?["text"] ?? "")
          .replaceAll(RegExp(r'\n\s*'), ' ')
          .replaceAll(RegExp(r'\s+'), ' ')
          .trim(),
    );
  }
}
