import 'package:flutter/material.dart';

class SearchScreen extends StatelessWidget {
  const SearchScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 93, 112, 113),

      body: SingleChildScrollView(
        child: Column(
          children: [

            /// HEADER
            Container(
              height: 200,
              width: double.infinity,

              decoration: const BoxDecoration(
                image: DecorationImage(
                  image: AssetImage(
                    "assets/images/search.png",
                  ),
                  fit: BoxFit.cover,
                ),
              ),

              child: const SafeArea(
                child: Padding(
                  padding: EdgeInsets.all(20),

                  child: Column(
                    crossAxisAlignment:
                        CrossAxisAlignment.start,

                    children: [

                      

                      Text(
                        "Search",
                        style: TextStyle(
                          color: Color(0xFFF4D17D),
                          fontSize: 30,
                          fontWeight: FontWeight.bold,
                        ),
                      ),

                      SizedBox(height: 2),

                      Text(
                        "Find knowledge, guidance\nand answers",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            /// SEARCH BAR
            Transform.translate(
              offset: const Offset(0, -30),

              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                ),

                child: Row(
                  children: [

                    Expanded(
                      child: Container(
                        height: 50,

                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius:
                              BorderRadius.circular(22),

                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(
                                alpha: 0.08,
                              ),
                              blurRadius: 10,
                              offset: const Offset(
                                0,
                                8,
                              ),
                            ),
                          ],
                        ),

                        child: const TextField(
                          textAlignVertical:
                              TextAlignVertical.center,

                          decoration: InputDecoration(
                            border: InputBorder.none,

                            prefixIcon: Icon(
                              Icons.search,
                              color: Colors.grey,
                            ),

                            hintText:
                                "Search books, hadith, duas...",

                            hintStyle: TextStyle(
                              color: Color.fromARGB(251, 120, 120, 91),
                              fontWeight:
                                  FontWeight.w500,
                              fontSize: 12,
                            ),

                            contentPadding:
                                EdgeInsets.symmetric(
                              vertical: 18,
                            ),
                          ),
                        ),
                      ),
                    ),

                    SizedBox(width: 9),

                    Container(
                      width: 70,
                      height: 55,

                      decoration: BoxDecoration(
                        color: Color.fromARGB(
                          245,
                          246,
                          226,
                          94,
                        ),
                        borderRadius:
                            BorderRadius.circular(22),

                        boxShadow: [
                          BoxShadow(
                            color: Colors.black12,
                            blurRadius: 15,
                            offset: Offset(0, 4),
                          ),
                        ],
                      ),

                      child: Icon(
                        Icons.tune,
                        color: Color(0xFF8C6A35),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 5),

SizedBox(
  height: 95,

  child: ListView(
    scrollDirection: Axis.horizontal,

    padding: const EdgeInsets.symmetric(
      horizontal: 15,
    ),

    children: [

      _searchChip(
        "assets/icons/L3.png",
        "Books",
        true,
      ),

      _searchChip(
        "assets/icons/Hadith.png",
        "Hadith",
        false,
      ),

      _searchChip(
        "assets/icons/L5.png",
        "Duas",
        false,
      ),

      _searchChip(
        "assets/icons/quranshareef.png",
        "Quran",
        false,
      ),

      _searchChip(
        "assets/icons/L6.png",
        "Audio",
        false,
      ),

      _searchChip(
        "assets/icons/L2.png",
        "Tareeqat",
        false,
      ),
    ],
  ),
),
Padding(
  padding: EdgeInsets.symmetric(
    horizontal: 15,
  ),

  child: Align(
    alignment: Alignment.centerLeft,

    child: Text(
      "Popular Searches",
      style: TextStyle(
        fontSize: 22,
        fontWeight: FontWeight.bold,
        fontStyle: FontStyle.italic,
      ),
    ),
  ),
),
const SizedBox(height: 12),

Padding(
  padding: EdgeInsets.symmetric(
    horizontal: 15,
  ),

  child: Wrap(
    spacing: 10,
    runSpacing: 10,

    children: [

      _searchTag("Patience"),
      _searchTag("Tawakkul"),
      _searchTag("Repentance"),
      _searchTag("Dhikr"),
      _searchTag("Prayer"),
      _searchTag("Love of Allah"),
    ],
  ),
),
const SizedBox(height: 25),

Padding(
  padding: EdgeInsets.symmetric(
    horizontal: 15,
  ),

  child: Align(
    alignment: Alignment.centerLeft,

    child: Text(
      "Recent Searches",
      style: TextStyle(
        fontSize: 22,
        fontWeight: FontWeight.bold,
        fontStyle: FontStyle.italic,
      ),
    ),
  ),
),
Padding(
  padding: const EdgeInsets.all(15),

  child: Column(
    children: [

      _recentItem("Kashf-ul-Mahjoob"),
      _recentItem("Morning Dua"),
      _recentItem("Surah Yaseen"),
      _recentItem("Imam Ghazali"),
    ],
  ),
),
const SizedBox(height: 15),

Padding(
  padding: const EdgeInsets.symmetric(
    horizontal: 15,
  ),

  child: Container(
    height: 183,
    width: double.infinity,

    decoration: BoxDecoration(
      borderRadius: BorderRadius.circular(24),

      image: const DecorationImage(
        image: AssetImage(
          "assets/images/sfooter.png",
        ),
        fit: BoxFit.cover,
      ),
    ),

    child: Padding(
      padding: const EdgeInsets.all(24),

      child: Column(
  mainAxisAlignment:
      MainAxisAlignment.center,

  crossAxisAlignment:
      CrossAxisAlignment.center,

        children: [

          const Text(
            "Daily Wisdom",
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Color(0xFFF4D17D),
              fontSize: 18,
              fontWeight: FontWeight.bold,
              fontStyle: FontStyle.italic
            ),
          ),

          const SizedBox(height: 12),

          const Text(
            "The best among you are those who have \nthe best manners and character!",
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.white,
              fontSize: 12,
              height: 1.5,
            ),
          ),

          const SizedBox(height: 15),

          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 14,
              vertical: 8,
            ),

            decoration: BoxDecoration(
              color: const Color(0xFFF4D17D),
              borderRadius:
                  BorderRadius.circular(14),
            ),

            child: const Text(
              "Prophet Muhammad (SAW)",
              style: TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    ),
  ),
),

const SizedBox(height: 10),
          ],
        ),
      ),
    );
  }
}
Widget _searchChip(
  String icon,
  String title,
  bool selected,
) {
  return Container(
    width: 72,
    margin: const EdgeInsets.only(
      right: 10,
    ),

    child: Column(
      children: [

        Container(
          width: 58,
          height: 58,

          decoration: BoxDecoration(
            color: selected
                ? const Color(0xFF0B4B4B)
                : const Color(0xFFF8F3EA),

            borderRadius:
                BorderRadius.circular(18),
          ),

          child: Center(
            child: Image.asset(
              icon,
              width: 24,
              height: 24,
            ),
          ),
        ),

        const SizedBox(height: 5),

        Text(
          title,
          style: TextStyle(
            fontSize: 11,
            color: selected
                ? const Color(0xFF0B4B4B)
                : Colors.black87,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    ),
  );
}
Widget _searchTag(String title) {
  return Container(
    padding: const EdgeInsets.symmetric(
      horizontal: 14,
      vertical: 8,
    ),

    decoration: BoxDecoration(
      color: const Color(0xFFF4D17D),
      borderRadius: BorderRadius.circular(18),
    ),

    child: Text(title),
  );
}
Widget _recentItem(String title) {
  return ListTile(
    leading: const Icon(
      Icons.history,
      color: Color(0xFF0B4B4B),
    ),

    title: Text(title),

    trailing: const Icon(
      Icons.north_west,
      size: 18,
    ),
  );
}