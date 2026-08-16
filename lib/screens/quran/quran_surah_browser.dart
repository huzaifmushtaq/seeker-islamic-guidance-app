import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../models/surah_model.dart';
import '../../services/quran_service.dart';

import '../../widgets/quran/quran_search_bar.dart';

enum QuranBrowserMode {
  arabic,
  tarjuma,
  tafsir,
}


class QuranSurahBrowser extends StatefulWidget {
  final QuranBrowserMode mode;

  /// Screen to open when a Surah is selected.
  final Widget Function(SurahModel surah) readerBuilder;

  const QuranSurahBrowser({
    super.key,
    required this.mode,
    required this.readerBuilder,
  });

  @override
  State<QuranSurahBrowser> createState() =>
      _QuranSurahBrowserState();
}

class _QuranSurahBrowserState
    extends State<QuranSurahBrowser> {
  final QuranService _quranService = QuranService();


  List<SurahModel> surahs = [];

  Set<int> bookmarks = {};

  String searchQuery = "";

  bool isLoading = true;
  bool searchExpanded = false;


  String get _bookmarkKey {
    switch (widget.mode) {
      case QuranBrowserMode.arabic:
        return "arabic_quran_bookmarks";

      case QuranBrowserMode.tarjuma:
        return "koshur_tarjuma_bookmarks";

      case QuranBrowserMode.tafsir:
        return "koshur_tafsir_bookmarks";
    }
  }

  String get _title {
    switch (widget.mode) {
      case QuranBrowserMode.arabic:
        return "Arabic Quran";

      case QuranBrowserMode.tarjuma:
        return "Koshur Tarjuma";

      case QuranBrowserMode.tafsir:
        return "Urdu Tafsir";
    }
  }

  String get _subtitle {
    switch (widget.mode) {
      case QuranBrowserMode.arabic:
        return "Read the Mushaf";

      case QuranBrowserMode.tarjuma:
        return "Quran • Kashmiri Translation";

      case QuranBrowserMode.tafsir:
        return "Quran • Urdu Explanation";
    }
  }

  @override
  void initState() {
    super.initState();

    _loadData();
  }
  Future<void> _loadData() async {
  final loadedSurahs =
      await _quranService.loadSurahs();

  await _loadBookmarks();

 

  if (!mounted) return;

  setState(() {
    surahs = loadedSurahs;
  
    isLoading = false;
  });
}

  Future<void> _loadBookmarks() async {
    final prefs =
        await SharedPreferences.getInstance();

    final saved =
        prefs.getStringList(_bookmarkKey) ?? [];

    if (!mounted) return;

    setState(() {
      bookmarks = saved
          .map(int.tryParse)
          .whereType<int>()
          .toSet();
    });
  }

  Future<void> _toggleBookmark(
    int surahNumber,
  ) async {
    final prefs =
        await SharedPreferences.getInstance();

    final updated =
        Set<int>.from(bookmarks);

    if (updated.contains(surahNumber)) {
      updated.remove(surahNumber);
    } else {
      updated.add(surahNumber);
    }

    await prefs.setStringList(
      _bookmarkKey,
      updated
          .map((e) => e.toString())
          .toList(),
    );

    if (!mounted) return;

    setState(() {
      bookmarks = updated;
    });
  }

  List<SurahModel> get filteredSurahs {
    if (searchQuery.trim().isEmpty) {
      return surahs;
    }

    final query =
        searchQuery.trim().toLowerCase();

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
          widget.readerBuilder(surah),
    ),
  );
}

  void _toggleSearch() {
    setState(() {
      searchExpanded = !searchExpanded;

      if (!searchExpanded) {
        searchQuery = "";
      }
    });
  }

  void _showBookmarks() {
    final bookmarkedSurahs = surahs
        .where(
          (surah) => bookmarks.contains(surah.id),
        )
        .toList();

    showModalBottomSheet(
      context: context,
      backgroundColor:
          const Color(0xffFBF8F1),
      showDragHandle: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(28),
        ),
      ),
      builder: (_) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(
              20,
              4,
              20,
              20,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Expanded(
                      child: Text(
                        "Bookmarks",
                        style: TextStyle(
                          color: Color(0xff0E5A56),
                          fontSize: 22,
                          fontWeight:
                              FontWeight.w700,
                        ),
                      ),
                    ),

                    Text(
                      "${bookmarkedSurahs.length}",
                      style: const TextStyle(
                        color: Color(0xffB28A2E),
                        fontWeight:
                            FontWeight.bold,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 14),

                if (bookmarkedSurahs.isEmpty)
                  const Padding(
                    padding:
                        EdgeInsets.symmetric(
                      vertical: 28,
                    ),
                    child: Center(
                      child: Text(
                        "No bookmarked Surahs yet.",
                        style: TextStyle(
                          color: Colors.black54,
                        ),
                      ),
                    ),
                  )
                else
                  Flexible(
                    child: ListView.builder(
                      shrinkWrap: true,
                      itemCount:
                          bookmarkedSurahs.length,
                      itemBuilder:
                          (context, index) {
                        final surah =
                            bookmarkedSurahs[index];

                        return ListTile(
                          contentPadding:
                              EdgeInsets.zero,

                          leading: Container(
                            width: 38,
                            height: 38,
                            alignment:
                                Alignment.center,
                            decoration:
                                BoxDecoration(
                              color:
                                  const Color(
                                0xffF6EFD9,
                              ),
                              borderRadius:
                                  BorderRadius
                                      .circular(12),
                            ),
                            child: Text(
                              "${surah.id}",
                              style:
                                  const TextStyle(
                                color:
                                    Color(
                                  0xff0E5A56,
                                ),
                                fontWeight:
                                    FontWeight.bold,
                                fontSize: 12,
                              ),
                            ),
                          ),

                          title: Text(
                            surah.nameSimple,
                            style:
                                const TextStyle(
                              color:
                                  Color(
                                0xff173F3B,
                              ),
                              fontWeight:
                                  FontWeight.w700,
                            ),
                          ),

                          subtitle: Text(
                            "${surah.revelationPlace} • ${surah.versesCount} Ayahs",
                            style:
                                const TextStyle(
                              fontSize: 11,
                              color:
                                  Colors.black45,
                            ),
                          ),

                          trailing:
                              const Icon(
                            Icons
                                .bookmark_rounded,
                            color:
                                Color(
                              0xffE8C76A,
                            ),
                          ),

                          onTap: () {
                            Navigator.pop(
                              context,
                            );

                            _openSurah(surah);
                          },
                        );
                      },
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }
 

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor:
          const Color(0xffFBF8F1),

      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 14),

            // ─────────────────────────────
            // TITLE ROW
            // ─────────────────────────────

            Padding(
              padding:
                  const EdgeInsets.symmetric(
                horizontal: 20,
              ),
              child: Row(
                children: [
                  Container(
                    width: 38,
                    height: 38,
                    decoration:
                        BoxDecoration(
                      color:
                          const Color(
                        0xffF6EFD9,
                      ),
                      borderRadius:
                          BorderRadius.circular(
                        12,
                      ),
                    ),
                    child: IconButton(
                      padding: EdgeInsets.zero,
                      icon: const Icon(
                        Icons
                            .arrow_back_ios_new_rounded,
                        size: 17,
                        color:
                            Color(0xff0E5A56),
                      ),
                      onPressed: () =>
                          Navigator.pop(
                        context,
                      ),
                    ),
                  ),

                  const SizedBox(width: 11),

                  Expanded(
                    child: Column(
                      crossAxisAlignment:
                          CrossAxisAlignment
                              .start,
                      children: [
                        Text(
                          _title,
                          style:
                              const TextStyle(
                            color:
                                Color(
                              0xff0E5A56,
                            ),
                            fontSize: 22,
                            fontWeight:
                                FontWeight.w700,
                          ),
                        ),

                        Text(
                          _subtitle,
                          style:
                              const TextStyle(
                            color:
                                Colors.black45,
                            fontSize: 10.5,
                            fontWeight:
                                FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),

                  // SEARCH
                  _headerButton(
                    icon: searchExpanded
                        ? Icons.close_rounded
                        : Icons.search_rounded,
                    onTap: _toggleSearch,
                  ),

                  const SizedBox(width: 8),

                  // BOOKMARKS
                  _headerButton(
                    icon:
                        Icons.bookmark_border_rounded,
                    onTap: _showBookmarks,
                  ),
                ],
              ),
            ),

            // ─────────────────────────────
            // EXPANDABLE SEARCH
            // ─────────────────────────────

            AnimatedSize(
              duration:
                  const Duration(
                milliseconds: 220,
              ),
              curve: Curves.easeOut,

              child: searchExpanded
                  ? Padding(
                      padding:
                          const EdgeInsets
                              .fromLTRB(
                        20,
                        12,
                        20,
                        0,
                      ),
                      child: QuranSearchBar(
                        onChanged: (value) {
                          setState(() {
                            searchQuery =
                                value;
                          });
                        },
                      ),
                    )
                  : const SizedBox.shrink(),
            ),

           

            const SizedBox(height: 16),

            // SURAH LIST
         
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

                        return _surahRow(
                          surah,
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _headerButton({
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return Material(
      color: const Color(0xffF6EFD9),
      borderRadius:
          BorderRadius.circular(12),
      child: InkWell(
        onTap: onTap,
        borderRadius:
            BorderRadius.circular(12),
        child: SizedBox(
          width: 38,
          height: 38,
          child: Icon(
            icon,
            color:
                const Color(0xff0E5A56),
            size: 19,
          ),
        ),
      ),
    );
  }

  Widget _surahRow(
    SurahModel surah,
  ) {
    final isBookmarked =
        bookmarks.contains(surah.id);

    return InkWell(
      onTap: () =>
          _openSurah(surah),

      child: Container(
        padding:
            const EdgeInsets.fromLTRB(
          20,
          10,
          20,
          10,
        ),

        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(
              color: Colors.black
                  .withValues(alpha: .055),
            ),
          ),
        ),

        child: Row(
          children: [
            // NUMBER
            Container(
              width: 34,
              height: 34,
              alignment:
                  Alignment.center,
              decoration:
                  const BoxDecoration(
                color:
                    Color(0xffF6EFD9),
                shape: BoxShape.circle,
              ),
              child: Text(
                "${surah.id}",
                style:
                    const TextStyle(
                  color:
                      Color(0xff0E5A56),
                  fontSize: 11,
                  fontWeight:
                      FontWeight.w700,
                ),
              ),
            ),

            const SizedBox(width: 12),

            // DETAILS
            Expanded(
              child: Column(
                crossAxisAlignment:
                    CrossAxisAlignment.start,
                children: [
                  Text(
                    surah.nameSimple,
                    maxLines: 1,
                    overflow:
                        TextOverflow.ellipsis,
                    style:
                        const TextStyle(
                      color:
                          Color(0xff173F3B),
                      fontSize: 15.5,
                      fontWeight:
                          FontWeight.w700,
                    ),
                  ),

                  const SizedBox(height: 2),

                  Text(
                    "${_capitalize(surah.revelationPlace)} • ${surah.versesCount} Ayahs",
                    style:
                        const TextStyle(
                      color:
                          Colors.black45,
                      fontSize: 10.5,
                      fontWeight:
                          FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),

            // ARABIC NAME
            Padding(
              padding:
                  const EdgeInsets.only(
                left: 8,
              ),
              child: Text(
                surah.nameArabic,
                textDirection:
                    TextDirection.rtl,
                style:
                    const TextStyle(
                  color:
                      Color(0xffB28A2E),
                  fontFamily: 'Amiri',
                  fontSize: 20,
                  height: 1,
                ),
              ),
            ),

            const SizedBox(width: 8),

            // BOOKMARK
            GestureDetector(
              onTap: () =>
                  _toggleBookmark(
                surah.id,
              ),
              child: SizedBox(
                width: 30,
                height: 36,
                child: Icon(
                  isBookmarked
                      ? Icons
                          .bookmark_rounded
                      : Icons
                          .bookmark_border_rounded,
                  color: isBookmarked
                      ? const Color(
                          0xffE8C76A,
                        )
                      : Colors.black26,
                  size: 19,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _capitalize(
    String value,
  ) {
    if (value.isEmpty) return value;

    return value[0].toUpperCase() +
        value.substring(1);
  }
}