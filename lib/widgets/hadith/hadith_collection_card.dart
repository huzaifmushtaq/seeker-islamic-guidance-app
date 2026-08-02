import 'package:flutter/material.dart';

class HadithCollectionCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final int totalHadith;
  final String coverImage;
  final VoidCallback? onTap;

  const HadithCollectionCard({
    super.key,
    required this.title,
    required this.subtitle,
    required this.totalHadith,
    required this.coverImage,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(24),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(24),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: const Color(0xffE7DCC1),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 16,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [

                /// BOOK IMAGE
                Expanded(
                  flex: 7,
                  child: Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(18),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(18),
                      child: Image.asset(
                        coverImage,
                        fit: BoxFit.contain,
                        errorBuilder: (
                          context,
                          error,
                          stackTrace,
                        ) {
                          return Container(
                            color: const Color(0xffF8F5ED),
                            child: const Center(
                              child: Icon(
                                Icons.menu_book_rounded,
                                size: 50,
                                color: Color(0xff0E5A56),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 14),

                /// TITLE
                Text(
                  title,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: Color(0xff12372A),
                    height: 1.25,
                  ),
                ),

                const SizedBox(height: 5),

                /// SUBTITLE
                Text(
                  subtitle,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 12,
                    color: Color(0xffB28B34),
                    fontWeight: FontWeight.w500,
                  ),
                ),

                const SizedBox(height: 10),

                /// FOOTER
                Row(
                  children: [
                    Container(
                      width: 28,
                      height: 28,
                      decoration: BoxDecoration(
                        color: const Color(0xffF6EFD9),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(
                        Icons.menu_book_rounded,
                        size: 15,
                        color: Color(0xff0E5A56),
                      ),
                    ),

                    const SizedBox(width: 8),

                    Expanded(
                      child: Text(
                        totalHadith == 0
                            ? "--"
                            : totalHadith.toString(),
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: Color(0xff12372A),
                        ),
                      ),
                    ),

                    const Icon(
                      Icons.arrow_forward_ios_rounded,
                      size: 15,
                      color: Color(0xff0E5A56),
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