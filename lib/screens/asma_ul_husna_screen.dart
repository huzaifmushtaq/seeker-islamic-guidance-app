import 'package:flutter/material.dart';


import '../models/asma_ul_husna_model.dart';
import 'package:seeker/services/asma_ul_husna_service.dart';

class AsmaUlHusnaScreen extends StatefulWidget {
  const AsmaUlHusnaScreen({super.key});

  @override
  State<AsmaUlHusnaScreen> createState() => _AsmaUlHusnaScreenState();
}

class _AsmaUlHusnaScreenState extends State<AsmaUlHusnaScreen> {
  final PageController _pageController = PageController(viewportFraction: .78);
  final AsmaUlHusnaService _service = AsmaUlHusnaService();

  int _currentIndex = 0;
  Set<int> _learned = <int>{};
  Set<int> _favorites = <int>{};
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadProgress();
  }

  Future<void> _loadProgress() async {
    final learned = await _service.loadLearned();
    final favorites = await _service.loadFavorites();

    if (!mounted) return;
    setState(() {
      _learned = learned;
      _favorites = favorites;
      _loading = false;
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  Future<void> _toggleLearned() async {
    final name = asmaUlHusna[_currentIndex];
    final value = !_learned.contains(name.number);

    setState(() {
      if (value) {
        _learned.add(name.number);
      } else {
        _learned.remove(name.number);
      }
    });

    await _service.setLearned(name.number, value);
  }

  Future<void> _toggleFavorite() async {
    final name = asmaUlHusna[_currentIndex];
    final value = !_favorites.contains(name.number);

    setState(() {
      if (value) {
        _favorites.add(name.number);
      } else {
        _favorites.remove(name.number);
      }
    });

    await _service.setFavorite(name.number, value);
  }

  void _goPrevious() {
    if (_currentIndex == 0) return;
    _pageController.previousPage(
      duration: const Duration(milliseconds: 420),
      curve: Curves.easeOutCubic,
    );
  }

  void _goNext() {
    if (_currentIndex == asmaUlHusna.length - 1) return;
    _pageController.nextPage(
      duration: const Duration(milliseconds: 420),
      curve: Curves.easeOutCubic,
    );
  }

  void _showDetails() {
    final name = asmaUlHusna[_currentIndex];
    final isLearned = _learned.contains(name.number);
    final isFavorite = _favorites.contains(name.number);

    showModalBottomSheet<void>(
      context: context,
      backgroundColor: const Color(0xff353535),
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
      ),
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(24, 16, 24, 26),
            child: SingleChildScrollView(
              child: Column(
                children: [
                  Container(
                    width: 42,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.white24,
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                  const SizedBox(height: 26),
                  Text(
                    '${name.number.toString().padLeft(2, '0')}  •  ASMA UL HUSNA',
                    style: const TextStyle(
                      color: Colors.white54,
                      fontSize: 11,
                      letterSpacing: 1.4,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 18),
                  Text(
                    name.arabic,
                    textAlign: TextAlign.center,
                    textDirection: TextDirection.rtl,
                    style: const TextStyle(
                      fontFamily: 'NotoNaskhArabic',
                      color: Colors.white,
                      fontSize: 44,
                      height: 1.35,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    name.transliteration,
                    style: const TextStyle(
                      color: Color(0xffA7D84B),
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 1.2,
                    ),
                  ),
                  const SizedBox(height: 24),
                  _detailSection(
                    title: 'Meaning',
                    child: Text(
                      name.meaning,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        height: 1.45,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  const SizedBox(height: 14),
                  _detailSection(
                    title: 'Urdu',
                    child: Text(
                      name.urduMeaning,
                      textAlign: TextAlign.center,
                      textDirection: TextDirection.rtl,
                      style: const TextStyle(
                        color: Color(0xffD7E7B4),
                        fontFamily: 'NotoNaskhArabic',
                        fontSize: 21,
                        height: 1.5,
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      Expanded(
                        child: _bottomAction(
                          icon: isFavorite
                              ? Icons.favorite_rounded
                              : Icons.favorite_border_rounded,
                          label: isFavorite ? 'Saved' : 'Save',
                          active: isFavorite,
                          onTap: () async {
                            Navigator.pop(context);
                            await _toggleFavorite();
                          },
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _bottomAction(
                          icon: isLearned
                              ? Icons.check_circle_rounded
                              : Icons.check_circle_outline_rounded,
                          label: isLearned ? 'Learned' : 'Mark learned',
                          active: isLearned,
                          onTap: () async {
                            Navigator.pop(context);
                            await _toggleLearned();
                          },
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _detailSection({required String title, required Widget child}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(18, 15, 18, 17),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: .045),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.white.withValues(alpha: .07)),
      ),
      child: Column(
        children: [
          Text(
            title.toUpperCase(),
            style: const TextStyle(
              color: Colors.white38,
              fontSize: 10,
              letterSpacing: 1.4,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 7),
          child,
        ],
      ),
    );
  }

  Widget _bottomAction({
    required IconData icon,
    required String label,
    required bool active,
    required VoidCallback onTap,
  }) {
    return Material(
      color: active
          ? const Color(0xffA7D84B).withValues(alpha: .14)
          : Colors.white.withValues(alpha: .055),
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 14),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 19,
                color: active ? const Color(0xffA7D84B) : Colors.white70,
              ),
              const SizedBox(width: 8),
              Text(
                label,
                style: TextStyle(
                  color: active ? const Color(0xffA7D84B) : Colors.white70,
                  fontWeight: FontWeight.w700,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final current = asmaUlHusna[_currentIndex];
    final progress = (_learned.length / asmaUlHusna.length).clamp(0.0, 1.0);

    return Scaffold(
      backgroundColor: const Color(0xff303030),
      body: SafeArea(
        child: Column(
          children: [
            _header(),
            const SizedBox(height: 14),
            _progressHeader(progress),
            const SizedBox(height: 8),
            Expanded(
              child: _loading
                  ? const Center(
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Color(0xffA7D84B),
                      ),
                    )
                  : PageView.builder(
                      controller: _pageController,
                      reverse: true,
                      physics: const BouncingScrollPhysics(),
                      itemCount: asmaUlHusna.length,
                      onPageChanged: (index) {
                        setState(() => _currentIndex = index);
                      },
                      itemBuilder: (context, index) {
                        final name = asmaUlHusna[index];
                        final selected = index == _currentIndex;

                        return AnimatedScale(
                          duration: const Duration(milliseconds: 300),
                          curve: Curves.easeOutCubic,
                          scale: selected ? 1 : .90,
                          child: AnimatedOpacity(
                            duration: const Duration(milliseconds: 300),
                            opacity: selected ? 1 : .62,
                            child: _nameCard(name),
                          ),
                        );
                      },
                    ),
            ),
            _bottomBar(current),
          ],
        ),
      ),
    );
  }

  Widget _header() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(18, 12, 18, 0),
      child: Row(
        children: [
          _headerButton(
            icon: Icons.arrow_back_rounded,
            onTap: () => Navigator.pop(context),
          ),
          const SizedBox(width: 18),
          const Expanded(
            child: Text(
              'Asma Ul Husna',
              style: TextStyle(
                color: Colors.white,
                fontSize: 25,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          _headerButton(
            icon: Icons.favorite_border_rounded,
            onTap: _toggleFavorite,
          ),
        ],
      ),
    );
  }

  Widget _headerButton({required IconData icon, required VoidCallback onTap}) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        customBorder: const CircleBorder(),
        child: Padding(
          padding: const EdgeInsets.all(8),
          child: Icon(icon, color: Colors.white, size: 29),
        ),
      ),
    );
  }

  Widget _progressHeader(double progress) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 34),
      child: Row(
        children: [
          const Icon(
            Icons.auto_awesome_rounded,
            color: Color(0xffA7D84B),
            size: 16,
          ),
          const SizedBox(width: 7),
          Text(
            '${_learned.length}/99 learned',
            style: const TextStyle(
              color: Colors.white60,
              fontSize: 11,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: LinearProgressIndicator(
                minHeight: 4,
                value: progress,
                backgroundColor: Colors.white10,
                color: const Color(0xffA7D84B),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _nameCard(AsmaUlHusnaModel name) {
    final isLearned = _learned.contains(name.number);
    final isFavorite = _favorites.contains(name.number);

    return GestureDetector(
      onTap: _showDetails,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 12, horizontal: 2),
        decoration: BoxDecoration(
          color: const Color(0xff454545),
          borderRadius: BorderRadius.circular(22),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: .34),
              blurRadius: 28,
              offset: const Offset(0, 15),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(22),
          child: Stack(
            children: [
              const Positioned.fill(child: _OrnamentBackground()),
              Positioned(
                top: 24,
                left: 0,
                right: 0,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: 34,
                      height: 34,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.black.withValues(alpha: .12),
                        border: Border.all(color: Colors.white12),
                      ),
                      child: Center(
                        child: Text(
                          name.number.toString().padLeft(2, '0'),
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Positioned(
                top: 28,
                right: 28,
                child: Icon(
                  isFavorite
                      ? Icons.favorite_rounded
                      : Icons.favorite_border_rounded,
                  size: 20,
                  color: isFavorite
                      ? const Color(0xffA7D84B)
                      : Colors.white24,
                ),
              ),
              Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        name.arabic,
                        textAlign: TextAlign.center,
                        textDirection: TextDirection.rtl,
                        style: const TextStyle(
                          fontFamily: 'NotoNaskhArabic',
                          color: Colors.white,
                          fontSize: 55,
                          height: 1.35,
                        ),
                      ),
                      const SizedBox(height: 14),
                      Container(
                        height: 1,
                        width: 52,
                        color: const Color(0xffA7D84B).withValues(alpha: .75),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        name.urduMeaning,
                        textAlign: TextAlign.center,
                        textDirection: TextDirection.rtl,
                        style: const TextStyle(
                          fontFamily: 'NotoNaskhArabic',
                          color: Color(0xffA7D84B),
                          fontSize: 23,
                          height: 1.4,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        name.transliteration,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 1.2,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        name.meaning,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          color: Colors.white54,
                          fontSize: 12,
                          height: 1.35,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Positioned(
                bottom: 24,
                left: 0,
                right: 0,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      isLearned
                          ? Icons.check_circle_rounded
                          : Icons.touch_app_rounded,
                      size: 14,
                      color: isLearned
                          ? const Color(0xffA7D84B)
                          : Colors.white30,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      isLearned ? 'LEARNED' : 'TAP TO EXPLORE',
                      style: TextStyle(
                        color: isLearned
                            ? const Color(0xffA7D84B)
                            : Colors.white30,
                        fontSize: 9,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 1.3,
                      ),
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

  Widget _bottomBar(AsmaUlHusnaModel current) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(26, 2, 26, 18),
      child: Row(
        children: [
          _navControl(
            icon: Icons.chevron_left_rounded,
            label: 'Previous',
            enabled: _currentIndex > 0,
            onTap: _goPrevious,
          ),
          Expanded(
            child: Column(
              children: [
                Text(
                  '${current.number} of 99',
                  style: const TextStyle(
                    color: Colors.white54,
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 3),
                const Text(
                  'Swipe  ← previous   •   next →',
                  style: TextStyle(
                    color: Colors.white24,
                    fontSize: 9,
                    letterSpacing: .2,
                  ),
                ),
              ],
            ),
          ),
          _navControl(
            icon: Icons.chevron_right_rounded,
            label: 'Next',
            enabled: _currentIndex < asmaUlHusna.length - 1,
            onTap: _goNext,
            alignRight: true,
          ),
        ],
      ),
    );
  }

  Widget _navControl({
    required IconData icon,
    required String label,
    required bool enabled,
    required VoidCallback onTap,
    bool alignRight = false,
  }) {
    final color = enabled ? Colors.white70 : Colors.white12;

    return SizedBox(
      width: 78,
      child: InkWell(
        onTap: enabled ? onTap : null,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 7),
          child: Column(
            children: [
              Icon(icon, color: color, size: 25),
              Text(
                label,
                textAlign: alignRight ? TextAlign.right : TextAlign.left,
                style: TextStyle(
                  color: enabled ? Colors.white38 : Colors.white10,
                  fontSize: 9,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _OrnamentBackground extends StatelessWidget {
  const _OrnamentBackground();

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _CornerOrnamentPainter(),
    );
  }
}

class _CornerOrnamentPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withValues(alpha: .82)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.15
      ..strokeCap = StrokeCap.round;

    void corner(double x, double y, bool flipX, bool flipY) {
      canvas.save();
      canvas.translate(x, y);
      canvas.scale(flipX ? -1 : 1, flipY ? -1 : 1);

      final path = Path()
        ..moveTo(0, 0)
        ..cubicTo(4, 12, 14, 19, 29, 24)
        ..cubicTo(17, 20, 12, 29, 10, 39)
        ..moveTo(5, 4)
        ..cubicTo(15, 5, 23, 11, 29, 20)
        ..moveTo(12, 10)
        ..cubicTo(18, 13, 22, 18, 25, 25)
        ..moveTo(3, 17)
        ..cubicTo(9, 18, 13, 23, 14, 29);

      canvas.drawPath(path, paint);

      final dots = <Offset>[
        const Offset(4, 7),
        const Offset(10, 3),
        const Offset(17, 7),
        const Offset(23, 13),
      ];
      for (final dot in dots) {
        canvas.drawCircle(dot, 1.2, paint..style = PaintingStyle.fill);
      }
      paint.style = PaintingStyle.stroke;
      canvas.restore();
    }

    corner(18, 20, false, false);
    corner(size.width - 18, 20, true, false);
    corner(18, size.height - 20, false, true);
    corner(size.width - 18, size.height - 20, true, true);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
