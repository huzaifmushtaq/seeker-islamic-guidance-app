import 'package:flutter/material.dart';

import '../../models/hadith_model.dart';
import '../../repositories/hadith_reader_repository.dart';
import '../../services/hadith_progress_service.dart';
import '../../services/hadith_bookmark_service.dart';
import '../../models/hadith_bookmark_model.dart';
import 'package:flutter/services.dart';
class HadithReaderScreen extends StatefulWidget {
  final String collection;
final int chapterId;
final String title;
final int initialIndex;

  const HadithReaderScreen({
  super.key,
  required this.collection,
  required this.chapterId,
  required this.title,
  this.initialIndex = 0,
});

  @override
  State<HadithReaderScreen> createState() =>
      _HadithReaderScreenState();
}

class _HadithReaderScreenState
    extends State<HadithReaderScreen> {
  final HadithReaderRepository _repository =
      HadithReaderRepository();
final HadithProgressService _progress =
    HadithProgressService();
  final PageController _pageController =
      PageController();
final HadithBookmarkService _bookmarkService =
    HadithBookmarkService();

bool isBookmarked = false;
  List<HadithModel> hadiths = [];

  bool isLoading = true;
  int currentPage = 0;
    
  @override
  void initState() {
    super.initState();
    _loadHadiths();
  }
    
  Future<void> _loadHadiths() async {
    final loaded = await _repository.loadHadiths(
      collection: widget.collection,
      chapterId: widget.chapterId,
    );

    if (!mounted) return;

    setState(() {
  hadiths = loaded;
  isLoading = false;
});

WidgetsBinding.instance.addPostFrameCallback((_) {
  if (widget.initialIndex < hadiths.length) {
    _pageController.jumpToPage(widget.initialIndex);

    setState(() {
      currentPage = widget.initialIndex;
    });
  }
});

await _saveProgress();
await _loadBookmark();
  }
  String formatTitle(String title) {
  final words = title.trim().split(RegExp(r'\s+'));

  if (words.length <= 5) return title;

  return "${words.take(5).join(' ')}\n${words.skip(5).join(' ')}";
}
Widget _action(
  IconData icon,
  String label,
  VoidCallback? onTap,
)  {
  return InkWell(
    borderRadius:
        BorderRadius.circular(16),
    onTap: onTap,
    child: Padding(
      padding: const EdgeInsets.all(8),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [

          Icon(
            icon,
            color: const Color(0xff12372A),
          ),

          const SizedBox(height:6),

          Text(
            label,
            style: const TextStyle(
              fontSize:12,
              color: Color(0xff12372A),
            ),
          ),

        ],
      ),
    ),
  );
}
Future<void> _saveProgress() async {
  if (hadiths.isEmpty) return;

  await _progress.saveProgress(
    collection: widget.collection,
    chapterId: widget.chapterId,
    index: currentPage,
    title: widget.title,
  );
}

