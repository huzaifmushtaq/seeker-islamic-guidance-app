import 'package:flutter/material.dart';

class SurahTile extends StatelessWidget {
  final int number;
  final String englishName;
  final String meaning;
  final String arabicName;
  final int verses;
  final String revelationType;
  const SurahTile({
    super.key,
    required this.number,
    required this.englishName,
    required this.meaning,
    required this.arabicName,
    required this.revelationType,
    required this.verses
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(14),
      onTap: () {},

      child: Padding(
        padding: const EdgeInsets.symmetric(
          vertical: 14,
          horizontal: 4,
        ),

        child: Row(
          children: [

            /// Number
            Container(
              width: 42,
              height: 42,

              decoration: BoxDecoration(
                border: Border.all(
                  color: const Color(0xFF0B4B4B),
                  width: 1.5,
                ),
                shape: BoxShape.circle,
              ),

              child: Center(
                child: Text(
                  number.toString(),
                  style: const TextStyle(
                    color: Color(0xFF0B4B4B),
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),

            const SizedBox(width: 16),

            /// English
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,

                children: [

                  Text(
                    englishName,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF0B4B4B),
                    ),
                  ),

                  const SizedBox(height: 2),

                 Text(
  "$revelationType • $verses Verses",
  style: TextStyle(
    color: Colors.grey.shade600,
    fontSize: 13,
    fontWeight: FontWeight.w500,
  ),
),
                ],
              ),
            ),

            /// Arabic
            Text(
              arabicName,
              style: const TextStyle(
                fontSize: 28,
                color: Color(0xFF0B4B4B),
                fontFamily: 'Amiri',
              ),
            ),
          ],
        ),
      ),
    );
  }
}