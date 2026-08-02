import 'package:flutter/material.dart';

import '../../models/hadith_model.dart';
import '../../repositories/hadith_reader_repository.dart';

class HadithReaderScreen extends StatefulWidget {
  final String collection;
  final int chapterId;
  final String title;

  const HadithReaderScreen({
    super.key,
    required this.collection,
    required this.chapterId,
    required this.title,
  });

  @override
  State<HadithReaderScreen> createState() =>
      _HadithReaderScreenState();
}

class _HadithReaderScreenState
    extends State<HadithReaderScreen> {
  final HadithReaderRepository _repository =
      HadithReaderRepository();

  final PageController _pageController =
      PageController();

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
  }
Widget _action(
  IconData icon,
  String label,
) {
  return InkWell(
    borderRadius:
        BorderRadius.circular(16),
    onTap: () {},
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

            IconButton(
              onPressed: () {},
              icon: const Icon(
                Icons.bookmark_border,
                color: Color(0xff12372A),
              ),
            ),

            IconButton(
              onPressed: () {},
              icon: const Icon(
                Icons.more_vert,
                color: Color(0xff12372A),
              ),
            ),
          ],
        ),
      ),

      const SizedBox(height: 20),

      Text(
        widget.title,
        style: const TextStyle(
          fontSize: 28,
          fontWeight: FontWeight.bold,
          color: Color(0xff12372A),
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

          onPageChanged: (i) {
            setState(() {
              currentPage = i;
            });
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
      Icons.bookmark_border,
      "Save",
    ),

    _action(
      Icons.copy_rounded,
      "Copy",
    ),

    _action(
      Icons.share_outlined,
      "Share",
    ),

    _action(
      Icons.text_fields,
      "Aa",
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