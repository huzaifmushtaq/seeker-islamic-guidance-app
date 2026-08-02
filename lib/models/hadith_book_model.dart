class HadithBookModel {
  final int id;
  final int collectionId;
  final String englishTitle;
  final String arabicTitle;

  const HadithBookModel({
    required this.id,
    required this.collectionId,
    required this.englishTitle,
    required this.arabicTitle,
  });

  factory HadithBookModel.fromMap(
    Map<String, dynamic> map,
  ) {
    return HadithBookModel(
      id: map["id"] ?? 0,
      collectionId: map["bookId"] ?? 0,
      englishTitle: map["english"] ?? "",
      arabicTitle: map["arabic"] ?? "",
    );
  }
}