import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_compass/flutter_compass.dart';

import '../../services/location_service.dart';
import '../../services/qibla_service.dart';

class QiblaScreen extends StatefulWidget {
  const QiblaScreen({super.key});

  @override
  State<QiblaScreen> createState() =>
      _QiblaScreenState();
}

class _QiblaScreenState
    extends State<QiblaScreen> {
  final LocationService _locationService =
      LocationService();

  double? qiblaBearing;
  double? heading;
  StreamSubscription<CompassEvent>? _compassSubscription;

  String cityName = 'Loading...';

  bool isLoading = true;
  String? errorMessage;

  @override
  void initState() {
    super.initState();

    _startCompass();
    _loadQibla();
  }

  void _startCompass() {
    final compassEvents = FlutterCompass.events;

    if (compassEvents == null) {
      if (!mounted) return;

      setState(() {
        errorMessage =
            'Compass sensor is not available on this device.';
      });

      return;
    }

    _compassSubscription =
        compassEvents.listen((event) {
      final value = event.heading;

      if (!mounted || value == null) {
        return;
      }

      setState(() {
        heading = value;
      });
    });
  }

  @override
  void dispose() {
    _compassSubscription?.cancel();
    _compassSubscription = null;
    super.dispose();
  }

  // ═════════════════════════════════════════════
  // LOAD LOCATION + QIBLA
  // ═════════════════════════════════════════════

  Future<void> _loadQibla() async {
    try {
      final latitude =
          await _locationService
              .getSavedLatitude();

      final longitude =
          await _locationService
              .getSavedLongitude();

      final city =
          await _locationService
              .getSavedCity();

      if (latitude == null ||
          longitude == null) {
        throw Exception(
          'Location is not available. Please enable location first.',
        );
      }

      final bearing =
          QiblaService.calculateQiblaBearing(
        latitude: latitude,
        longitude: longitude,
      );

      if (!mounted) return;

      setState(() {
        qiblaBearing = bearing;
        cityName = city ?? 'Your location';
        isLoading = false;
      });
    } catch (e) {
      debugPrint(
        'Qibla loading error: $e',
      );

      if (!mounted) return;

      setState(() {
        errorMessage = e.toString();
        isLoading = false;
      });
    }
  }

  // ═════════════════════════════════════════════
  // ANGLE DIFFERENCE
  // ═════════════════════════════════════════════

  double get _difference {
    if (heading == null ||
        qiblaBearing == null) {
      return 0;
    }

    double difference =
        qiblaBearing! - heading!;

    while (difference > 180) {
      difference -= 360;
    }

    while (difference < -180) {
      difference += 360;
    }

    return difference;
  }

  bool get _isAligned {
    return heading != null &&
        qiblaBearing != null &&
        _difference.abs() <= 5;
  }

  String get _directionInstruction {
    if (heading == null) {
      return 'Finding your direction...';
    }

    if (_isAligned) {
      return 'You are facing the Qibla';
    }

    final degrees =
        _difference.abs().round();

    if (_difference > 0) {
      return 'Turn right $degrees°';
    }

    return 'Turn left $degrees°';
  }

  // ═════════════════════════════════════════════
  // BUILD
  // ═════════════════════════════════════════════

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor:
          const Color(0xffFBF8F1),

      appBar: AppBar(
        backgroundColor:
            const Color(0xffFBF8F1),

        elevation: 0,

        scrolledUnderElevation: 0,

        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new_rounded,
            color: Color(0xff0E5A56),
          ),
          onPressed: () {
            Navigator.pop(context);
          },
        ),

        title: const Text(
          'Qibla',
          style: TextStyle(
            color: Color(0xff0E5A56),
            fontSize: 20,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),

      body: isLoading
          ? const Center(
              child:
                  CircularProgressIndicator(
                color: Color(0xff0E5A56),
              ),
            )
          : errorMessage != null
              ? _errorView()
              : _qiblaView(),
    );
  }

  // ═════════════════════════════════════════════
  // QIBLA VIEW
  // ═════════════════════════════════════════════

  Widget _qiblaView() {
    return SingleChildScrollView(
          padding:
              const EdgeInsets.fromLTRB(
            20,
            10,
            20,
            30,
          ),

          child: Column(
            children: [
              // ─────────────────────────────
              // INTRO
              // ─────────────────────────────

              const Text(
                'Find the Qibla',
                style: TextStyle(
                  color:
                      Color(0xff182C2A),
                  fontSize: 25,
                  fontWeight:
                      FontWeight.w700,
                ),
              ),

              const SizedBox(height: 5),

              const Text(
                'Face the direction of the Kaaba',
                style: TextStyle(
                  color:
                      Colors.black54,
                  fontSize: 12,
                  fontWeight:
                      FontWeight.w500,
                ),
              ),

              const SizedBox(height: 24),

              // ─────────────────────────────
              // COMPASS
              // ─────────────────────────────

              _buildCompass(),

              const SizedBox(height: 20),

              // ─────────────────────────────
              // BEARING
              // ─────────────────────────────

              Text(
                '${qiblaBearing!.round()}°',
                style: const TextStyle(
                  color:
                      Color(0xff0E5A56),
                  fontSize: 25,
                  fontWeight:
                      FontWeight.w800,
                ),
              ),

              const SizedBox(height: 2),

              const Text(
                'QIBLA BEARING',
                style: TextStyle(
                  color:
                      Colors.black45,
                  fontSize: 9,
                  fontWeight:
                      FontWeight.w800,
                  letterSpacing: 1.2,
                ),
              ),

              const SizedBox(height: 14),

              // ─────────────────────────────
              // INSTRUCTION
              // ─────────────────────────────
Text(
  _directionInstruction,
  textAlign: TextAlign.center,
  style: TextStyle(
    color: _isAligned
        ? const Color(0xff0E5A56)
        : Colors.black54,
    fontSize: 14,
    fontWeight: FontWeight.w700,
  ),
),

            const SizedBox(height: 22),

              // ─────────────────────────────
              // LOCATION CARD
              // ─────────────────────────────

              _locationCard(),

              const SizedBox(height: 18),

              // ─────────────────────────────
              // SACRED DIRECTION
              // ─────────────────────────────

              _sacredDirectionCard(),
            ],
          ),
    );
  }

  // ═════════════════════════════════════════════
  // COMPASS
  // ═════════════════════════════════════════════

  Widget _buildCompass() {
    final currentHeading =
        heading ?? 0;

    final compassRotation =
        -currentHeading *
            math.pi /
            180;

    final isAligned = _isAligned;

    return AnimatedContainer(
      duration:
          const Duration(milliseconds: 300),

      width: 300,
      height: 300,

      decoration: BoxDecoration(
        shape: BoxShape.circle,

        color:
            const Color(0xffFFFDF8),

        border: Border.all(
          color: isAligned
              ? const Color(
                  0xffE8C76A,
                )
              : const Color(
                  0xff0E5A56,
                ).withValues(
                  alpha: .10,
                ),
          width:
              isAligned ? 3 : 1.5,
        ),

        boxShadow: [
          BoxShadow(
            color: isAligned
                ? const Color(
                    0xffE8C76A,
                  ).withValues(
                    alpha: .22,
                  )
                : Colors.black.withValues(
                    alpha: .045,
                  ),
            blurRadius:
                isAligned ? 30 : 18,
            offset:
                const Offset(0, 8),
          ),
        ],
      ),

      child: Stack(
        alignment:
            Alignment.center,

        children: [
          // ─────────────────────────────
          // ROTATING COMPASS DIAL
          // ─────────────────────────────

          Transform.rotate(
            angle: compassRotation,

            child: CustomPaint(
              size:
                  const Size(
                270,
                270,
              ),

              painter:
                  _CompassPainter(
                aligned:
                    isAligned,
              ),
            ),
          ),

          // ─────────────────────────────
          // FIXED QIBLA INDICATOR
          // ─────────────────────────────

          Positioned(
            top: 22,

            child: AnimatedContainer(
              duration:
                  const Duration(
                milliseconds: 250,
              ),

              width: 38,
              height: 38,

              decoration:
                  BoxDecoration(
                color: isAligned
                    ? const Color(
                        0xffE8C76A,
                      )
                    : const Color(
                        0xff0E5A56,
                      ),

                shape:
                    BoxShape.circle,
              ),

              child: const Icon(
                Icons
                    .navigation_rounded,
                color: Colors.white,
                size: 20,
              ),
            ),
          ),

          // ─────────────────────────────
          // KAABA
          // ─────────────────────────────

          AnimatedContainer(
            duration:
                const Duration(
              milliseconds: 250,
            ),

            width: 76,
            height: 76,

            decoration:
                BoxDecoration(
              color: isAligned
                  ? const Color(
                      0xffE8C76A,
                    ).withValues(
                      alpha: .16,
                    )
                  : const Color(
                      0xff0E5A56,
                    ).withValues(
                      alpha: .08,
                    ),

              shape:
                  BoxShape.circle,
            ),

            child: Center(
              child: Text(
                '🕋',
                style:
                    const TextStyle(
                  fontSize: 38,
                ),
              ),
            ),
          ),

          if (isAligned)
            Positioned.fill(
              child: IgnorePointer(
                child: Center(
                  child: Container(
                    width: 92,
                    height: 92,
                    decoration:
                        BoxDecoration(
                      shape:
                          BoxShape.circle,
                      border: Border.all(
                        color:
                            const Color(
                          0xffE8C76A,
                        ).withValues(
                          alpha: .55,
                        ),
                        width: 2,
                      ),
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  // ═════════════════════════════════════════════
  // LOCATION CARD
  // ═════════════════════════════════════════════

  Widget _locationCard() {
    return Container(
      width: double.infinity,

      padding:
          const EdgeInsets.all(16),

      decoration: BoxDecoration(
        color:
            const Color(0xffFFFDF8),

        borderRadius:
            BorderRadius.circular(20),

        border: Border.all(
          color:
              const Color(0xff0E5A56)
                  .withValues(
            alpha: .07,
          ),
        ),

        boxShadow: [
          BoxShadow(
            color:
                Colors.black.withValues(
              alpha: .035,
            ),
            blurRadius: 12,
            offset:
                const Offset(0, 5),
          ),
        ],
      ),

      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,

            decoration: BoxDecoration(
              color:
                  const Color(
                0xff0E5A56,
              ).withValues(
                alpha: .08,
              ),

              borderRadius:
                  BorderRadius.circular(
                12,
              ),
            ),

            child: const Icon(
              Icons.location_on_rounded,
              color:
                  Color(0xff0E5A56),
              size: 20,
            ),
          ),

          const SizedBox(width: 12),

          Expanded(
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                const Text(
                  'YOUR LOCATION',
                  style: TextStyle(
                    color:
                        Color(0xff0E5A56),
                    fontSize: 9,
                    fontWeight:
                        FontWeight.w800,
                    letterSpacing: 1,
                  ),
                ),

                const SizedBox(height: 4),

                Text(
                  cityName,
                  style:
                      const TextStyle(
                    color:
                        Color(0xff182C2A),
                    fontSize: 14,
                    fontWeight:
                        FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),

          Column(
            crossAxisAlignment:
                CrossAxisAlignment.end,
            children: [
              const Text(
                'QIBLA',
                style: TextStyle(
                  color:
                      Colors.black45,
                  fontSize: 9,
                  fontWeight:
                      FontWeight.w700,
                  letterSpacing: .8,
                ),
              ),

              const SizedBox(height: 4),

              Text(
                '${qiblaBearing!.toStringAsFixed(1)}°',
                style:
                    const TextStyle(
                  color:
                      Color(0xffB28A2E),
                  fontSize: 15,
                  fontWeight:
                      FontWeight.w800,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ═════════════════════════════════════════════
  // SACRED DIRECTION
  // ═════════════════════════════════════════════

  Widget _sacredDirectionCard() {
    return Container(
      width: double.infinity,

      padding:
          const EdgeInsets.fromLTRB(
        18,
        18,
        18,
        20,
      ),

      decoration: BoxDecoration(
        color:
            const Color(0xffF2E4BE)
                .withValues(
          alpha: .55,
        ),

        borderRadius:
            BorderRadius.circular(20),
      ),

      child: Column(
        children: [
          const Text(
            'THE SACRED DIRECTION',
            style: TextStyle(
              color:
                  Color(0xff0E5A56),
              fontSize: 10,
              fontWeight:
                  FontWeight.w800,
              letterSpacing: 1.1,
            ),
          ),

          const SizedBox(height: 10),

          const Text(
            '“So turn your face toward\nAl-Masjid Al-Haram.”',
            textAlign:
                TextAlign.center,
            style: TextStyle(
              color:
                  Color(0xff182C2A),
              fontSize: 15,
              fontWeight:
                  FontWeight.w600,
              height: 1.5,
            ),
          ),

          const SizedBox(height: 7),

          const Text(
            'Qur’an 2:144',
            style: TextStyle(
              color:
                  Color(0xffB28A2E),
              fontSize: 11,
              fontWeight:
                  FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }

  // ═════════════════════════════════════════════
  // ERROR
  // ═════════════════════════════════════════════

  Widget _errorView() {
    return Center(
      child: Padding(
        padding:
            const EdgeInsets.all(28),

        child: Column(
          mainAxisAlignment:
              MainAxisAlignment.center,

          children: [
            Container(
              width: 64,
              height: 64,

              decoration:
                  BoxDecoration(
                color:
                    const Color(
                  0xff0E5A56,
                ).withValues(
                  alpha: .08,
                ),
                shape:
                    BoxShape.circle,
              ),

              child: const Icon(
                Icons
                    .location_off_rounded,
                color:
                    Color(0xff0E5A56),
                size: 28,
              ),
            ),

            const SizedBox(height: 18),

            const Text(
              'Location unavailable',
              style: TextStyle(
                color:
                    Color(0xff182C2A),
                fontSize: 19,
                fontWeight:
                    FontWeight.w700,
              ),
            ),

            const SizedBox(height: 8),

            Text(
              errorMessage ??
                  'Please enable location to find the Qibla.',
              textAlign:
                  TextAlign.center,
              style:
                  const TextStyle(
                color:
                    Colors.black54,
                fontSize: 12,
                height: 1.5,
              ),
            ),

            const SizedBox(height: 20),

            ElevatedButton(
              onPressed:
                  _loadQibla,

              style:
                  ElevatedButton.styleFrom(
                backgroundColor:
                    const Color(
                  0xff0E5A56,
                ),
                foregroundColor:
                    Colors.white,
                elevation: 0,
                padding:
                    const EdgeInsets
                        .symmetric(
                  horizontal: 20,
                  vertical: 12,
                ),
                shape:
                    RoundedRectangleBorder(
                  borderRadius:
                      BorderRadius.circular(
                    14,
                  ),
                ),
              ),

              child:
                  const Text(
                'Try Again',
                style:
                    TextStyle(
                  fontWeight:
                      FontWeight.w700,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════
// COMPASS PAINTER
// ═══════════════════════════════════════════════

class _CompassPainter
    extends CustomPainter {
  final bool aligned;

  _CompassPainter({
    required this.aligned,
  });

  @override
  void paint(
    Canvas canvas,
    Size size,
  ) {
    final center =
        Offset(
      size.width / 2,
      size.height / 2,
    );

    final radius =
        size.width / 2;

    final paint =
        Paint()
          ..style =
              PaintingStyle.stroke
          ..strokeWidth = 1
          ..color =
              const Color(
            0xff0E5A56,
          ).withValues(
            alpha: .12,
          );

    canvas.drawCircle(
      center,
      radius - 3,
      paint,
    );

    // ─────────────────────────────────────────
    // TICK MARKS
    // ─────────────────────────────────────────

    final tickPaint =
        Paint()
          ..color =
              const Color(
            0xff0E5A56,
          ).withValues(
            alpha: .22,
          )
          ..strokeWidth = 1;

    for (int i = 0;
        i < 72;
        i++) {
      final angle =
          i * 5 * math.pi / 180;

      final outer =
          Offset(
        center.dx +
            math.sin(angle) *
                (radius - 8),
        center.dy -
            math.cos(angle) *
                (radius - 8),
      );

      final innerLength =
          i % 3 == 0 ? 10.0 : 5.0;

      final inner =
          Offset(
        center.dx +
            math.sin(angle) *
                (radius -
                    8 -
                    innerLength),
        center.dy -
            math.cos(angle) *
                (radius -
                    8 -
                    innerLength),
      );

      canvas.drawLine(
        inner,
        outer,
        tickPaint,
      );
    }

    // ─────────────────────────────────────────
    // CARDINAL DIRECTIONS
    // ─────────────────────────────────────────

    _drawText(
      canvas,
      'N',
      Offset(
        center.dx,
        center.dy -
            radius +
            28,
      ),
      aligned,
    );

    _drawText(
      canvas,
      'E',
      Offset(
        center.dx +
            radius -
            28,
        center.dy,
      ),
      aligned,
    );

    _drawText(
      canvas,
      'S',
      Offset(
        center.dx,
        center.dy +
            radius -
            28,
      ),
      aligned,
    );

    _drawText(
      canvas,
      'W',
      Offset(
        center.dx -
            radius +
            28,
        center.dy,
      ),
      aligned,
    );
  }

  void _drawText(
    Canvas canvas,
    String text,
    Offset position,
    bool aligned,
  ) {
    final textPainter =
        TextPainter(
      text: TextSpan(
        text: text,
        style: TextStyle(
          color: aligned
              ? const Color(
                  0xffB28A2E,
                )
              : const Color(
                  0xff0E5A56,
                ),
          fontSize: 13,
          fontWeight:
              FontWeight.w800,
        ),
      ),
      textDirection:
          TextDirection.ltr,
    );

    textPainter.layout();

    textPainter.paint(
      canvas,
      Offset(
        position.dx -
            textPainter.width / 2,
        position.dy -
            textPainter.height / 2,
      ),
    );
  }

  @override
  bool shouldRepaint(
    _CompassPainter oldDelegate,
  ) {
    return oldDelegate.aligned !=
        aligned;
  }
}