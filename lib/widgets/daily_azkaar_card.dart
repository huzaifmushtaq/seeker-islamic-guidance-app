import 'package:flutter/material.dart';

import '../../models/azkar_model.dart';
import '../../services/azkar_service.dart';
import '../../services/azkar_progress_service.dart';
class DailyAzkaarCard extends StatefulWidget {
  const DailyAzkaarCard({super.key});

  @override
  State<DailyAzkaarCard> createState() =>
      _DailyAzkaarCardState();
}

class _DailyAzkaarCardState extends State<DailyAzkaarCard> {
  final AzkarService _azkarService = AzkarService();
final AzkarProgressService _progressService =
    AzkarProgressService();
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
    final azkar =
        await _azkarService.getTodayAzkar();

    if (!mounted) return;

    if (azkar == null) {
      setState(() {
        isLoading = false;
      });
      return;
    }

    // 2. Check whether today's progress was already saved
    final savedProgress =
        await _progressService.loadProgress();

    int savedCount = 0;

    if (savedProgress != null &&
        savedProgress['azkarId'] == azkar.id) {
      savedCount =
          savedProgress['count'] ?? 0;
    }

    // 3. Restore today's state
    setState(() {
      currentAzkar = azkar;
      currentCount = savedCount;
      isLoading = false;
      _showFullAzkar = false;
    });
  } catch (e) {
    debugPrint(
      'Today Azkar loading error: $e',
    );

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
    return Container(
      margin: const EdgeInsets.symmetric(
        horizontal: 20,
      ),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(28),
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
            color: Colors.black.withOpacity(.06),
            blurRadius: 22,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [

          /// HEADER
          Row(
            children: [

              Container(
                height: 68,
                width: 46,
                decoration: BoxDecoration(
                  color: const Color(0xff0E5A56)
                      .withOpacity(.12),
                  borderRadius:
                      BorderRadius.circular(15),
                ),
                child: const Icon(
                  Icons.self_improvement_rounded,
                  color: Color(0xff0E5A56),
                ),
              ),

              const SizedBox(width: 14),

              const Expanded(
                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.start,
                  children: [

                    Text(
                      "Daily Azkaar",
                      style: TextStyle(
                        fontSize: 19,
                        fontWeight: FontWeight.w700,
                      ),
                    ),

                    SizedBox(height: 2),

                    Text(
                      "Continue today's remembrance",
                      style: TextStyle(
                        color: Colors.black54,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),

              if (!isLoading && currentAzkar != null)
                Container(
                  padding:
                      const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius:
                        BorderRadius.circular(18),
                  ),
                  child:Text(
  currentAzkar == null
      ? ""
      : "${(currentAzkar!.targetCount - currentCount).clamp(
          0,
          currentAzkar!.targetCount,
        )} Left",
  style: const TextStyle(
    color: Color(0xff0E5A56),
    fontWeight: FontWeight.bold,
    fontSize: 12,
  ),
),
                ),
            ],
          ),

          const SizedBox(height: 18),

          /// ARABIC
         LayoutBuilder(
  builder: (context, constraints) {
    final arabic = currentAzkar?.arabic ?? "";

    final textPainter = TextPainter(
      text: TextSpan(
        text: arabic,
        style: const TextStyle(
          fontSize: 26,
          fontWeight: FontWeight.bold,
          height: 1.7,
        ),
      ),
      textDirection: TextDirection.rtl,
      maxLines: 5,
    );

    textPainter.layout(
      maxWidth: constraints.maxWidth,
    );

    final isLong =
        textPainter.didExceedMaxLines;

    return Column(
      children: [

        Text(
          isLoading
              ? "Loading..."
              : arabic,
          textAlign: TextAlign.center,
          maxLines: _showFullAzkar ? null : 5,
          overflow: _showFullAzkar
              ? TextOverflow.visible
              : TextOverflow.ellipsis,
          style: const TextStyle(
            fontSize: 26,
            fontWeight: FontWeight.bold,
            height: 1.7,
          ),
        ),

        if (isLong) ...[
          const SizedBox(height: 6),

          GestureDetector(
            onTap: () {
              setState(() {
                _showFullAzkar =
                    !_showFullAzkar;
              });
            },
            child: Text(
              _showFullAzkar
                  ? "Hide Azkar ↑"
                  : "See full Azkar ↓",
              style: const TextStyle(
                color: Color(0xff0E5A56),
                fontSize: 13,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ],
    );
  },
),

          const SizedBox(height: 18),

          /// V1 PLACEHOLDER PROGRESS
          Row(
            children: [

              Expanded(
                child: ClipRRect(
                  borderRadius:
                      BorderRadius.circular(20),
                  child:
                       LinearProgressIndicator(
                    value: currentAzkar == null ||
        currentAzkar!.targetCount == 0
    ? 0
    : currentCount /
        currentAzkar!.targetCount,
                    minHeight: 8,
                    backgroundColor:
                        Colors.white,
                    valueColor:
                        AlwaysStoppedAnimation(
                      Color(0xff0E5A56),
                    ),
                  ),
                ),
              ),

              const SizedBox(width: 12),

             Text(
  isLoading || currentAzkar == null
      ? ""
      : "$currentCount / ${currentAzkar!.targetCount}",
  style: const TextStyle(
    color: Color(0xff0E5A56),
    fontWeight: FontWeight.bold,
  ),
),
            ],
          ),
if (currentAzkar != null &&
    currentCount >= currentAzkar!.targetCount)
  const Padding(
    padding: EdgeInsets.only(top: 12),
    child: Center(
      child: Text(
        "✓ Today's Dhikr completed",
        style: TextStyle(
          color: Color(0xff0E5A56),
          fontSize: 13,
          fontWeight: FontWeight.w700,
        ),
      ),
    ),
  ),
          const SizedBox(height: 18),

          /// CONTINUE
          SizedBox(
            width: double.infinity,
            height: 46,
            child: ElevatedButton(
              style:
                  ElevatedButton.styleFrom(
                backgroundColor:
                    const Color(0xff0E5A56),
                foregroundColor:
                    Colors.white,
                elevation: 0,
                shape:
                    RoundedRectangleBorder(
                  borderRadius:
                      BorderRadius.circular(16),
                ),
              ),
            onPressed: isLoading ||
        currentAzkar == null ||
        currentCount >= currentAzkar!.targetCount
    ? null
    : _continueAzkar,
              child: Row(
                mainAxisAlignment:
                    MainAxisAlignment.center,
                children: [

                  Text(
                   currentAzkar != null &&
        currentCount >= currentAzkar!.targetCount
    ? "Completed"
    : "Continue",
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight:
                          FontWeight.w600,
                    ),
                  ),

                  SizedBox(width: 6),

                  Icon(
                    Icons.arrow_forward_rounded,
                    size: 18,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}