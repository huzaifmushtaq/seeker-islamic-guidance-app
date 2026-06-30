import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../models/prayer_model.dart';
import 'dart:async';
import 'package:hijri/hijri_calendar.dart';

class PrayerTimesScreen extends StatefulWidget {
  final PrayerModel prayerModel;
  final String city;

  const PrayerTimesScreen({
    super.key,
    required this.prayerModel,
    required this.city,
  });

  @override
  State<PrayerTimesScreen> createState() => _PrayerTimesScreenState();
}

class _PrayerTimesScreenState extends State<PrayerTimesScreen> {
  Timer? _timer;

  @override
  void initState() {
    super.initState();

    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) {
        setState(() {});
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  String formatTime(BuildContext context, DateTime time) {
    return TimeOfDay.fromDateTime(time).format(context);
  }

  static const int ishraqOffsetMinutes = 20;
  DateTime getIshraqTime() {
    return widget.prayerModel.sunrise.add(
      const Duration(minutes: ishraqOffsetMinutes),
    );
  }

  String? prayerError;
  String getHijriDate() {
    HijriCalendar.setLocal("en");

    final hijri = HijriCalendar.now();

    return "${hijri.hDay} ${hijri.longMonthName} ${hijri.hYear} AH";
  }

  String formatDuration(Duration duration) {
    final hours = duration.inHours;
    final minutes = duration.inMinutes.remainder(60);
    final seconds = duration.inSeconds.remainder(60);

    return "${hours.toString().padLeft(2, '0')}:"
        "${minutes.toString().padLeft(2, '0')}:"
        "${seconds.toString().padLeft(2, '0')}";
  }

  @override
  Widget build(BuildContext context) {
    final date = DateFormat("EEEE, d MMMM yyyy").format(DateTime.now());

    return Scaffold(
      backgroundColor: const Color(0xFFF7F8FA),

      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              /// HEADER
              Container(
                width: double.infinity,

                padding: const EdgeInsets.fromLTRB(20, 18, 20, 30),

                decoration: const BoxDecoration(
                  color: Color(0xFF0B4B4B),

                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(35),
                    bottomRight: Radius.circular(35),
                  ),
                ),

                child: Column(
                  children: [
                    Row(
                      children: [
                        InkWell(
                          borderRadius: BorderRadius.circular(30),

                          onTap: () {
                            Navigator.pop(context);
                          },

                          child: const Padding(
                            padding: EdgeInsets.all(8),

                            child: Icon(
                              Icons.arrow_back_ios_new,
                              color: Colors.white,
                            ),
                          ),
                        ),

                        const Spacer(),

                        const Text(
                          "Prayer Times",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),

                        const Spacer(),

                        const SizedBox(width: 40),
                      ],
                    ),

                    const SizedBox(height: 22),

                    Text(
                      date,
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 15,
                      ),
                    ),
                    const SizedBox(height: 4),

                    Text(
                      getHijriDate(),
                      style: const TextStyle(
                        color: Color(0xFFF5C76B),
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 35),

                    Row(
                      children: [
                        Expanded(
                          child: Container(
                            padding: const EdgeInsets.all(18),

                            decoration: BoxDecoration(
                              color: const Color(0xFFF5C76B),

                              borderRadius: BorderRadius.circular(22),
                            ),

                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,

                              children: [
                                Text(
                                  widget.prayerModel.currentPrayer == "morning"
                                      ? "Current Status"
                                      : "Current Prayer",
                                  style: const TextStyle(
                                    color: Colors.black54,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),

                                const SizedBox(height: 12),

                                Text(
                                  widget.prayerModel.currentPrayer == "morning"
                                      ? "Morning"
                                      : widget.prayerModel.currentPrayer[0]
                                                .toUpperCase() +
                                            widget.prayerModel.currentPrayer
                                                .substring(1),

                                  style: const TextStyle(
                                    fontSize: 26,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),

                                const SizedBox(height: 10),

                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      widget.prayerModel.currentPrayer ==
                                              "morning"
                                          ? "Next Prayer"
                                          : "Ends At",
                                      style: const TextStyle(
                                        fontSize: 13,
                                        color: Colors.black54,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),

                                    const SizedBox(height: 4),

                                    Text(
                                      widget.prayerModel.currentPrayer ==
                                              "morning"
                                          ? formatTime(
                                              context,
                                              widget.prayerModel.nextPrayerTime,
                                            )
                                          : formatTime(
                                              context,
                                              widget.prayerModel.nextPrayerTime,
                                            ),
                                      style: const TextStyle(
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),

                        Expanded(
                          child: Container(
                            margin: const EdgeInsets.only(left: 14),
                            padding: const EdgeInsets.all(18),

                            decoration: BoxDecoration(
                              color: const Color.fromARGB(255, 208, 79, 167),
                              borderRadius: BorderRadius.circular(22),
                            ),

                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,

                              children: [
                                const Text(
                                  "Next Prayer",
                                  style: TextStyle(
                                    color: Colors.grey,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),

                                const SizedBox(height: 12),

                                Text(
                                  widget.prayerModel.nextPrayer[0]
                                          .toUpperCase() +
                                      widget.prayerModel.nextPrayer.substring(
                                        1,
                                      ),

                                  style: const TextStyle(
                                    fontSize: 26,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),

                                const SizedBox(height: 10),

                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text(
                                      "Starts At",
                                      style: TextStyle(
                                        color: Color.fromARGB(255, 31, 30, 30),
                                        fontSize: 13,
                                      ),
                                    ),

                                    const SizedBox(height: 4),

                                    Text(
                                      formatTime(
                                        context,
                                        widget.prayerModel.nextPrayerTime,
                                      ),
                                      style: const TextStyle(
                                        color: Color(0xFF0B4B4B),
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 22),

                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 18,
                        vertical: 14,
                      ),

                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: .15),
                        borderRadius: BorderRadius.circular(18),
                      ),

                      child: Row(
                        children: [
                          const Icon(
                            Icons.location_on,
                            color: Color(0xFFF5C76B),
                          ),

                          const SizedBox(width: 10),

                          const Expanded(
                            child: Text(
                              "Current Location",
                              style: TextStyle(
                                color: Colors.white70,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),

                          Text(
                            widget.city,
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 22),

                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 18),

                      child: Container(
                        decoration: BoxDecoration(
                          color: const Color.fromARGB(255, 5, 161, 133),
                          borderRadius: BorderRadius.circular(24),

                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: .05),
                              blurRadius: 14,
                              offset: const Offset(0, 6),
                            ),
                          ],
                        ),

                        child: Column(
                          children: [
                            const SizedBox(height: 12),

                            PrayerRow(
                              icon: Icons.nightlight_round,
                              title: "Fajr",
                              time: formatTime(
                                context,
                                widget.prayerModel.fajr,
                              ),
                              isCurrent:
                                  widget.prayerModel.currentPrayer == "fajr",
                            ),

                            PrayerRow(
                              icon: Icons.wb_sunny_outlined,
                              title: "Sunrise",
                              time: formatTime(
                                context,
                                widget.prayerModel.sunrise,
                              ),
                            ),

                            PrayerRow(
                              icon: Icons.wb_sunny,
                              title: "Ishraq",
                              time: formatTime(context, getIshraqTime()),
                            ),

                            PrayerRow(
                              icon: Icons.mosque,
                              title: "Dhuhr",
                              time: formatTime(
                                context,
                                widget.prayerModel.dhuhr,
                              ),
                              isCurrent:
                                  widget.prayerModel.currentPrayer == "dhuhr",
                            ),

                            PrayerRow(
                              icon: Icons.cloud_outlined,
                              title: "Asr",
                              time: formatTime(context, widget.prayerModel.asr),
                              isCurrent:
                                  widget.prayerModel.currentPrayer == "asr",
                            ),

                            PrayerRow(
                              icon: Icons.wb_twilight,
                              title: "Maghrib",
                              time: formatTime(
                                context,
                                widget.prayerModel.maghrib,
                              ),
                              isCurrent:
                                  widget.prayerModel.currentPrayer == "maghrib",
                            ),

                            PrayerRow(
                              icon: Icons.dark_mode_outlined,
                              title: "Isha",
                              time: formatTime(
                                context,
                                widget.prayerModel.isha,
                              ),
                              isCurrent:
                                  widget.prayerModel.currentPrayer == "isha",
                            ),

                            const SizedBox(height: 10),
                          ],
                        ),
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
}

class PrayerRow extends StatelessWidget {
  final IconData icon;
  final String title;
  final String time;
  final bool isCurrent;

  const PrayerRow({
    super.key,
    required this.icon,
    required this.title,
    required this.time,
    this.isCurrent = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),

      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: Colors.grey.shade200)),
      ),

      child: Row(
        children: [
          Icon(
            icon,
            color: isCurrent
                ? const Color(0xFFF5B940)
                : const Color(0xFF0B4B4B),
            size: 24,
          ),

          const SizedBox(width: 14),

          Expanded(
            child: Text(
              title,
              style: TextStyle(
                fontSize: 17,
                fontWeight: isCurrent ? FontWeight.bold : FontWeight.w500,
                color: isCurrent
                    ? const Color.fromARGB(255, 238, 203, 64)
                    : Colors.black87,
              ),
            ),
          ),

          if (isCurrent)
            Container(
              margin: const EdgeInsets.only(right: 10),

              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),

              decoration: BoxDecoration(
                color: const Color(0xFFF5B940),
                borderRadius: BorderRadius.circular(20),
              ),

              child: const Text(
                "NOW",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),

          Text(
            time,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: isCurrent ? const Color(0xFFF5B940) : Colors.black87,
            ),
          ),
        ],
      ),
    );
  }
}
