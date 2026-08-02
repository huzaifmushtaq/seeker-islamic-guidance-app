import 'package:flutter/material.dart';

import '../../widgets/hadith/continue_hadith_card.dart';
import '../../widgets/hadith/hadith_collection_card.dart';
import '../../widgets/hadith/hadith_search_bar.dart';
import '../../models/hadith_collection_model.dart';
import '../../repositories/hadith_library_repository.dart';
import 'hadith_books_screen.dart';

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
  

  @override
void initState() {
  super.initState();
  _loadCollections();
}

Future<void> _loadCollections() async {
  final loaded = await _repository.loadCollections();

  if (!mounted) return;

  setState(() {
    collections = loaded;
    isLoading = false;
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
                collectionName: "Sahih Muslim",
                bookName: "Book of Faith",
                hadithNumber: 145,
                onTap: () {},
              ),

              const SizedBox(height: 34),

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
    onTap: () {
  Navigator.push(
    context,
    MaterialPageRoute(
      builder: (_) => HadithBooksScreen(
        collection: item,
      ),
    ),
  );
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
}