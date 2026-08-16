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
import '../quran/quran_ayah_reader_screen.dart';
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

  // ─────────────────────────────────────────────
  // OPEN QURAN MODE
  // ─────────────────────────────────────────────

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
                  return QuranAyahReaderScreen(
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

  // ─────────────────────────────────────────────
  // INIT
  // ─────────────────────────────────────────────

  @override
  void initState() {
    super.initState();

    _loadSurahs();
    _loadLastRead();
    _loadProgress();
  }

  // ─────────────────────────────────────────────
  // LOAD PROGRESS
  // ─────────────────────────────────────────────

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

  // ─────────────────────────────────────────────
  // LOAD SURAHS
  // ─────────────────────────────────────────────

  Future<void> _loadSurahs() async {
    final loadedSurahs =
        await _quranService.loadSurahs();

    if (!mounted) return;

    setState(() {
      surahs = loadedSurahs;
      isLoading = false;
    });
  }

  // ─────────────────────────────────────────────
  // LOAD LAST READ
  // ─────────────────────────────────────────────

  Future<void> _loadLastRead() async {
    final data =
        await _readingProgressService.getLastRead();

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

  // ─────────────────────────────────────────────
  // BACK TO QURAN HOME
  // ─────────────────────────────────────────────

  void _backToQuranHome() {
    setState(() {
      showingSurahs = false;
      searchQuery = "";
    });
  }

  // ─────────────────────────────────────────────
  // BUILD
  // ─────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor:
          const Color(0xffFBF8F1),

      body: SafeArea(
        child: showingSurahs
            ? _buildSurahBrowser()
            : _buildQuranHome(),
      ),
    );
  }

  // ─────────────────────────────────────────────
  // CONTINUE READING CARD
  // ─────────────────────────────────────────────

  Widget _continueReadingCard({
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
        hasProgress
            ? surah.nameSimple
            : "Begin your reading";

    final String progressText =
        hasProgress
            ? "Ayah ${progress.ayah}"
            : "Explore 114 Surahs";

    return Container(
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

        borderRadius:
            BorderRadius.circular(18),

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
          borderRadius:
              BorderRadius.circular(18),

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
            padding:
                const EdgeInsets.symmetric(
              horizontal: 13,
            ),

            child: Row(
              children: [
                // ICON
                Container(
                  width: 38,
                  height: 38,

                  decoration:
                      BoxDecoration(
                    color: const Color(
                      0xffE8C76A,
                    ).withValues(
                      alpha: .18,
                    ),
                    borderRadius:
                        BorderRadius.circular(
                      12,
                    ),
                  ),

                  child: Icon(
                    hasProgress
                        ? Icons
                            .menu_book_rounded
                        : Icons
                            .play_arrow_rounded,
                    color:
                        const Color(0xffE8C76A),
                    size: 20,
                  ),
                ),

                const SizedBox(width: 11),

                // TEXT
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

                        style:
                            const TextStyle(
                          color:
                              Colors.white70,
                          fontSize: 8.5,
                          fontWeight:
                              FontWeight.w700,
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
                                  TextOverflow
                                      .ellipsis,

                              style:
                                  const TextStyle(
                                color:
                                    Colors.white,
                                fontSize: 13.5,
                                fontWeight:
                                    FontWeight
                                        .w700,
                              ),
                            ),
                          ),

                          const SizedBox(width: 7),

                          Container(
                            width: 3,
                            height: 3,

                            decoration:
                                const BoxDecoration(
                              color: Color(
                                0xffE8C76A,
                              ),
                              shape:
                                  BoxShape.circle,
                            ),
                          ),

                          const SizedBox(width: 7),

                          Text(
                            progressText,
                            style:
                                const TextStyle(
                              color:
                                  Colors.white70,
                              fontSize: 10,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                const SizedBox(width: 8),

                // ARROW
                Container(
                  width: 32,
                  height: 32,

                  decoration:
                      BoxDecoration(
                    color: Colors.white
                        .withValues(
                      alpha: .10,
                    ),
                    shape:
                        BoxShape.circle,
                  ),

                  child: const Icon(
                    Icons
                        .arrow_forward_rounded,
                    color: Colors.white,
                    size: 17,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ─────────────────────────────────────────────
  // CONTINUE READING NAVIGATION
  // ─────────────────────────────────────────────

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
            builder: (_) =>
                QuranAyahReaderScreen(
              surahNumber: surah.id,
              englishName:
                  surah.nameSimple,
              arabicName:
                  surah.nameArabic,
              revelationType:
                  "${surah.revelationPlace[0].toUpperCase()}${surah.revelationPlace.substring(1)}",
              verses:
                  surah.versesCount,
              initialAyah:
                  progress.ayah,
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
              englishName:
                  surah.nameSimple,
              arabicName:
                  surah.nameArabic,
              revelationType:
                  "${surah.revelationPlace[0].toUpperCase()}${surah.revelationPlace.substring(1)}",
              verses:
                  surah.versesCount,
              initialAyah:
                  progress.ayah,
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
              englishName:
                  surah.nameSimple,
              arabicName:
                  surah.nameArabic,
              revelationType:
                  "${surah.revelationPlace[0].toUpperCase()}${surah.revelationPlace.substring(1)}",
              verses:
                  surah.versesCount,
              initialAyah:
                  progress.ayah,
            ),
          ),
        );
        break;
    }
  }

  // ─────────────────────────────────────────────
  // QURAN HOME
  // ─────────────────────────────────────────────

  Widget _buildQuranHome() {
    return SingleChildScrollView(
      physics:
          const BouncingScrollPhysics(),

      padding: const EdgeInsets.only(
        top: 16,
        bottom: 30,
      ),

      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,

        children: [
          const SizedBox(height: 20),

          // ═══════════════════════════════
          // ARABIC QURAN
          // ═══════════════════════════════

          Padding(
            padding:
                const EdgeInsets.symmetric(
              horizontal: 20,
            ),

            child: Column(
              children: [
                _quranFeatureCard(
                  icon:
                      Icons.menu_book_rounded,
                  title: "Arabic Quran",
                  subtitle:
                      "Read the original Mushaf",
                  detail:
                      "Original Arabic • 114 Surahs",
                  accent:
                      const Color(0xff0E5A56),

                 onTap: () async {
  await Navigator.push(
    context,
    MaterialPageRoute(
      builder: (_) => QuranSurahBrowser(
        mode: QuranBrowserMode.arabic,
        readerBuilder: (surah) {
          return QuranAyahReaderScreen(
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

  await _loadProgress();
},
                ),

                const SizedBox(height: 7),

                _continueReadingCard(
                  progress:
                      arabicProgress,
                  mode:
                      QuranMode.arabic,
                ),
              ],
            ),
          ),

          const SizedBox(height: 18),

          // ═══════════════════════════════
          // KOSHUR TARJUMA
          // ═══════════════════════════════

          Padding(
            padding:
                const EdgeInsets.symmetric(
              horizontal: 20,
            ),

            child: Column(
              children: [
                _quranFeatureCard(
                  icon:
                      Icons.translate_rounded,
                  title:
                      "Koshur Tarjuma",
                  subtitle:
                      "Read the Quran in Kashmiri",
                  detail:
                      "Kashmiri translation • 114 Surahs",
                  accent:
                      const Color(0xff0E5A56),

                onTap: () async {
  await Navigator.push(
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

  await _loadProgress();
},
                ),

                const SizedBox(height: 7),

                _continueReadingCard(
                  progress:
                      tarjumaProgress,
                  mode:
                      QuranMode.tarjuma,
                ),
              ],
            ),
          ),

          const SizedBox(height: 18),

          // ═══════════════════════════════
          // KOSHUR TAFSIR
          // ═══════════════════════════════

          Padding(
            padding:
                const EdgeInsets.symmetric(
              horizontal: 20,
            ),

            child: Column(
              children: [
                _quranFeatureCard(
                  icon:
                      Icons.auto_awesome_rounded,
                  title:
                      "Urdu Tafsir",
                  subtitle:
                      "Tarjuma of the Quran in Kashmiri",
                  detail:
                      "Verse-by-verse urdu explanation • 114 Surahs",
                  accent:
                      const Color(0xff0E5A56),

              onTap: () async {
  await Navigator.push(
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

  await _loadProgress();
},
                ),

                const SizedBox(height: 7),

                _continueReadingCard(
                  progress:
                      tafsirProgress,
                  mode:
                      QuranMode.tafsir,
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

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
          ),
          */
        ],
      ),
    );
  }

  // ─────────────────────────────────────────────
  // FEATURE CARD
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

        borderRadius:
            BorderRadius.circular(20),

        child: Container(
          height: 88,

          decoration: BoxDecoration(
            gradient:
                const LinearGradient(
              begin:
                  Alignment.topLeft,
              end:
                  Alignment.bottomRight,
              colors: [
                Color(0xff0E5A56),
                Color(0xff0A4D4A),
              ],
            ),

            borderRadius:
                BorderRadius.circular(20),

            border: Border.all(
              color: const Color(
                0xffE8C76A,
              ).withValues(alpha: .18),
            ),

            boxShadow: [
              BoxShadow(
                color: const Color(
                  0xff0E5A56,
                ).withValues(alpha: .16),
                blurRadius: 14,
                offset:
                    const Offset(0, 6),
              ),
            ],
          ),

          child: Stack(
            children: [
              // DECORATIVE GLOW

              Positioned(
                right: -25,
                top: -35,

                child: Container(
                  width: 110,
                  height: 110,

                  decoration:
                      BoxDecoration(
                    shape:
                        BoxShape.circle,
                    color: Colors.white
                        .withValues(
                      alpha: .035,
                    ),
                  ),
                ),
              ),

              // CONTENT

              Padding(
                padding:
                    const EdgeInsets
                        .symmetric(
                  horizontal: 13,
                  vertical: 10,
                ),

                child: Row(
                  children: [
                    // ICON

                    Container(
                      width: 52,
                      height: 52,

                      decoration:
                          BoxDecoration(
                        color:
                            const Color(
                          0xffF6EFD9,
                        ),

                        borderRadius:
                            BorderRadius
                                .circular(
                          16,
                        ),

                        boxShadow: [
                          BoxShadow(
                            color:
                                Colors.black
                                    .withValues(
                              alpha: .08,
                            ),
                            blurRadius: 8,
                            offset:
                                const Offset(
                              0,
                              3,
                            ),
                          ),
                        ],
                      ),

                      child: Icon(
                        icon,
                        size: 25,
                        color: accent,
                      ),
                    ),

                    const SizedBox(
                      width: 13,
                    ),

                    // TEXT

                    Expanded(
                      child: Column(
                        mainAxisAlignment:
                            MainAxisAlignment
                                .center,

                        crossAxisAlignment:
                            CrossAxisAlignment
                                .start,

                        children: [
                          Text(
                            title,
                            maxLines: 1,
                            overflow:
                                TextOverflow
                                    .ellipsis,

                            style:
                                const TextStyle(
                              color:
                                  Colors.white,
                              fontSize: 16,
                              fontWeight:
                                  FontWeight
                                      .w700,
                              letterSpacing:
                                  -.15,
                            ),
                          ),

                          const SizedBox(
                            height: 2,
                          ),

                          Text(
                            subtitle,
                            maxLines: 1,
                            overflow:
                                TextOverflow
                                    .ellipsis,

                            style: TextStyle(
                              color:
                                  Colors.white
                                      .withValues(
                                alpha: .82,
                              ),
                              fontSize: 11.5,
                              fontWeight:
                                  FontWeight
                                      .w500,
                            ),
                          ),

                          const SizedBox(
                            height: 3,
                          ),

                          Text(
                            detail,
                            maxLines: 1,
                            overflow:
                                TextOverflow
                                    .ellipsis,

                            style: TextStyle(
                              color:
                                  const Color(
                                0xffE8C76A,
                              ).withValues(
                                alpha: .95,
                              ),
                              fontSize: 9.5,
                              fontWeight:
                                  FontWeight
                                      .w600,
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(
                      width: 8,
                    ),

                    // ARROW

                    Container(
                      width: 34,
                      height: 34,

                      decoration:
                          BoxDecoration(
                        color: Colors.white
                            .withValues(
                          alpha: .10,
                        ),
                        shape:
                            BoxShape.circle,

                        border:
                            Border.all(
                          color: Colors.white
                              .withValues(
                            alpha: .12,
                          ),
                        ),
                      ),

                      child: const Icon(
                        Icons
                            .arrow_forward_rounded,
                        size: 18,
                        color:
                            Colors.white,
                      ),
                    ),
                  ],
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
        // HEADER

        Padding(
          padding:
              const EdgeInsets.fromLTRB(
            20,
            16,
            20,
            12,
          ),

          child: Row(
            children: [
              InkWell(
                onTap:
                    _backToQuranHome,

                borderRadius:
                    BorderRadius.circular(
                  14,
                ),

                child: Container(
                  width: 42,
                  height: 42,

                  decoration:
                      BoxDecoration(
                    color:
                        const Color(
                      0xffF6EFD9,
                    ),

                    borderRadius:
                        BorderRadius.circular(
                      14,
                    ),
                  ),

                  child: const Icon(
                    Icons
                        .arrow_back_rounded,
                    color:
                        Color(0xff0E5A56),
                  ),
                ),
              ),

              const SizedBox(
                width: 12,
              ),

              const Expanded(
                child: Text(
                  "Arabic Quran",
                  style: TextStyle(
                    color:
                        Color(0xff0E5A56),
                    fontSize: 24,
                    fontWeight:
                        FontWeight.w700,
                  ),
                ),
              ),

              Container(
                padding:
                    const EdgeInsets
                        .symmetric(
                  horizontal: 12,
                  vertical: 7,
                ),

                decoration:
                    BoxDecoration(
                  color:
                      const Color(
                    0xffF6EFD9,
                  ),

                  borderRadius:
                      BorderRadius.circular(
                    20,
                  ),
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

        // SEARCH

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

        // SURAHS

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
                        await _loadProgress();
                      },
                    );
                  },
                ),
        ),
      ],
    );
  }
}