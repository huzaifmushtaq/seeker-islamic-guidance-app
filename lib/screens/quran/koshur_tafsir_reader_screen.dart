import 'package:flutter/material.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';

import '../../models/verse_model.dart';
import '../../repositories/quran_repository.dart';
import '../../services/translation_preferences_service.dart';
import '../../services/quran_mode_progress_service.dart';

class KoshurTafsirReaderScreen extends StatefulWidget {
  final int surahNumber;
  final String englishName;
  final String arabicName;
  final String revelationType;
  final int verses;

  /// Ayah to open directly.
  final int? initialAyah;

  const KoshurTafsirReaderScreen({
    super.key,
    required this.surahNumber,
    required this.englishName,
    required this.arabicName,
    required this.revelationType,
    required this.verses,
    this.initialAyah,
  });

  @override
  State<KoshurTafsirReaderScreen> createState() =>
      _KoshurTafsirReaderScreenState();
}

class _KoshurTafsirReaderScreenState
    extends State<KoshurTafsirReaderScreen> {
  final QuranRepository _repository =
      QuranRepository();

  final QuranModeProgressService _progressService =
      QuranModeProgressService();

  final ItemScrollController _itemScrollController =
      ItemScrollController();

  final ItemPositionsListener _itemPositionsListener =
      ItemPositionsListener.create();

  late Future<List<VerseModel>> _versesFuture;

  /// Current Ayah.
  int _currentAyah = 1;

  /// Prevents scrolling from changing progress while
  /// Continue Reading is restoring the saved Ayah.
  bool _isRestoring = false;

  bool _restoreCompleted = false;

  /// One key for the Arabic text of every Ayah.
  ///
  /// IMPORTANT:
  /// Arabic is the only reading anchor.
  /// Tarjuma and Tafsir do not participate in
  /// Ayah detection.
  final Map<int, GlobalKey> _arabicKeys = {};

  @override
  void initState() {
    super.initState();

    _currentAyah =
        widget.initialAyah ?? 1;

    _versesFuture =
        _repository.loadSurah(
      widget.surahNumber,
      widget.verses,
    );

    _itemPositionsListener.itemPositions
        .addListener(_updateCurrentAyah);

    WidgetsBinding.instance.addPostFrameCallback(
      (_) {
        _restoreInitialAyah();
      },
    );
  }

  @override
  void dispose() {
    _itemPositionsListener.itemPositions
        .removeListener(_updateCurrentAyah);

    super.dispose();
  }

  // ─────────────────────────────────────────────
  // CURRENT AYAH
  // ─────────────────────────────────────────────

  void _updateCurrentAyah() {
    if (!mounted ||
        _isRestoring ||
        !_restoreCompleted) {
      return;
    }

    final positions =
        _itemPositionsListener
            .itemPositions
            .value;

    if (positions.isEmpty) {
      return;
    }

    final visiblePositions =
        positions.where(
      (position) =>
          position.itemTrailingEdge > 0 &&
          position.itemLeadingEdge < 1,
    );

    if (visiblePositions.isEmpty) {
      return;
    }

    final sorted =
        visiblePositions.toList()
          ..sort(
            (a, b) =>
                a.index.compareTo(
              b.index,
            ),
          );

    int? detectedAyah;

    /*
     * This is the reading boundary.
     *
     * We check the Arabic text itself against
     * this boundary.
     *
     * The size of the Tafsir underneath the
     * Arabic text does NOT matter.
     */
    const double readingBoundary = 115;

    for (final position in sorted) {
      final ayahNumber =
          position.index + 1;

      final key =
          _arabicKeys[ayahNumber];

      if (key == null) {
        continue;
      }

      final context =
          key.currentContext;

      if (context == null) {
        continue;
      }

      final renderObject =
          context.findRenderObject();

      if (renderObject == null ||
          renderObject is! RenderBox ||
          !renderObject.hasSize) {
        continue;
      }

      final globalPosition =
          renderObject.localToGlobal(
        Offset.zero,
      );

      final bottom =
          globalPosition.dy +
              renderObject.size.height;

      /*
       * The current Ayah remains highlighted
       * until the LAST LINE of its Arabic text
       * crosses the reading boundary.
       *
       * Once it crosses, the next Ayah becomes
       * current.
       */
      if (bottom > readingBoundary) {
        detectedAyah = ayahNumber;
        break;
      }
    }

    /*
     * Important for fast scrolling.
     *
     * If no Arabic text remains above the
     * boundary, use the last visible Ayah.
     */
    detectedAyah ??=
        sorted.last.index + 1;

    if (detectedAyah == _currentAyah) {
      return;
    }

    setState(() {
      _currentAyah = detectedAyah!;
    });

    _saveProgress(detectedAyah);
  }

  // ─────────────────────────────────────────────
  // SAVE PROGRESS
  // ─────────────────────────────────────────────

  Future<void> _saveProgress(
    int ayah,
  ) async {
    if (!mounted ||
        _isRestoring ||
        !_restoreCompleted) {
      return;
    }

    await _progressService.saveProgress(
      mode: QuranMode.tafsir,
      surah: widget.surahNumber,
      ayah: ayah,
    );
  }

  // ─────────────────────────────────────────────
  // RESTORE AYAH
  // ─────────────────────────────────────────────

  Future<void> _restoreInitialAyah() async {
    final initialAyah =
        widget.initialAyah;

    if (initialAyah == null) {
      _restoreCompleted = true;
      return;
    }

    _isRestoring = true;

    final verses =
        await _versesFuture;

    if (!mounted) {
      return;
    }

    final index =
        _getInitialIndex(verses);

    if (index == -1) {
      _restoreCompleted = true;
      _isRestoring = false;
      return;
    }

    /*
     * First move to the correct Ayah ITEM.
     *
     * This is the same mechanism as the working
     * Arabic/Tarjuma reader.
     */
    if (_itemScrollController.isAttached) {
      _itemScrollController.jumpTo(
        index: index,
        alignment: 0.02,
      );
    }

    /*
     * Give Flutter time to build the target
     * Arabic widget.
     */
    await Future.delayed(
      const Duration(milliseconds: 80),
    );

    if (!mounted) {
      return;
    }

    /*
     * Now position the actual Arabic text.
     *
     * NOT the whole Tafsir card.
     */
    await _ensureArabicTextVisible(
      initialAyah,
    );

    if (!mounted) {
      return;
    }

    setState(() {
      _currentAyah = initialAyah;
    });

    _restoreCompleted = true;
    _isRestoring = false;
  }

  // ─────────────────────────────────────────────
  // POSITION ACTUAL ARABIC TEXT
  // ─────────────────────────────────────────────

  Future<void> _ensureArabicTextVisible(
    int ayah,
  ) async {
    final key =
        _arabicKeys[ayah];

    if (key == null) {
      return;
    }

    final context =
        key.currentContext;

    if (context == null ||
        !mounted) {
      return;
    }

    /*
     * Position the Arabic text itself.
     *
     * Tarjuma/Tafsir height has no effect on
     * what Ayah is restored.
     */
    await Scrollable.ensureVisible(
      context,
      alignment: 0.12,
      duration:
          const Duration(milliseconds: 1),
      curve: Curves.linear,
    );
  }

  // ─────────────────────────────────────────────
  // INITIAL INDEX
  // ─────────────────────────────────────────────

  int _getInitialIndex(
    List<VerseModel> verses,
  ) {
    if (widget.initialAyah == null) {
      return 0;
    }

    final index =
        verses.indexWhere(
      (verse) =>
          verse.ayah ==
          widget.initialAyah,
    );

    if (index == -1) {
      return 0;
    }

    return index;
  }

  // ─────────────────────────────────────────────
  // BUILD
  // ─────────────────────────────────────────────

  @override
  Widget build(
    BuildContext context,
  ) {
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
            color:
                Color(0xff0E5A56),
          ),
          onPressed: () {
            Navigator.pop(context);
          },
        ),

        title: Column(
          crossAxisAlignment:
              CrossAxisAlignment.start,

          children: [
            Text(
              widget.arabicName,

              style:
                  const TextStyle(
                color:
                    Color(0xff0E5A56),
                fontFamily: 'Amiri',
                fontSize: 22,
                fontWeight:
                    FontWeight.w700,
              ),
            ),

            Text(
              "Urdu Tafsir • "
              "${widget.verses} Ayahs",

              style:
                  const TextStyle(
                color:
                    Colors.black54,
                fontSize: 11,
                fontWeight:
                    FontWeight.w500,
              ),
            ),
          ],
        ),
      ),

      body:
          FutureBuilder<List<VerseModel>>(
        future: _versesFuture,

        builder:
            (context, snapshot) {
          if (snapshot.connectionState !=
              ConnectionState.done) {
            return const Center(
              child:
                  CircularProgressIndicator(
                color:
                    Color(0xff0E5A56),
              ),
            );
          }

          if (snapshot.hasError) {
            return Center(
              child: Padding(
                padding:
                    const EdgeInsets.all(24),

                child: Text(
                  'Unable to load Quran.\n\n'
                  '${snapshot.error}',

                  textAlign:
                      TextAlign.center,
                ),
              ),
            );
          }

          final verses =
              snapshot.data ?? [];

          if (verses.isEmpty) {
            return const Center(
              child:
                  Text('No verses found.'),
            );
          }

          /*
           * Create one Arabic key per Ayah.
           */
          for (final verse in verses) {
            _arabicKeys.putIfAbsent(
              verse.ayah,
              () => GlobalKey(),
            );
          }

          final initialIndex =
              _getInitialIndex(
            verses,
          );

          return ScrollablePositionedList
              .builder(
            initialScrollIndex:
                initialIndex,

            initialAlignment:
                0.02,

            itemScrollController:
                _itemScrollController,

            itemPositionsListener:
                _itemPositionsListener,

            physics:
                const BouncingScrollPhysics(),

            padding:
                const EdgeInsets.fromLTRB(
              16,
              8,
              16,
              32,
            ),

            itemCount:
                verses.length,

            itemBuilder:
                (context, index) {
              final verse =
                  verses[index];

              return _ayahCard(
                verse,
              );
            },
          );
        },
      ),
    );
  }

  // ─────────────────────────────────────────────
  // AYAH CARD
  // ─────────────────────────────────────────────

  Widget _ayahCard(
    VerseModel verse,
  ) {
    final kashmiri =
        verse.translation(
      TranslationType.kashmiri,
    );

    final tafsir =
        verse.bayanulFurqanTafsir;

    final isCurrent =
        _currentAyah ==
            verse.ayah;

    return Container(
      margin:
          const EdgeInsets.only(
        bottom: 14,
      ),

      decoration:
          BoxDecoration(
        color: isCurrent
            ? const Color(0xffF1E8CC)
            : Colors.white,

        borderRadius:
            BorderRadius.circular(22),

        border:
            Border.all(
          color:
              const Color(0xff0E5A56)
                  .withValues(
            alpha: .07,
          ),
        ),

        boxShadow: [
          BoxShadow(
            color:
                Colors.black.withValues(
              alpha: .035,
            ),
            blurRadius: 14,
            offset:
                const Offset(0, 5),
          ),
        ],
      ),

      child: Padding(
        padding:
            const EdgeInsets.fromLTRB(
          18,
          16,
          18,
          18,
        ),

        child: Column(
          crossAxisAlignment:
              CrossAxisAlignment.stretch,

          children: [
            // ───────── AYAH NUMBER ─────────

            Row(
              children: [
                Container(
                  width: 30,
                  height: 30,

                  decoration:
                      const BoxDecoration(
                    color:
                        Color(0xffF6EFD9),
                    shape:
                        BoxShape.circle,
                  ),

                  alignment:
                      Alignment.center,

                  child: Text(
                    verse.ayah
                        .toString(),

                    style:
                        const TextStyle(
                      color:
                          Color(0xff0E5A56),
                      fontSize: 11,
                      fontWeight:
                          FontWeight.bold,
                    ),
                  ),
                ),

                const Spacer(),

                Text(
                  "آيَة ${verse.ayah}",

                  textDirection:
                      TextDirection.rtl,

                  style:
                      const TextStyle(
                    color:
                        Color(0xffB28A2E),
                    fontFamily: 'Amiri',
                    fontSize: 13,
                    fontWeight:
                        FontWeight.w600,
                  ),
                ),
              ],
            ),

            const SizedBox(
              height: 16,
            ),

            // ───────── ARABIC ─────────
            //
            // THIS IS THE ONLY AYAH ANCHOR.

            Text(
              verse.arabic,

              key:
                  _arabicKeys[
                verse.ayah
              ],

              textAlign:
                  TextAlign.right,

              textDirection:
                  TextDirection.rtl,

              style:
                  const TextStyle(
                color:
                    Color(0xff182C2A),
                fontFamily: 'Amiri',
                fontSize: 24,
                height: 1.9,
                fontWeight:
                    FontWeight.w500,
              ),
            ),

            const SizedBox(
              height: 15,
            ),

            // ───────── KASHMIRI TARJUMA ─────────

            Row(
              children: [
                Container(
                  width: 28,
                  height: 2,

                  decoration:
                      BoxDecoration(
                    color:
                        const Color(
                      0xffE8C76A,
                    ),
                    borderRadius:
                        BorderRadius.circular(
                      10,
                    ),
                  ),
                ),

                const SizedBox(
                  width: 8,
                ),

                const Text(
                  "TARJUMA",

                  style:
                      TextStyle(
                    color:
                        Color(0xffB28A2E),
                    fontSize: 12,
                    fontWeight:
                        FontWeight.w700,
                    letterSpacing: 1,
                  ),
                ),
              ],
            ),

            const SizedBox(
              height: 10,
            ),

            Text(
              kashmiri,

              textAlign:
                  TextAlign.right,

              textDirection:
                  TextDirection.rtl,

              style:
                  const TextStyle(
                color:
                    Color(0xff40504E),
                fontSize: 16,
                height: 1.75,
                fontWeight:
                    FontWeight.w500,
              ),
            ),

            const SizedBox(
              height: 18,
            ),

            // ───────── TAFSIR ─────────

            Row(
              children: [
                Container(
                  width: 28,
                  height: 2,

                  decoration:
                      BoxDecoration(
                    color:
                        const Color(
                      0xffE8C76A,
                    ),
                    borderRadius:
                        BorderRadius.circular(
                      10,
                    ),
                  ),
                ),

                const SizedBox(
                  width: 8,
                ),

                const Text(
                  "TAFSIR",

                  style:
                      TextStyle(
                    color:
                        Color(0xffB28A2E),
                    fontSize: 12,
                    fontWeight:
                        FontWeight.w700,
                    letterSpacing: 1,
                  ),
                ),
              ],
            ),

            const SizedBox(
              height: 10,
            ),

            Text(
              tafsir,

              textAlign:
                  TextAlign.right,

              textDirection:
                  TextDirection.rtl,

              style:
                  const TextStyle(
                color:
                    Color(0xff40504E),
                fontSize: 15,
                height: 1.75,
                fontWeight:
                    FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}