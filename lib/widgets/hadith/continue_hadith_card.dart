import 'package:flutter/material.dart';

class ContinueHadithCard extends StatelessWidget {
  final String collectionName;
  final String bookName;
  final int hadithNumber;
  final VoidCallback? onTap;

  const ContinueHadithCard({
    super.key,
    required this.collectionName,
    required this.bookName,
    required this.hadithNumber,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(28),
      child: InkWell(
        borderRadius: BorderRadius.circular(28),
        onTap: onTap,
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(28),
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0xff0E5A56), Color(0xff0A403C)],
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: .12),
                blurRadius: 18,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Stack(
            children: [
              Positioned(
                right: -20,
                top: -20,
                child: Container(
                  width: 130,
                  height: 130,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: .05),
                    shape: BoxShape.circle,
                  ),
                ),
              ),

              Positioned(
                right: 25,
                bottom: 20,
                child: Icon(
                  Icons.menu_book_rounded,
                  size: 90,
                  color: Colors.white.withValues(alpha: .08),
                ),
              ),

              Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 7,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xffD4AF37),
                        borderRadius: BorderRadius.circular(50),
                      ),
                      child: const Text(
                        "CONTINUE READING",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 11,
                          letterSpacing: 1.2,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),

                    const SizedBox(height: 22),

                    Text(
                      collectionName,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 23,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 6),

                    Text(
                      bookName,
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: .82),
                        fontSize: 15,
                      ),
                    ),

                    const SizedBox(height: 24),

                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 10,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: .12),
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(
                              color: Colors.white.withValues(alpha: .15),
                            ),
                          ),
                          child: Row(
                            children: [
                              const Icon(
                                Icons.bookmark_rounded,
                                color: Color(0xffF6EFD9),
                                size: 18,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                "Hadith #$hadithNumber",
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),

                        const Spacer(),

                        Container(
                          width: 54,
                          height: 54,
                          decoration: const BoxDecoration(
                            color: Color(0xffD4AF37),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.arrow_forward_rounded,
                            color: Colors.white,
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
      ),
    );
  }
}
