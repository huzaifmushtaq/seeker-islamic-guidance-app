import 'package:flutter/material.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';

import '../../models/quran_ayah.dart';
import '../../repositories/qpc_quran_repository.dart';
import '../../services/quran_mode_progress_service.dart';

class QuranAyahReaderScreen extends StatefulWidget {
  final int surahNumber;
  final String englishName;
  final String arabicName;
  final String revelationType;
  final int verses;

  final int? initialAyah;

  const QuranAyahReaderScreen({
    super.key,
    required this.surahNumber,
    required this.englishName,
    required this.arabicName,
    required this.revelationType,
    required this.verses,
    this.initialAyah,
  });

  @override
  State<QuranAyahReaderScreen> createState() =>
      _QuranAyahReaderScreenState();
}

class _QuranAyahReaderScreenState
    extends State<QuranAyahReaderScreen> {
  final QpcQuranRepository _repository =
      QpcQuranRepository();

  final QuranModeProgressService _progressService =
      QuranModeProgressService();

  final ItemScrollController _itemScrollController =
      ItemScrollController();

  final ItemPositionsListener _itemPositionsListener =
      ItemPositionsListener.create();

  late Future<List<QuranAyah>> _ayahsFuture;

  int _currentAyah = 1;

  final Map<int, GlobalKey> _ayahTextKeys = {};

  bool _initialPositionFixed = false;

  @override
  void initState() {
    super.initState();

    _currentAyah = widget.initialAyah ?? 1;

    _ayahsFuture =
        _repository.loadSurah(
      widget.surahNumber,
    );

    _itemPositionsListener.itemPositions
        .addListener(_updateCurrentAyah);
  }

  @override
  void dispose() {
    _itemPositionsListener.itemPositions
        .removeListener(_updateCurrentAyah);

    super.dispose();
  }

  // ─────────────────────────────────────────────
  // CURRENT AYAH TRACKING
  // ─────────────────────────────────────────────

  void _updateCurrentAyah() {
    if (!mounted) return;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;

      final ayahNumber =
          _findCurrentAyahFromText();

      if (ayahNumber == null) return;

      if (_currentAyah == ayahNumber) {
        return;
      }

      setState(() {
        _currentAyah = ayahNumber;
      });

      _saveProgress(ayahNumber);
    });
  }

  int? _findCurrentAyahFromText() {
    if (_ayahTextKeys.isEmpty) {
      return null;
    }

    final double boundary =
        kToolbarHeight + 35;

    int? candidate;

    final entries =
        _ayahTextKeys.entries.toList()
          ..sort(
            (a, b) =>
                a.key.compareTo(b.key),
          );

    for (final entry in entries) {
      final context =
          entry.value.currentContext;

      if (context == null) {
        continue;
      }

      final renderObject =
          context.findRenderObject();

      if (renderObject == null ||
          renderObject is! RenderBox) {
        continue;
      }

      if (!renderObject.hasSize) {
        continue;
      }

      final position =
          renderObject.localToGlobal(
        Offset.zero,
      );

      final top = position.dy;

      final bottom =
          position.dy +
              renderObject.size.height;

      if (bottom > boundary) {
        candidate = entry.key;
        break;
      }

      if (top <= boundary &&
          bottom <= boundary) {
        continue;
      }
    }

    return candidate;
  }

  // ─────────────────────────────────────────────
  // SAVE PROGRESS
  // ─────────────────────────────────────────────

  Future<void> _saveProgress(
    int ayah,
  ) async {
    await _progressService.saveProgress(
      mode: QuranMode.arabic,
      surah: widget.surahNumber,
      ayah: ayah,
    );
  }

  // ─────────────────────────────────────────────
  // FIX INITIAL CONTINUE-READING POSITION
  // ─────────────────────────────────────────────

  void _fixInitialPosition(
    List<QuranAyah> ayahs,
  ) {
    if (_initialPositionFixed) {
      return;
    }

    if (widget.initialAyah == null) {
      return;
    }

    if (!_itemScrollController.isAttached) {
      return;
    }

    final key =
        _ayahTextKeys[widget.initialAyah!];

    if (key == null) {
      return;
    }

    final textContext =
        key.currentContext;

    if (textContext == null) {
      return;
    }

    _initialPositionFixed = true;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;

      final context =
          key.currentContext;

      if (context == null) {
        return;
      }

      /*
       * Position the ACTUAL Arabic text,
       * not the entire Ayah card.
       *
       * Alignment 0.12 means the Arabic text
       * starts around 12% down the visible
       * reading area.
       */
      Scrollable.ensureVisible(
        context,
        alignment: 0.12,
        duration:
            const Duration(milliseconds: 1),
        curve: Curves.linear,
      );
    });
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
              widget.englishName,

              style:
                  const TextStyle(
                color:
                    Color(0xff0E5A56),
                fontSize: 20,
                fontWeight:
                    FontWeight.w700,
              ),
            ),

            Text(
              widget.arabicName,

              style:
                  const TextStyle(
                color:
                    Colors.black54,
                fontFamily: 'Amiri',
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),

      body:
          FutureBuilder<List<QuranAyah>>(
        future: _ayahsFuture,

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

          final ayahs =
              snapshot.data ?? [];

          if (ayahs.isEmpty) {
            return const Center(
              child:
                  Text('No Ayahs found.'),
            );
          }

          final initialIndex =
              _getInitialIndex(
            ayahs,
          );

          /*
           * Once the list has been built,
           * position the actual saved Ayah's
           * Arabic text correctly.
           */
          if (widget.initialAyah != null &&
              !_initialPositionFixed) {
            WidgetsBinding.instance
                .addPostFrameCallback((_) {
              if (!mounted) return;

              _fixInitialPosition(
                ayahs,
              );
            });
          }

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
              16,
              16,
              40,
            ),

            itemCount:
                ayahs.length,

            itemBuilder:
                (context, index) {
              final ayah =
                  ayahs[index];

              return _ayahCard(
                ayah,
              );
            },
          );
        },
      ),
    );
  }

  // ─────────────────────────────────────────────
  // INITIAL AYAH
  // ─────────────────────────────────────────────

  int _getInitialIndex(
    List<QuranAyah> ayahs,
  ) {
    if (widget.initialAyah == null) {
      return 0;
    }

    final index =
        ayahs.indexWhere(
      (ayah) =>
          ayah.ayah ==
          widget.initialAyah,
    );

    if (index == -1) {
      return 0;
    }

    return index;
  }

  // ─────────────────────────────────────────────
  // AYAH CARD
  // ─────────────────────────────────────────────

  Widget _ayahCard(
    QuranAyah ayah,
  ) {
    final isCurrent =
        _currentAyah ==
            ayah.ayah;

    final textKey =
        _ayahTextKeys.putIfAbsent(
      ayah.ayah,
      () => GlobalKey(),
    );

    return Container(
      margin:
          const EdgeInsets.only(
        bottom: 14,
      ),

      padding:
          const EdgeInsets.fromLTRB(
        18,
        16,
        18,
        20,
      ),

      decoration:
          BoxDecoration(
        color: isCurrent
            ? const Color(0xffF1E8CC)
            : Colors.white,

        borderRadius:
            BorderRadius.circular(
          22,
        ),

        border:
            Border.all(
          color:
              const Color(0xff0E5A56)
                  .withValues(
            alpha: .08,
          ),
        ),

        boxShadow: [
          BoxShadow(
            color:
                Colors.black.withValues(
              alpha: .035,
            ),
            blurRadius: 12,
            offset:
                const Offset(0, 4),
          ),
        ],
      ),

      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment
                .stretch,

        children: [
          Row(
            children: [
              Container(
                width: 32,
                height: 32,

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
                  ayah.ayah
                      .toString(),

                  style:
                      const TextStyle(
                    color:
                        Color(0xff0E5A56),
                    fontSize: 12,
                    fontWeight:
                        FontWeight.bold,
                  ),
                ),
              ),

              const Spacer(),

              Text(
                ayah.verseKey,

                style:
                    const TextStyle(
                  color:
                      Color(0xffB28A2E),
                  fontSize: 12,
                  fontWeight:
                      FontWeight.w600,
                ),
              ),
            ],
          ),

          const SizedBox(
            height: 18,
          ),

          Text(
            ayah.text,

            key: textKey,

            textDirection:
                TextDirection.rtl,

            textAlign:
                TextAlign.right,

            style:
                const TextStyle(
              fontFamily:
                  'QPCHafs',

              fontSize: 28,

              height: 2.0,

              color:
                  Color(0xff182C2A),
            ),
          ),
        ],
      ),
    );
  }
}