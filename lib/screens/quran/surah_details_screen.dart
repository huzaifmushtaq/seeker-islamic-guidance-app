import 'package:flutter/material.dart';
import 'package:qcf_quran/qcf_quran.dart';
import 'package:seeker/widgets/quran/seeker_qcf_page.dart';
import 'package:visibility_detector/visibility_detector.dart';
import '../../services/quran_mode_progress_service.dart';
import '../../services/reading_progress_service.dart';

bool hideUI = false;

class SurahDetailsScreen extends StatefulWidget {
  final int surahNumber;
  final String englishName;
  final String arabicName;
  final String revelationType;
  final int verses;
  final int? initialPage;

  const SurahDetailsScreen({
    super.key,
    required this.surahNumber,
    required this.englishName,
    required this.arabicName,
    required this.revelationType,
    required this.verses,
    this.initialPage,
  });

  @override
  State<SurahDetailsScreen> createState() =>
      _SurahDetailsScreenState();
}

final ScrollController _scrollController =
    ScrollController();

class _SurahDetailsScreenState
    extends State<SurahDetailsScreen> {
  final ReadingProgressService _readingProgressService =
      ReadingProgressService();
final QuranModeProgressService
    _quranProgressService =
    QuranModeProgressService();
  late int firstPage;
  late int lastPage;


  @override
  void initState() {
    super.initState();

    firstPage = getPageNumber(
      widget.surahNumber,
      1,
    );

    lastPage = getPageNumber(
      widget.surahNumber,
      widget.verses,
    );

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _jumpToSavedPage();
    });
  }

  // ─────────────────────────────────────────────
  // JUMP TO LAST READ PAGE
  // ─────────────────────────────────────────────

  void _jumpToSavedPage() {
    if (widget.initialPage == null) return;

    final pageIndex =
        widget.initialPage! - firstPage;

    if (pageIndex < 0) return;

    _scrollController.animateTo(
      pageIndex * 1150,
      duration: const Duration(
        milliseconds: 600,
      ),
      curve: Curves.easeInOut,
    );
  }

  // ─────────────────────────────────────────────
  // READER OPTIONS
  // ─────────────────────────────────────────────

  void _showReaderOptions() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      showDragHandle: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(28),
        ),
      ),
      builder: (_) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(
              vertical: 12,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Padding(
                  padding: EdgeInsets.only(
                    top: 8,
                    bottom: 18,
                  ),
                  child: Text(
                    "Reader Options",
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),

               

                
             
                _option(
                  icon: Icons.settings_outlined,
                  title: "Reader Settings",
                  onTap: () {},
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // ─────────────────────────────────────────────
  // OPTION TILE
  // ─────────────────────────────────────────────

  Widget _option({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return ListTile(
      onTap: onTap,

      contentPadding:
          const EdgeInsets.symmetric(
        horizontal: 24,
        vertical: 4,
      ),

      leading: Container(
        width: 42,
        height: 42,

        decoration: BoxDecoration(
          color: const Color(0xFF0B4B4B)
              .withValues(alpha: .08),
          borderRadius:
              BorderRadius.circular(12),
        ),

        child: Icon(
          icon,
          color: const Color(0xFF0B4B4B),
        ),
      ),

      title: Text(
        title,
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
        ),
      ),

      trailing: const Icon(
        Icons.arrow_forward_ios_rounded,
        size: 16,
        color: Colors.grey,
      ),
    );
  }

  // ─────────────────────────────────────────────
  // BUILD
  // ─────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor:
          const Color(0xFFF5F7F7),

      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: true,

        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new_rounded,
            color: Colors.black87,
          ),

          onPressed: () =>
              Navigator.pop(context),
        ),

        title: Column(
          mainAxisAlignment:
              MainAxisAlignment.center,

          children: [
            Text(
              widget.englishName,
              style: const TextStyle(
                color: Colors.black87,
                fontSize: 20,
                fontWeight: FontWeight.w700,
              ),
            ),

            const SizedBox(height: 2),

            Text(
              "Juz 1 • Page $firstPage",
              style: TextStyle(
                color: Colors.grey.shade600,
                fontWeight: FontWeight.bold,
                fontSize: 13,
              ),
            ),
          ],
        ),

        actions: [

          IconButton(
            icon: const Icon(
              Icons.more_vert,
              color: Colors.black87,
            ),

            onPressed: _showReaderOptions,
          ),
        ],
      ),

            body: Column(
        children: [
          const SizedBox(height: 8),

          Expanded(
            child: ListView.builder(
              controller: _scrollController,

              padding: const EdgeInsets.only(
                left: 8,
                right: 8,
                bottom: 24,
              ),

              itemCount: lastPage - firstPage + 1,

              itemBuilder: (context, index) {
                final page = firstPage + index;

                return Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.stretch,

                  children: [
                    /// PAGE SEPARATOR
                    if (index != 0)
                      Padding(
                        padding:
                            const EdgeInsets.symmetric(
                          vertical: 20,
                        ),
                        child: Row(
                          children: [
                            const Expanded(
                              child: Divider(
                                thickness: 0.7,
                                indent: 20,
                                endIndent: 12,
                                color: Colors.grey,
                              ),
                            ),

                            Text(
                              convertToArabicNumber(
                                page.toString(),
                              ),
                              style: const TextStyle(
                                fontSize: 15,
                                fontWeight:
                                    FontWeight.w600,
                                color: Colors.grey,
                              ),
                            ),

                            const Expanded(
                              child: Divider(
                                thickness: 0.7,
                                indent: 12,
                                endIndent: 20,
                                color: Colors.grey,
                              ),
                            ),
                          ],
                        ),
                      ),

                    /// QURAN PAGE
                    VisibilityDetector(
                      key: Key('page_$page'),

                      onVisibilityChanged:
                          (info) async {
                       if (info.visibleFraction >= 0.6) {
  await _readingProgressService.saveLastRead(
    page: page,
    surah: widget.surahNumber,
    ayah: 1,
  );

  await _quranProgressService.saveProgress(
    mode: QuranMode.arabic,
    surah: widget.surahNumber,
    ayah: 1,
    page: page,
  );
}
                      },

                      child: SeekerQcfPage(
                        pageNumber: page,
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}