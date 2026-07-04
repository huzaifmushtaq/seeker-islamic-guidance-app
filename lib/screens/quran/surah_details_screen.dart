import 'package:flutter/material.dart';
import 'package:qcf_quran/qcf_quran.dart';
import 'package:seeker/widgets/quran/seeker_qcf_page.dart';
import 'package:seeker/services/translation_service.dart';
import 'package:seeker/widgets/quran/translation_view.dart';
import 'package:seeker/widgets/quran/tafsir_view.dart';
class SurahDetailsScreen extends StatefulWidget {
  final int surahNumber;
  final String englishName;
  final String arabicName;
  final String revelationType;
  final int verses;

  const SurahDetailsScreen({
    super.key,
    required this.surahNumber,
    required this.englishName,
    required this.arabicName,
    required this.revelationType,
    required this.verses,
  });

  @override
  State<SurahDetailsScreen> createState() =>
      _SurahDetailsScreenState();
}

class _SurahDetailsScreenState
    extends State<SurahDetailsScreen> {

  int selectedTab = 0;

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

}



  @override
  Widget build(BuildContext context) {

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7F7),
appBar: PreferredSize(
  preferredSize: const Size.fromHeight(60),
  child: AppBar(
    backgroundColor: const Color.fromARGB(255, 201, 116, 235),
    elevation: 0,
    centerTitle: true,
    toolbarHeight: 72,

    shadowColor: Colors.black.withOpacity(.08),

    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(
        bottom: Radius.circular(20),
      ),
    ),

    leading: Padding(
      padding: const EdgeInsets.only(left: 8),
      child: IconButton(
        splashRadius: 22,
        onPressed: () => Navigator.pop(context),
        icon: const Icon(
          Icons.arrow_back_ios_new_rounded,
          color: Colors.white,
          size: 22,
        ),
      ),
    ),

    title: Text(
      widget.arabicName,
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      style: const TextStyle(
        color: Colors.white,
        fontSize: 28,
        fontWeight: FontWeight.w700,
        letterSpacing: .4,
      ),
    ),

    actions: const [
      SizedBox(width: 56),
    ],
  ),
),

      body: Column(

        children: [

          const SizedBox(height: 15),

          Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 16),

            child: Container(

              height: 54,

              decoration: BoxDecoration(
  color: const Color.fromARGB(255, 244, 231, 117),
  borderRadius: BorderRadius.circular(18),
  border: Border.all(
    color: Colors.grey.shade300,
  ),
),

              child: Row(
                children: [

                  _buildTab(
                    "Quran",
                    0,
                  ),

                  _buildTab(
                    "Translation",
                    1,
                  ),

                  _buildTab(
                    "Tafsir",
                    2,
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 15),

         Expanded(
  child: selectedTab == 0
      ? ListView.builder(
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
                    padding: const EdgeInsets.symmetric(
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

                SeekerQcfPage(
                  pageNumber: page,
                ),
              ],
            );
          },
        )
      : selectedTab == 1
    ? TranslationView(
  surahNumber: widget.surahNumber,
  verses: widget.verses,
)
   : TafsirView(
    surahNumber: widget.surahNumber,
    verses: widget.verses,
  ),
),
        ],
      ),
    );
  }
Widget _buildTab(
  String title,
  int index,
) {
  final bool selected = selectedTab == index;

  return Expanded(
    child: GestureDetector(
      onTap: () {
        setState(() {
          selectedTab = index;
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 220),
        curve: Curves.easeInOut,
        margin: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          color: selected
              ? Colors.white
              : Colors.transparent,
          borderRadius: BorderRadius.circular(14),
          border: selected
              ? Border.all(
                  color: const Color(0xFF0B4B4B),
                  width: 1.2,
                )
              : null,
          boxShadow: selected
              ? [
                  BoxShadow(
                    color: Colors.black.withOpacity(.06),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ]
              : [],
        ),
        child: Center(
          child: AnimatedDefaultTextStyle(
            duration: const Duration(milliseconds: 220),
            style: TextStyle(
              fontSize: 14,
              fontWeight:
                  selected ? FontWeight.w700 : FontWeight.w500,
              color: selected
                  ? const Color(0xFF0B4B4B)
                  : Colors.grey.shade600,
            ),
            child: Text(title),
          ),
        ),
      ),
    ),
  );
}
}