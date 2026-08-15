import 'package:flutter/material.dart';

class SurahTile extends StatelessWidget {
  final int number;
  final String englishName;
  final String meaning;
  final String arabicName;
  final int verses;
  final String revelationType;
  final VoidCallback? onTap;

  const SurahTile({
    super.key,
    required this.number,
    required this.englishName,
    required this.meaning,
    required this.arabicName,
    required this.revelationType,
    required this.verses,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(
            horizontal: 18,
            vertical: 13,
          ),
          decoration: const BoxDecoration(
            border: Border(
              bottom: BorderSide(
                color: Color(0xFFE7E3D9),
                width: 0.8,
              ),
            ),
          ),
          child: Row(
            children: [
              /// ─────────────────────────────
              /// SURAH NUMBER ORNAMENT
              /// ─────────────────────────────
              SizedBox(
                width: 48,
                height: 48,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    Icon(
                      Icons.star_rounded,
                      size: 46,
                      color: const Color(0xff0E5A56),
                    ),

                    Icon(
                      Icons.star_border_rounded,
                      size: 43,
                      color: const Color(0xffF8F4E8),
                    ),

                    Text(
                      number.toString(),
                      style: const TextStyle(
                        color: Color(0xff0E5A56),
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(width: 14),

              /// ─────────────────────────────
              /// SURAH INFORMATION
              /// ─────────────────────────────
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      englishName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Color(0xff0E5A56),
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                        height: 1.15,
                      ),
                    ),

                    const SizedBox(height: 4),

                    Text(
                      "$revelationType • $verses Verses",
                      style: const TextStyle(
                        color: Color(0xff777777),
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        height: 1.1,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(width: 14),

              /// ─────────────────────────────
              /// ARABIC NAME
              /// ─────────────────────────────
              SizedBox(
                width: 105,
                child: Text(
                  arabicName,
                  textAlign: TextAlign.right,
                  textDirection: TextDirection.rtl,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Color(0xffB28A2E),
                    fontSize: 25,
                    fontFamily: 'Amiri',
                    fontWeight: FontWeight.w500,
                    height: 1.2,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}