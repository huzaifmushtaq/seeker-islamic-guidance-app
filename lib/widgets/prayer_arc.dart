import 'package:flutter/material.dart';

class PrayerArc extends StatelessWidget {
  /// 0.0 = Prayer just started
  /// 1.0 = Prayer almost finished
  final double progress;

  const PrayerArc({super.key, required this.progress});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 200,
      height: 100,
      child: CustomPaint(painter: PrayerArcPainter(progress)),
    );
  }
}

class PrayerArcPainter extends CustomPainter {
  final double progress;

  PrayerArcPainter(this.progress);

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Rect.fromLTWH(0, 0, size.width, size.height * 2);

    final yellowPaint = Paint()
      ..color = const Color.fromARGB(255, 86, 204, 100)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 30
      ..strokeCap = StrokeCap.round;

    final whitePaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = 30
      ..strokeCap = StrokeCap.round;

    // Full yellow arc
    canvas.drawArc(rect, 3.14159265359, 3.14159265359, false, yellowPaint);

    // White grows with progress
    canvas.drawArc(
      rect,
      3.14159265359,
      3.14159265359 * progress.clamp(0.0, 1.0),
      false,
      whitePaint,
    );
  }

  @override
  bool shouldRepaint(covariant PrayerArcPainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}
