import 'package:flutter/material.dart';
import 'package:seeker/models/verse_model.dart';
import 'package:seeker/repositories/quran_repository.dart';
import 'package:seeker/services/translation_preferences_service.dart';

class TranslationView extends StatefulWidget {
  final int surahNumber;
  final int verses;
  final TranslationType selectedTranslation;

  const TranslationView({
    super.key,
    required this.surahNumber,
    required this.verses,
    required this.selectedTranslation,
  });

  @override
  State<TranslationView> createState() => _TranslationViewState();
}

class _TranslationViewState extends State<TranslationView> {
  final QuranRepository _repository = QuranRepository();

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<VerseModel>>(
      future: _repository.loadSurah(widget.surahNumber, widget.verses),
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Center(child: Text(snapshot.error.toString()));
        }

        final versesList = snapshot.data!;

        return ListView.builder(
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
          itemCount: versesList.length,
          itemBuilder: (context, index) {
            final verse = versesList[index];

            return Card(
              margin: const EdgeInsets.only(bottom: 18),
              elevation: 1,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: Padding(
                padding: const EdgeInsets.all(18),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Center(
                      child: Text(
                        "﴿ ${verse.ayah} ﴾",
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF0B4B4B),
                        ),
                      ),
                    ),

                    const SizedBox(height: 16),

                    Text(
                      verse.arabic,
                      textAlign: TextAlign.center,
                      textDirection: TextDirection.rtl,
                      style: const TextStyle(fontSize: 24, height: 1.7),
                    ),

                    const SizedBox(height: 18),

                    Text(
                      verse.translation(widget.selectedTranslation),
                      textAlign: TextAlign.right,
                      style: const TextStyle(fontSize: 17, height: 1.7),
                    ),

                    // Uncomment later when you add a translation selector
                    /*
                    const Divider(height: 32),

                    Text(
                      verse.bayanulFurqanTranslation,
                      textAlign: TextAlign.right,
                      style: const TextStyle(
                        fontSize: 17,
                        height: 1.7,
                      ),
                    ),
                    */
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
}
