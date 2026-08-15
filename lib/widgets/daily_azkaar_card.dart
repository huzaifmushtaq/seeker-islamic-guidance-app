import 'package:flutter/material.dart';

import '../../models/azkar_model.dart';
import '../../services/azkar_service.dart';
import '../../services/azkar_progress_service.dart';

class DailyAzkaarCard extends StatefulWidget {
  const DailyAzkaarCard({super.key});

  @override
  State<DailyAzkaarCard> createState() => _DailyAzkaarCardState();
}

class _DailyAzkaarCardState extends State<DailyAzkaarCard> {
  final AzkarService _azkarService = AzkarService();
  final AzkarProgressService _progressService = AzkarProgressService();
  AzkarModel? currentAzkar;

  bool isLoading = true;
  int currentCount = 0;
  bool _showFullAzkar = false;
  @override
  void initState() {
    super.initState();
    _loadTodayAzkar();
  }

  Future<void> _loadTodayAzkar() async {
    try {
      // 1. Get today's Azkar
      final azkar = await _azkarService.getTodayAzkar();

      if (!mounted) return;

      if (azkar == null) {
        setState(() {
          isLoading = false;
        });
        return;
      }

      // 2. Check whether today's progress was already saved
      final savedProgress = await _progressService.loadProgress();

      int savedCount = 0;

      if (savedProgress != null && savedProgress['azkarId'] == azkar.id) {
        savedCount = savedProgress['count'] ?? 0;
      }

      // 3. Restore today's state
      setState(() {
        currentAzkar = azkar;
        currentCount = savedCount;
        isLoading = false;
        _showFullAzkar = false;
      });
    } catch (e) {
      debugPrint('Today Azkar loading error: $e');

      if (!mounted) return;

      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> _continueAzkar() async {
    if (currentAzkar == null) return;

    if (currentCount >= currentAzkar!.targetCount) {
      return;
    }

    final newCount = currentCount + 1;

    setState(() {
      currentCount = newCount;
    });

    await _progressService.saveProgress(
      azkarId: currentAzkar!.id,
      count: newCount,
    );
  }

  @override
Widget build(BuildContext context) {
  final bool completed =
      currentAzkar != null &&
      currentCount >= currentAzkar!.targetCount;

  final int remaining = currentAzkar == null
      ? 0
      : (currentAzkar!.targetCount - currentCount)
          .clamp(0, currentAzkar!.targetCount);

  final double progress = currentAzkar == null ||
          currentAzkar!.targetCount == 0
      ? 0
      : currentCount / currentAzkar!.targetCount;

  return AnimatedContainer(
    duration: const Duration(milliseconds: 250),
    margin: const EdgeInsets.symmetric(horizontal: 20),
    padding: const EdgeInsets.fromLTRB(16, 14, 16, 13),
    decoration: BoxDecoration(
      borderRadius: BorderRadius.circular(22),
      gradient: const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          Color(0xffF6EFD9),
          Color(0xffF2E4BE),
        ],
      ),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withValues(alpha: .05),
          blurRadius: 16,
          offset: const Offset(0, 7),
        ),
      ],
    ),
    child: completed
        ? _completedView()
        : _activeView(
            remaining: remaining,
            progress: progress,
          ),
  );
}
Widget _activeView({
  required int remaining,
  required double progress,
}) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [

      /// HEADER
      Row(
        children: [

          Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(
              color: const Color(0xff0E5A56)
                  .withValues(alpha: .10),
              borderRadius: BorderRadius.circular(11),
            ),
            child: const Icon(
              Icons.self_improvement_rounded,
              color: Color(0xff0E5A56),
              size: 19,
            ),
          ),

          const SizedBox(width: 10),

          const Expanded(
            child: Text(
              "DAILY DHIKR",
              style: TextStyle(
                color: Color(0xff0E5A56),
                fontSize: 12,
                fontWeight: FontWeight.w800,
                letterSpacing: 1,
              ),
            ),
          ),

          Text(
           isLoading || currentAzkar == null
    ? "-- / --"
    : "$currentCount / ${currentAzkar!.targetCount}",
            style: const TextStyle(
              color: Color(0xff0E5A56),
              fontSize: 13,
              fontWeight: FontWeight.w800,
            ),
          ),

       
        
        ],
      ),

      const SizedBox(height: 10),

      /// ARABIC
      LayoutBuilder(
        builder: (context, constraints) {
          final arabic = currentAzkar?.arabic ?? "";

          final textPainter = TextPainter(
            text: TextSpan(
              text: arabic,
              style: const TextStyle(
                fontSize: 21,
                fontWeight: FontWeight.bold,
                height: 1.5,
              ),
            ),
            textDirection: TextDirection.rtl,
            maxLines: 2,
          );

          textPainter.layout(
            maxWidth: constraints.maxWidth,
          );

          final isLong = textPainter.didExceedMaxLines;

          return Column(
            children: [

              Text(
                isLoading ? "Loading..." : arabic,
                textAlign: TextAlign.center,
                maxLines: _showFullAzkar ? null : 2,
                overflow: _showFullAzkar
                    ? TextOverflow.visible
                    : TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 21,
                  fontWeight: FontWeight.bold,
                  height: 1.5,
                ),
              ),

              if (isLong) ...[
                const SizedBox(height: 3),

                GestureDetector(
                  onTap: () {
                    setState(() {
                      _showFullAzkar =
                          !_showFullAzkar;
                    });
                  },
                  child: Text(
                    _showFullAzkar
                        ? "Hide ↑"
                        : "See full Azkar ↓",
                    style: const TextStyle(
                      color: Color(0xff0E5A56),
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ],
          );
        },
      ),

      const SizedBox(height: 10),

      /// PROGRESS + ACTION
      Row(
        children: [

          Expanded(
            child: ClipRRect(
              borderRadius:
                  BorderRadius.circular(10),
              child: LinearProgressIndicator(
                value: progress,
                minHeight: 5,
                backgroundColor: Colors.white,
                valueColor:
                    const AlwaysStoppedAnimation(
                  Color(0xff0E5A56),
                ),
              ),
            ),
          ),

          const SizedBox(width: 10),

          GestureDetector(
            onTap: isLoading ||
                    currentAzkar == null ||
                    currentCount >=
                        currentAzkar!.targetCount
                ? null
                : _continueAzkar,
            child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 7,
              ),
              decoration: BoxDecoration(
                color: const Color(0xff0E5A56),
                borderRadius:
                    BorderRadius.circular(15),
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [

                  Text(
                    "Continue",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                    ),
                  ),

                  SizedBox(width: 4),

                  Icon(
                    Icons.arrow_forward_rounded,
                    color: Colors.white,
                    size: 14,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    ],
  );
}
Widget _completedView() {
  return Row(
    children: [

      Container(
        width: 34,
        height: 34,
        decoration: BoxDecoration(
          color: const Color(0xff0E5A56)
              .withValues(alpha: .10),
          shape: BoxShape.circle,
        ),
        child: const Icon(
          Icons.check_rounded,
          color: Color(0xff0E5A56),
          size: 20,
        ),
      ),

      const SizedBox(width: 10),

      const Expanded(
        child: Column(
          crossAxisAlignment:
              CrossAxisAlignment.start,
          children: [

            Text(
              "DAILY DHIKR",
              style: TextStyle(
                color: Color(0xff0E5A56),
                fontSize: 11,
                fontWeight: FontWeight.w800,
                letterSpacing: 1,
              ),
            ),

            SizedBox(height: 2),

            Text(
              "Today's dhikr completed",
              style: TextStyle(
                color: Colors.black54,
                fontSize: 11,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),

      const Icon(
        Icons.check_circle_rounded,
        color: Color(0xff0E5A56),
        size: 20,
      ),
    ],
  );
}
}
