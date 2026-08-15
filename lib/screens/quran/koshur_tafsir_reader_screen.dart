import 'package:flutter/material.dart';

import '../../models/verse_model.dart';
import '../../repositories/quran_repository.dart';
import '../../services/translation_preferences_service.dart';
import '../../services/quran_mode_progress_service.dart';
import 'package:visibility_detector/visibility_detector.dart';

class KoshurTafsirReaderScreen extends StatefulWidget {
  final int surahNumber;
  final String englishName;
  final String arabicName;
  final String revelationType;
  final int verses;

  const KoshurTafsirReaderScreen({
    super.key,
    required this.surahNumber,
    required this.englishName,
    required this.arabicName,
    required this.revelationType,
    required this.verses,
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

  late Future<List<VerseModel>> _versesFuture;

  @override
  void initState() {
    super.initState();

    _versesFuture = _repository.loadSurah(
      widget.surahNumber,
      widget.verses,
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

        title: Column(
          crossAxisAlignment:
              CrossAxisAlignment.start,
          children: [
            Text(
              widget.arabicName,
              style: const TextStyle(
                color: Color(0xff0E5A56),
                fontFamily: 'Amiri',
                fontSize: 22,
                fontWeight: FontWeight.w700,
              ),
            ),

            Text(
              "Koshur Tafsir • ${widget.verses} Ayahs",
              style: const TextStyle(
                color: Colors.black54,
                fontSize: 11,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),

      body: FutureBuilder<List<VerseModel>>(
        future: _versesFuture,

        builder: (context, snapshot) {
          if (snapshot.connectionState !=
              ConnectionState.done) {
            return const Center(
              child: CircularProgressIndicator(
                color: Color(0xff0E5A56),
              ),
            );
          }

          if (snapshot.hasError) {
            return Center(
              child: Padding(
                padding:
                    const EdgeInsets.all(24),
                child: Text(
                  snapshot.error.toString(),
                  textAlign: TextAlign.center,
                ),
              ),
            );
          }

          final verses =
              snapshot.data ?? [];

          if (verses.isEmpty) {
            return const Center(
              child: Text(
                "No verses found.",
              ),
            );
          }

          return ListView.builder(
            physics:
                const BouncingScrollPhysics(),

            padding:
                const EdgeInsets.fromLTRB(
              16,
              8,
              16,
              32,
            ),

            itemCount: verses.length,

            itemBuilder: (context, index) {
              final verse = verses[index];
             return VisibilityDetector(
  key: Key(
    'tafsir_${widget.surahNumber}_${verse.ayah}',
  ),

  onVisibilityChanged: (info) async {
    if (info.visibleFraction >= 0.6) {
      await _progressService.saveProgress(
        mode: QuranMode.tafsir,
        surah: widget.surahNumber,
        ayah: verse.ayah,
      );
    }
  },

  child: _ayahCard(verse),
);
            },
          );
        },
      ),
    );
  }

  Widget _ayahCard(
    VerseModel verse,
  ) {
    final kashmiri =
        verse.translation(
      TranslationType.kashmiri,
    );

    final tafsir =
        verse.bayanulFurqanTafsir;

    return Container(
      margin:
          const EdgeInsets.only(bottom: 14),

      decoration: BoxDecoration(
        color: Colors.white,

        borderRadius:
            BorderRadius.circular(22),

        border: Border.all(
          color: const Color(0xff0E5A56)
              .withValues(alpha: .07),
        ),

        boxShadow: [
          BoxShadow(
            color: Colors.black
                .withValues(alpha: .035),
            blurRadius: 14,
            offset: const Offset(0, 5),
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
            /// AYAH NUMBER
            Row(
              children: [
                Container(
                  width: 30,
                  height: 30,

                  decoration:
                      const BoxDecoration(
                    color:
                        Color(0xffF6EFD9),
                    shape: BoxShape.circle,
                  ),

                  alignment:
                      Alignment.center,

                  child: Text(
                    verse.ayah.toString(),
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

            const SizedBox(height: 16),

            /// ARABIC
            Text(
              verse.arabic,
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

            const SizedBox(height: 15),

            /// TRANSLATION DIVIDER
            Row(
              children: [
                Container(
                  width: 28,
                  height: 2,
                  decoration:
                      BoxDecoration(
                    color:
                        Color(0xffE8C76A),
                    borderRadius:
                        BorderRadius.circular(
                      10,
                    ),
                  ),
                ),

                const SizedBox(width: 8),

                const Expanded(
                  child: Divider(
                    height: 1,
                    color:
                        Color(0x10000000),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 13),

            /// KASHMIRI TRANSLATION
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

            const SizedBox(height: 16),

            /// TAFSIR LABEL
            Row(
              children: [
                const Icon(
                  Icons.auto_awesome_rounded,
                  size: 15,
                  color:
                      Color(0xffB28A2E),
                ),

                const SizedBox(width: 6),

                const Text(
                  "Koshur Tafsir",
                  style: TextStyle(
                    color:
                        Color(0xffB28A2E),
                    fontSize: 12,
                    fontWeight:
                        FontWeight.w700,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 8),

            /// TAFSIR
            Text(
              tafsir,
              textAlign:
                  TextAlign.right,
              textDirection:
                  TextDirection.rtl,
              style:
                  const TextStyle(
                color:
                    Color(0xff596664),
                fontSize: 14,
                height: 1.7,
                fontWeight:
                    FontWeight.w400,
              ),
            ),
          ],
        ),
      ),
    );
  }
}