Future<void> _loadBookmark() async {
  if (hadiths.isEmpty) return;

  isBookmarked =
      await _bookmarkService.isBookmarked(
    hadiths[currentPage].id,
  );

  if (mounted) setState(() {});
}
  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    return Scaffold(backgroundColor: const Color(0xffF7F3EA),

body: SafeArea(
  child: Column(
    children: [

      const SizedBox(height: 18),

      Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: 18,
        ),
        child: Row(
          children: [

            InkWell(
              onTap: () => Navigator.pop(context),
              borderRadius: BorderRadius.circular(50),
              child: Container(
                height: 48,
                width: 48,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius:
                      BorderRadius.circular(50),
                  boxShadow: const [
                    BoxShadow(
                      blurRadius: 12,
                      color: Colors.black12,
                      offset: Offset(0,4),
                    )
                  ],
                ),
                child: const Icon(
                  Icons.arrow_back_ios_new,
                  color: Color(0xff12372A),
                  size: 18,
                ),
              ),
            ),

            const Spacer(),

          ],
        ),
      ),

      const SizedBox(height: 20),

    Text(
  formatTitle(widget.title),
  textAlign: TextAlign.center,
  style: const TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.bold,
    color: Color(0xff12372A),
    height: 1.1,
  ),
),
      const SizedBox(height: 6),

      Text(
        widget.collection
            .replaceAll("_", " ")
            .toUpperCase(),
        style: const TextStyle(
          letterSpacing: 2,
          color: Colors.black54,
          fontSize: 12,
        ),
      ),

      const SizedBox(height: 18),

      Container(
        margin: const EdgeInsets.symmetric(
          horizontal: 40,
        ),
        padding: const EdgeInsets.symmetric(
          vertical: 10,
        ),
        decoration: BoxDecoration(
          color: const Color(0xffE8DCC4),
          borderRadius:
              BorderRadius.circular(50),
        ),
        child: Center(
          child: Text(
            "${currentPage + 1} / ${hadiths.length}",
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              color: Color(0xff12372A),
            ),
          ),
        ),
      ),

      const SizedBox(height: 20),

      Expanded(
        child: PageView.builder(
          physics:
              const NeverScrollableScrollPhysics(),
          controller: _pageController,
          itemCount: hadiths.length,

          onPageChanged: (i) async {
  setState(() {
    currentPage = i;
  });

  await _saveProgress();
  await _loadBookmark();
},

          itemBuilder: (context,index){

            final hadith = hadiths[index];

            return SingleChildScrollView(
              padding:
                  const EdgeInsets.fromLTRB(
                22,
                0,
                22,
                30,
              ),

              child: Container(
                padding:
                    const EdgeInsets.all(28),

                decoration: BoxDecoration(
                  color:
                      const Color(0xffFFFDF8),

                  borderRadius:
                      BorderRadius.circular(28),

                  border: Border.all(
                    color:
                        const Color(0xffDCCDAA),
                  ),

                  boxShadow: const [

                    BoxShadow(
                      blurRadius: 18,
                      offset: Offset(0,8),
                      color:
                          Color.fromARGB(
                              20,
                              0,
                              0,
                              0),
                    )

                  ],
                ),

                child: Column(
                  children: [

                    const Text(
                       "﷽",
                      style: TextStyle(
                        fontSize: 27,
                        color:
                            Color(0xff12372A),
                      ),
                    ),

                    const SizedBox(height: 20),

                    Text(
  hadith.arabic,
  textAlign: TextAlign.right,
  textDirection: TextDirection.rtl,
  style: const TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.w500,
    color: Color(0xff12372A),
    height: 1.5,
  ),
),

const SizedBox(height: 20),

Container(
  width: 80,
  height: 3,
  decoration: BoxDecoration(
    color: const Color(0xffC7A96B),
    borderRadius: BorderRadius.circular(50),
  ),
),

const SizedBox(height: 25),

if (hadith.narrator.isNotEmpty)
  Column(
    children: [

      const Text(
        "Narrated by",
        style: TextStyle(
          fontSize: 13,
          color: Colors.black54,
          letterSpacing: 2,
          fontWeight: FontWeight.w500,
        ),
      ),

      const SizedBox(height: 20),

      Text(
        hadith.narrator,
        textAlign: TextAlign.center,
        style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: Color(0xff0E5A56),
          height: 1.5,
        ),
      ),

      const SizedBox(height: 20),

      Divider(
        color: Colors.grey.shade300,
        thickness: 1,
      ),

      const SizedBox(height: 20),
    ],
  ),
Text(
  hadith.english,
  textAlign: TextAlign.left,
  style: const TextStyle(
    fontSize: 18,
    height: 1.9,
    color: Color(0xff2D2D2D),
  ),
),

const SizedBox(height: 20),

Container(
  width: double.infinity,
  padding: const EdgeInsets.symmetric(
    vertical: 16,
    horizontal: 18,
  ),
  decoration: BoxDecoration(
    color: const Color(0xffF4EEE0),
    borderRadius: BorderRadius.circular(18),
  ),
  child: Column(
    children: [

      Text(
        widget.collection
            .replaceAll("_", " ")
            .toUpperCase(),
        style: const TextStyle(
          letterSpacing: 0,
          fontWeight: FontWeight.bold,
          color: Color(0xff12372A),
        ),
      ),

      const SizedBox(height: 8),

      Text(
        "Hadith ${hadith.idInBook}",
        style: const TextStyle(
          fontSize: 16,
          color: Colors.black87,
        ),
      ),

      const SizedBox(height: 4),

      Text(
        "Chapter ${widget.chapterId}",
        style: const TextStyle(
          color: Colors.black54,
        ),
      ),
    ],
  ),
),

const SizedBox(height: 36),

Row(
  children: [

    Expanded(
      child: FilledButton.tonal(
        style: FilledButton.styleFrom(
          padding: const EdgeInsets.symmetric(
            vertical: 16,
          ),
          shape: RoundedRectangleBorder(
            borderRadius:
                BorderRadius.circular(18),
          ),
        ),
        onPressed: currentPage == 0
            ? null
            : () {
                _pageController.previousPage(
                  duration: const Duration(
                    milliseconds: 350,
                  ),
                  curve: Curves.easeInOut,
                );
              },
        child: const Row(
          mainAxisAlignment:
              MainAxisAlignment.center,
          children: [

            Icon(Icons.arrow_back_ios,size:16),

            SizedBox(width:8),

            Text(
              "Previous",
              style: TextStyle(
                fontSize:16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    ),

    const SizedBox(width:16),

    Expanded(
      child: FilledButton(
        style: FilledButton.styleFrom(
          backgroundColor:
              const Color(0xff12372A),
          padding: const EdgeInsets.symmetric(
            vertical: 16,
          ),
          shape: RoundedRectangleBorder(
            borderRadius:
                BorderRadius.circular(18),
          ),
        ),
        onPressed: currentPage ==
                hadiths.length - 1
            ? null
            : () {
                _pageController.nextPage(
                  duration: const Duration(
                    milliseconds: 350,
                  ),
                  curve: Curves.easeInOut,
                );
              },
        child: const Row(
          mainAxisAlignment:
              MainAxisAlignment.center,
          children: [

            Text(
              "Next",
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),

            SizedBox(width:8),

            Icon(
              Icons.arrow_forward_ios,
              size:16,
              color: Colors.white,
            ),
          ],
        ),
      ),
    ),
  ],
),

const SizedBox(height:24),

Row(
  mainAxisAlignment:
      MainAxisAlignment.spaceEvenly,
  children: [

_action(
  isBookmarked
      ? Icons.bookmark
      : Icons.bookmark_border,
  "Bookmark",
  () async {
    final hadith = hadiths[currentPage];

    await _bookmarkService.toggleBookmark(
      HadithBookmarkModel(
        collection: widget.collection,
        chapterId: widget.chapterId,
        chapterTitle: widget.title,
        hadithIndex: currentPage,
        hadithId: hadith.id,
        arabic: hadith.arabic,
        english: hadith.english,
        savedAt: DateTime.now(),
      ),
    );

    await _loadBookmark();
  },
),
_action(
  Icons.copy_rounded,
  "Copy",
  () async {
    final hadith = hadiths[currentPage];

    final text = '''
${hadith.arabic}

${hadith.narrator}

${hadith.english}

Source:
${widget.collection.toUpperCase()}
${widget.title}
Hadith ${hadith.idInBook}
''';

    await Clipboard.setData(
      ClipboardData(text: text),
    );

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text("Hadith copied to clipboard "),
        duration: Duration(seconds: 2),
      ),
    );
  },
),

_action(
  Icons.share_outlined,
  "Share",
  () {
    
  },
),

_action(
  Icons.text_fields,
  "Aa",
  () {
    
  },
),
  ],
  ),
const SizedBox(height:12),

],
),
),
);
},
),
),
],
),
),
);
  }
    }