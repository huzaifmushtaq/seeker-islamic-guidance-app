import 'package:flutter/material.dart';
import '../../widgets/hadith/continue_hadith_card.dart';
import '../../widgets/hadith/hadith_collection_card.dart';
import '../../widgets/hadith/hadith_search_bar.dart';
import '../../models/hadith_collection_model.dart';
import '../../repositories/hadith_library_repository.dart';
import 'hadith_books_screen.dart';
import '../../services/hadith_progress_service.dart';
import 'hadith_reader_screen.dart';
import '../../widgets/hadith/bookmarks_card.dart';
import '../../services/hadith_bookmark_service.dart';
import 'bookmarks_screen.dart';

class HadithScreen extends StatefulWidget {
  const HadithScreen({super.key});

  @override
  State<HadithScreen> createState() => _HadithScreenState();
}

class _HadithScreenState extends State<HadithScreen> {
  String searchQuery = "";
final HadithLibraryRepository _repository =
    HadithLibraryRepository();
    List<HadithCollectionModel> collections = [];
    bool isLoading = true;
  final HadithProgressService _progress =
    HadithProgressService();
final HadithBookmarkService _bookmarkService =
    HadithBookmarkService();

int bookmarkCount = 0;
Map<String, dynamic>? lastRead;

  @override
void initState() {
  super.initState();
  _loadCollections();
  _loadLastRead();
  _loadBookmarkCount();

}

Future<void> _loadCollections() async {
  final loaded = await _repository.loadCollections();

  if (!mounted) return;

  setState(() {
    collections = loaded;
    isLoading = false;
  });
}
Future<void> _loadLastRead() async {
  lastRead = await _progress.loadProgress();

  if (!mounted) return;

  setState(() {});
}
Future<void> _loadBookmarkCount() async {
  final bookmarks =
      await _bookmarkService.loadBookmarks();

  if (!mounted) return;

  setState(() {
    bookmarkCount = bookmarks.length;
  });
}
  @override
  Widget build(BuildContext context) {
   final filtered = collections;

    return Scaffold(
      backgroundColor: const Color(0xffFBF8F1),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 18, 20, 30),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [

              /// SEARCH
              HadithSearchBar(
                onChanged: (value) {
                  setState(() {
                    searchQuery = value;
                  });
                },
              ),

              const SizedBox(height: 28),

              /// CONTINUE READING
             ContinueHadithCard(
  collectionName: lastRead == null
      ? "Start Reading"
      : _collectionTitle(
          lastRead!["collection"] as String,
        ),

  bookName: lastRead == null
      ? "Choose any collection"
      : lastRead!["title"] as String,

  hadithNumber: lastRead == null
      ? 0
      : (lastRead!["index"] as int) + 1,
onTap: () async {
  if (lastRead == null) return;

  await Navigator.push(
    context,
    MaterialPageRoute(
      builder: (_) => HadithReaderScreen(
        collection: lastRead!["collection"],
        chapterId: lastRead!["chapter"],
        title: lastRead!["title"],
        initialIndex: lastRead!["index"],
      ),
    ),
  );

  await _loadLastRead();
  await _loadBookmarkCount();
},
    ),

              const SizedBox(height: 18),
BookmarksCard(
  totalBookmarks: bookmarkCount,
  onTap: () async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const BookmarksScreen(),
      ),
    );

    await _loadBookmarkCount();
  },
),

const SizedBox(height: 30),

              /// TITLE
              Row(
                children: [
                  const Expanded(
                    child: Text(
                      "Library",
                      style: TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.bold,
                        color: Color(0xff12372A),
                      ),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xffF6EFD9),
                      borderRadius: BorderRadius.circular(50),
                    ),
                    child: Text(
                      "${filtered.length} Books",
                      style: const TextStyle(
                        color: Color(0xff0E5A56),
                        fontWeight: FontWeight.w700,
                        fontSize: 13,
                      ),
                    ),
                  )
                ],
              ),

              const SizedBox(height: 6),

              const Text(
                "Explore the six authentic collections of Hadith.",
                style: TextStyle(
                  color: Colors.black54,
                  fontSize: 14,
                ),
              ),

              const SizedBox(height: 24),

              /// BOOK GRID
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: filtered.length,
                gridDelegate:
                    const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 18,
                  mainAxisSpacing: 22,
                  childAspectRatio: .67,
                ),
               itemBuilder: (context, index) {
  final item = filtered[index];

  return HadithCollectionCard(
    title: item.title,
    subtitle: item.introduction,
    totalHadith: item.totalHadith,
    coverImage: item.coverAsset,
   onTap: () async {
  await Navigator.push(
    context,
    MaterialPageRoute(
      builder: (_) => HadithBooksScreen(
        collection: item,
      ),
    ),
  );

  await _loadLastRead();
  await _loadBookmarkCount();
},
  );
},
              ),

              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }
  String _collectionTitle(String id) {
  switch (id) {
    case "bukhari":
      return "Sahih al-Bukhari";

    case "muslim":
      return "Sahih Muslim";

    case "abudawud":
      return "Sunan Abu Dawud";

    case "tirmidhi":
      return "Jami' at-Tirmidhi";

    case "nasai":
      return "Sunan an-Nasa'i";

    case "ibnmajah":
      return "Sunan Ibn Majah";

    default:
      return id;
  }
}
}