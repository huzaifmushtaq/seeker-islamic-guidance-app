import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:hijri/hijri_calendar.dart';
import 'package:share_plus/share_plus.dart';

import 'package:seeker/models/knowledge_card_model.dart';
import 'package:seeker/services/image_export_service.dart';

class KnowledgeCardScreen extends StatefulWidget {
  final KnowledgeCardModel card;

  const KnowledgeCardScreen({
    super.key,
    required this.card,
  });

  @override
  State<KnowledgeCardScreen> createState() => _KnowledgeCardScreenState();
}


class _CardCorner extends StatelessWidget {
  final bool isLeft;
  final bool isTop;

  const _CardCorner({
    required this.isLeft,
    required this.isTop,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 92,
      height: 92,
      child: CustomPaint(
        painter: _CornerPainter(
          isLeft: isLeft,
          isTop: isTop,
        ),
      ),
    );
  }
}

class _CornerPainter extends CustomPainter {
  final bool isLeft;
  final bool isTop;

  const _CornerPainter({
    required this.isLeft,
    required this.isTop,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final teal = Paint()
      ..color = const Color(0xFF164D45)
      ..style = PaintingStyle.fill;

    final gold = Paint()
      ..color = const Color(0xFFD2B36A)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.4;

    final path = Path();

    if (isLeft && isTop) {
      path
        ..moveTo(0, 0)
        ..lineTo(92, 0)
        ..quadraticBezierTo(70, 9, 64, 30)
        ..quadraticBezierTo(57, 49, 33, 59)
        ..quadraticBezierTo(13, 68, 0, 92)
        ..close();
    } else if (!isLeft && isTop) {
      path
        ..moveTo(92, 0)
        ..lineTo(0, 0)
        ..quadraticBezierTo(22, 9, 28, 30)
        ..quadraticBezierTo(35, 49, 59, 59)
        ..quadraticBezierTo(79, 68, 92, 92)
        ..close();
    } else if (isLeft && !isTop) {
      path
        ..moveTo(0, 92)
        ..lineTo(92, 92)
        ..quadraticBezierTo(70, 83, 64, 62)
        ..quadraticBezierTo(57, 43, 33, 33)
        ..quadraticBezierTo(13, 24, 0, 0)
        ..close();
    } else {
      path
        ..moveTo(92, 92)
        ..lineTo(0, 92)
        ..quadraticBezierTo(22, 83, 28, 62)
        ..quadraticBezierTo(35, 43, 59, 33)
        ..quadraticBezierTo(79, 24, 92, 0)
        ..close();
    }

    canvas.drawPath(path, teal);
    canvas.drawPath(path, gold);

    final detail = Paint()
      ..color = const Color(0xFFD2B36A).withValues(alpha: 0.55)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;

    final inner = Path();

    if (isLeft && isTop) {
      inner
        ..moveTo(8, 8)
        ..quadraticBezierTo(28, 14, 38, 34)
        ..quadraticBezierTo(48, 51, 76, 76);
    } else if (!isLeft && isTop) {
      inner
        ..moveTo(84, 8)
        ..quadraticBezierTo(64, 14, 54, 34)
        ..quadraticBezierTo(44, 51, 16, 76);
    } else if (isLeft && !isTop) {
      inner
        ..moveTo(8, 84)
        ..quadraticBezierTo(28, 78, 38, 58)
        ..quadraticBezierTo(48, 41, 76, 16);
    } else {
      inner
        ..moveTo(84, 84)
        ..quadraticBezierTo(64, 78, 54, 58)
        ..quadraticBezierTo(44, 41, 16, 16);
    }

    canvas.drawPath(inner, detail);
  }

  @override
  bool shouldRepaint(covariant _CornerPainter oldDelegate) => false;
}

class _MiniLantern extends StatelessWidget {
  const _MiniLantern();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 34,
      height: 70,
      child: CustomPaint(
        painter: _LanternPainter(),
      ),
    );
  }
}

