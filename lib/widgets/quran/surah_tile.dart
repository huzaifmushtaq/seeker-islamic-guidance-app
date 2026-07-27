import 'package:flutter/material.dart';
// ignore: unused_import
import '../../screens/quran/surah_details_screen.dart';

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
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: 20,
        vertical: 6,
      ),
      child: Material(
        color: const Color.fromARGB(255, 235, 233, 152),
        borderRadius: BorderRadius.circular(22),
        child: InkWell(
          borderRadius: BorderRadius.circular(22),
         onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 20,
              vertical: 12,
            ),
            child: Row(
              children: [

                /// Number
                SizedBox(
                  width: 34,
                  child: Text(
                    number.toString().padLeft(2, '0'),
                    style: const TextStyle(
                      color: Color(0xFFD4AF37),
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),

                const SizedBox(width: 18),

                /// English
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [

                      Text(
                        englishName,
                        style: const TextStyle(
                          color: Color.fromARGB(255, 67, 89, 146),
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                        ),
                      ),

                      const SizedBox(height: 5),

                      Text(
                        "$revelationType • $verses Verses",
                        style: const TextStyle(
                          color: Color.fromARGB(255, 78, 104, 149),
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(width: 16),

                /// Arabic
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [

                    Text(
                      arabicName,
                      style: const TextStyle(
                        color: Color(0xFFD4AF37),
                        fontSize: 28,
                        fontFamily: 'Amiri',
                      ),
                    ),

                    const SizedBox(height: 8),

                    const Icon(
                      Icons.arrow_forward_ios_rounded,
                      color: Color(0xFFD4AF37),
                      size: 16,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}