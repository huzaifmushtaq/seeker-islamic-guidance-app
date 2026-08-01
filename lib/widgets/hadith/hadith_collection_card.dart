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
      borderRadius: BorderRadius.circular(26),
      child: InkWell(
        borderRadius: BorderRadius.circular(26),
        onTap: onTap,
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(26),
            border: Border.all(
              color: const Color(0xffE7DCC1),
              width: 1.2,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(.05),
                blurRadius: 18,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [

                /// BOOK COVER PLACEHOLDER
                Expanded(
                  flex: 7,
                  child: ClipRRect(
  borderRadius: BorderRadius.circular(18),
  child: Image.asset(
    coverImage,
    width: double.infinity,
    fit: BoxFit.contain,
  ),
),
                ),

                const SizedBox(height: 14),

                Text(
                  title,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: Color(0xff12372A),
                    height: 1.2,
                  ),
                ),

                const SizedBox(height: 5),

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

                const Spacer(),

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
                        "$totalHadith",
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