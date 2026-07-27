import 'package:flutter/material.dart';

import '../../models/last_read_model.dart';
import '../../models/surah_model.dart';

class LastReadCard extends StatelessWidget {
  final VoidCallback? onTap;
  final LastReadModel? lastRead;
  final List<SurahModel> surahs;

  const LastReadCard({
  super.key,
  required this.lastRead,
  required this.surahs,
  this.onTap,
});

  @override
  Widget build(BuildContext context) {
    String surahName = "No Reading Yet";
    String ayahText = "Start reading the Quran";

    if (lastRead != null) {
      try {
        final surah = surahs.firstWhere(
          (s) => s.id == lastRead!.surah,
        );

        surahName = surah.nameSimple;
        ayahText = "Ayah ${lastRead!.ayah} • Page ${lastRead!.page}";
      } catch (_) {}
    }

   return InkWell(
  borderRadius: BorderRadius.circular(30),
  onTap: onTap,
  child: Container(
      height: 235,
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: const Color.fromARGB(255, 77, 101, 45),
        borderRadius: BorderRadius.circular(30),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(.18),
            blurRadius: 30,
            offset: const Offset(0, 14),
          ),
        ],
      ),
      child: Stack(
        children: [
          Positioned(
            right: -25,
            top: -25,
            child: Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(.03),
                shape: BoxShape.circle,
              ),
            ),
          ),

          Positioned(
            right: 25,
            bottom: -35,
            child: Container(
              width: 90,
              height: 90,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(.02),
                shape: BoxShape.circle,
              ),
            ),
          ),

          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 46,
                    height: 46,
                    decoration: BoxDecoration(
                      color: const Color(0xFFD4AF37).withOpacity(.15),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: const Icon(
                      Icons.menu_book_rounded,
                      color: Color(0xFFD4AF37),
                      size: 24,
                    ),
                  ),

                  const SizedBox(width: 14),

                  const Text(
                    "Continue Reading",
                    style: TextStyle(
                      color: Color(0xFFB9C6E0),
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),

              const Spacer(),

              Text(
                surahName,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 30,
                  fontWeight: FontWeight.bold,
                  letterSpacing: .3,
                ),
              ),

              const SizedBox(height: 6),

              Text(
                ayahText,
                style: const TextStyle(
                  color: Color(0xFF8FA8D4),
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                ),
              ),

              const Spacer(),

              Align(
                alignment: Alignment.bottomRight,
                child: Container(
                  width: 52,
                  height: 52,
                  decoration: const BoxDecoration(
                    color: Color(0xFFD4AF37),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.arrow_forward_rounded,
                    color: Color(0xFF0B1730),
                    size: 24,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
  ),
    );
  }
}