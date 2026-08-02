class HadithCollectionModel {
  final String id;
  final String title;
  final String arabicTitle;
  final String author;
  final String introduction;
  final String assetPath;
  final String coverAsset;
  final int totalHadith;
  const HadithCollectionModel({
    required this.id,
    required this.title,
    required this.arabicTitle,
    required this.author,
    required this.introduction,
    required this.assetPath,
    required this.coverAsset,
    required this.totalHadith,
  });
}