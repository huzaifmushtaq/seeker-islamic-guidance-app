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
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 7),
      child: Material(
        color: Colors.white,
        elevation: 1.0,
        shadowColor: Colors.black12,
        borderRadius: BorderRadius.circular(24),
        child: InkWell(
          borderRadius: BorderRadius.circular(24),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
            child: Row(
              children: [
                /// Surah Number
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: const Color(0xffF6EFD9),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    number.toString(),
                    style: const TextStyle(
                      color: Color(0xff0E5A56),
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ),

                const SizedBox(width: 16),

                /// English Details
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        meaning,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: Color(0xffB28A2E),
                          fontSize: 18,
                          fontWeight: FontWeight.w500,
                        ),
                      ),

                      const SizedBox(height: 5),

                      Text(
                        "$revelationType • $verses Verses",
                        style: const TextStyle(
                          color: Color.fromARGB(137, 15, 12, 12),
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(width: 16),

                /// Arabic + Arrow
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      arabicName,
                      style: const TextStyle(
                        color: Color(0xff0E5A56),
                        fontSize: 26,
                        fontFamily: 'Amiri',
                      ),
                    ),

                    const SizedBox(height: 8),

                    Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        color: const Color(0xffF6EFD9),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(
                        Icons.arrow_forward_ios_rounded,
                        size: 14,
                        color: Color(0xff0E5A56),
                      ),
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
