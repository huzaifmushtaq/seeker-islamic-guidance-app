class HadithBookmarkModel {
  final String collection;
  final int chapterId;
  final String chapterTitle;
  final int hadithIndex;
  final int hadithId;
  final String arabic;
  final String english;
  final DateTime savedAt;

  const HadithBookmarkModel({
    required this.collection,
    required this.chapterId,
    required this.chapterTitle,
    required this.hadithIndex,
    required this.hadithId,
    required this.arabic,
    required this.english,
    required this.savedAt,
  });

  Map<String, dynamic> toMap() {
    return {
      "collection": collection,
      "chapterId": chapterId,
      "chapterTitle": chapterTitle,
      "hadithIndex": hadithIndex,
      "hadithId": hadithId,
      "arabic": arabic,
      "english": english,
      "savedAt": savedAt.millisecondsSinceEpoch,
    };
  }

  factory HadithBookmarkModel.fromMap(
    Map<String, dynamic> map,
  ) {
    return HadithBookmarkModel(
      collection: map["collection"],
      chapterId: map["chapterId"],
      chapterTitle: map["chapterTitle"],
      hadithIndex: map["hadithIndex"],
      hadithId: map["hadithId"],
      arabic: map["arabic"],
      english: map["english"],
      savedAt: DateTime.fromMillisecondsSinceEpoch(
        map["savedAt"],
      ),
    );
  }
}