import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/hadith_bookmark_model.dart';

class HadithBookmarkService {
  static const _key = "hadith_bookmarks";

  Future<List<HadithBookmarkModel>> loadBookmarks() async {
    final prefs = await SharedPreferences.getInstance();

    final json = prefs.getString(_key);

    if (json == null) return [];

    final List list = jsonDecode(json);

    return list.map((e) => HadithBookmarkModel.fromMap(e)).toList();
  }

  Future<void> saveBookmarks(List<HadithBookmarkModel> bookmarks) async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.setString(
      _key,
      jsonEncode(bookmarks.map((e) => e.toMap()).toList()),
    );
  }

  Future<bool> isBookmarked(int hadithId) async {
    final bookmarks = await loadBookmarks();

    return bookmarks.any((e) => e.hadithId == hadithId);
  }

  Future<void> addBookmark(HadithBookmarkModel bookmark) async {
    final bookmarks = await loadBookmarks();

    final exists = bookmarks.any((e) => e.hadithId == bookmark.hadithId);

    if (exists) return;

    bookmarks.add(bookmark);

    await saveBookmarks(bookmarks);
  }

  Future<void> removeBookmark(int hadithId) async {
    final bookmarks = await loadBookmarks();

    bookmarks.removeWhere((e) => e.hadithId == hadithId);

    await saveBookmarks(bookmarks);
  }

  Future<void> toggleBookmark(HadithBookmarkModel bookmark) async {
    final bookmarks = await loadBookmarks();

    final exists = bookmarks.any((e) => e.hadithId == bookmark.hadithId);

    if (exists) {
      bookmarks.removeWhere((e) => e.hadithId == bookmark.hadithId);
    } else {
      bookmarks.add(bookmark);
    }

    await saveBookmarks(bookmarks);
  }
}
