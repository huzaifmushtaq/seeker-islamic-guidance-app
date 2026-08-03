import 'package:flutter/material.dart';

import '../../models/hadith_bookmark_model.dart';
import '../../services/hadith_bookmark_service.dart';
import 'hadith_reader_screen.dart';

class BookmarksScreen extends StatefulWidget {
  const BookmarksScreen({super.key});

  @override
  State<BookmarksScreen> createState() =>
      _BookmarksScreenState();
}

class _BookmarksScreenState
    extends State<BookmarksScreen> {
  final HadithBookmarkService _service =
      HadithBookmarkService();

  List<HadithBookmarkModel> bookmarks = [];

  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadBookmarks();
  }

  Future<void> _loadBookmarks() async {
    final loaded =
        await _service.loadBookmarks();

    if (!mounted) return;

    setState(() {
      bookmarks = loaded.reversed.toList();
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    return Scaffold(
      backgroundColor:
          const Color(0xffFBF8F1),

      appBar: AppBar(
        backgroundColor:
            const Color(0xffFBF8F1),
        elevation: 0,
        centerTitle: true,
        title: const Text(
          "Bookmarks",
          style: TextStyle(
            color: Color(0xff12372A),
            fontWeight: FontWeight.bold,
          ),
        ),
      ),

      body: bookmarks.isEmpty
          ? const Center(
              child: Text(
                "No bookmarks yet.",
                style: TextStyle(
                  fontSize: 17,
                ),
              ),
            )
          : ListView.builder(
              padding:
                  const EdgeInsets.all(18),
              itemCount: bookmarks.length,
              itemBuilder: (
                context,
                index,
              ) {
                final bookmark =
                    bookmarks[index];

                return Card(
                  margin:
                      const EdgeInsets.only(
                    bottom: 14,
                  ),
                  elevation: 0,
                  shape:
                      RoundedRectangleBorder(
                    borderRadius:
                        BorderRadius.circular(
                            18),
                    side: const BorderSide(
                      color:
                          Color(0xffE8DFC9),
                    ),
                  ),
                  child: ListTile(
                    contentPadding:
                        const EdgeInsets.all(
                            16),

                    leading: const Icon(
                      Icons.bookmark,
                      color:
                          Color(0xffB28B34),
                    ),

                    title: Text(
                      bookmark.chapterTitle,
                      style:
                          const TextStyle(
                        fontWeight:
                            FontWeight.bold,
                      ),
                    ),

                    subtitle: Padding(
                      padding:
                          const EdgeInsets.only(
                              top: 6),
                      child: Text(
                        bookmark.english,
                        maxLines: 2,
                        overflow:
                            TextOverflow
                                .ellipsis,
                      ),
                    ),

                    trailing: Text(
                      "#${bookmark.hadithId}",
                      style:
                          const TextStyle(
                        color:
                            Color(0xff0E5A56),
                        fontWeight:
                            FontWeight.bold,
                      ),
                    ),
onTap: () {
  Navigator.push(
    context,
    MaterialPageRoute(
      builder: (_) => HadithReaderScreen(
        collection: bookmark.collection,
        chapterId: bookmark.chapterId,
        title: bookmark.chapterTitle,
        initialIndex: bookmark.hadithIndex,
      ),
    ),
  );
                    },
                  ),
                );
              },
            ),
    );
  }
}