import 'package:flutter/material.dart';

class BookmarksCard extends StatelessWidget {
  final int totalBookmarks;
  final VoidCallback onTap;

  const BookmarksCard({
    super.key,
    required this.totalBookmarks,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(20),
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: onTap,
        child: Container(
          height: 84,
          padding: const EdgeInsets.symmetric(horizontal: 20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: const Color(0xffE8DFC9)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: .05),
                blurRadius: 14,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                width: 54,
                height: 54,
                decoration: BoxDecoration(
                  color: const Color(0xffF6EFD9),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Icon(
                  Icons.bookmark_rounded,
                  color: Color(0xffB28B34),
                  size: 28,
                ),
              ),

              const SizedBox(width: 16),

              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Bookmarks",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Color(0xff12372A),
                      ),
                    ),

                    const SizedBox(height: 4),

                    Text(
                      "$totalBookmarks saved hadiths",
                      style: const TextStyle(
                        color: Colors.black54,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),

              const Icon(
                Icons.arrow_forward_ios_rounded,
                color: Color(0xff0E5A56),
                size: 18,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
