import 'package:flutter/material.dart';

import '../../widgets/hadith/continue_hadith_card.dart';
import '../../widgets/hadith/hadith_collection_card.dart';
import '../../widgets/hadith/hadith_search_bar.dart';

class HadithScreen extends StatefulWidget {
  const HadithScreen({super.key});

  @override
  State<HadithScreen> createState() => _HadithScreenState();
}

class _HadithScreenState extends State<HadithScreen> {
  String searchQuery = "";

  final List<Map<String, dynamic>> collections = [
    {
      "title": "Sahih al-Bukhari",
      "subtitle": "Authentic Collection",
      "count": 7563,
      "cover": "assets/images/hadith/Book1.png",
    },
    {
      "title": "Sahih Muslim",
      "subtitle": "Authentic Collection",
      "count": 5362,
      "cover": "assets/images/hadith/Book2.png",
    },
    {
      "title": "Sunan Abu Dawud",
      "subtitle": "Collection of Sunnah",
      "count": 5274,
      "cover": "assets/images/hadith/Book3.png",
    },
    {
      "title": "Jami' at-Tirmidhi",
      "subtitle": "Collection of Hadith",
      "count": 3956,
      "cover": "assets/images/hadith/Book4.png",
    },
    {
      "title": "Sunan an-Nasa'i",
      "subtitle": "Collection of Sunnah",
      "count": 5758,
      "cover": "assets/images/hadith/Book5.png",
    },
    {
      "title": "Sunan Ibn Majah",
      "subtitle": "Collection of Hadith",
      "count": 4341,
      "cover": "assets/images/hadith/Book6.png",
    },
  ];

  @override
  Widget build(BuildContext context) {
    final filtered = collections.where((book) {
      final q = searchQuery.toLowerCase();
      return book["title"].toLowerCase().contains(q) ||
          book["subtitle"].toLowerCase().contains(q);
    }).toList();

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
  title: item["title"],
  subtitle: item["subtitle"],
  totalHadith: item["count"],
  coverImage: item["cover"],
                    onTap: () {},
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