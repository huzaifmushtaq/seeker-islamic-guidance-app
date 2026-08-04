import 'package:flutter/material.dart';

class HadithShareCard extends StatelessWidget {
  final String arabic;
  final String narrator;
  final String english;
  final String collection;
  final String chapter;
  final int hadithNumber;

  const HadithShareCard({
    super.key,
    required this.arabic,
    required this.narrator,
    required this.english,
    required this.collection,
    required this.chapter,
    required this.hadithNumber,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 1080,
      height: 2300,

      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Color(0xffF7F2E4),
            Color(0xffEFE4C7),
          ],
        ),
      ),

      child: Stack(
        children: [

          /// TOP RIGHT DECORATION
          Positioned(
            top: -120,
            right: -120,
            child: Container(
              width: 420,
              height: 420,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Color(0xff0E5A56).withOpacity(.05),
              ),
            ),
          ),

          /// BOTTOM LEFT DECORATION
          Positioned(
            bottom: -160,
            left: -160,
            child: Container(
              width: 460,
              height: 460,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Color(0xffD4AF37).withOpacity(.06),
              ),
            ),
          ),

          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 70,
              vertical: 80,
            ),

            child: Column(
              children: [

                /// BISMILLAH
                const Text(
                  "﷽",
                  style: TextStyle(
                    fontSize: 84,
                    color: Color(0xff12372A),
                    fontWeight: FontWeight.w500,
                  ),
                ),

                const SizedBox(height: 55),

                /// GOLD DIVIDER
                Container(
                  width: 180,
                  height: 4,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(100),
                    gradient: const LinearGradient(
                      colors: [
                        Color(0xffB28B34),
                        Color(0xffE4C96A),
                        Color(0xffB28B34),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 60),

                /// ARABIC CARD
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 45,
                    vertical: 55,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(.45),
                    borderRadius: BorderRadius.circular(36),
                    border: Border.all(
                      color: const Color(0xffD9C79E),
                      width: 2,
                    ),
                  ),

                  child: Column(
                    children: [

                      Text(
                        arabic,
                        textAlign: TextAlign.center,
                        textDirection: TextDirection.rtl,
                        style: const TextStyle(
                          fontSize: 48,
                          height: 2.05,
                          color: Color(0xff12372A),
                          fontWeight: FontWeight.w500,
                        ),
                      ),

                      if (narrator.isNotEmpty) ...[

                        const SizedBox(height: 45),

                        Container(
                          width: 120,
                          height: 2,
                          color: const Color(0xffD4AF37),
                        ),

                        const SizedBox(height: 32),

                        const Text(
                          "Narrated By",
                          style: TextStyle(
                            fontSize: 22,
                            letterSpacing: 2,
                            color: Colors.black54,
                          ),
                        ),

                        const SizedBox(height: 16),

                        Text(
                          narrator,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 30,
                            fontWeight: FontWeight.bold,
                            color: Color(0xff0E5A56),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),

                const SizedBox(height: 55),

                Container(
                  width: double.infinity,
                  height: 2,
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Colors.transparent,
                        Color(0xffB28B34),
                        Colors.transparent,
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 45),

                                /// ENGLISH TRANSLATION
                Expanded(
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 28,
                    ),
                    child: SingleChildScrollView(
                      physics:
                          const NeverScrollableScrollPhysics(),
                      child: Text(
                        english,
                        textAlign: TextAlign.justify,
                        style: const TextStyle(
                          fontSize: 35,
                          height: 1.9,
                          color: Color(0xff2D2D2D),
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 50),

               /// COLLECTION INFO
Container(
  width: double.infinity,
  padding: const EdgeInsets.symmetric(
    horizontal: 30,
    vertical: 20,
  ),
  decoration: BoxDecoration(
    color: Colors.white.withOpacity(.55),
    borderRadius: BorderRadius.circular(22),
    border: Border.all(
      color: const Color(0xffD8C59A),
      width: 1.6,
    ),
  ),
  child: Row(
    crossAxisAlignment: CrossAxisAlignment.center,
    children: [

      Container(
        width: 54,
        height: 54,
        decoration: BoxDecoration(
          color: const Color(0xff0E5A56).withOpacity(.08),
          borderRadius: BorderRadius.circular(16),
        ),
        child: const Icon(
          Icons.menu_book_rounded,
          color: Color(0xff0E5A56),
          size: 30,
        ),
      ),

      const SizedBox(width: 18),

      Expanded(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [

            Text(
              collection
    .replaceAll("_", " ")
    .toUpperCase(),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontSize: 38,
                fontWeight: FontWeight.bold,
                color: Color(0xff12372A),
              ),
            ),

            const SizedBox(height: 6),

            Text(
              chapter,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontSize: 25,
                color: Colors.black87,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),

      const SizedBox(width: 20),

      Container(
        padding: const EdgeInsets.symmetric(
          horizontal: 22,
          vertical: 12,
        ),
        decoration: BoxDecoration(
          color: const Color(0xffD4AF37),
          borderRadius: BorderRadius.circular(30),
        ),
        child: Text(
          "Hadith $hadithNumber",
          style: const TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),

    ],
  ),
),

                const SizedBox(height: 55),

                                /// PREMIUM FOOTER
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(
                    vertical: 35,
                    horizontal: 30,
                  ),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [
                        Color(0xff0E5A56),
                        Color(0xff12372A),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(30),
                  ),
                  child: Column(
                    children: [

                      const Icon(
                        Icons.auto_awesome_rounded,
                        color: Color(0xffD4AF37),
                        size: 46,
                      ),

                      const SizedBox(height: 20),

                      const Text(
                        "SEEKER",
                        style: TextStyle(
                          fontSize: 40,
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 8,
                        ),
                      ),

                      const SizedBox(height: 12),

                      Container(
                        width: 220,
                        height: 2,
                        decoration: const BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              Colors.transparent,
                              Color(0xffD4AF37),
                              Colors.transparent,
                            ],
                          ),
                        ),
                      ),

                      const SizedBox(height: 18),

                      const Text(
                        "Authentic Islamic Knowledge",
                        style: TextStyle(
                          color: Color(0xffE8DDBE),
                          fontSize: 20,
                          letterSpacing: 1.2,
                        ),
                      ),

                      const SizedBox(height: 10),

                      const Row(
                        mainAxisAlignment:
                            MainAxisAlignment.center,
                        children: [

                          Icon(
                            Icons.menu_book_rounded,
                            color: Color(0xffD4AF37),
                            size: 24,
                          ),

                          SizedBox(width: 12),

                          Text(
                            "Read • Reflect • Practice",
                            style: TextStyle(
                              color: Colors.white70,
                              fontSize: 20,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

              ],
            ),
          ),
        ],
      ),
    );
  }
}