class _LanternPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final gold = Paint()
      ..color = const Color(0xFFD2B36A)
      ..style = PaintingStyle.fill;

    final outline = Paint()
      ..color = const Color(0xFF9B772E)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;

    canvas.drawRect(
      const Rect.fromLTWH(16, 0, 2, 13),
      gold,
    );
    canvas.drawCircle(
      const Offset(17, 15),
      2.5,
      gold,
    );

    final body = Path()
      ..moveTo(10, 20)
      ..lineTo(24, 20)
      ..lineTo(27, 29)
      ..lineTo(24, 43)
      ..lineTo(10, 43)
      ..lineTo(7, 29)
      ..close();

    canvas.drawPath(body, gold);
    canvas.drawPath(body, outline);

    final glass = Paint()
      ..color = const Color(0xFFF3E4B5)
      ..style = PaintingStyle.fill;

    canvas.drawRect(
      const Rect.fromLTWH(11, 25, 12, 13),
      glass,
    );

    final flame = Paint()
      ..color = const Color(0xFF164D45)
      ..style = PaintingStyle.fill;

    final flamePath = Path()
      ..moveTo(17, 27)
      ..quadraticBezierTo(12.5, 33, 17, 36)
      ..quadraticBezierTo(21.5, 33, 17, 27)
      ..close();

    canvas.drawPath(flamePath, flame);

    canvas.drawLine(
      const Offset(8, 29),
      const Offset(26, 29),
      outline,
    );
    canvas.drawLine(
      const Offset(11, 43),
      const Offset(23, 43),
      outline,
    );
  }

  @override
  bool shouldRepaint(covariant _LanternPainter oldDelegate) => false;
}

class _KnowledgeCardScreenState extends State<KnowledgeCardScreen> {
  static const Color teal = Color(0xFF164D45);
  static const Color darkTeal = Color(0xFF0B302B);
  static const Color gold = Color(0xFFD2B36A);
  static const Color cream = Color(0xFFF0E9D6);
  static const Color softGold = Color(0xFFD9C895);
  static const Color ivory = Color(0xFFF7F1DF);

  final GlobalKey _cardKey = GlobalKey();

  bool _isSaving = false;
  bool _isSharing = false;

  // ------------------------------------------------------------
  // CAPTURE CARD
  // ------------------------------------------------------------

  Future<Uint8List?> _captureCard() async {
    try {
      await Future.delayed(const Duration(milliseconds: 80));

      final boundary =
          _cardKey.currentContext?.findRenderObject() as RenderRepaintBoundary?;

      if (boundary == null) {
        return null;
      }

      final image = await boundary.toImage(
        pixelRatio: 3.0,
      );

      final byteData = await image.toByteData(
        format: ui.ImageByteFormat.png,
      );

      image.dispose();

      return byteData?.buffer.asUint8List();
    } catch (e) {
      debugPrint('Card capture error: $e');
      return null;
    }
  }

  // ------------------------------------------------------------
  // SAVE
  // ------------------------------------------------------------

  Future<void> _saveCard() async {
    if (_isSaving || _isSharing) return;

    setState(() {
      _isSaving = true;
    });

    try {
      final bytes = await _captureCard();

      if (bytes == null) {
        throw Exception('Unable to create card image.');
      }

      await ImageExportService.saveImage(
        bytes,
        name: 'seeker_hadith_${DateTime.now().millisecondsSinceEpoch}',
      );

      if (!mounted) return;

      _showMessage(
        'Hadith card saved successfully',
        Icons.check_circle_rounded,
      );
    } catch (e) {
      if (!mounted) return;

      _showMessage(
        e.toString().replaceFirst('Exception: ', ''),
        Icons.error_outline_rounded,
        isError: true,
      );
    } finally {
      if (mounted) {
        setState(() {
          _isSaving = false;
        });
      }
    }
  }

  // ------------------------------------------------------------
  // SHARE
  // ------------------------------------------------------------
Future<void> _shareCard() async {
  if (_isSharing || _isSaving) return;

  setState(() {
    _isSharing = true;
  });

  try {
    final bytes = await _captureCard();

    if (bytes == null) {
      throw Exception('Unable to create card image.');
    }

    final fileName =
        'seeker_hadith_${DateTime.now().millisecondsSinceEpoch}.png';

    final file = XFile.fromData(
      bytes,
      mimeType: 'image/png',
    );

    await Share.shareXFiles(
      [file],
      text: 'Wisdom of the Day ',
      subject: 'Wisdom of the Day ',
      fileNameOverrides: [fileName],
    );
  } catch (e) {
    if (!mounted) return;

    _showMessage(
      e.toString().replaceFirst('Exception: ', ''),
      Icons.error_outline_rounded,
      isError: true,
    );
  } finally {
    if (mounted) {
      setState(() {
        _isSharing = false;
      });
    }
  }
}
  // ------------------------------------------------------------
  // MESSAGE
  // ------------------------------------------------------------

