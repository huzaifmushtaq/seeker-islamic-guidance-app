import 'package:flutter/material.dart';

class LibraryScreen extends StatelessWidget {
  const LibraryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F8F8),

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
                    'assets/images/library-top.png',
                  ),
                  fit: BoxFit.cover,
                ),
              ),

              child: SafeArea(
                child: Padding(
                  padding: const EdgeInsets.all(20),

                  child: Column(
                    crossAxisAlignment:
                        CrossAxisAlignment.start,

                    children: [

                      Row(
                        mainAxisAlignment:
                            MainAxisAlignment.spaceBetween,

                        children: [

                          
                        ],
                      ),

                     

                      const Text(
                        "Library",
                        style: TextStyle(
                          color: Color(0xFFF4D17D),
                          fontSize: 30,
                          fontWeight: FontWeight.bold,
                          fontFamily: "Georgia",
                        ),
                      ),

                      const SizedBox(height: 4),

                      const Text(
                        "A world of knowledge. \nA path to closeness.",
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
            


Padding(
  padding: const EdgeInsets.symmetric(
    horizontal: 20,
  ),

  child: GridView.count(
    crossAxisCount: 2,
    shrinkWrap: true,
    physics:
        const NeverScrollableScrollPhysics(),

    crossAxisSpacing: 8,
    mainAxisSpacing: 8,

    childAspectRatio: 1.35,

    children: [

  _categoryCard(
    "assets/icons/L1.png",
    "Islamic Books",
    "General Knowledge",
  ),

  _categoryCard(
    "assets/icons/L2.png",
    "Tasawwuf",
    "Inner Purification",
  ),

  _categoryCard(
    "assets/icons/L3.png",
    "Quran & Tafsir",
    "Translation ",
  ),

  _categoryCard(
    "assets/icons/L4.png",
    "Hadith",
    "Authentic Collections",
  ),

  _categoryCard(
    "assets/icons/L5.png",
    "Duas",
    "Supplications",
  ),

  _categoryCard(
    "assets/icons/L6.png",
    "Audio Library",
    "Bayans & Naats",
    
  ),
],
  ),
),
  const SizedBox(height: 10),

Padding(
  padding: const EdgeInsets.symmetric(
    horizontal: 15,
  ),
  

  child: Row(
    mainAxisAlignment:
        MainAxisAlignment.spaceBetween,

    children: [

      const Text( 
        "Continue Reading",
        style: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          fontStyle: FontStyle.italic,
        ),
      ),

      TextButton(
        onPressed: () {},

        child: const Text(
          "View All > ",
          style: TextStyle(
            fontSize: 10,
            color: Colors.black87,
            fontWeight: FontWeight.bold,
            fontStyle: FontStyle.italic
          ),
        ),
      ),
    ],
  ),
),
const SizedBox(height: 10),
Padding(
  padding: const EdgeInsets.symmetric(
    horizontal: 15,
  ),

  child: Container(
    padding: const EdgeInsets.all(16),

    decoration: BoxDecoration(
      color: Color.fromARGB(255, 228, 213, 178),
      borderRadius: BorderRadius.circular(24),

      boxShadow: [
        BoxShadow(
          color: Colors.black.withValues(
            alpha: 0.05,
          ),
          blurRadius: 10,
          offset: const Offset(0, 4),
        ),
      ],
    ),

    child: Row(
      crossAxisAlignment:
          CrossAxisAlignment.start,

      children: [

        ClipRRect(
          borderRadius:
              BorderRadius.circular(12),

          child: Image.asset(
            "assets/images/book1.jpeg",
            width: 80,
            height: 110,
            fit: BoxFit.cover,
          ),
        ),

        const SizedBox(width: 20),

        Expanded(
          child: Column(
            crossAxisAlignment:
                CrossAxisAlignment.start,

            children: [

              const Text(
                "Minhaj-ul-Aabideen",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 4),

              const Text(
                "Imam al-Ghazali (R.A)",
                style: TextStyle(
                  color: Color.fromARGB(255, 51, 44, 44),
                ),
              ),

              const SizedBox(height: 8),

              const Text(
                "Chapter 4 • Aqabat al-Awarid",
                style: TextStyle(
                  fontSize: 12,
                ),
              ),

              const SizedBox(height: 12),

              ClipRRect(
                borderRadius:
                    BorderRadius.circular(10),

                child: LinearProgressIndicator(
                  value: 0.65,
                  minHeight: 8,
                  backgroundColor:
                      Colors.grey.shade200,
                  color:
                      const Color(0xFF0B4B4B),
                ),
              ),

              const SizedBox(height: 8),

              const Text(
                "65% Completed",
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 15,
                ),
              ),
            ],
          ),
        ),
      ],
    ),
  ),
),
const SizedBox(height: 10),

Padding(
  padding: const EdgeInsets.symmetric(
    horizontal: 15,
  ),

  child: Row(
    mainAxisAlignment:
        MainAxisAlignment.spaceBetween,

    children: [

      const Text(
        "Recently Added",
        style: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          fontStyle: FontStyle.italic,
        ),
      ),

      TextButton(
        onPressed: () {},

        child: const Text(
          "View All > ",
          style: TextStyle(
            color: Colors.black87,
            fontSize: 10,
            fontWeight: FontWeight.bold,
            fontStyle: FontStyle.italic,
          ),
        ),
      ),
    ],
  ),
),
const SizedBox(height: 10),
SizedBox(
  height: 220,

  child: ListView(
    scrollDirection: Axis.horizontal,

    padding: const EdgeInsets.symmetric(
      horizontal: 15,
    ),

    children: [

      _bookCard(
        "assets/images/book2.jpeg",
        "Sufism",
        "John A Subhan",
      ),

      _bookCard(
        "assets/images/sealednector.jpg",
        "Sealed Nector",
        "Mubarakabadi",
      ),

      _bookCard(
        "assets/images/book4.jpeg",
        "Jalaaludin Rumi",
        "M Fatih Citlak",
      ),

      _bookCard(
        "assets/images/book5.jpeg",
        "Baqayat-e-Iqbal",
        "Syed Taqii",
      ),

      _bookCard(
        "assets/images/book7.webp",
        "Stories of Prophets",
        "Ibn Kathir",
      ),
    ],
  ),
),
          const SizedBox(height: 12),

Padding(
  padding: const EdgeInsets.symmetric(
    horizontal: 15,
  ),

  child: Row(
    mainAxisAlignment:
        MainAxisAlignment.spaceBetween,

  ),
),
Padding(
  padding: const EdgeInsets.symmetric(
    horizontal: 15,
  ),

  child: Container(
    padding: const EdgeInsets.all(22),

    decoration: BoxDecoration(
      color: const Color(0xFFF9F1DD),
      borderRadius: BorderRadius.circular(24),

      border: Border.all(
        color: const Color(0xFFE3C88A),
      ),
    ),

    child: Row(
      children: [

        Container(
          width: 40,
          height: 40,

          decoration: BoxDecoration(
            color: const Color(0xFF0B4B4B),
            borderRadius:
                BorderRadius.circular(30),
          ),

          child: const Icon(
            Icons.person,
            color: Color(0xFFF4D17D),
            size: 30,
          ),
        ),

        const SizedBox(width: 10),

        Expanded(
  child: Column(
    crossAxisAlignment:
        CrossAxisAlignment.start,

    children: [

      const Text(
        "Handpicked wisdom from our Guide",
        style: TextStyle(
          fontWeight: FontWeight.bold,
          fontStyle: FontStyle.italic,
          fontSize: 14,
        ),
      ),

      const SizedBox(height: 14),

    

      Align(
        alignment: Alignment.centerRight,

        child: Container(
          padding: const EdgeInsets.symmetric(
            horizontal: 12,
            vertical: 8,
          ),

          decoration: BoxDecoration(
            color: const Color(0xFF0B4B4B),
            borderRadius:
                BorderRadius.circular(12),
          ),

          child: const Row(
            mainAxisSize: MainAxisSize.min,
            children: [

              Text(
                "Explore Collection",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                ),
              ),

              SizedBox(width: 4),

              Icon(
                Icons.arrow_forward,
                color: Colors.white,
                size: 14,
              ),
            ],
          ),
        ),
      ),
    ],
  ),
),
      ],
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


Widget _categoryCard(
  String iconPath,
  String title,
  String subtitle,
 
) {
  return Container(
    padding: const EdgeInsets.all(16),

    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(22),

      boxShadow: [
        BoxShadow(
          color: Colors.black.withValues(
            alpha: 0.05,
          ),
          blurRadius: 10,
          offset: const Offset(0, 4),
        ),
      ],
    ),

    child: Column(
      crossAxisAlignment:
          CrossAxisAlignment.start,

      children: [

        Image.asset(
  iconPath,
  width: 42,
  height: 42,
),

        const Spacer(),

        Text(
          title,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 15,
          ),
        ),
Text(
          subtitle,
          style: const TextStyle(
            fontWeight: FontWeight.w800,
            fontSize: 10,
          ),
        ),
        const SizedBox(height: 4),

          ],
    ),
  );
}

Widget _bookCard(
  String image,
  String title,
  String author,
) {
  return Container(
    width: 90,
    margin: const EdgeInsets.only(
      right: 12,
    ),

    child: Column(
      crossAxisAlignment:
          CrossAxisAlignment.start,

      children: [

        ClipRRect(
          borderRadius:
              BorderRadius.circular(16),

          child: Image.asset(
            image,
            height: 150,
            width: 130,
            fit: BoxFit.cover,
          ),
        ),

        const SizedBox(height: 8),

        Text(
          title,
          maxLines: 2,
          overflow:
              TextOverflow.ellipsis,

          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 11,
          ),
        ),

        const SizedBox(height: 2),

        Text(
          author,
          style: const TextStyle(
            color: Color.fromARGB(255, 80, 73, 73),
            fontWeight: FontWeight.bold,
            fontSize: 9,
          ),
        ),
      ],
    ),
  );
}
