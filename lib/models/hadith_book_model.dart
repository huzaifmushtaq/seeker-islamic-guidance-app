class HadithBookModel {
  final int id;
  final int bookId;
  final String arabicTitle;
  final String englishTitle;

  const HadithBookModel({
    required this.id,
    required this.bookId,
    required this.arabicTitle,
    required this.englishTitle,
  });

  factory HadithBookModel.fromMap(
    Map<String, dynamic> map,
  ) {
    return HadithBookModel(
      id: (map["id"] as num).toInt(),
      bookId: (map["bookId"] as num).toInt(),
      arabicTitle: map["arabic"] ?? "",
      englishTitle: map["english"] ?? "",
    );
  }
}