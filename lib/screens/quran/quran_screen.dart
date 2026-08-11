import 'package:flutter/material.dart';

import '../../models/surah_model.dart';
import '../../services/quran_service.dart';

import '../../widgets/quran/last_read_card.dart';
import '../../widgets/quran/quran_search_bar.dart';
import '../../widgets/quran/surah_tile.dart';
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
      return surah.nameSimple.toLowerCase().contains(
            searchQuery.toLowerCase(),
          ) ||
          surah.name.toLowerCase().contains(searchQuery.toLowerCase()) ||
          surah.nameArabic.contains(searchQuery);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffFBF8F1),

      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 18),

              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: LastReadCard(
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
              ),

              const SizedBox(height: 22),

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

              const SizedBox(height: 20),

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

              const SizedBox(height: 26),

              Padding(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
                child: Row(
                  children: [
                    const Text(
                      "All Surahs",
                      style: TextStyle(
                        color: Color(0xff1D3D3A),
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const Spacer(),

                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xffF6EFD9),
                        borderRadius: BorderRadius.circular(30),
                      ),
                      child: Text(
                        "${filteredSurahs.length}",
                        style: const TextStyle(
                          color: Color(0xff0E5A56),
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
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

                separatorBuilder: (_, _) => const SizedBox(height: 10),

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

              const SizedBox(height: 28),
            ],
          ),
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
    onTap: onTap,
    borderRadius: BorderRadius.circular(20),
    child: Container(
      height: 78,
      decoration: BoxDecoration(
        color: const Color(0xff0E5A56),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: const Color(0xff0E5A56).withValues(alpha: .12),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: const Color(0xffE8C76A), size: 24),

          const SizedBox(height: 8),

          Text(
            title,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w600,
              fontSize: 12,
            ),
          ),
        ],
      ),
    ),
  );
}
