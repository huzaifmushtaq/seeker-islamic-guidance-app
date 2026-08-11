import 'package:flutter/material.dart';
import 'package:qcf_quran/qcf_quran.dart';
import 'package:seeker/widgets/quran/seeker_qcf_page.dart';
import 'package:seeker/widgets/quran/translation_view.dart';
import 'package:seeker/widgets/quran/tafsir_view.dart';
import 'package:visibility_detector/visibility_detector.dart';
import '../../services/reading_progress_service.dart';
import '../../services/translation_preferences_service.dart';
import 'package:seeker/services/tafsir_preferences_service.dart';

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
  State<SurahDetailsScreen> createState() => _SurahDetailsScreenState();
}

final ScrollController _scrollController = ScrollController();

class _SurahDetailsScreenState extends State<SurahDetailsScreen> {
  final ReadingProgressService _readingProgressService =
      ReadingProgressService();
  int selectedTab = 0;
  TranslationType selectedTranslation = TranslationType.kashmiri;
  TafsirType selectedTafsir = TafsirType.bayanulFurqan;
  late int firstPage;
  late int lastPage;
  void _showTranslationSelector() {
    showModalBottomSheet(
      context: context,
      showDragHandle: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Padding(
                padding: EdgeInsets.all(18),
                child: Text(
                  "Choose Translation",
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
              ),

              ListTile(
                leading: const Icon(Icons.language),
                title: const Text("Kashmiri"),
                onTap: () async {
                  await TranslationPreferencesService().setSelectedTranslation(
                    TranslationType.kashmiri,
                  );

                  selectedTranslation = TranslationType.kashmiri;

                  if (!mounted) return;

                  Navigator.pop(context);

                  setState(() {});
                },
              ),

              ListTile(
                leading: const Icon(Icons.language),
                title: const Text("Bayan-ul-Furqan"),
                onTap: () async {
                  await TranslationPreferencesService().setSelectedTranslation(
                    TranslationType.bayanulFurqan,
                  );

                  selectedTranslation = TranslationType.bayanulFurqan;

                  if (!mounted) return;

                  Navigator.pop(context);

                  setState(() {});
                },
              ),

              const SizedBox(height: 16),
            ],
          ),
        );
      },
    );
  }

  void _showTafsirSelector() {
    showModalBottomSheet(
      context: context,
      showDragHandle: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Padding(
                padding: EdgeInsets.all(18),
                child: Text(
                  "Choose Tafsir",
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
              ),

              ListTile(
                leading: const Icon(Icons.menu_book),
                title: const Text("Bayan-ul-Furqan"),
                onTap: () async {
                  await TafsirPreferencesService().setSelectedTafsir(
                    TafsirType.bayanulFurqan,
                  );

                  selectedTafsir = TafsirType.bayanulFurqan;

                  if (!mounted) return;

                  Navigator.pop(context);

                  setState(() {});
                },
              ),

              ListTile(
                leading: const Icon(Icons.menu_book),
                title: const Text("Ibn Kathir"),
                onTap: () async {
                  await TafsirPreferencesService().setSelectedTafsir(
                    TafsirType.ibnKathir,
                  );

                  selectedTafsir = TafsirType.ibnKathir;

                  if (!mounted) return;

                  Navigator.pop(context);

                  setState(() {});
                },
              ),

              const SizedBox(height: 16),
            ],
          ),
        );
      },
    );
  }

  @override
  void initState() {
    super.initState();

    firstPage = getPageNumber(widget.surahNumber, 1);

    lastPage = getPageNumber(widget.surahNumber, widget.verses);
    _loadTranslationPreference();
    _loadTafsirPreference();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _jumpToSavedPage();
    });
  }

  void _jumpToSavedPage() {
    if (widget.initialPage == null) return;

    final pageIndex = widget.initialPage! - firstPage;

    if (pageIndex < 0) return;

    _scrollController.animateTo(
      pageIndex * 1150, // we'll improve this later
      duration: const Duration(milliseconds: 600),
      curve: Curves.easeInOut,
    );
  }

  Future<void> _loadTranslationPreference() async {
    selectedTranslation = await TranslationPreferencesService()
        .getSelectedTranslation();

    if (mounted) {
      setState(() {});
    }
  }

  Future<void> _loadTafsirPreference() async {
    selectedTafsir = await TafsirPreferencesService().getSelectedTafsir();

    if (mounted) {
      setState(() {});
    }
  }

  void _showReaderOptions() {
    const Padding(
      padding: EdgeInsets.only(top: 8, bottom: 18),
      child: Text(
        "Reader Options",
        style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
      ),
    );
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      showDragHandle: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (_) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 12),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _option(
                  icon: Icons.bookmark_border,
                  title: "Bookmarks",
                  onTap: () {},
                ),

                _option(
                  icon: Icons.menu_book_rounded,
                  title: "Jump to Surah",
                  onTap: () {},
                ),

                _option(
                  icon: Icons.description_outlined,
                  title: "Jump to Page",
                  onTap: () {},
                ),

                _option(
                  icon: Icons.translate_rounded,
                  title: "Translation",
                  onTap: () {
                    Navigator.pop(context);
                    _showTranslationSelector();
                  },
                ),

                _option(
                  icon: Icons.library_books_outlined,
                  title: "Tafsir",
                  onTap: () {
                    Navigator.pop(context);
                    _showTafsirSelector();
                  },
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

  Widget _option({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return ListTile(
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 4),

      leading: Container(
        width: 42,
        height: 42,
        decoration: BoxDecoration(
          color: const Color(0xFF0B4B4B).withValues(alpha: .08),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(icon, color: const Color(0xFF0B4B4B)),
      ),

      title: Text(
        title,
        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
      ),

      trailing: const Icon(
        Icons.arrow_forward_ios_rounded,
        size: 16,
        color: Colors.grey,
      ),
    );
  }

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
          onPressed: () => Navigator.pop(context),
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
              Icons.bookmark_border_rounded,
              color: Colors.black87,
            ),
            onPressed: () {},
          ),

          IconButton(
            icon: const Icon(Icons.more_vert, color: Colors.black87),
            onPressed: _showReaderOptions,
          ),
        ],
      ),

      body: Column(
        children: [
          const SizedBox(height: 15),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),

            child: Container(
              height: 56,

              decoration: BoxDecoration(
                color: const Color(0xffF8F5F2),

                borderRadius: BorderRadius.circular(18),

                border: Border.all(color: Colors.grey.shade300),
              ),

              child: Row(
                children: [
                  _buildTab("Tafsir", 2),

                  _buildTab("Translation", 1),

                  _buildTab("Quran", 0),
                ],
              ),
            ),
          ),
          const SizedBox(height: 15),

          Expanded(
            child: selectedTab == 0
                ? ListView.builder(
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
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          if (index != 0)
                            Padding(
                              padding: const EdgeInsets.symmetric(vertical: 20),
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
                                    convertToArabicNumber(page.toString()),
                                    style: const TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.w600,
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

                          VisibilityDetector(
                            key: Key('page_$page'),
                            onVisibilityChanged: (info) async {
                              if (info.visibleFraction >= 0.6) {
                                await _readingProgressService.saveLastRead(
                                  page: page,
                                  surah: widget.surahNumber,
                                  ayah: 1,
                                );
                              }
                            },
                            child: SeekerQcfPage(pageNumber: page),
                          ),
                        ],
                      );
                    },
                  )
                : selectedTab == 1
                ? TranslationView(
                    key: ValueKey(selectedTranslation),
                    surahNumber: widget.surahNumber,
                    verses: widget.verses,
                    selectedTranslation: selectedTranslation,
                  )
                : TafsirView(
                    key: ValueKey(selectedTafsir),
                    surahNumber: widget.surahNumber,
                    verses: widget.verses,
                    selectedTafsir: selectedTafsir,
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildTab(String title, int index) {
    final selected = selectedTab == index;

    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() {
            selectedTab = index;
          });
        },

        child: AnimatedContainer(
          duration: const Duration(milliseconds: 250),

          margin: const EdgeInsets.all(5),

          decoration: BoxDecoration(
            color: selected ? Colors.white : Colors.transparent,

            borderRadius: BorderRadius.circular(14),

            boxShadow: selected
                ? [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: .08),
                      blurRadius: 10,
                      offset: const Offset(0, 3),
                    ),
                  ]
                : [],
          ),

          child: Center(
            child: AnimatedDefaultTextStyle(
              duration: const Duration(milliseconds: 250),

              style: TextStyle(
                color: selected ? const Color(0xff7B3AED) : Colors.grey,

                fontWeight: FontWeight.w700,

                fontSize: 15,
              ),

              child: Text(title),
            ),
          ),
        ),
      ),
    );
  }
}
