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

class _SurahDetailsScreenState extends State<SurahDetailsScreen> {
  final ScrollController _scrollController = ScrollController();

  final ReadingProgressService _readingProgressService =
      ReadingProgressService();

  final QuranModeProgressService _quranProgressService =
      QuranModeProgressService();

  late int firstPage;
  late int lastPage;

  /// One key for every actual Quran page.
  final Map<int, GlobalKey> _pageKeys = {};

  /// Prevents the restore operation from immediately
  /// overwriting the saved position.
  /// 
 
  bool _isRestoringPosition = false;

  bool _restoreCompleted = false;

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

    for (int page = firstPage; page <= lastPage; page++) {
      _pageKeys[page] = GlobalKey();
    }

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _restoreSavedPage();
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  // ─────────────────────────────────────────────
  // RESTORE EXACT LAST READ PAGE
  // ─────────────────────────────────────────────

 Future<void> _restoreSavedPage() async {
  final savedPage = widget.initialPage;

  if (savedPage == null ||
      savedPage < firstPage ||
      savedPage > lastPage) {
    _restoreCompleted = true;
    return;
  }

  _isRestoringPosition = true;

  // Wait until the ListView has actually attached.
  for (int attempt = 0; attempt < 20; attempt++) {
    if (!mounted) return;

    if (_scrollController.hasClients) {
      break;
    }

    await Future.delayed(
      const Duration(milliseconds: 50),
    );
  }

  if (!mounted || !_scrollController.hasClients) {
    _isRestoringPosition = false;
    _restoreCompleted = true;
    return;
  }

  final pageIndex = savedPage - firstPage;

  // Rough jump only to make Flutter build the target page.
  final roughOffset = pageIndex * 1150.0;

  final maxExtent =
      _scrollController.position.maxScrollExtent;

  _scrollController.jumpTo(
    roughOffset.clamp(
      0.0,
      maxExtent,
    ),
  );

  // Give the target page time to be built.
  await Future.delayed(
    const Duration(milliseconds: 150),
  );

  if (!mounted) return;

  // Now locate the ACTUAL page widget.
  await _ensureSavedPageVisible(savedPage);

  await Future.delayed(
    const Duration(milliseconds: 100),
  );

  _isRestoringPosition = false;
  _restoreCompleted = true;
}
Future<void> _ensureSavedPageVisible(
  int page,
) async {
  final key = _pageKeys[page];

  if (key == null) return;

  for (int attempt = 0; attempt < 10; attempt++) {
    if (!mounted) return;

    final pageContext = key.currentContext;

    if (pageContext != null) {
      await Scrollable.ensureVisible(
        pageContext,
        duration: const Duration(
          milliseconds: 500,
        ),
        curve: Curves.easeOutCubic,
        alignment: 0.0,
      );

      return;
    }

    // Target page hasn't been built yet.
    if (_scrollController.hasClients) {
      final pageIndex = page - firstPage;

      final roughOffset =
          pageIndex * 1150.0;

      final maxExtent =
          _scrollController.position.maxScrollExtent;

      _scrollController.jumpTo(
        roughOffset.clamp(
          0.0,
          maxExtent,
        ),
      );
    }

    await Future.delayed(
      const Duration(milliseconds: 100),
    );
  }
}
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
      contentPadding: const EdgeInsets.symmetric(
        horizontal: 24,
        vertical: 4,
      ),
      leading: Container(
        width: 42,
        height: 42,
        decoration: BoxDecoration(
          color: const Color(0xFF0B4B4B)
              .withValues(alpha: .08),
          borderRadius: BorderRadius.circular(12),
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
  // SAVE PAGE PROGRESS
  // ─────────────────────────────────────────────

  Future<void> _savePageProgress(
    int page,
  ) async {
    if (_isRestoringPosition ||
        !_restoreCompleted ||
        !mounted) {
      return;
    }

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

  // ─────────────────────────────────────────────
  // BUILD
  // ─────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7F7),

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
          onPressed: () {
            Navigator.pop(context);
          },
        ),

        title: Column(
          mainAxisAlignment: MainAxisAlignment.center,
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
              "Page $firstPage",
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

  physics: const BouncingScrollPhysics(),

  padding: const EdgeInsets.fromLTRB(
    8,
    0,
    8,
    32,
  ),

  itemCount: lastPage - firstPage + 1,

  itemBuilder: (context, index) {
    final page = firstPage + index;

    final pageKey = _pageKeys.putIfAbsent(
      page,
      () => GlobalKey(),
    );

    return Column(
      crossAxisAlignment:
          CrossAxisAlignment.stretch,

      children: [
        /// PAGE
        KeyedSubtree(
          key: pageKey,

          child: VisibilityDetector(
            key: Key(
              'arabic_page_$page',
            ),

          onVisibilityChanged: (info) async {
  if (_isRestoringPosition) {
    return;
  }

  if (info.visibleFraction >= 0.6) {
    await _savePageProgress(page);
  }
},

            child: SeekerQcfPage(
              pageNumber: page,
            ),
          ),
        ),

        /// SPACE BETWEEN MUSHAF PAGES
        const SizedBox(height: 18),

        /// PAGE NUMBER / SEPARATOR
        Row(
          children: [
            const Expanded(
              child: Divider(
                thickness: 0.6,
                indent: 24,
                endIndent: 12,
                color: Color(0x22000000),
              ),
            ),

            Text(
              convertToArabicNumber(
                page.toString(),
              ),
              style: const TextStyle(
                fontSize: 13,
                fontWeight:
                    FontWeight.w600,
                color: Colors.grey,
              ),
            ),

            const Expanded(
              child: Divider(
                thickness: 0.6,
                indent: 12,
                endIndent: 24,
                color: Color(0x22000000),
              ),
            ),
          ],
        ),

        const SizedBox(height: 18),
      ],
    );
  },
)
          ),
        ],
      ),
    );
  }
}