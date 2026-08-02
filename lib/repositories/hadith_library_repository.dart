import 'dart:convert';
import 'package:flutter/services.dart';
import '../models/hadith_collection_model.dart';

class HadithLibraryRepository {
  HadithLibraryRepository._();

  static final HadithLibraryRepository _instance =
      HadithLibraryRepository._();

  factory HadithLibraryRepository() => _instance;

  Future<Map<String, dynamic>> loadJson(
    String assetPath,
  ) async {
    final jsonString =
        await rootBundle.loadString(assetPath);

    return jsonDecode(jsonString)
        as Map<String, dynamic>;
  }
  Future<Map<String, dynamic>> loadCollectionMetadata(
  String collection,
) async {final json = await loadJson(
  "assets/hadith/by_book/the_9_books/$collection.json",
);

  return json["metadata"] as Map<String, dynamic>;
}
Future<List<HadithCollectionModel>> loadCollections() async {
  final collections = [
    "bukhari",
    "muslim",
    "abudawud",
    "tirmidhi",
    "nasai",
    "ibnmajah",
  ];

  final List<HadithCollectionModel> result = [];

  for (final collection in collections) {
    final metadata =
        await loadCollectionMetadata(collection);

    result.add(
      HadithCollectionModel(
  id: collection,
  title: metadata["english"]["title"] ?? "",
  arabicTitle: metadata["arabic"]["title"] ?? "",
  author: metadata["english"]["author"] ?? "",
  introduction: metadata["english"]["introduction"] ?? "",
  totalHadith: metadata["length"] ?? 0,
  assetPath: "assets/hadith/by_book/the_9_books/$collection.json",
  coverAsset: "assets/images/hadith/${_coverImage(collection)}",
),
    );
  }

  return result;
}
String _coverImage(String collection) {
  switch (collection) {
    case "bukhari":
      return "Book1.png";
    case "muslim":
      return "Book2.png";
    case "abudawud":
      return "Book3.png";
    case "tirmidhi":
      return "Book4.png";
    case "nasai":
      return "Book5.png";
    case "ibnmajah":
      return "Book6.png";
    default:
      return "Book1.png";
  }
}
}