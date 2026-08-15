import 'package:flutter/material.dart';

import '../../models/surah_model.dart';
import '../../models/last_read_model.dart';
import '../../services/quran_service.dart';
import '../../services/reading_progress_service.dart';
import '../../widgets/quran/quran_search_bar.dart';
import '../../widgets/quran/surah_tile.dart';
import '../quran/surah_details_screen.dart';

import '../quran/koshur_tafsir_reader_screen.dart';
import '../quran/koshur_tarjuma_reader_screen.dart';

import '../quran/quran_surah_browser.dart';
import '../../services/quran_mode_progress_service.dart';


class QuranScreen extends StatefulWidget {
  const QuranScreen({super.key});

  @override
  State<QuranScreen> createState() => _QuranScreenState();
}

class _QuranScreenState extends State<QuranScreen> {
  final QuranService _quranService = QuranService();

  final ReadingProgressService _readingProgressService =
      ReadingProgressService();

final QuranModeProgressService _progressService =
    QuranModeProgressService();

QuranProgress? arabicProgress;
QuranProgress? tarjumaProgress;
QuranProgress? tafsirProgress;

  LastReadModel? lastRead;
  List<SurahModel> surahs = [];
  String searchQuery = "";
  bool isLoading = true;

  /// When false → Quran Hub
  /// When true → Surah browser
  bool showingSurahs = false;
void _openQuranMode(QuranMode mode) {
  Navigator.push(
    context,
    MaterialPageRoute(
      builder: (_) {
        switch (mode) {
          case QuranMode.arabic:
            return QuranSurahBrowser(
              mode: QuranBrowserMode.arabic,
              readerBuilder: (surah) {
                return SurahDetailsScreen(
                  surahNumber: surah.id,
                  englishName: surah.nameSimple,
                  arabicName: surah.nameArabic,
                  revelationType:
                      "${surah.revelationPlace[0].toUpperCase()}${surah.revelationPlace.substring(1)}",
                  verses: surah.versesCount,
                );
              },
            );

          case QuranMode.tarjuma:
            return QuranSurahBrowser(
              mode: QuranBrowserMode.tarjuma,
              readerBuilder: (surah) {
                return KoshurTarjumaReaderScreen(
                  surahNumber: surah.id,
                  englishName: surah.nameSimple,
                  arabicName: surah.nameArabic,
                  revelationType:
                      "${surah.revelationPlace[0].toUpperCase()}${surah.revelationPlace.substring(1)}",
                  verses: surah.versesCount,
                );
              },
            );

          case QuranMode.tafsir:
            return QuranSurahBrowser(
              mode: QuranBrowserMode.tafsir,
              readerBuilder: (surah) {
                return KoshurTafsirReaderScreen(
                  surahNumber: surah.id,
                  englishName: surah.nameSimple,
                  arabicName: surah.nameArabic,
                  revelationType:
                      "${surah.revelationPlace[0].toUpperCase()}${surah.revelationPlace.substring(1)}",
                  verses: surah.versesCount,
                );
              },
            );
        }
      },
    ),
  );
}
  @override
  void initState() {
    super.initState();

    _loadSurahs();
    _loadLastRead();
     _loadProgress();
  }

Future<void> _loadProgress() async {
  final results = await Future.wait([
    _progressService.getProgress(
      QuranMode.arabic,
    ),
    _progressService.getProgress(
      QuranMode.tarjuma,
    ),
    _progressService.getProgress(
      QuranMode.tafsir,
    ),
  ]);

  if (!mounted) return;

  setState(() {
    arabicProgress = results[0];
    tarjumaProgress = results[1];
    tafsirProgress = results[2];
  });
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

  // ─────────────────────────────────────────────
  // SEARCH
  // ─────────────────────────────────────────────

  List<SurahModel> get filteredSurahs {
    if (searchQuery.trim().isEmpty) {
      return surahs;
    }

    final query = searchQuery.toLowerCase().trim();

    return surahs.where((surah) {
      return surah.nameSimple.toLowerCase().contains(query) ||
          surah.name.toLowerCase().contains(query) ||
          surah.nameArabic.contains(query);
    }).toList();
  }

  // ─────────────────────────────────────────────
  // OPEN ARABIC QURAN
  // ─────────────────────────────────────────────



  void _backToQuranHome() {
    setState(() {
      showingSurahs = false;
      searchQuery = "";
    });
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffFBF8F1),

      body: SafeArea(
        child: showingSurahs
            ? _buildSurahBrowser()
            : _buildQuranHome(),
      ),
    );
  }

  // ─────────────────────────────────────────────
  // QURAN HOME
  // ─────────────────────────────────────────────
