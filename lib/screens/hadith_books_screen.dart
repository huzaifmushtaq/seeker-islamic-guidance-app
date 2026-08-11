import 'package:flutter/material.dart';

import '../../models/hadith_book_model.dart';
import '../../models/hadith_collection_model.dart';
import '../../repositories/hadith_book_repository.dart';
import 'hadith_reader_screen.dart';

class HadithBooksScreen extends StatefulWidget {
  final HadithCollectionModel collection;

  const HadithBooksScreen({super.key, required this.collection});

  @override
  State<HadithBooksScreen> createState() => _HadithBooksScreenState();
}

class _HadithBooksScreenState extends State<HadithBooksScreen> {
  final HadithBookRepository _repository = HadithBookRepository();

  List<HadithBookModel> books = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadBooks();
  }

  Future<void> _loadBooks() async {
    final loaded = await _repository.loadBooks(
      collection: widget.collection.id,
    );

    if (!mounted) return;

    setState(() {
      books = loaded;
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffFBF8F1),

      appBar: AppBar(
        backgroundColor: const Color(0xffFBF8F1),
        elevation: 0,
        centerTitle: true,
        title: Text(
          widget.collection.title,
          style: const TextStyle(
            color: Color(0xff12372A),
            fontWeight: FontWeight.bold,
          ),
        ),
        iconTheme: const IconThemeData(color: Color(0xff12372A)),
      ),

      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView.separated(
              padding: const EdgeInsets.all(20),
              itemCount: books.length,
              separatorBuilder: (_, _) => const SizedBox(height: 14),
              itemBuilder: (context, index) {
                final book = books[index];

                return Card(
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(18),
                    side: const BorderSide(color: Color(0xffE7DCC1)),
                  ),
                  child: ListTile(
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 18,
                      vertical: 12,
                    ),

                    leading: CircleAvatar(
                      backgroundColor: const Color(0xffF6EFD9),
                      child: Text(
                        "${book.id}",
                        style: const TextStyle(
                          color: Color(0xff12372A),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),

                    title: Text(
                      book.englishTitle,
                      style: const TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 16,
                      ),
                    ),

                    subtitle: Padding(
                      padding: const EdgeInsets.only(top: 4),
                      child: Text(
                        book.arabicTitle,
                        textDirection: TextDirection.rtl,
                        style: const TextStyle(
                          fontSize: 18,
                          fontFamily: 'Amiri',
                        ),
                      ),
                    ),

                    trailing: const Icon(Icons.arrow_forward_ios, size: 18),

                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => HadithReaderScreen(
                            collection: widget.collection.id,
                            chapterId: book.id,
                            title: book.englishTitle,
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
