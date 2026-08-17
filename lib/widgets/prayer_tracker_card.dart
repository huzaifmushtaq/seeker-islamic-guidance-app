import 'package:flutter/material.dart';
import '../../models/prayer_tracker_model.dart';

class PrayerTrackerCard extends StatefulWidget {
  const PrayerTrackerCard({super.key});

  @override
  State<PrayerTrackerCard> createState() =>
      _PrayerTrackerCardState();
}

class _PrayerTrackerCardState
    extends State<PrayerTrackerCard> {
  final tracker = PrayerTrackerModel();

  int? expandedPrayer;

  // ─────────────────────────────────────────────
  // TODAY'S DUAS
  // ─────────────────────────────────────────────

  final List<String> fajrDuas = [
    'O Allah, bless this morning and guide me toward what pleases You.',
    'O Allah, fill my heart with Your remembrance and my day with goodness.',
    'O Allah, make this day better than yesterday and keep me close to You.',
    'O Allah, guide my steps today and protect my heart from what displeases You.',
  ];

  final List<String> dhuhrDuas = [
    'O Allah, place barakah in my work and keep my heart mindful of You.',
    'O Allah, help me remember You throughout the rest of this day.',
    'O Allah, grant me sincerity in what I do and goodness in what I seek.',
    'O Allah, strengthen me to finish this day with patience and gratitude.',
  ];

  final List<String> asrDuas = [
    'O Allah, help me remain patient and grateful through the rest of my day.',
    'O Allah, forgive my shortcomings and guide me toward what is right.',
    'O Allah, keep my heart firm upon Your remembrance until this day ends.',
    'O Allah, protect me from wasting the remaining moments of this day.',
  ];

  final List<String> maghribDuas = [
    'O Allah, forgive my shortcomings and fill my evening with Your remembrance.',
    'O Allah, accept the good I did today and forgive what I did wrong.',
    'O Allah, place peace in my heart and blessings in my evening.',
    'O Allah, let this evening bring me closer to You.',
  ];

  final List<String> ishaDuas = [
    'O Allah, forgive me, accept my day, and grant me peaceful rest.',
    'O Allah, forgive what I did wrong today and accept what I did for Your sake.',
    'O Allah, purify my heart before I sleep and bring me closer to You.',
    'O Allah, let me sleep with Your remembrance and wake with gratitude.',
  ];

  // ─────────────────────────────────────────────
  // TODAY INDEX
  // ─────────────────────────────────────────────

  int _todayIndex(int length) {
    final now = DateTime.now();

    final startOfYear =
        DateTime(now.year, 1, 1);

    final difference =
        now.difference(startOfYear).inDays;

    return difference % length;
  }

  String _getDua(int prayerIndex) {
    switch (prayerIndex) {
      case 0:
        return fajrDuas[
            _todayIndex(fajrDuas.length)];

      case 1:
        return dhuhrDuas[
            _todayIndex(dhuhrDuas.length)];

      case 2:
        return asrDuas[
            _todayIndex(asrDuas.length)];

      case 3:
        return maghribDuas[
            _todayIndex(maghribDuas.length)];

      case 4:
        return ishaDuas[
            _todayIndex(ishaDuas.length)];

      default:
        return '';
    }
  }

  String _getPrayerName(int index) {
    switch (index) {
      case 0:
        return 'FAJR';

      case 1:
        return 'DHUHR';

      case 2:
        return 'ASR';

      case 3:
        return 'MAGHRIB';

      case 4:
        return 'ISHA';

      default:
        return '';
    }
  }

  // ─────────────────────────────────────────────
  // PRAYER TAP
  // ─────────────────────────────────────────────

  void _handlePrayerTap(int index) {
    setState(() {
      // Existing prayer completion behavior
      switch (index) {
        case 0:
          tracker.fajr = !tracker.fajr;
          break;

        case 1:
          tracker.dhuhr = !tracker.dhuhr;
          break;

        case 2:
          tracker.asr = !tracker.asr;
          break;

        case 3:
          tracker.maghrib = !tracker.maghrib;
          break;

        case 4:
          tracker.isha = !tracker.isha;
          break;
      }

      // Expand / collapse the OUTER container
      if (expandedPrayer == index) {
        expandedPrayer = null;
      } else {
        expandedPrayer = index;
      }
    });
  }

  // ─────────────────────────────────────────────
  // BUILD
  // ─────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration:
          const Duration(milliseconds: 280),

      curve: Curves.easeOutCubic,

      margin:
          const EdgeInsets.symmetric(
        horizontal: 20,
      ),

      padding:
          const EdgeInsets.fromLTRB(
        18,
        10,
        18,
        14,
      ),

      decoration: BoxDecoration(
        color:
            const Color(0xffFFFDF8),

        borderRadius:
            BorderRadius.circular(28),

        boxShadow: [
          BoxShadow(
            color:
                Colors.black.withValues(
              alpha: .05,
            ),
            blurRadius: 20,
            offset:
                const Offset(0, 10),
          ),
        ],
      ),

      child: Column(
        children: [
          // ─────────────────────────────────────
          // FIVE PRAYER TILES
          // ─────────────────────────────────────

          Row(
            mainAxisAlignment:
                MainAxisAlignment.center,

            crossAxisAlignment:
                CrossAxisAlignment.start,

            children: [
              _PrayerTile(
                emoji: "🌅",
                title: "Fajr",
                checked: tracker.fajr,
                onTap:
                    () => _handlePrayerTap(0),
              ),

              const SizedBox(width: 11.5),

              _PrayerTile(
                emoji: "☀️",
                title: "Dhuhr",
                checked: tracker.dhuhr,
                onTap:
                    () => _handlePrayerTap(1),
              ),

              const SizedBox(width: 11.5),

              _PrayerTile(
                emoji: "🌤️",
                title: "Asr",
                checked: tracker.asr,
                onTap:
                    () => _handlePrayerTap(2),
              ),

              const SizedBox(width: 11.5),

              _PrayerTile(
                emoji: "🌇",
                title: "Maghrib",
                checked: tracker.maghrib,
                onTap:
                    () => _handlePrayerTap(3),
              ),

              const SizedBox(width: 11.5),

              _PrayerTile(
                emoji: "🌙",
                title: "Isha",
                checked: tracker.isha,
                onTap:
                    () => _handlePrayerTap(4),
              ),
            ],
          ),

          // ─────────────────────────────────────
          // EXPANDED DUA AREA
          // ─────────────────────────────────────

          AnimatedSize(
            duration:
                const Duration(milliseconds: 280),

            curve:
                Curves.easeOutCubic,

            child: expandedPrayer == null
                ? const SizedBox.shrink()
                : Padding(
                    padding:
                        const EdgeInsets.only(
                      top: 14,
                      bottom: 2,
                    ),

                    child: Column(
                      crossAxisAlignment:
                          CrossAxisAlignment.start,

                      children: [
                        Text(
                          "TODAY'S DUA AFTER NIMAZ E ${_getPrayerName(expandedPrayer!)} ",
                          style:
                              const TextStyle(
                            color:
                                Color(0xff0E5A56),
                            fontSize: 9,
                            fontWeight:
                                FontWeight.w800,
                            letterSpacing:
                                .8,
                          ),
                        ),

                        const SizedBox(height: 5),

                        Text(
                          _getDua(
                            expandedPrayer!,
                          ),
                          maxLines: 2,
                          overflow:
                              TextOverflow.ellipsis,
                          style:
                              const TextStyle(
                            color:
                                Colors.black54,
                            fontSize: 11,
                            fontWeight:
                                FontWeight.w500,
                            height: 1.4,
                          ),
                        ),
                      ],
                    ),
                  ),
          ),

          const SizedBox(height: 12),

          // ─────────────────────────────────────
          // COMPLETION MESSAGE
          // ─────────────────────────────────────

          Text(
            tracker.completedCount == 5
                ? "🌙 May Allah accept your prayers."
                : "You made ${tracker.completedCount} connections out of 5 ",
            style: const TextStyle(
              color:
                  Colors.black54,
              fontWeight:
                  FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════
// PRAYER TILE
// ═══════════════════════════════════════════════

class _PrayerTile extends StatelessWidget {
  final String emoji;
  final String title;
  final bool checked;
  final VoidCallback onTap;

  const _PrayerTile({
    required this.emoji,
    required this.title,
    required this.checked,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius:
          BorderRadius.circular(16),

      onTap: onTap,

      child: AnimatedContainer(
        duration:
            const Duration(milliseconds: 220),

        width: 54,

        padding:
            const EdgeInsets.symmetric(
          vertical: 10,
        ),

        decoration: BoxDecoration(
          color: checked
              ? const Color.fromARGB(
                  255,
                  20,
                  83,
                  83,
                )
              : const Color.fromARGB(
                  255,
                  240,
                  237,
                  233,
                ),

          borderRadius:
              BorderRadius.circular(16),
        ),

        child: Column(
          children: [
            Text(
              emoji,
              style:
                  const TextStyle(
                fontSize: 18,
              ),
            ),

            const SizedBox(height: 10),

            Text(
              title,
              style: TextStyle(
                fontSize: 10,
                fontWeight:
                    FontWeight.w600,
                color: checked
                    ? Colors.white
                    : Colors.black87,
              ),
            ),
          ],
        ),
      ),
    );
  }
}