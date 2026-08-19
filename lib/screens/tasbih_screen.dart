import 'dart:math' as math;

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

class TasbihScreen extends StatefulWidget {
  const TasbihScreen({super.key});

  @override
  State<TasbihScreen> createState() => _TasbihScreenState();
}

class _TasbihScreenState extends State<TasbihScreen> {
  static const Color _background = Color(0xffFBF8F1);
  static const Color _text = Color(0xff182C2A);
  static const Color _teal = Color(0xff0E5A56);
  static const Color _gold = Color(0xffE8C76A);

  final AudioPlayer _tapPlayer = AudioPlayer();

  final List<_Dhikr> _dhikrOptions = const [
    _Dhikr(
      name: 'SubhanAllah',
      arabic: 'سُبْحَانَ اللَّهِ',
      meaning: 'Glory be to Allah, free from all imperfections',
      target: 33,
    ),
    _Dhikr(
      name: 'Alhamdulillah',
      arabic: 'الْحَمْدُ لِلَّهِ',
      meaning: 'All praise belongs to Allah',
      target: 33,
    ),
    _Dhikr(
      name: 'Allahu Akbar',
      arabic: 'اللَّهُ أَكْبَرُ',
      meaning: 'Allah is the Greatest',
      target: 34,
    ),
    _Dhikr(
      name: 'La ilaha illallah',
      arabic: 'لَا إِلَٰهَ إِلَّا اللَّهُ',
      meaning: 'There is no deity except Allah',
      target: 100,
    ),
    _Dhikr(
      name: 'Astaghfirullah',
      arabic: 'أَسْتَغْفِرُ اللَّهَ',
      meaning: 'I seek forgiveness from Allah',
      target: 100,
    ),
  ];

  int _selectedIndex = 0;
  int _count = 0;
  int _totalDhikr = 0;

  bool _isLoading = true;
  bool _completed = false;

  _Dhikr get _currentDhikr => _dhikrOptions[_selectedIndex];

  @override
  void initState() {
    super.initState();
    _restoreSession();
  }

