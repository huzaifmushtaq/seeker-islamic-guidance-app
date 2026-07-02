import 'package:flutter/material.dart';

import '../../models/surah_model.dart';
import '../../services/quran_service.dart';

import '../../widgets/quran/guidance_carousel.dart';
import '../../widgets/quran/last_read_card.dart';
import '../../widgets/quran/quran_search_bar.dart';
import '../../widgets/quran/surah_tile.dart';
import '../../widgets/quran/surah_toggle.dart';

class QuranScreen extends StatefulWidget {
  const QuranScreen({super.key});

  @override
  State<QuranScreen> createState() => _QuranScreenState();
}

class _QuranScreenState extends State<QuranScreen> {
  final QuranService _quranService = QuranService();

  List<SurahModel> surahs = [];
  String searchQuery = "";
  bool isLoading = true;
  bool isSurahSelected = true;
  
  @override
  void initState() {
    super.initState();
    _loadSurahs();
  }

  Future<void> _loadSurahs() async {
    final loadedSurahs = await _quranService.loadSurahs();

    if (!mounted) return;

    setState(() {
      surahs = loadedSurahs;
      isLoading = false;
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
      backgroundColor: const Color(0xFFF5F7F7),

      appBar: AppBar(
        backgroundColor: const Color(0xFF0B4B4B),
        elevation: 0,
        centerTitle: true,
        title: const Text(
          "Al-Quran",
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
      ),

      body: isLoading
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : SingleChildScrollView(
              padding: const EdgeInsets.all(18),

              child: Column(
                children: [
                  const LastReadCard(),

                  const SizedBox(height: 18),

                  const GuidanceCarousel(),

                  const SizedBox(height: 16),

                  QuranSearchBar(
                    onChanged: (value) {
                      setState(() {
                        searchQuery = value;
                      });
                    },
                  ),

                  const SizedBox(height: 18),

                  

                  const SizedBox(height: 8),

                  ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: filteredSurahs.length,

                    separatorBuilder: (_, __) =>
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
                      );
                    },
                  ),
                ],
              ),
            ),
    );
  }
}