  void _showMessage(
    String message,
    IconData icon, {
    bool isError = false,
  }) {
    ScaffoldMessenger.of(context).hideCurrentSnackBar();

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        behavior: SnackBarBehavior.floating,
        backgroundColor: isError ? Colors.red.shade800 : darkTeal,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
        ),
        margin: const EdgeInsets.fromLTRB(18, 0, 18, 18),
        content: Row(
          children: [
            Icon(
              icon,
              color: Colors.white,
              size: 20,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                message,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ------------------------------------------------------------
  // SCREEN
  // ------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFE2D8BF),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF0E9D6),
        elevation: 0,
        centerTitle: false,
        foregroundColor: darkTeal,
        title: const Text(
          'Knowledge Card',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: darkTeal,
          ),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(12, 14, 12, 20),
                child: Center(
                  child: RepaintBoundary(
                    key: _cardKey,
                    child: _buildCard(),
                  ),
                ),
              ),
            ),

            // ACTION BAR — NOT PART OF THE IMAGE
            _buildActionBar(),
          ],
        ),
      ),
    );
  }

  // ------------------------------------------------------------
  // MAIN CARD
  // ------------------------------------------------------------

  Widget _buildCard() {
    return LayoutBuilder(
      builder: (context, constraints) {
        final availableWidth = constraints.maxWidth;

        final cardWidth = availableWidth > 760
            ? 760.0
            : availableWidth;

        return Container(
          width: cardWidth,
          decoration: BoxDecoration(
            color: cream,
            border: Border.all(
              color: gold.withValues(alpha: 0.82),
              width: 1.4,
            ),
            boxShadow: const [
              BoxShadow(
                color: Color(0x45000000),
                blurRadius: 30,
                offset: Offset(0, 14),
              ),
            ],
          ),
          child: Stack(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(
                  18,
                  22,
                  18,
                  20,
                ),
                child: Column(
                  children: [
                    const SizedBox(height: 5),
                    _buildBrandHeader(),

                    const SizedBox(height: 15),

                    _buildGoldOrnament(),

                    const SizedBox(height: 17),

                    _buildBismillah(),

                    const SizedBox(height: 17),

                    _buildDatePanel(),

                    const SizedBox(height: 20),

                    _buildKnowledgeContent(),

                    const SizedBox(height: 18),

                    _buildCardFooter(),
                  ],
                ),
              ),

              // Decorative elements are overlays only.
              const Positioned(
                left: 0,
                top: 0,
                child: _CardCorner(isLeft: true, isTop: true),
              ),
              const Positioned(
                right: 0,
                top: 0,
                child: _CardCorner(isLeft: false, isTop: true),
              ),
              const Positioned(
                left: 0,
                bottom: 0,
                child: _CardCorner(isLeft: true, isTop: false),
              ),
              const Positioned(
                right: 0,
                bottom: 0,
                child: _CardCorner(isLeft: false, isTop: false),
              ),
              const Positioned(
                left: 11,
                top: 0,
                child: _MiniLantern(),
              ),
              const Positioned(
                right: 11,
                top: 0,
                child: _MiniLantern(),
              ),
            ],
          ),
        );
      },
    );
  }

  // ------------------------------------------------------------
  // SEEKER BRAND
  // ------------------------------------------------------------

  Widget _buildBrandHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          width: 30,
          height: 40,
          decoration: BoxDecoration(
            color: teal,
            shape: BoxShape.circle,
            border: Border.all(
              color: gold,
              width: 1,
            ),
          ),
          child: const Icon(
            Icons.auto_awesome,
            color: Color(0xFFE4C978),
            size: 15,
          ),
        ),
        const SizedBox(width: 9),
        const Text(
          'SEEKER',
          style: TextStyle(
            color: darkTeal,
            fontSize: 12,
            fontWeight: FontWeight.w800,
            letterSpacing: 3.2,
          ),
        ),
      ],
    );
  }

  // ------------------------------------------------------------
  // BISMILLAH
  // ------------------------------------------------------------

  Widget _buildBismillah() {
    return const Text(
      'بِسْمِ اللَّهِ الرَّحْمَنِ الرَّحِيمِ',
      textDirection: TextDirection.rtl,
      textAlign: TextAlign.center,
      style: TextStyle(
        color: darkTeal,
        fontFamily: 'NotoNaskhArabic',
        fontSize: 24,
        height: 1.6,
        fontWeight: FontWeight.w600,
      ),
    );
  }

  // ------------------------------------------------------------
  // ORNAMENT
  // ------------------------------------------------------------

  Widget _buildGoldOrnament() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Expanded(
          child: Container(
            height: 1,
            color: gold.withValues(alpha: 0.55),
          ),
        ),
        const SizedBox(width: 12),
        const Icon(
          Icons.auto_awesome,
          color: gold,
          size: 16,
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Container(
            height: 1,
            color: gold.withValues(alpha: 0.55),
          ),
        ),
      ],
    );
  }

  // ------------------------------------------------------------
  // DATE PANEL
  // ------------------------------------------------------------

  Widget _buildDatePanel() {
    final now = DateTime.now();

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(
        horizontal: 10,
        vertical: 16,
      ),
      decoration: BoxDecoration(
        color: ivory,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: softGold,
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Expanded(
            flex: 38,
            child: _dateCell(
              icon: Icons.nightlight_round,
              title: 'Hijri Date',
              value: _hijri(),
            ),
          ),

          _dateDivider(),

          Expanded(
            flex: 36,
            child: _dateCell(
              icon: Icons.calendar_month_rounded,
              title: 'Gregorian',
              value: _gregorian(now),
            ),
          ),

          _dateDivider(),

          Expanded(
            flex: 28,
            child: _dateCell(
              icon: Icons.today_rounded,
              title: 'Today',
              value: _weekday(now),
            ),
          ),
        ],
      ),
    );
  }

  Widget _dateCell({
    required IconData icon,
    required String title,
    required String value,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 5),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            title,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Color(0xFF8A6A32),
              fontSize: 9.5,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.35,
            ),
          ),

          const SizedBox(height: 8),

          Container(
            width: 37,
            height: 37,
            decoration: const BoxDecoration(
              color: Color(0xFFDDE8DF),
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              color: teal,
              size: 19,
            ),
          ),

          const SizedBox(height: 8),

          SizedBox(
            height: 18,
            width: double.infinity,
            child: FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                value,
                maxLines: 1,
                softWrap: false,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: teal,
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _dateDivider() {
    return Container(
      width: 1,
      height: 68,
      color: softGold,
    );
  }

  // ------------------------------------------------------------
  // KNOWLEDGE CONTENT
  // ------------------------------------------------------------

  Widget _buildKnowledgeContent() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(
        20,
        20,
        20,
        22,
      ),
      decoration: BoxDecoration(
        color: ivory,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: softGold,
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 4,
                height: 22,
                decoration: BoxDecoration(
                  color: gold,
                  borderRadius: BorderRadius.circular(3),
                ),
              ),

              const SizedBox(width: 10),

              const Text(
                'آج کا علم',
                textDirection: TextDirection.rtl,
                style: TextStyle(
                  color: teal,
                  fontFamily: 'NotoNaskhArabic',
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),

          const SizedBox(height: 19),

          Center(
            child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 17,
                vertical: 7,
              ),
              decoration: BoxDecoration(
                color: teal,
                borderRadius: BorderRadius.circular(30),
              ),
              child: const Text(
                'حدیثِ نبوی ﷺ',
                textDirection: TextDirection.rtl,
                style: TextStyle(
                  color: ivory,
                  fontFamily: 'NotoNaskhArabic',
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),

          const SizedBox(height: 17),

          Directionality(
            textDirection: TextDirection.rtl,
            child: Text(
              widget.card.translationUrdu,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Color(0xFF17453F),
                fontFamily: 'NotoNaskhArabic',
                fontSize: 20,
                height: 1.9,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),

          const SizedBox(height: 22),

          _buildHadithMeta(),
        ],
      ),
    );
  }

  // ------------------------------------------------------------
  // HADITH META
  // ------------------------------------------------------------

  Widget _buildHadithMeta() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(
        horizontal: 4,
        vertical: 13,
      ),
      decoration: const BoxDecoration(
        border: Border(
          top: BorderSide(
            color: Color(0xFFD7C69B),
            width: 1,
          ),
          bottom: BorderSide(
            color: Color(0xFFD7C69B),
            width: 1,
          ),
        ),
      ),
      child: Column(
        children: [
          _metaSingleRow(
            icon: Icons.person_outline_rounded,
            label: 'راوی',
            value: widget.card.narrator ?? '—',
          ),

          const SizedBox(height: 11),

          _metaSingleRow(
            icon: Icons.menu_book_outlined,
            label: 'حوالہ',
            value: widget.card.primarySource,
          ),
        ],
      ),
    );
  }

  Widget _metaSingleRow({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(
          child: Text(
            value,
            textDirection: TextDirection.rtl,
            textAlign: TextAlign.right,
            maxLines: label == 'راوی' ? 3 : 2,
            softWrap: true,
            style: const TextStyle(
              color: Color(0xFF17453F),
              fontFamily: 'NotoNaskhArabic',
              fontSize: 12.5,
              height: 1.4,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),

        const SizedBox(width: 8),

        Text(
          label,
          textDirection: TextDirection.rtl,
          style: const TextStyle(
            color: Color(0xFF8A6A32),
            fontFamily: 'NotoNaskhArabic',
            fontSize: 12.5,
            fontWeight: FontWeight.w700,
          ),
        ),

        const SizedBox(width: 8),

        Container(
          width: 30,
          height: 30,
          decoration: const BoxDecoration(
            color: Color(0xFFDDE8DF),
            shape: BoxShape.circle,
          ),
          child: Icon(
            icon,
            color: teal,
            size: 15,
          ),
        ),
      ],
    );
  }

  // ------------------------------------------------------------
  // FOOTER
  // ------------------------------------------------------------

  Widget _buildCardFooter() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          width: 5,
          height: 5,
          decoration: const BoxDecoration(
            color: gold,
            shape: BoxShape.circle,
          ),
        ),

        const SizedBox(width: 8),

        const Text(
          'SEEKER  •  KNOWLEDGE • FAITH • LIFE',
          style: TextStyle(
            color: Color(0xFF8A6A32),
            fontSize: 8.5,
            fontWeight: FontWeight.w700,
            letterSpacing: 1.05,
          ),
        ),

        const SizedBox(width: 8),

        Container(
          width: 5,
          height: 5,
          decoration: const BoxDecoration(
            color: gold,
            shape: BoxShape.circle,
          ),
        ),
      ],
    );
  }

  // ------------------------------------------------------------
  // ACTION BAR
  // ------------------------------------------------------------

  Widget _buildActionBar() {
    return Container(
      padding: const EdgeInsets.fromLTRB(
        16,
        12,
        16,
        12,
      ),
      decoration: const BoxDecoration(
        color: Color(0xFFF0E9D6),
        border: Border(
          top: BorderSide(
            color: Color(0xFFD8C9A8),
            width: 1,
          ),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: _actionButton(
              icon: _isSaving
                  ? Icons.hourglass_top_rounded
                  : Icons.download_rounded,
              label: _isSaving ? 'Saving...' : 'Save Image',
              onTap: _isSaving || _isSharing
                  ? null
                  : _saveCard,
              filled: false,
            ),
          ),

          const SizedBox(width: 10),

          Expanded(
            child: _actionButton(
              icon: _isSharing
                  ? Icons.hourglass_top_rounded
                  : Icons.share_rounded,
              label: _isSharing ? 'Sharing...' : 'Share',
              onTap: _isSharing || _isSaving
                  ? null
                  : _shareCard,
              filled: true,
            ),
          ),
        ],
      ),
    );
  }

  Widget _actionButton({
    required IconData icon,
    required String label,
    required VoidCallback? onTap,
    required bool filled,
  }) {
    return SizedBox(
      height: 48,
      child: ElevatedButton.icon(
        onPressed: onTap,
        icon: Icon(
          icon,
          size: 19,
        ),
        label: Text(
          label,
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w700,
          ),
        ),
        style: ElevatedButton.styleFrom(
          elevation: 0,
          backgroundColor: filled ? teal : const Color(0xFFF7F1DF),
          foregroundColor: filled ? const Color(0xFFF7F1DF) : teal,
          disabledBackgroundColor:
              filled ? teal.withValues(alpha: 0.45) : ivory,
          disabledForegroundColor:
              teal.withValues(alpha: 0.45),
          side: BorderSide(
            color: teal.withValues(alpha: 0.55),
            width: 1,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
      ),
    );
  }

  // ------------------------------------------------------------
  // DATE HELPERS
  // ------------------------------------------------------------

  String _weekday(DateTime date) {
    const days = [
      'Monday',
      'Tuesday',
      'Wednesday',
      'Thursday',
      'Friday',
      'Saturday',
      'Sunday',
    ];

    return days[date.weekday - 1];
  }

  String _gregorian(DateTime date) {
    const months = [
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December',
    ];

    return '${date.day} ${months[date.month - 1]}';
  }

  String _hijri() {
    HijriCalendar.setLocal('en');

    final h = HijriCalendar.now();

    return '${h.hDay} ${h.longMonthName}';
  }
}