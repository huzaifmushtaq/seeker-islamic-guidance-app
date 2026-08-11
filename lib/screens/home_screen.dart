import 'package:flutter/material.dart';
import 'package:seeker/widgets/daily_azkaar_card.dart';
import '../widgets/location_permission_dialog.dart';

import '../services/location_service.dart';
import '../services/prayer_service.dart';
import '../models/prayer_model.dart';
import 'dart:async';
import 'prayer_times_screen.dart';
import 'package:hijri/hijri_calendar.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../widgets/prayer_tracker_card.dart';
import '../widgets/prayer_arc.dart';
import '../../models/wisdom_model.dart';
import '../../services/wisdom_service.dart';
import 'dart:typed_data';
import 'package:screenshot/screenshot.dart';
import 'package:share_plus/share_plus.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final LocationService _locationService = LocationService();
  final PrayerService _prayerService = PrayerService();
  final WisdomService _wisdomService = WisdomService();

  WisdomModel? _todayWisdom;
  bool _wisdomLoading = true;

  PrayerModel? prayerModel;
  Timer? _countdownTimer;
  String cityName = "Loading...";
  bool locationUnavailable = false;
  bool isLoadingPrayer = true;
  String? prayerError;

  String getHijriDate() {
    HijriCalendar.setLocal("en");

    final hijri = HijriCalendar.now();

    return "${hijri.hDay} ${hijri.longMonthName} ${hijri.hYear} AH";
  }

  @override
  void dispose() {
    _countdownTimer?.cancel();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();

    _loadPrayerTimes();
    _checkLocationSetup();
    _loadTodayWisdom();
    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!mounted || prayerModel == null) return;

      final remaining = prayerModel!.nextPrayerTime.difference(DateTime.now());

      setState(() {
        prayerModel = PrayerModel(
          fajr: prayerModel!.fajr,
          sunrise: prayerModel!.sunrise,
          dhuhr: prayerModel!.dhuhr,
          asr: prayerModel!.asr,
          maghrib: prayerModel!.maghrib,
          isha: prayerModel!.isha,

          currentPrayer: prayerModel!.currentPrayer,
          nextPrayer: prayerModel!.nextPrayer,
          nextPrayerTime: prayerModel!.nextPrayerTime,

          remainingDuration: remaining,
        );
      });

      if (remaining.inSeconds <= 0) {
        _loadPrayerTimes();
      }
    });
  }

  Future<void> _loadPrayerTimes() async {
    try {
      // 1. Try saved location first
      final savedLat = await _locationService.getSavedLatitude();
      final savedLng = await _locationService.getSavedLongitude();
      final savedCity = await _locationService.getSavedCity();

      if (savedLat != null && savedLng != null && savedCity != null) {
        final savedPosition = _locationService.getSavedPosition(
          latitude: savedLat,
          longitude: savedLng,
        );

        if (savedPosition != null) {
          final model = _prayerService.getPrayerModel(savedPosition);

          if (mounted) {
            setState(() {
              prayerModel = model;
              cityName = savedCity;
              isLoadingPrayer = false;
            });
          }
        }
      }

      final configured = await _locationService.isLocationConfigured();

      if (!configured) {
        if (prayerModel == null && mounted) {
          setState(() {
            isLoadingPrayer = false;
            locationUnavailable = true;
          });
        }
        return;
      }

      // 2. Refresh silently using live GPS
      final livePosition = await _locationService.getCurrentLocation();
      final liveCity = await _locationService.getCityName(livePosition);

      await _locationService.saveLocation(
        latitude: livePosition.latitude,
        longitude: livePosition.longitude,
        city: liveCity,
      );

      final liveModel = _prayerService.getPrayerModel(livePosition);

      if (!mounted) return;

      setState(() {
        prayerModel = liveModel;
        cityName = liveCity;
        isLoadingPrayer = false;
      });
    } catch (e) {
      // If GPS fails but saved location exists,
      // we simply keep showing the saved prayer times.

      if (prayerModel != null) return;

      if (!mounted) return;

      setState(() {
        prayerError = e.toString();
        isLoadingPrayer = false;
        locationUnavailable = true;
      });
    }
  }

  Future<void> _checkLocationSetup() async {
    final asked = await _locationService.hasAskedLocationPermission();

    if (asked || !mounted) return;

    await Future.delayed(const Duration(milliseconds: 700));

    if (!mounted) return;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => LocationPermissionDialog(
        onLater: () async {
          final navigator = Navigator.of(context);

          await _locationService.setAskedLocationPermission();

          if (!mounted) return;

          navigator.pop();

          setState(() {
            isLoadingPrayer = false;
            locationUnavailable = true;
          });
        },

        onAllow: () async {
          final navigator = Navigator.of(context);

          await _locationService.setAskedLocationPermission();
          try {
            final position = await _locationService.getCurrentLocation();

            final city = await _locationService.getCityName(position);

            await _locationService.saveLocation(
              latitude: position.latitude,
              longitude: position.longitude,
              city: city,
            );

            if (!mounted) return;

            navigator.pop();

            await _loadPrayerTimes();
          } catch (e) {
            if (!mounted) return;

            navigator.pop();

            setState(() {
              isLoadingPrayer = false;
              locationUnavailable = true;
            });

            debugPrint(e.toString());
          }
        },
      ),
    );
  }

  Future<void> _requestLocationAgain() async {
    // Allow the permission flow to run again
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove("asked_location_permission");

    if (!mounted) return;

    setState(() {
      locationUnavailable = false;
      isLoadingPrayer = true;
    });

    await _checkLocationSetup();
  }

  Future<void> _loadTodayWisdom() async {
    try {
      final wisdoms = await _wisdomService.loadWisdoms();

      if (!mounted) return;

      if (wisdoms.isEmpty) {
        setState(() {
          _wisdomLoading = false;
        });
        return;
      }

      final now = DateTime.now();

      final startOfYear = DateTime(now.year, 1, 1);

      final dayOfYear = now.difference(startOfYear).inDays;

      final index = dayOfYear % wisdoms.length;

      setState(() {
        _todayWisdom = wisdoms[index];
        _wisdomLoading = false;
      });
    } catch (e) {
      debugPrint('Wisdom loading error: $e');

      if (!mounted) return;

      setState(() {
        _wisdomLoading = false;
      });
    }
  }

  Future<void> _shareWisdom() async {
    if (_todayWisdom == null) return;

    try {
      final wisdom = _todayWisdom!;
      final bool isQuran = wisdom.type.toLowerCase() == "quran";

      final screenshotController = ScreenshotController();

      final Uint8List image = await screenshotController.captureFromWidget(
        _buildShareImage(wisdom: wisdom, isQuran: isQuran),
        context: context,
        pixelRatio: 2.0,
      );

      final file = XFile.fromData(
        image,
        mimeType: 'image/png',
        name: 'seeker_wisdom.png',
      );

      await Share.shareXFiles([file], text: 'Seeker • Wisdom of the Day');
    } catch (e) {
      debugPrint('Wisdom share error: $e');
    }
  }

  Widget _buildShareImage({
    required WisdomModel wisdom,
    required bool isQuran,
  }) {
    return Material(
      color: Colors.white,
      child: Container(
        width: 360,
        padding: const EdgeInsets.all(28),
        decoration: BoxDecoration(
          color: const Color(0xff0E5A56),
          borderRadius: BorderRadius.circular(28),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            /// HEADER
            Row(
              children: [
                Container(
                  width: 42,
                  height: 42,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: .12),
                    borderRadius: BorderRadius.circular(13),
                  ),
                  child: Icon(
                    isQuran
                        ? Icons.menu_book_rounded
                        : Icons.auto_stories_rounded,
                    color: const Color(0xffE8C76A),
                    size: 21,
                  ),
                ),

                const SizedBox(width: 12),

                Expanded(
                  child: Text(
                    isQuran
                        ? "Quran • Wisdom of the Day"
                        : "Hadith • Wisdom of the Day",
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 28),

            /// WISDOM
            Text(
              wisdom.text,
              textAlign: TextAlign.left,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 21,
                fontWeight: FontWeight.w600,
                height: 1.5,
              ),
            ),

            const SizedBox(height: 22),

            /// DIVIDER
            Container(
              width: 58,
              height: 4,
              decoration: BoxDecoration(
                color: const Color(0xffE8C76A),
                borderRadius: BorderRadius.circular(20),
              ),
            ),

            const SizedBox(height: 14),

            /// REFERENCE
            Text(
              "— ${wisdom.reference}",
              style: const TextStyle(
                color: Color(0xffE8C76A),
                fontSize: 13,
                fontWeight: FontWeight.w700,
              ),
            ),

            const SizedBox(height: 30),

            /// BRAND
            Row(
              children: [
                Container(
                  width: 7,
                  height: 7,
                  decoration: const BoxDecoration(
                    color: Color(0xffE8C76A),
                    shape: BoxShape.circle,
                  ),
                ),

                const SizedBox(width: 8),

                const Text(
                  "Seeker",
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,

      body: SafeArea(
        top: false,
        child: SingleChildScrollView(
          child: Column(
            children: [
              /// TOP PRAYER HEADER
              Container(
                height: 340,
                width: double.infinity,
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [Color(0xff0E5A56), Color(0xff176C66)],
                  ),
                ),

                child: SafeArea(
                  bottom: false,
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(22, 18, 22, 0),

                    child: Stack(
                      children: [
                        /// TOP ROW
                        Positioned(
                          top: 4,
                          left: 22,
                          right: 22,
                          child: Row(
                            children: [
                              const Icon(
                                Icons.location_on_rounded,
                                color: Color.fromARGB(253, 246, 244, 244),
                                size: 18,
                              ),

                              const SizedBox(width: 5),

                              Expanded(
                                child: Text(
                                  locationUnavailable
                                      ? "Location unavailable"
                                      : cityName,
                                  style: const TextStyle(
                                    color: Color.fromARGB(248, 236, 237, 239),
                                    fontWeight: FontWeight.w600,
                                    fontSize: 12,
                                  ),
                                ),
                              ),

                              Text(
                                getHijriDate(),
                                style: const TextStyle(
                                  color: Color.fromARGB(235, 248, 249, 247),
                                  fontSize: 15,
                                  fontWeight: FontWeight.w300,
                                ),
                              ),
                            ],
                          ),
                        ),

                        /// CENTER PRAYER
                        Positioned(
                          top: locationUnavailable ? 92 : 76,
                          left: 0,
                          right: 0,
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              /// NORMAL PRAYER STATE
                              if (!locationUnavailable) ...[
                                PrayerArc(
                                  progress: prayerModel?.prayerProgress ?? 0,
                                ),

                                Transform.translate(
                                  offset: const Offset(0, -35),
                                  child: Text(
                                    prayerModel == null
                                        ? "--"
                                        : "${prayerModel!.currentPrayer[0].toUpperCase()}${prayerModel!.currentPrayer.substring(1)}",
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 30,
                                      fontWeight: FontWeight.bold,
                                      height: 1,
                                    ),
                                  ),
                                ),
                              ],

                              /// LOCATION UNAVAILABLE
                              if (locationUnavailable) ...[
                                const Text(
                                  "Prayer Times Unavailable",
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                    height: 1.1,
                                  ),
                                ),

                                const SizedBox(height: 12),

                                const Text(
                                  "Enable location to get accurate prayer times.",
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    color: Colors.white70,
                                    fontSize: 13,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),

                                const SizedBox(height: 14),

                                GestureDetector(
                                  onTap: _requestLocationAgain,
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 16,
                                      vertical: 8,
                                    ),
                                    decoration: BoxDecoration(
                                      color: const Color(0xffE8C76A),
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    child: const Text(
                                      "Enable Location",
                                      style: TextStyle(
                                        color: Color(0xff0E5A56),
                                        fontSize: 12,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),

                        /// BOTTOM ACTION BAR
                        Positioned(
                          left: 24,
                          right: 24,
                          bottom: 35,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 14,
                              vertical: 0,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: .12),
                              borderRadius: BorderRadius.circular(18),
                              border: Border.all(
                                color: const Color.fromARGB(
                                  255,
                                  162,
                                  131,
                                  131,
                                ).withValues(alpha: .12),
                              ),
                            ),
                            child: Row(
                              children: [
                                /// ALARM
                                Expanded(
                                  child: InkWell(
                                    onTap: () {},
                                    borderRadius: BorderRadius.circular(14),
                                    child: const Padding(
                                      padding: EdgeInsets.symmetric(
                                        vertical: 8,
                                      ),
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Icon(
                                            Icons.alarm_rounded,
                                            color: Color.fromARGB(
                                              255,
                                              226,
                                              223,
                                              25,
                                            ),
                                            size: 18,
                                          ),

                                          SizedBox(width: 8),

                                          Text(
                                            "Alarm",
                                            style: TextStyle(
                                              color: Colors.white,
                                              fontSize: 13,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),

                                Container(
                                  width: 1,
                                  height: 24,
                                  color: Colors.white24,
                                ),

                                /// FULL SCHEDULE
                                Expanded(
                                  child: InkWell(
                                    onTap: prayerModel == null
                                        ? null
                                        : () {
                                            Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                builder: (_) =>
                                                    PrayerTimesScreen(
                                                      prayerModel: prayerModel!,
                                                      city: cityName,
                                                    ),
                                              ),
                                            );
                                          },
                                    borderRadius: BorderRadius.circular(14),
                                    child: Padding(
                                      padding: const EdgeInsets.symmetric(
                                        vertical: 8,
                                      ),
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Icon(
                                            Icons.schedule_rounded,
                                            color: const Color.fromARGB(
                                              255,
                                              216,
                                              216,
                                              26,
                                            ),
                                            size: 18,
                                          ),

                                          const SizedBox(width: 8),

                                          const Text(
                                            "Full Schedule",
                                            style: TextStyle(
                                              color: Colors.white,
                                              fontSize: 13,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
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
              ),

              /// WHITE SECTION
              Transform.translate(
                offset: const Offset(0, -22),
                child: Container(
                  width: double.infinity,
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(34),
                      topRight: Radius.circular(34),
                    ),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.only(top: 24, bottom: 30),
                    child: Column(
                      children: [
                        const PrayerTrackerCard(),

                        const SizedBox(height: 20),

                        const DailyAzkaarCard(),

                        const SizedBox(height: 20),

                        _hadithOfTheDayCard(),

                        const SizedBox(height: 20),

                        _duaCard(),

                        const SizedBox(height: 20),

                        _essentialToolsCard(),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _hadithOfTheDayCard() {
    if (_wisdomLoading) {
      return Container(
        margin: const EdgeInsets.symmetric(horizontal: 20),
        height: 280,
        decoration: BoxDecoration(
          color: const Color(0xff0E5A56),
          borderRadius: BorderRadius.circular(32),
        ),
        child: const Center(
          child: CircularProgressIndicator(color: Color(0xffE8C76A)),
        ),
      );
    }

    if (_todayWisdom == null) {
      return const SizedBox.shrink();
    }

    final bool isQuran = _todayWisdom!.type.toLowerCase() == "quran";

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      decoration: BoxDecoration(
        color: const Color(0xff0E5A56),
        borderRadius: BorderRadius.circular(32),
        boxShadow: [
          BoxShadow(
            color: const Color(0xff0E5A56).withValues(alpha: .22),
            blurRadius: 24,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Stack(
        children: [
          /// Decorative quote
          Positioned(
            right: -15,
            top: -20,
            child: Icon(
              Icons.format_quote_rounded,
              size: 130,
              color: Colors.white.withValues(alpha: .06),
            ),
          ),

          Padding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                /// TOP BADGE
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: .12),
                    borderRadius: BorderRadius.circular(30),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        isQuran
                            ? Icons.menu_book_rounded
                            : Icons.auto_stories_rounded,
                        size: 18,
                        color: const Color.fromARGB(255, 245, 223, 163),
                      ),

                      const SizedBox(width: 8),

                      Text(
                        isQuran ? "Wisdom of the Day" : "Wisdom of the Day",
                        style: const TextStyle(
                          color: Color.fromARGB(255, 245, 251, 156),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 37),

                /// WISDOM TEXT
                Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 285),
                    child: Text(
                      _todayWisdom!.text,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.w600,
                        height: 1.4,
                        letterSpacing: 0.1,
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 25),

                /// GOLD DIVIDER
                Center(
                  child: Container(
                    width: 58,
                    height: 4,
                    decoration: BoxDecoration(
                      color: const Color(0xffE8C76A),
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                ),

                const SizedBox(height: 14),

                /// REFERENCE
                Center(
                  child: Text(
                    _todayWisdom!.reference,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: Color(0xffE8C76A),
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      height: 1.2,
                    ),
                  ),
                ),
                const SizedBox(height: 26),

                /// BUTTONS
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.white,
                          side: BorderSide(
                            color: Colors.white.withValues(alpha: .25),
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(18),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                        ),
                        onPressed: _shareWisdom,
                        icon: const Icon(Icons.share_rounded),
                        label: const Text("Share"),
                      ),
                    ),

                    const SizedBox(width: 14),

                    /*  Expanded(
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor:
                            const Color(0xffE8C76A),
                        foregroundColor:
                            const Color(0xff0E5A56),
                        elevation: 0,
                        padding: const EdgeInsets.symmetric(
                          vertical: 14,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(18),
                        ),
                      ),
                      onPressed: () {
                        // Read More will be implemented later.
                      },
                      icon: const Icon(
                        Icons.arrow_forward_rounded,
                      ),
                      label: const Text(
                        "Read More",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  */
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _duaCard() {
    return InkWell(
      borderRadius: BorderRadius.circular(24),
      onTap: () {
        // Navigate to Dua Screen
      },
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 20),
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xff5A3F98), Color(0xff7B58C8)],
          ),
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: const Color(0xff5A3F98).withValues(alpha: .22),
              blurRadius: 18,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              height: 52,
              width: 52,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: .15),
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Icon(
                Icons.volunteer_activism_rounded,
                color: Color(0xffF5D97A),
                size: 28,
              ),
            ),

            const SizedBox(width: 16),

            const Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    "Duas",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 19,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  SizedBox(height: 4),

                  Text(
                    "Supplications for every occasion",
                    style: TextStyle(color: Colors.white70, fontSize: 13),
                  ),
                ],
              ),
            ),

            Container(
              height: 42,
              width: 42,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: .18),
                borderRadius: BorderRadius.circular(14),
              ),
              child: const Icon(
                Icons.arrow_forward_rounded,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _essentialToolsCard() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xffFFFDF8),
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: const Color(0xffE8DFC8)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: .05),
            blurRadius: 18,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Essentials",
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
          ),

          const SizedBox(height: 6),

          const Text(
            "Quick access to your daily tools",
            style: TextStyle(color: Colors.black54, fontSize: 13),
          ),

          const SizedBox(height: 22),

          Row(
            children: [
              Expanded(
                child: _tool(
                  Icons.explore_rounded,
                  "Qibla",
                  const Color(0xff2D6A4F),
                ),
              ),

              const SizedBox(width: 14),

              Expanded(
                child: _tool(
                  Icons.touch_app_rounded,
                  "Tasbih",
                  const Color(0xff7B58C8),
                ),
              ),

              const SizedBox(width: 14),

              Expanded(
                child: _tool(
                  Icons.mosque_rounded,
                  "Mosques",
                  const Color(0xffC58A17),
                ),
              ),
            ],
          ),

          const SizedBox(height: 14),

          Row(
            children: [
              Expanded(
                child: _tool(
                  Icons.calendar_month_rounded,
                  "Hijri",
                  const Color(0xff0E5A56),
                ),
              ),

              const SizedBox(width: 14),

              Expanded(
                child: _tool(
                  Icons.calculate_rounded,
                  "Zakat",
                  const Color(0xffE76F51),
                ),
              ),

              const SizedBox(width: 14),

              Expanded(
                child: _tool(
                  Icons.menu_book_rounded,
                  "99 Names",
                  const Color(0xff3A86FF),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _tool(IconData icon, String title, Color color) {
    return InkWell(
      borderRadius: BorderRadius.circular(18),
      onTap: () {},
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: color.withValues(alpha: .08),
          borderRadius: BorderRadius.circular(18),
        ),
        child: Column(
          children: [
            Container(
              height: 48,
              width: 48,
              decoration: BoxDecoration(
                color: color.withValues(alpha: .15),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color),
            ),

            const SizedBox(height: 10),

            Text(
              title,
              style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
            ),
          ],
        ),
      ),
    );
  }
}