import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

import '../../services/hadith_share_service.dart';
import '../../widgets/hadith/hadith_share_card.dart';

class SharePreviewScreen extends StatefulWidget {
  final String arabic;
  final String narrator;
  final String english;
  final String collection;
  final String chapter;
  final int hadithNumber;

  const SharePreviewScreen({
    super.key,
    required this.arabic,
    required this.narrator,
    required this.english,
    required this.collection,
    required this.chapter,
    required this.hadithNumber,
  });

  @override
  State<SharePreviewScreen> createState() => _SharePreviewScreenState();
}

class _SharePreviewScreenState extends State<SharePreviewScreen> {
  final GlobalKey _shareKey = GlobalKey();

  final HadithShareService _shareService = HadithShareService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffF7F3EA),

      appBar: AppBar(
        backgroundColor: const Color(0xffF7F3EA),
        elevation: 0,
        centerTitle: true,
        title: const Text(
          "Share Hadith",
          style: TextStyle(
            color: Color(0xff12372A),
            fontWeight: FontWeight.bold,
          ),
        ),
      ),

      body: Center(
        child: SingleChildScrollView(
          child: RepaintBoundary(
            key: _shareKey,
            child: AspectRatio(
              aspectRatio: 9 / 16,
              child: FittedBox(
                child: HadithShareCard(
                  arabic: widget.arabic,
                  narrator: widget.narrator,
                  english: widget.english,
                  collection: widget.collection,
                  chapter: widget.chapter,
                  hadithNumber: widget.hadithNumber,
                ),
              ),
            ),
          ),
        ),
      ),

      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: const Color(0xff12372A),
        icon: const Icon(Icons.share),
        label: const Text("Share"),
        onPressed: () async {
          final messenger = ScaffoldMessenger.of(context);

          try {
            final renderObject = _shareKey.currentContext?.findRenderObject();

            if (renderObject is! RenderRepaintBoundary) {
              throw Exception("Share preview is not ready yet.");
            }

            await _shareService.share(renderObject);
          } catch (e) {
            if (!mounted) return;

            messenger.showSnackBar(SnackBar(content: Text(e.toString())));
          }
        },
      ),
    );
  }
}
