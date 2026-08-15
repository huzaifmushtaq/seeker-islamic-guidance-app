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
              _todayWisdom!.urdu,
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
            /// COMPACT PRAYER HEADER
Container(
  margin: const EdgeInsets.fromLTRB(
    16,
    22,
    16,
    0,
  ),
  height: 232,
  width: double.infinity,
  decoration: BoxDecoration(
    borderRadius: BorderRadius.circular(28),
    gradient: const LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [
        Color(0xff0E5A56),
        Color(0xff176C66),
      ],
    ),
    boxShadow: [
      BoxShadow(
        color: const Color(0xff0E5A56).withOpacity(.18),
        blurRadius: 20,
        offset: const Offset(0, 10),
      ),
    ],
  ),

  child: Padding(
    padding: const EdgeInsets.fromLTRB(22, 18, 22, 18),

    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [

        /// TOP INFORMATION
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            /// CURRENT PRAYER
            Expanded(
              child: Column(
                crossAxisAlignment:
                    CrossAxisAlignment.start,
                children: [

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

                      const SizedBox(width: 7),

                      const Text(
                        "CURRENT PRAYER",
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 1.2,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 5),

                  Text(
                    locationUnavailable
                        ? "Prayer Times"
                        : prayerModel == null
                            ? "Loading..."
                            : prayerModel!
                                .currentPrayer
                                .substring(0, 1)
                                .toUpperCase() +
                              prayerModel!
                                  .currentPrayer
                                  .substring(1),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),

            /// CITY / LOCATION
            Column(
              crossAxisAlignment:
                  CrossAxisAlignment.end,
              children: [

                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [

                    const Icon(
                      Icons.location_on_rounded,
                      color: Colors.white70,
                      size: 14,
                    ),

                    const SizedBox(width: 3),

                    Text(
                      locationUnavailable
                          ? "Unavailable"
                          : cityName,
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 10),

                const Text(
                  "PRAYER TIME",
                  style: TextStyle(
                    color: Colors.white54,
                    fontSize: 9,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1,
                  ),
                ),

                const SizedBox(height: 3),

                Text(
                  locationUnavailable
                      ? "--:--"
                      : prayerModel == null
                          ? "--:--"
                          : _currentPrayerTimeText(),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ],
        ),

       const SizedBox(height: 14),

/// REMAINING TIME
Column(
  crossAxisAlignment: CrossAxisAlignment.start,
  children: [
    const Text(
      "REMAINING TIME",
      style: TextStyle(
        color: Colors.white70,
        fontSize: 9,
        fontWeight: FontWeight.w700,
        letterSpacing: 1.1,
      ),
    ),

    const SizedBox(height: 6),

    Text(
      locationUnavailable || prayerModel == null
          ? "--:--:--"
          : _formatDuration(
              prayerModel!.remainingDuration,
            ),
      style: const TextStyle(
        color: Colors.white,
        fontSize: 22,
        fontWeight: FontWeight.w700,
        letterSpacing: 1.2,
        height: 1,
      ),
    ),
  ],
),

const SizedBox(height: 12),

/// DIVIDER
Container(
  height: 1,
  color: Colors.white.withOpacity(.10),
),

const SizedBox(height: 12),

        const SizedBox(height: 13),

        /// NEXT PRAYER INFORMATION
        Row(
          children: [

            /// ICON
            Container(
              width: 34,
              height: 34,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(.10),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.access_time_rounded,
                color: Color(0xffE8C76A),
                size: 18,
              ),
            ),

            const SizedBox(width: 10),

            /// NEXT PRAYER
            Expanded(
              child: Text(
                locationUnavailable
                    ? "Enable location for prayer times"
                    : prayerModel == null
                        ? "Loading next prayer..."
                        : "Next Prayer : ${_capitalizePrayer(
  prayerModel!.nextPrayer
      .replaceAll("After", "")
      .replaceAll("after", ""),
)} at ${TimeOfDay.fromDateTime(
  prayerModel!.nextPrayerTime,
).format(context)}",
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),

            /// COUNTDOWN
            if (!locationUnavailable &&
                prayerModel != null)
            GestureDetector(
  onTap: prayerModel == null
      ? null
      : () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => PrayerTimesScreen(
                prayerModel: prayerModel!,
                city: cityName,
              ),
            ),
          );
        },
  child: Container(
    padding: const EdgeInsets.symmetric(
      horizontal: 13,
      vertical: 7,
    ),
    decoration: BoxDecoration(
      color: const Color(0xffE8C76A),
      borderRadius: BorderRadius.circular(18),
    ),
    child: const Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          Icons.schedule_rounded,
          color: Color(0xff0E5A56),
          size: 14,
        ),
        SizedBox(width: 5),
        Text(
          "Schedule",
          style: TextStyle(
            color: Color(0xff0E5A56),
            fontSize: 10,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    ),
  ),
),

            /// ENABLE LOCATION
            if (locationUnavailable)
              GestureDetector(
                onTap: _requestLocationAgain,
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 7,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xffE8C76A),
                    borderRadius:
                        BorderRadius.circular(20),
                  ),
                  child: const Text(
                    "Enable",
                    style: TextStyle(
                      color: Color(0xff0E5A56),
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ],
    ),
  ),
),

              /// WHITE SECTION
              Transform.translate(
                offset: const Offset(0, 0),
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
        child: CircularProgressIndicator(
          color: Color(0xffE8C76A),
        ),
      ),
    );
  }

  if (_todayWisdom == null) {
    return const SizedBox.shrink();
  }

  final bool isQuran =
      _todayWisdom!.type.toLowerCase() == "quran";

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
        /// Decorative background quote
        Positioned(
          right: -15,
          top: -20,
          child: Icon(
            Icons.format_quote_rounded,
            size: 130,
            color: Colors.white.withValues(alpha: .055),
          ),
        ),

        Padding(
          padding: const EdgeInsets.fromLTRB(
            20,
            18,
            20,
            17,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              /// ─────────────────────────────
              /// HEADER
              /// ─────────────────────────────
              Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: .10),
                      borderRadius: BorderRadius.circular(13),
                    ),
                    child: Icon(
                      isQuran
                          ? Icons.menu_book_rounded
                          : Icons.auto_stories_rounded,
                      size: 20,
                      color: const Color(0xffE8C76A),
                    ),
                  ),

                  const SizedBox(width: 11),

                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        isQuran
                            ? "Quran • Wisdom of the Day"
                            : "Hadith • Wisdom of the Day",
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 14.5,
                          fontWeight: FontWeight.w700,
                          letterSpacing: .15,
                        ),
                      ),

                      const SizedBox(height: 2),

                    
                    ],
                  ),
                ],

              ),

              const SizedBox(height: 20),

              /// ─────────────────────────────
              /// ARABIC TEXT
              /// ─────────────────────────────
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(
                  horizontal: 8,
                  vertical: 2,
                ),
                child: Text(
                  _todayWisdom!.arabic,
                  textAlign: TextAlign.center,
                  textDirection: TextDirection.rtl,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: isQuran ? 20 : 18,
                    fontWeight: FontWeight.w500,
                    height: isQuran ? 1.75 : 1.7,
                    letterSpacing: .15,
                  ),
                ),
              ),

              const SizedBox(height: 13),

              /// ─────────────────────────────
              /// SMALL GOLD ACCENT
              /// ─────────────────────────────
              Center(
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 28,
                      height: 1,
                      color: const Color(0xffE8C76A)
                          .withValues(alpha: .55),
                    ),

                    const SizedBox(width: 8),

                    const Icon(
                      Icons.auto_awesome_rounded,
                      size: 13,
                      color: Color(0xffE8C76A),
                    ),

                    const SizedBox(width: 8),

                    Container(
                      width: 28,
                      height: 1,
                      color: const Color(0xffE8C76A)
                          .withValues(alpha: .55),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 13),

              /// ─────────────────────────────
              /// URDU TRANSLATION
              /// ─────────────────────────────
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(
                  horizontal: 6,
                ),
                child: Text(
                  _todayWisdom!.urdu,
                  textAlign: TextAlign.center,
                  textDirection: TextDirection.rtl,
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: .92),
                    fontSize: isQuran ? 16 : 15.5,
                    fontWeight: FontWeight.w500,
                    height: 1.65,
                  ),
                ),
              ),

              const SizedBox(height: 20),

              /// ─────────────────────────────
              /// REFERENCE
              /// ─────────────────────────────
              Center(
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 11,
                    vertical: 5,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xffE8C76A)
                        .withValues(alpha: .10),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: const Color(0xffE8C76A)
                          .withValues(alpha: .22),
                    ),
                  ),
                  child: Text(
                    _todayWisdom!.reference,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: Color(0xffE8C76A),
                      fontSize: 11.5,
                      fontWeight: FontWeight.w700,
                      letterSpacing: .2,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 15),

              /// ─────────────────────────────
              /// SHARE
              /// ─────────────────────────────
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.white,
                    side: BorderSide(
                      color: Colors.white.withValues(alpha: .22),
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    padding: const EdgeInsets.symmetric(
                      vertical: 11,
                    ),
                  ),
                  onPressed: _shareWisdom,
                  icon: const Icon(
                    Icons.share_rounded,
                    size: 18,
                  ),
                  label: const Text(
                    "Share Wisdom",
                    style: TextStyle(
                      fontSize: 13.5,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
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
  String _capitalizePrayer(String prayer) {
  if (prayer.isEmpty) return "";

  return prayer[0].toUpperCase() +
      prayer.substring(1);
}

  String _currentPrayerTimeText() {
  if (prayerModel == null) return "--:--";

  DateTime? time;

  switch (prayerModel!.currentPrayer) {
    case "fajr":
      time = prayerModel!.fajr;
      break;

    case "sunrise":
      time = prayerModel!.sunrise;
      break;

    case "dhuhr":
      time = prayerModel!.dhuhr;
      break;

    case "asr":
      time = prayerModel!.asr;
      break;

    case "maghrib":
      time = prayerModel!.maghrib;
      break;

    case "isha":
      time = prayerModel!.isha;
      break;
  }

  if (time == null) return "-- : --";

  return TimeOfDay.fromDateTime(time).format(context);
}
String _formatDuration(Duration duration) {
  if (duration.isNegative) {
    return "00 : 00 : 00";
  }

  final hours = duration.inHours;
  final minutes = duration.inMinutes.remainder(60);
  final seconds = duration.inSeconds.remainder(60);

  return "${hours.toString().padLeft(2, '0')}:"
      "${minutes.toString().padLeft(2, '0')}:"
      "${seconds.toString().padLeft(2, '0')}";
}
}

