import 'package:flutter/material.dart';

import '../../models/surah_model.dart';
import '../../services/quran_service.dart';

import '../../widgets/quran/last_read_card.dart';
import '../../widgets/quran/quran_search_bar.dart';
import '../../widgets/quran/surah_tile.dart';
// ignore: unused_import
import '../../widgets/quran/surah_toggle.dart';
import '../../models/last_read_model.dart';
import '../../services/reading_progress_service.dart';
import '../quran/surah_details_screen.dart';

class QuranScreen extends StatefulWidget {
  const QuranScreen({super.key});

  @override
  State<QuranScreen> createState() => _QuranScreenState();
}

class _QuranScreenState extends State<QuranScreen> {
 final QuranService _quranService = QuranService();
final ReadingProgressService _readingProgressService =
    ReadingProgressService();

LastReadModel? lastRead;
 
  List<SurahModel> surahs = [];
  String searchQuery = "";
  bool isLoading = true;
  bool isSurahSelected = true;
  
  @override
void initState() {
  super.initState();
  _loadSurahs();
  _loadLastRead();
}

  Future<void> _loadSurahs() async {
    final loadedSurahs = await _quranService.loadSurahs();

    if (!mounted) return;

    setState(() {
      surahs = loadedSurahs;
      isLoading = false;
    });
  }
Future<void> _loadLastRead() async {
  final data = await _readingProgressService.getLastRead();

  if (!mounted) return;

  setState(() {
    lastRead = data;
  });
}
  List<SurahModel> get filteredSurahs {
    if (searchQuery.trim().isEmpty) {
      return surahs;
    }

    return surahs.where((surah) {
      return surah.nameSimple
              .toLowerCase()
              .contains(searchQuery.toLowerCase()) ||
          surah.name
              .toLowerCase()
              .contains(searchQuery.toLowerCase()) ||
          surah.nameArabic.contains(searchQuery);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 247, 247, 248),


      body: SingleChildScrollView(
        child: Column(
          children: [
          SafeArea(
  child: Padding(
    padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
    child: Column(
      children: [
        LastReadCard(
  lastRead: lastRead,
  surahs: surahs,
  onTap: () async {
    if (lastRead == null) return;

    final surah = surahs.firstWhere(
      (s) => s.id == lastRead!.surah,
    );

   await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => SurahDetailsScreen(
          surahNumber: surah.id,
          englishName: surah.nameSimple,
          arabicName: surah.nameArabic,
          revelationType:
              "${surah.revelationPlace[0].toUpperCase()}${surah.revelationPlace.substring(1)}",
          verses: surah.versesCount,

          initialPage: lastRead!.page,
        ),
      ),
    );
    await _loadLastRead();
  },
),
      ],
    ),
  ),
),
    const SizedBox(height: 10),
                 


                 Padding(
  padding: const EdgeInsets.symmetric(horizontal: 20),
  child: QuranSearchBar(
    onChanged: (value) {
      setState(() {
        searchQuery = value;
      });
    },
  ),
),
                  const SizedBox(height: 18),
Padding(
  padding: const EdgeInsets.symmetric(horizontal: 20),
  child: Row(
    children: [
      Expanded(
        child: _quickAction(
          icon: Icons.bookmark_rounded,
          title: "Bookmarks",
          onTap: () {},
        ),
      ),

      const SizedBox(width: 12),

      Expanded(
        child: _quickAction(
          icon: Icons.history_rounded,
          title: "History",
          onTap: () {},
        ),
      ),

      const SizedBox(width: 12),

      Expanded(
        child: _quickAction(
          icon: Icons.headphones_rounded,
          title: "Audio",
          onTap: () {},
        ),
      ),

      const SizedBox(width: 12),

      Expanded(
        child: _quickAction(
          icon: Icons.mosque_rounded,
          title: "Juz",
          onTap: () {},
        ),
      ),
    ],
  ),
),

                  Padding(
  padding: const EdgeInsets.fromLTRB(24, 28, 24, 18),
  child: Row(
    children: [

      const Text(
        "All Surahs",
        style: TextStyle(
          color: Color.fromARGB(255, 33, 41, 57),
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
      ),

      const Spacer(),

      Container(
        padding: const EdgeInsets.symmetric(
          horizontal: 12,
          vertical: 6,
        ),
        decoration: BoxDecoration(
          color: const Color(0xFFD4AF37),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          "${surahs.length}",
          style: const TextStyle(
            color: Color(0xFF0B1730),
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    ],
  ),
),


                 

                  ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: filteredSurahs.length,

                    separatorBuilder: (_, _) =>
                        const Divider(height: 1),

                    itemBuilder: (context, index) {
                      final surah = filteredSurahs[index];

                     return SurahTile(
  number: surah.id,
  englishName: surah.nameSimple,
  meaning: surah.name,
  arabicName: surah.nameArabic,
  verses: surah.versesCount,
  revelationType:
      "${surah.revelationPlace[0].toUpperCase()}${surah.revelationPlace.substring(1)}",

  onTap: () async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => SurahDetailsScreen(
          surahNumber: surah.id,
          englishName: surah.nameSimple,
          arabicName: surah.nameArabic,
          revelationType:
              "${surah.revelationPlace[0].toUpperCase()}${surah.revelationPlace.substring(1)}",
          verses: surah.versesCount,
        ),
      ),
    );

    await _loadLastRead();
  },
);
                    },
                  ),
                ],
              ),
            ),
    );
  }
}
Widget _quickAction({
  required IconData icon,
  required String title,
  required VoidCallback onTap,
}) {
  return InkWell(
    borderRadius: BorderRadius.circular(20),
    onTap: onTap,
    child: Container(
      height: 82,

      decoration: BoxDecoration(
        color: const Color(0xFF13213A),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: Colors.white.withOpacity(.05),
        ),
      ),

      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [

          Icon(
            icon,
            color: const Color(0xFFD4AF37),
            size: 26,
          ),

          const SizedBox(height: 10),

          Text(
            title,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    ),
  );
}