  Future<void> _restoreSession() async {
    try {
      final prefs = await SharedPreferences.getInstance();

      final savedIndex = prefs.getInt('tasbih_selected_index') ?? 0;
      final safeIndex = savedIndex.clamp(0, _dhikrOptions.length - 1);

      final savedCount =
          prefs.getInt('tasbih_count_${safeIndex.toInt()}') ?? 0;

      final savedTotalDhikr =
          prefs.getInt('tasbih_total_dhikr') ?? 0;

      if (!mounted) return;

      setState(() {
        _selectedIndex = safeIndex.toInt();
        _count = savedCount;
        _totalDhikr = savedTotalDhikr;
        _completed = _count >= _currentDhikr.target;
        _isLoading = false;
      });
    } catch (e) {
      debugPrint('Tasbih restore error: $e');

      if (!mounted) return;

      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _saveSession() async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.setInt(
      'tasbih_selected_index',
      _selectedIndex,
    );

    await prefs.setInt(
      'tasbih_count_$_selectedIndex',
      _count,
    );

    await prefs.setInt(
      'tasbih_total_dhikr',
      _totalDhikr,
    );
  }

  Future<void> _playTapSound() async {
    try {
      await _tapPlayer.stop();

      await _tapPlayer.play(
        AssetSource('sounds/tasbih_click.wav'),
      );
    } catch (e) {
      debugPrint('Tasbih sound error: $e');
    }
  }

  Future<void> _increment() async {
    if (_isLoading || _completed) return;

    HapticFeedback.lightImpact();

    await _playTapSound();

    final nextCount = _count + 1;
    final nextTotalDhikr = _totalDhikr + 1;

    final reachedTarget =
        nextCount >= _currentDhikr.target;

    setState(() {
      _count = nextCount;
      _totalDhikr = nextTotalDhikr;
      _completed = reachedTarget;
    });

    await _saveSession();

    if (reachedTarget) {
      HapticFeedback.mediumImpact();
    }
  }

  Future<void> _reset() async {
    HapticFeedback.selectionClick();

    setState(() {
      _count = 0;
      _completed = false;
    });

    // Total Dhikr deliberately remains untouched.
    await _saveSession();
  }

  Future<void> _selectDhikr(int index) async {
    if (index == _selectedIndex) return;

    HapticFeedback.selectionClick();

    final prefs = await SharedPreferences.getInstance();

    final savedCount =
        prefs.getInt('tasbih_count_$index') ?? 0;

    if (!mounted) return;

    setState(() {
      _selectedIndex = index;
      _count = savedCount;
      _completed =
          _count >= _dhikrOptions[index].target;
    });

    await prefs.setInt(
      'tasbih_selected_index',
      index,
    );
  }

  void _showDhikrSelector() {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: _background,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(28),
        ),
      ),
      builder: (sheetContext) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(
              20,
              12,
              20,
              24,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 42,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.black12,
                    borderRadius:
                        BorderRadius.circular(4),
                  ),
                ),

                const SizedBox(height: 20),

                const Text(
                  'Choose your dhikr',
                  style: TextStyle(
                    color: _text,
                    fontSize: 19,
                    fontWeight: FontWeight.w800,
                  ),
                ),

                const SizedBox(height: 16),

                ...List.generate(
                  _dhikrOptions.length,
                  (index) {
                    final item = _dhikrOptions[index];
                    final selected =
                        index == _selectedIndex;

                    return Padding(
                      padding:
                          const EdgeInsets.only(bottom: 8),
                      child: ListTile(
                        onTap: () async {
                          Navigator.pop(sheetContext);
                          await _selectDhikr(index);
                        },
                        tileColor: selected
                            ? _teal.withValues(alpha: .08)
                            : Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius:
                              BorderRadius.circular(16),
                        ),
                        leading: Container(
                          width: 42,
                          height: 42,
                          decoration: BoxDecoration(
                            color: selected
                                ? _teal.withValues(alpha: .12)
                                : const Color(0xffF1ECE1),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            selected
                                ? Icons.check_rounded
                                : Icons
                                    .self_improvement_rounded,
                            color: selected
                                ? _teal
                                : Colors.black54,
                            size: 20,
                          ),
                        ),
                        title: Text(
                          item.name,
                          style: const TextStyle(
                            color: _text,
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        subtitle: Text(
                          '${item.target} repetitions',
                          style: const TextStyle(
                            color: Colors.black45,
                            fontSize: 11,
                          ),
                        ),
                        trailing: Text(
                          item.arabic,
                          textDirection:
                              TextDirection.rtl,
                          style: const TextStyle(
                            color: _text,
                            fontSize: 17,
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  void dispose() {
    _tapPlayer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _background,

      appBar: AppBar(
        backgroundColor: _background,
        elevation: 0,
        scrolledUnderElevation: 0,

        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new_rounded,
            color: _text,
          ),
          onPressed: () => Navigator.pop(context),
        ),

        title: Text(
          _currentDhikr.name,
          style: const TextStyle(
            color: _text,
            fontSize: 18,
            fontWeight: FontWeight.w700,
          ),
        ),

        actions: [
          IconButton(
            tooltip: 'Choose dhikr',
            icon: const Icon(
              Icons.language_rounded,
              color: _teal,
              size: 21,
            ),
            onPressed: _showDhikrSelector,
          ),
        ],
      ),

      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(
                color: _teal,
              ),
            )
          : SafeArea(
              child: LayoutBuilder(
                builder: (context, constraints) {
                  return SingleChildScrollView(
                    child: ConstrainedBox(
                      constraints: BoxConstraints(
                        minHeight: constraints.maxHeight,
                      ),
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(
                          18,
                          8,
                          18,
                          24,
                        ),
                        child: Column(
                          children: [
                            const SizedBox(height: 8),

                            // ==================================================
                            // TASBIH / COUNTER
                            // ==================================================

                            GestureDetector(
                              behavior: HitTestBehavior.opaque,
                              onTap: _increment,
                              child: SizedBox(
                                height: 500,
                                width: double.infinity,
                                child: Stack(
                                  alignment: Alignment.center,
                                  children: [

                                    // Very subtle circular guide.
                                    // No filled disk anymore.
                                    Positioned.fill(
                                      child: CustomPaint(
                                        painter:
                                            _TasbihBackgroundPainter(),
                                      ),
                                    ),

                                    // ------------------------------------------------
                                    // CENTRAL COUNTER
                                    // ------------------------------------------------

                                    Positioned(
                                      top: 72,
                                      left: 0,
                                      right: 0,
                                      child: Column(
                                        children: [
                                          Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            crossAxisAlignment:
                                                CrossAxisAlignment.end,
                                            children: [
                                              Text(
                                                '$_count',
                                                style:
                                                    const TextStyle(
                                                  color: _text,
                                                  fontSize: 68,
                                                  height: .88,
                                                  fontWeight:
                                                      FontWeight.w700,
                                                  letterSpacing: -3,
                                                ),
                                              ),

                                              const SizedBox(
                                                width: 9,
                                              ),

                                              Padding(
                                                padding:
                                                    const EdgeInsets.only(
                                                  bottom: 5,
                                                ),
                                                child: Text(
                                                  '/ ${_currentDhikr.target}',
                                                  style:
                                                      const TextStyle(
                                                    color:
                                                        Colors.black45,
                                                    fontSize: 22,
                                                    fontWeight:
                                                        FontWeight.w600,
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),

                                          const SizedBox(
                                            height: 13,
                                          ),

                                          Container(
                                            width: 48,
                                            height: 4,
                                            decoration:
                                                BoxDecoration(
                                              color: _gold,
                                              borderRadius:
                                                  BorderRadius
                                                      .circular(5),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),

                                    // ------------------------------------------------
                                    // MISBAHA BEADS
                                    // ------------------------------------------------

                                    Positioned.fill(
                                      child: CustomPaint(
                                        painter:
                                            _TasbihBeadsPainter(
                                          progress:
                                              _count /
                                                  _currentDhikr
                                                      .target,
                                          completed:
                                              _completed,
                                        ),
                                      ),
                                    ),

                                    // ------------------------------------------------
                                    // TAP INDICATOR
                                    // ------------------------------------------------

                                    Positioned(
                                      bottom: 58,
                                      left: 0,
                                      right: 0,
                                      child: AnimatedSwitcher(
                                        duration:
                                            const Duration(
                                          milliseconds: 180,
                                        ),
                                        child: _completed
                                            ? Column(
                                                key: const ValueKey(
                                                  'done',
                                                ),
                                                children: [
                                                  Container(
                                                    width: 42,
                                                    height: 42,
                                                    decoration:
                                                        const BoxDecoration(
                                                      color: _teal,
                                                      shape:
                                                          BoxShape
                                                              .circle,
                                                    ),
                                                    child:
                                                        const Icon(
                                                      Icons
                                                          .check_rounded,
                                                      color:
                                                          Colors.white,
                                                      size: 23,
                                                    ),
                                                  ),

                                                  const SizedBox(
                                                    height: 7,
                                                  ),

                                                  const Text(
                                                    'Dhikr completed',
                                                    style:
                                                        TextStyle(
                                                      color: _teal,
                                                      fontSize: 12,
                                                      fontWeight:
                                                          FontWeight
                                                              .w800,
                                                    ),
                                                  ),
                                                ],
                                              )
                                            : Column(
                                                key: const ValueKey(
                                                  'tap',
                                                ),
                                                children: [
                                                  Icon(
                                                    Icons
                                                        .touch_app_rounded,
                                                    color: _teal
                                                        .withValues(
                                                      alpha: .48,
                                                    ),
                                                    size: 19,
                                                  ),

                                                  const SizedBox(
                                                    height: 3,
                                                  ),

                                                  Text(
                                                    'TAP TO COUNT',
                                                    style:
                                                        TextStyle(
                                                      color: _teal
                                                          .withValues(
                                                        alpha: .62,
                                                      ),
                                                      fontSize: 9,
                                                      fontWeight:
                                                          FontWeight
                                                              .w800,
                                                      letterSpacing:
                                                          1.2,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),

                            const SizedBox(height: 8),

                            // ==================================================
                            // TOTAL DHIKR
                            // ==================================================

                            Container(
                              padding:
                                  const EdgeInsets.symmetric(
                                horizontal: 18,
                                vertical: 10,
                              ),
                              decoration: BoxDecoration(
                                color:
                                    _teal.withValues(alpha: .06),
                                borderRadius:
                                    BorderRadius.circular(14),
                                border: Border.all(
                                  color:
                                      _teal.withValues(alpha: .08),
                                ),
                              ),
                              child: Row(
                                mainAxisSize:
                                    MainAxisSize.min,
                                children: [
                                  Icon(
                                    Icons
                                        .auto_awesome_rounded,
                                    color: _teal.withValues(
                                      alpha: .65,
                                    ),
                                    size: 16,
                                  ),

                                  const SizedBox(width: 8),

                                  Text(
                                    'Total Dhikr',
                                    style: TextStyle(
                                      color:
                                          _text.withValues(
                                        alpha: .65,
                                      ),
                                      fontSize: 11,
                                      fontWeight:
                                          FontWeight.w600,
                                    ),
                                  ),

                                  const SizedBox(width: 8),

                                  Text(
                                    '$_totalDhikr',
                                    style: const TextStyle(
                                      color: _teal,
                                      fontSize: 13,
                                      fontWeight:
                                          FontWeight.w800,
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            const SizedBox(height: 40),

                            // ==================================================
                            // ARABIC + MEANING
                            // ==================================================

                            Text(
                              _currentDhikr.arabic,
                              textDirection:
                                  TextDirection.rtl,
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                color: _text,
                                fontSize: 28,
                                fontWeight: FontWeight.w500,
                                height: 1.5,
                              ),
                            ),

                            const SizedBox(height: 5),

                            Padding(
                              padding:
                                  const EdgeInsets.symmetric(
                                horizontal: 24,
                              ),
                              child: Text(
                                '"${_currentDhikr.meaning}"',
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                  color: Colors.black45,
                                  fontSize: 11,
                                  fontWeight: FontWeight.w500,
                                  height: 1.45,
                                ),
                              ),
                            ),

                            const SizedBox(height: 22),

                            // ==================================================
                            // CONTROLS
                            // ==================================================

                            Row(
                              mainAxisAlignment:
                                  MainAxisAlignment.center,
                              children: [
                                _ControlButton(
                                  icon:
                                      Icons.refresh_rounded,
                                  label: 'Reset',
                                  onTap: _reset,
                                ),

                                const SizedBox(width: 12),

                                _ControlButton(
                                  icon: Icons
                                      .auto_awesome_rounded,
                                  label: 'Change dhikr',
                                  onTap:
                                      _showDhikrSelector,
                                  filled: true,
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
    );
  }
}

// ============================================================================
// DHIKR MODEL
// ============================================================================

class _Dhikr {
  final String name;
  final String arabic;
  final String meaning;
  final int target;

  const _Dhikr({
    required this.name,
    required this.arabic,
    required this.meaning,
    required this.target,
  });
}

// ============================================================================
// CONTROL BUTTON
// ============================================================================

class _ControlButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final bool filled;

  const _ControlButton({
    required this.icon,
    required this.label,
    required this.onTap,
    this.filled = false,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: filled
          ? const Color(0xff0E5A56)
          : const Color(0xffFFFDF8),
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 11,
          ),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: filled
                ? null
                : Border.all(
                    color: const Color(0xffE8DFC8),
                  ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                color: filled
                    ? Colors.white
                    : const Color(0xff0E5A56),
                size: 17,
              ),

              const SizedBox(width: 7),

              Text(
                label,
                style: TextStyle(
                  color: filled
                      ? Colors.white
                      : const Color(0xff0E5A56),
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ============================================================================
// SUBTLE TASBIH BACKGROUND
// ============================================================================

class _TasbihBackgroundPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(
      size.width / 2,
      size.height * .53,
    );

    // Outer extremely subtle guide ring.
    final outerRadius =
        math.min(size.width, size.height) * .405;

    final outerPaint = Paint()
      ..color =
          const Color(0xffE8DFC8).withValues(alpha: .18)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;

    canvas.drawCircle(
      center,
      outerRadius,
      outerPaint,
    );

    // Inner whisper of teal.
    final innerRadius = outerRadius - 20;

    final innerPaint = Paint()
      ..color =
          const Color(0xff0E5A56).withValues(alpha: .025)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;

    canvas.drawCircle(
      center,
      innerRadius,
      innerPaint,
    );
  }

  @override
  bool shouldRepaint(
    covariant CustomPainter oldDelegate,
  ) {
    return false;
  }
}

// ============================================================================
// MISBAHA BEADS
// ============================================================================

class _TasbihBeadsPainter extends CustomPainter {
  final double progress;
  final bool completed;

  _TasbihBeadsPainter({
    required this.progress,
    required this.completed,
  });

  @override
  void paint(Canvas canvas, Size size) {
    // ----------------------------------------------------------
    // Geometry
    // ----------------------------------------------------------

    final center = Offset(
      size.width / 2,
      size.height * .53,
    );

    final rx = size.width * .425;
    final ry = size.height * .245;

    const start = math.pi * .13;
    const end = math.pi * .87;

    // ----------------------------------------------------------
    // Fine connecting cord
    // ----------------------------------------------------------

    final path = Path();

    for (int i = 0; i <= 120; i++) {
      final t = i / 120;
      final angle =
          start + (end - start) * t;

      final x =
          center.dx + rx * math.cos(angle);
      final y =
          center.dy + ry * math.sin(angle);

      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }

    final cordPaint = Paint()
      ..color =
          const Color(0xff0E5A56).withValues(alpha: .22)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.35
      ..strokeCap = StrokeCap.round;

    canvas.drawPath(
      path,
      cordPaint,
    );

    // ----------------------------------------------------------
    // Beads
    // ----------------------------------------------------------

    const beadCount = 15;
    const beadRadius = 18.5;

    for (int i = 0; i < beadCount; i++) {
      final beadProgress =
          i / (beadCount - 1);

      final angle =
          start +
              (end - start) * beadProgress;

      final x =
          center.dx + rx * math.cos(angle);

      final y =
          center.dy + ry * math.sin(angle);

      final isPassed =
          completed ||
          beadProgress <= progress;

      final isLast =
          i == beadCount - 1;

      _drawBead(
        canvas,
        Offset(x, y),
        beadRadius,
        isPassed,
        isLast && completed,
      );
    }
  }

  void _drawBead(
    Canvas canvas,
    Offset center,
    double radius,
    bool active,
    bool finalBead,
  ) {
    // ----------------------------------------------------------
    // Soft shadow
    // ----------------------------------------------------------

    final shadowPaint = Paint()
      ..color = Colors.black.withValues(
        alpha: active ? .12 : .07,
      )
      ..maskFilter = const MaskFilter.blur(
        BlurStyle.normal,
        4,
      );

    canvas.drawCircle(
      Offset(
        center.dx,
        center.dy + 2.5,
      ),
      radius,
      shadowPaint,
    );

    // ----------------------------------------------------------
    // Bead gradient
    // ----------------------------------------------------------

    final rect = Rect.fromCircle(
      center: center,
      radius: radius,
    );

    final colors = active
        ? [
            const Color(0xffF2D982),
            const Color(0xffC39B35),
            const Color(0xff80621F),
          ]
        : [
            const Color(0xffE5E1D7),
            const Color(0xffC9C4B9),
            const Color(0xffA7A196),
          ];

    final gradient = RadialGradient(
      center: const Alignment(-.34, -.38),
      radius: 1.0,
      colors: colors,
      stops: const [
        0.0,
        .48,
        1.0,
      ],
    );

    final beadPaint = Paint()
      ..shader =
          gradient.createShader(rect);

    canvas.drawCircle(
      center,
      radius,
      beadPaint,
    );

    // ----------------------------------------------------------
    // Soft highlight
    // ----------------------------------------------------------

    final highlightPaint = Paint()
      ..color = Colors.white.withValues(
        alpha: active ? .38 : .24,
      );

    canvas.drawCircle(
      Offset(
        center.dx - radius * .34,
        center.dy - radius * .35,
      ),
      radius * .19,
      highlightPaint,
    );

    // Tiny secondary reflection.
    final tinyHighlightPaint = Paint()
      ..color = Colors.white.withValues(
        alpha: active ? .10 : .08,
      );

    canvas.drawCircle(
      Offset(
        center.dx + radius * .30,
        center.dy + radius * .30,
      ),
      radius * .07,
      tinyHighlightPaint,
    );

    // ----------------------------------------------------------
    // Completion ring
    // ----------------------------------------------------------

    if (finalBead) {
      final ringPaint = Paint()
        ..color =
            Colors.white.withValues(alpha: .85)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.2;

      canvas.drawCircle(
        center,
        radius + 4,
        ringPaint,
      );
    }
  }

  @override
  bool shouldRepaint(
    covariant _TasbihBeadsPainter oldDelegate,
  ) {
    return oldDelegate.progress != progress ||
        oldDelegate.completed != completed;
  }
}