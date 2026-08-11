import 'package:flutter/material.dart';
import '../../models/prayer_tracker_model.dart';

class PrayerTrackerCard extends StatefulWidget {
  const PrayerTrackerCard({super.key});

  @override
  State<PrayerTrackerCard> createState() => _PrayerTrackerCardState();
}

class _PrayerTrackerCardState extends State<PrayerTrackerCard> {
  final tracker = PrayerTrackerModel();
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.fromLTRB(18, 10, 18, 14),
      decoration: BoxDecoration(
        color: const Color(0xffFFFDF8),
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: .05),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _PrayerTile(
                emoji: "🌅",
                title: "Fajr",
                checked: tracker.fajr,
                onTap: () => setState(() {
                  tracker.fajr = !tracker.fajr;
                }),
              ),

              const SizedBox(width: 11.5),

              _PrayerTile(
                emoji: "☀️",
                title: "Dhuhr",
                checked: tracker.dhuhr,
                onTap: () => setState(() {
                  tracker.dhuhr = !tracker.dhuhr;
                }),
              ),

              const SizedBox(width: 11.5),

              _PrayerTile(
                emoji: "🌤️",
                title: "Asr",
                checked: tracker.asr,
                onTap: () => setState(() {
                  tracker.asr = !tracker.asr;
                }),
              ),

              const SizedBox(width: 11.5),

              _PrayerTile(
                emoji: "🌇",
                title: "Maghrib",
                checked: tracker.maghrib,
                onTap: () => setState(() {
                  tracker.maghrib = !tracker.maghrib;
                }),
              ),

              const SizedBox(width: 11.5),

              _PrayerTile(
                emoji: "🌙",
                title: "Isha",
                checked: tracker.isha,
                onTap: () => setState(() {
                  tracker.isha = !tracker.isha;
                }),
              ),
            ],
          ),

          const SizedBox(height: 16),

          Text(
            tracker.completedCount == 5
                ? "🌙 May Allah accept your prayers."
                : "You made ${tracker.completedCount} connections out of 5 ",
            style: const TextStyle(
              color: Colors.black54,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

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
      borderRadius: BorderRadius.circular(16),
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 220),
        width: 54,
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: checked
              ? const Color.fromARGB(255, 20, 83, 83)
              : const Color.fromARGB(255, 240, 237, 233),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          children: [
            Text(emoji, style: const TextStyle(fontSize: 18)),

            const SizedBox(height: 10),

            Text(
              title,
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w600,
                color: checked ? Colors.white : Colors.black87,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
