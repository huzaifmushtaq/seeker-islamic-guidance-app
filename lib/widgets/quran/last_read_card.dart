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
        final surah = surahs.firstWhere((s) => s.id == lastRead!.surah);

        surahName = surah.nameSimple;
        ayahText = "Ayah ${lastRead!.ayah} • Page ${lastRead!.page}";
      } catch (_) {}
    }

    return InkWell(
      borderRadius: BorderRadius.circular(30),
      onTap: onTap,
      child: Container(
        height: 220,
        width: double.infinity,
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xff0E5A56), Color(0xff16756F)],
          ),
          borderRadius: BorderRadius.circular(30),
          boxShadow: [
            BoxShadow(
              color: const Color(0xff0E5A56).withValues(alpha: .25),
              blurRadius: 26,
              spreadRadius: 1,
              offset: Offset(0, 12),
            ),
          ],
        ),
        child: Stack(
          children: [
            Positioned(
              right: -30,
              top: -20,
              child: Icon(
                Icons.auto_awesome_rounded,
                size: 140,
                color: Colors.white.withValues(alpha: .05),
              ),
            ),

            Positioned(
              right: -30,
              top: -20,
              child: Icon(
                Icons.auto_awesome_rounded,
                size: 140,
                color: Colors.white.withValues(alpha: .05),
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 54,
                      height: 52,
                      decoration: BoxDecoration(
                        color: const Color(0xFFD4AF37).withValues(alpha: .15),
                        borderRadius: BorderRadius.circular(18),
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
                        color: Color.fromARGB(255, 217, 223, 235),
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 12),

                Container(
                  width: 55,
                  height: 2,
                  decoration: BoxDecoration(
                    color: Color(0xffE8C76A),
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
                const SizedBox(height: 6),

                Text(
                  surahName,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    letterSpacing: .3,
                  ),
                ),

                const SizedBox(height: 4),

                Text(
                  ayahText,
                  style: const TextStyle(
                    color: Color.fromARGB(255, 201, 208, 220),
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),

                const Spacer(),

                Align(
                  alignment: Alignment.bottomRight,
                  child: Container(
                    width: 52,
                    height: 42,
                    decoration: const BoxDecoration(
                      color: Color(0xFFD4AF37),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.play_arrow_rounded,
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
