import 'package:flutter/material.dart';
import '../../models/surah_model.dart';
import '../../services/quran_service.dart';
import '../../widgets/quran/quran_search_bar.dart';
import '../../widgets/quran/surah_tile.dart';
import 'koshur_tafsir_reader_screen.dart';
class KoshurTafsirScreen extends StatefulWidget {
  const KoshurTafsirScreen({super.key});

  @override
  State<KoshurTafsirScreen> createState() =>
      _KoshurTafsirScreenState();
}

class _KoshurTafsirScreenState
    extends State<KoshurTafsirScreen> {
  final QuranService _quranService = QuranService();

  List<SurahModel> surahs = [];

  String searchQuery = "";

  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadSurahs();
  }

  Future<void> _loadSurahs() async {
    final loaded =
        await _quranService.loadSurahs();

    if (!mounted) return;

    setState(() {
      surahs = loaded;
      isLoading = false;
    });
  }

  List<SurahModel> get filteredSurahs {
    if (searchQuery.trim().isEmpty) {
      return surahs;
    }

    final query =
        searchQuery.toLowerCase().trim();

    return surahs.where((surah) {
      return surah.nameSimple
              .toLowerCase()
              .contains(query) ||
          surah.name
              .toLowerCase()
              .contains(query) ||
          surah.nameArabic.contains(query);
    }).toList();
  }

  Future<void> _openSurah(
    SurahModel surah,
  ) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) =>
            KoshurTafsirReaderScreen(
          surahNumber: surah.id,
          englishName: surah.nameSimple,
          arabicName: surah.nameArabic,
          revelationType:
              "${surah.revelationPlace[0].toUpperCase()}${surah.revelationPlace.substring(1)}",
          verses: surah.versesCount,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor:
          const Color(0xffFBF8F1),

      appBar: AppBar(
        backgroundColor:
            const Color(0xffFBF8F1),

        elevation: 0,

        scrolledUnderElevation: 0,

        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new_rounded,
            color: Color(0xff0E5A56),
          ),
          onPressed: () =>
              Navigator.pop(context),
        ),

        title: const Column(
          crossAxisAlignment:
              CrossAxisAlignment.start,
          children: [
            Text(
              "Koshur Tafsir",
              style: TextStyle(
                color: Color(0xff0E5A56),
                fontSize: 21,
                fontWeight: FontWeight.w700,
              ),
            ),

            SizedBox(height: 2),

            Text(
              "Understand the Quran in Kashmiri",
              style: TextStyle(
                color: Colors.black54,
                fontSize: 11.5,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),

      body: Column(
        children: [
          const SizedBox(height: 8),

          Padding(
            padding:
                const EdgeInsets.symmetric(
              horizontal: 20,
            ),
            child: QuranSearchBar(
              onChanged: (value) {
                setState(() {
                  searchQuery = value;
                });
              },
            ),
          ),

          const SizedBox(height: 12),

          Expanded(
            child: isLoading
                ? const Center(
                    child:
                        CircularProgressIndicator(
                      color:
                          Color(0xff0E5A56),
                    ),
                  )
                : ListView.builder(
                    physics:
                        const BouncingScrollPhysics(),

                    padding:
                        const EdgeInsets.only(
                      bottom: 24,
                    ),

                    itemCount:
                        filteredSurahs.length,

                    itemBuilder:
                        (context, index) {
                      final surah =
                          filteredSurahs[index];
                          

                      return SurahTile(
                        number: surah.id,
                        englishName:
                            surah.nameSimple,
                        meaning: surah.name,
                        arabicName:
                            surah.nameArabic,
                        verses:
                            surah.versesCount,
                        revelationType:
                            "${surah.revelationPlace[0].toUpperCase()}${surah.revelationPlace.substring(1)}",
                        onTap: () =>
                            _openSurah(surah),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}