Widget _continueReadingCard({
  required String title,
  required QuranProgress? progress,
  required QuranMode mode,
}) {
  SurahModel? surah;

  if (progress != null) {
    try {
      surah = surahs.firstWhere(
        (s) => s.id == progress.surah,
      );
    } catch (_) {
      surah = null;
    }
  }

  final bool hasProgress =
      progress != null && surah != null;

  final String surahName =
      hasProgress ? surah.nameSimple : "Begin your reading";

  final String progressText = hasProgress
      ? mode == QuranMode.arabic
          ? "Page ${progress.page ?? '-'}"
          : "Ayah ${progress.ayah}"
      : "Explore 114 Surahs";

  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Padding(
        padding: const EdgeInsets.only(
          left: 4,
          bottom: 7,
        ),
        child: Text(
          title,
          style: const TextStyle(
            color: Color(0xff173F3B),
            fontSize: 10.5,
            fontWeight: FontWeight.w700,
            letterSpacing: .8,
          ),
        ),
      ),

      Container(
        height: 64,
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
            colors: [
              Color(0xff0E5A56),
              Color(0xff176C66),
            ],
          ),
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(
              color: const Color(0xff0E5A56)
                  .withValues(alpha: .12),
              blurRadius: 12,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(18),
            onTap: () async {
              if (hasProgress) {
                await _openContinueReading(
                  mode: mode,
                  surah: surah!,
                  progress: progress,
                );
              } else {
                _openQuranMode(mode);
              }

              await _loadProgress();
            },
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 13,
              ),
              child: Row(
                children: [
                  Container(
                    width: 38,
                    height: 38,
                    decoration: BoxDecoration(
                      color: const Color(0xffE8C76A)
                          .withValues(alpha: .18),
                      borderRadius:
                          BorderRadius.circular(12),
                    ),
                    child: Icon(
                      hasProgress
                          ? Icons.menu_book_rounded
                          : Icons.play_arrow_rounded,
                      color: const Color(0xffE8C76A),
                      size: 20,
                    ),
                  ),

                  const SizedBox(width: 11),

                  Expanded(
                    child: Column(
                      mainAxisAlignment:
                          MainAxisAlignment.center,
                      crossAxisAlignment:
                          CrossAxisAlignment.start,
                      children: [
                        Text(
                          hasProgress
                              ? "CONTINUE READING"
                              : "START READING",
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 8.5,
                            fontWeight: FontWeight.w700,
                            letterSpacing: .8,
                          ),
                        ),

                        const SizedBox(height: 2),

                        Row(
                          children: [
                            Flexible(
                              child: Text(
                                surahName,
                                maxLines: 1,
                                overflow:
                                    TextOverflow.ellipsis,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 13.5,
                                  fontWeight:
                                      FontWeight.w700,
                                ),
                              ),
                            ),

                            const SizedBox(width: 7),

                            Container(
                              width: 3,
                              height: 3,
                              decoration:
                                  const BoxDecoration(
                                color:
                                    Color(0xffE8C76A),
                                shape: BoxShape.circle,
                              ),
                            ),

                            const SizedBox(width: 7),

                            Text(
                              progressText,
                              style: const TextStyle(
                                color: Colors.white70,
                                fontSize: 10,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: Colors.white
                          .withValues(alpha: .10),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.arrow_forward_rounded,
                      color: Colors.white,
                      size: 17,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    ],
  );
}

Future<void> _openContinueReading({
  required QuranMode mode,
  required SurahModel surah,
  required QuranProgress progress,
}) async {
  switch (mode) {
    case QuranMode.arabic:
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
            initialPage: progress.page,
          ),
        ),
      );
      break;

    case QuranMode.tarjuma:
      await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) =>
              KoshurTarjumaReaderScreen(
            surahNumber: surah.id,
            englishName: surah.nameSimple,
            arabicName: surah.nameArabic,
            revelationType:
                "${surah.revelationPlace[0].toUpperCase()}${surah.revelationPlace.substring(1)}",
            verses: surah.versesCount,
          
          ),
        ),
      );
      break;

    case QuranMode.tafsir:
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
      break;
  }
}

  Widget _buildQuranHome() {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),

      padding: const EdgeInsets.only(
        top: 16,
        bottom: 30,
      ),

      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [ 
        
          const SizedBox(height: 20),

// ─────────────────────────────────────
// CONTINUE READING
// ─────────────────────────────────────
Padding(
  padding: const EdgeInsets.symmetric(
    horizontal: 20,
  ),
  child: Column(
    children: [
      _continueReadingCard(
        title: "ARABIC QURAN",
        progress: arabicProgress,
        mode: QuranMode.arabic,
      ),

      const SizedBox(height: 12),

      _continueReadingCard(
        title: "KOSHUR TARJUMA",
        progress: tarjumaProgress,
        mode: QuranMode.tarjuma,
      ),

      const SizedBox(height: 12),

      _continueReadingCard(
        title: "KOSHUR TAFSIR",
        progress: tafsirProgress,
        mode: QuranMode.tafsir,
      ),
    ],
  ),
),

const SizedBox(height: 26),

// ─────────────────────────────────────
// SECTION TITLE
// ─────────────────────────────────────
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 20,
            ),

            child: GridView.count(
              crossAxisCount: 2,

              shrinkWrap: true,

              physics:
                  const NeverScrollableScrollPhysics(),

              mainAxisSpacing: 12,

              crossAxisSpacing: 12,

              childAspectRatio: 1.35,

              children: [

              _quranFeatureCard(
  icon: Icons.menu_book_rounded,
  title: "Arabic Quran",
  subtitle: "Read the Mushaf",
  detail: "Original Arabic • 114 Surahs",
  accent: const Color(0xff0E5A56),
  onTap: () {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => QuranSurahBrowser(
          mode: QuranBrowserMode.arabic,
          readerBuilder: (surah) {
            return SurahDetailsScreen(
              surahNumber: surah.id,
              englishName: surah.nameSimple,
              arabicName: surah.nameArabic,
              revelationType:
                  "${surah.revelationPlace[0].toUpperCase()}${surah.revelationPlace.substring(1)}",
              verses: surah.versesCount,
            );
          },
        ),
      ),
    );
  },
),

            _quranFeatureCard(
  icon: Icons.translate_rounded,
  title: "Koshur Tarjuma",
  subtitle: "Quran in Kashmiri",
  detail: "Read the meaning • 114 Surahs",
  accent: const Color(0xff0E5A56),
  onTap: () {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => QuranSurahBrowser(
          mode: QuranBrowserMode.tarjuma,
          readerBuilder: (surah) {
            return KoshurTarjumaReaderScreen(
              surahNumber: surah.id,
              englishName: surah.nameSimple,
              arabicName: surah.nameArabic,
              revelationType:
                  "${surah.revelationPlace[0].toUpperCase()}${surah.revelationPlace.substring(1)}",
              verses: surah.versesCount,
            );
          },
        ),
      ),
    );
  },
),

              _quranFeatureCard(
  icon: Icons.auto_awesome_rounded,
  title: "Koshur Tafsir",
  subtitle: "Understand the Quran",
  detail: "Verse-by-verse explanation",
  accent: const Color(0xff0E5A56),
  onTap: () {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => QuranSurahBrowser(
          mode: QuranBrowserMode.tafsir,
          readerBuilder: (surah) {
            return KoshurTafsirReaderScreen(
              surahNumber: surah.id,
              englishName: surah.nameSimple,
              arabicName: surah.nameArabic,
              revelationType:
                  "${surah.revelationPlace[0].toUpperCase()}${surah.revelationPlace.substring(1)}",
              verses: surah.versesCount,
            );
          },
        ),
      ),
    );
  },
),
/*
                _quranCategory(
                  icon: Icons.headphones_rounded,
                  title: "Koshur Audio",
                  subtitle: "Listen in Kashmiri",
                  onTap: () {
                    _showComingSoon(
                      "Koshur Audio",
                    );
                  },
                ),

                _quranCategory(
                  icon: Icons.play_circle_fill_rounded,
                  title: "Koshur Video",
                  subtitle: "Watch the Quran",
                  onTap: () {
                    _showComingSoon(
                      "Koshur Video",
                    );
                  },
                ),

                _quranCategory(
                  icon: Icons.format_list_numbered_rounded,
                  title: "15-Line Quran",
                  subtitle: "Traditional Mushaf",
                  onTap: () {
                    _showComingSoon(
                      "15-Line Quran",
                    );
                  },
                ),*/
              ], 
            ),
          ),

          const SizedBox(height: 26),

          // ─────────────────────────────────────
          // SMALL EXTRA FEATURES
          // ─────────────────────────────────────

          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 20,
            ),

            child: Row(
              children: [

                Expanded(
                  child: _smallQuranAction(
                    icon: Icons.bookmark_rounded,
                    title: "Bookmarks",
                    onTap: () {
                      _showComingSoon(
                        "Bookmarks",
                      );
                    },
                  ),
                ),

                const SizedBox(width: 12),

                Expanded(
                  child: _smallQuranAction(
                    icon: Icons.history_rounded,
                    title: "Reading History",
                    onTap: () {
                      _showComingSoon(
                        "Reading History",
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ─────────────────────────────────────────────
  // CATEGORY CARD
  // ─────────────────────────────────────────────
Widget _quranFeatureCard({
  required IconData icon,
  required String title,
  required String subtitle,
  required String detail,
  required Color accent,
  required VoidCallback onTap,
}) {
  return Material(
    color: Colors.transparent,
    child: InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(24),
      child: Container(
        height: 128,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: const Color(0xffE8E1D3),
          ),
          boxShadow: [
            BoxShadow(
              color: accent.withValues(alpha: .07),
              blurRadius: 18,
              offset: const Offset(0, 7),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: const Color(0xffF6EFD9),
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: Icon(
                    icon,
                    color: accent,
                    size: 23,
                  ),
                ),

                const Spacer(),

                Container(
                  width: 30,
                  height: 30,
                  decoration: BoxDecoration(
                    color: accent.withValues(alpha: .07),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.arrow_forward_rounded,
                    color: accent,
                    size: 16,
                  ),
                ),
              ],
            ),

            const Spacer(),

            Text(
              title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: accent,
                fontSize: 15,
                fontWeight: FontWeight.w700,
              ),
            ),

            const SizedBox(height: 2),

            Text(
              subtitle,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: Color(0xff263B38),
                fontSize: 11,
                fontWeight: FontWeight.w600,
              ),
            ),

            const SizedBox(height: 2),

            Text(
              detail,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: Colors.black45,
                fontSize: 9.5,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    ),
  );
}

  // ─────────────────────────────────────────────
  // SMALL ACTION
  // ─────────────────────────────────────────────

  Widget _smallQuranAction({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,

      child: InkWell(
        onTap: onTap,

        borderRadius:
            BorderRadius.circular(16),

        child: Container(
          height: 50,

          decoration: BoxDecoration(
            color: const Color(0xff0E5A56),

            borderRadius:
                BorderRadius.circular(16),
          ),

          child: Row(
            mainAxisAlignment:
                MainAxisAlignment.center,

            children: [

              Icon(
                icon,

                color:
                    const Color(0xffE8C76A),

                size: 18,
              ),

              const SizedBox(width: 8),

              Text(
                title,

                style:
                    const TextStyle(
                  color: Colors.white,

                  fontSize: 12,

                  fontWeight:
                      FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ─────────────────────────────────────────────
  // SURAH BROWSER
  // ─────────────────────────────────────────────

  Widget _buildSurahBrowser() {
    return Column(
      children: [

        // Header
        Padding(
          padding: const EdgeInsets.fromLTRB(
            20,
            16,
            20,
            12,
          ),

          child: Row(
            children: [

              InkWell(
                onTap: _backToQuranHome,

                borderRadius:
                    BorderRadius.circular(14),

                child: Container(
                  width: 42,
                  height: 42,

                  decoration: BoxDecoration(
                    color:
                        const Color(0xffF6EFD9),

                    borderRadius:
                        BorderRadius.circular(14),
                  ),

                  child: const Icon(
                    Icons.arrow_back_rounded,

                    color:
                        Color(0xff0E5A56),
                  ),
                ),
              ),

              const SizedBox(width: 12),

              const Expanded(
                child: Text(
                  "Arabic Quran",
                  style: TextStyle(
                    color: Color(0xff0E5A56),
                    fontSize: 24,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),

              Container(
                padding:
                    const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 7,
                ),

                decoration: BoxDecoration(
                  color:
                      const Color(0xffF6EFD9),

                  borderRadius:
                      BorderRadius.circular(20),
                ),

                child: Text(
                  "${surahs.length}",

                  style:
                      const TextStyle(
                    color:
                        Color(0xff0E5A56),

                    fontSize: 12,

                    fontWeight:
                        FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
        ),

        // Search
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

        // Surahs
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

                      meaning:
                          surah.name,

                      arabicName:
                          surah.nameArabic,

                      verses:
                          surah.versesCount,

                      revelationType:
                          "${surah.revelationPlace[0].toUpperCase()}${surah.revelationPlace.substring(1)}",

                      onTap: () async {
                        await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) =>
                                SurahDetailsScreen(
                              surahNumber:
                                  surah.id,

                              englishName:
                                  surah.nameSimple,

                              arabicName:
                                  surah.nameArabic,

                              revelationType:
                                  "${surah.revelationPlace[0].toUpperCase()}${surah.revelationPlace.substring(1)}",

                              verses:
                                  surah.versesCount,
                            ),
                          ),
                        );

                        await _loadLastRead();
                      },
                    );
                  },
                ),
        ),
      ],
    );
  }

  // ─────────────────────────────────────────────
  // TEMPORARY
  // ─────────────────────────────────────────────

  void _showComingSoon(String title) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(
            "$title will be added next.",
          ),

          behavior:
              SnackBarBehavior.floating,

          duration:
              const Duration(seconds: 2),

          backgroundColor:
              const Color(0xff0E5A56),

          shape:
              RoundedRectangleBorder(
            borderRadius:
                BorderRadius.circular(14),
          ),
        ),
      );
  }
}