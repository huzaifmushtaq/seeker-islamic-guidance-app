import 'package:flutter/material.dart';

class ShareLayoutService {
  static const double _cardWidth = 940;

  /// Fixed height occupied by:
  /// - Bismillah
  /// - Arabic card padding
  /// - Dividers
  /// - Collection info
  /// - Footer
  /// - Overall paddings
  static const double _fixedHeight = 1050;

  static bool fitsInImage({
    required String arabic,
    required String narrator,
    required String english,
  }) {
    double totalHeight = _fixedHeight;

    totalHeight += _measureArabic(arabic);

    if (narrator.isNotEmpty) {
      totalHeight += _measureNarrator(narrator);
    }

    totalHeight += _measureEnglish(english);

    return totalHeight <= 2300;
  }

  static double _measureArabic(String text) {
    final painter = TextPainter(
      text: TextSpan(
        text: text,
        style: const TextStyle(
          fontSize: 48,
          height: 2.05,
        ),
      ),
      textDirection: TextDirection.rtl,
    );

    painter.layout(maxWidth: _cardWidth);

    return painter.height;
  }

  static double _measureNarrator(String text) {
    final painter = TextPainter(
      text: TextSpan(
        text: text,
        style: const TextStyle(
          fontSize: 30,
          fontWeight: FontWeight.bold,
        ),
      ),
      textDirection: TextDirection.ltr,
    );

    painter.layout(maxWidth: _cardWidth);

    return painter.height + 100;
  }

  static double _measureEnglish(String text) {
    final painter = TextPainter(
      text: TextSpan(
        text: text,
        style: const TextStyle(
          fontSize: 35,
          height: 1.8,
        ),
      ),
      textDirection: TextDirection.ltr,
    );

    painter.layout(maxWidth: _cardWidth);

    return painter.height;
  }
}