

import 'package:flutter/material.dart';
import '../widgets/location_permission_dialog.dart';

import '../services/location_service.dart';
import '../services/prayer_service.dart';
import '../models/prayer_model.dart';
import 'dart:async';
import 'prayer_times_screen.dart';
import 'package:hijri/hijri_calendar.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/verse_model.dart';
import '../services/daily_verse_service.dart';


class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final LocationService _locationService = LocationService();
  final PrayerService _prayerService = PrayerService();

  PrayerModel? prayerModel;
  Timer? _countdownTimer;
  String cityName = "Loading...";
bool locationUnavailable = false;
  bool isLoadingPrayer = true;
  String? prayerError;
VerseModel? _verseOfTheDay;
bool _isLoadingVerse = true;
  final DailyVerseService _dailyVerseService =
    DailyVerseService();
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
    _loadVerseOfTheDay();
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

Future<void> _loadVerseOfTheDay() async {
  try {
    final verse =
        await _dailyVerseService.getTodaysVerse();

    if (!mounted) return;

    setState(() {
      _verseOfTheDay = verse;
      _isLoadingVerse = false;
    });
  } catch (e) {
    debugPrint(e.toString());

    if (!mounted) return;

    setState(() {
      _isLoadingVerse = false;
    });
  }
}

  Future<void> _checkLocationSetup() async {
    final asked =
    await _locationService.hasAskedLocationPermission();

if (asked || !mounted) return;

    await Future.delayed(const Duration(milliseconds: 700));

    if (!mounted) return;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => LocationPermissionDialog(
       onLater: () async {
  await _locationService.setAskedLocationPermission();

  if (!mounted) return;

  Navigator.pop(context);

  setState(() {
    isLoadingPrayer = false;
    locationUnavailable = true;
  });
},

      onAllow: () async {
        await _locationService.setAskedLocationPermission();
  try {
    final position = await _locationService.getCurrentLocation();

    final city =
        await _locationService.getCityName(position);

    await _locationService.saveLocation(
      latitude: position.latitude,
      longitude: position.longitude,
      city: city,
    );

    

    if (!mounted) return;

    Navigator.pop(context);

    await _loadPrayerTimes();
 } catch (e) {
  if (!mounted) return;

  Navigator.pop(context);

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
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,

      body: SingleChildScrollView(
        child: Column(
          children: [
            /// HEADER
            SizedBox(
              height: 135,
              width: double.infinity,

              child: SafeArea(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),

                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,

                    children: [
                      Container(
                        width: 50,
                        height: 50,

                        decoration: BoxDecoration(
                          color: const Color(0xFF0B4B4B),

                          borderRadius: BorderRadius.circular(16),
                        ),

                        child: const Icon(Icons.menu, color: Colors.white),
                      ),

                      const Text(
                        "لا تقنطوا من رحمة الله",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF0B4B4B),
                        ),
                      ),

                      Container(
                        width: 50,
                        height: 50,

                        decoration: BoxDecoration(
                          color: const Color(0xFF0B4B4B),

                          borderRadius: BorderRadius.circular(16),
                        ),

                        child: const Icon(
                          Icons.notifications_none,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            GestureDetector(
              onTap: () {
                if (prayerModel == null) return;

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

              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),

                child: Container(
                  height: 220,
                  width: double.infinity,

                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(28),

                    image: const DecorationImage(
                      image: AssetImage("assets/images/homebg.png"),
                      fit: BoxFit.cover,
                    ),
                  ),

                  child: Padding(
                    padding: const EdgeInsets.all(20),

                    child: Row(
                      children: [
                        /// LEFT SIDE
                        Expanded(
                          flex: 3,

                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,

                            children: [
                              Text(
                                getHijriDate(),
                                style: const TextStyle(
                                  color: Colors.white70,
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 5),
                              Text(
                                prayerModel?.currentPrayer == "morning"
                                    ? "MORNING"
                                    : "CURRENT PRAYER",
                                style: const TextStyle(
                                  color: Color(0xFFF4D17D),
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 1,
                                ),
                              ),

                              const SizedBox(height: 6),

                              Text(
  prayerModel == null
      ? (locationUnavailable
          ? "Prayer Times\nUnavailable"
          : "Loading...")
      : prayerModel!.currentPrayer == "morning"
          ? "No Prayer"
          : "${prayerModel!.currentPrayer[0].toUpperCase()}${prayerModel!.currentPrayer.substring(1)}",
  style: TextStyle(
    color: Colors.white,
    fontSize: prayerModel == null && locationUnavailable ? 20 : 32,
    fontWeight: FontWeight.bold,
    height: 1.2,
  ),
),
                             Text(
  prayerModel == null
      ? (locationUnavailable
          ? "Display prayer times."
          : "--:--:--")
      : _formatDuration(
          prayerModel!.remainingDuration,
        ),
  style: TextStyle(
    color: Colors.white,
    fontSize: prayerModel == null && locationUnavailable ? 18 : 32,
    fontWeight: FontWeight.bold,
    height: 1.3,
  ),
),
    const SizedBox(height: 10),
                            locationUnavailable
    ? GestureDetector(
        onTap: _requestLocationAgain,
        child: Container(
          padding: const EdgeInsets.symmetric(
            horizontal: 14,
            vertical: 6,
          ),
          decoration: BoxDecoration(
            color: const Color(0xFFF4D17D),
            borderRadius: BorderRadius.circular(20),
          ),
          child: const Text(
            "Enable Location",
            style: TextStyle(
              color: Colors.black,
              fontWeight: FontWeight.bold,
              fontSize: 12,
            ),
          ),
        ),
      )
    : const Text(
        "Next Prayer Time",
        style: TextStyle(
          color: Colors.white70,
          fontSize: 13,
          fontWeight: FontWeight.bold,
        ),
      ),

                             const SizedBox(height: 6),

                              Row(
                                children: [
                                  const Icon(
                                    Icons.access_time,
                                    color: Color(0xFFF4D17D),
                                    size: 18,
                                  ),

                                  const SizedBox(width: 5),

                                  Text(
                                    prayerModel == null
                                        ? "--:--"
                                        : "${prayerModel!.nextPrayer[0].toUpperCase()}${prayerModel!.nextPrayer.substring(1)} • "
                                              "${TimeOfDay.fromDateTime(prayerModel!.nextPrayerTime).format(context)}",
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 13,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),

                                  const SizedBox(width: 12),

                                  const Icon(
                                    Icons.location_on,
                                    color: Color(0xFFF4D17D),
                                    size: 18,
                                  ),

                                  const SizedBox(width: 4),

                                  Text(
                                    cityName,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 13,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),

              child: Container(
                width: double.infinity,

                padding: const EdgeInsets.all(18),

                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(24),

                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.05),
                      blurRadius: 10,
                    ),
                  ],
                ),

                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,

                  children: [
                    const Text(
                      "Verse of the Day",
                      style: TextStyle(
                        color: Color(0xFF0B4B4B),
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 12),

                   _isLoadingVerse
    ? const Center(
        child: CircularProgressIndicator(),
      )
    : Text(
        _verseOfTheDay?.arabic ?? "",
        textAlign: TextAlign.right,
        style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
        ),
      ),
                    const SizedBox(height: 12),

                 Text(
  "Surah ${_verseOfTheDay?.surah}:${_verseOfTheDay?.ayah}",
  style: const TextStyle(
    color: Color.fromARGB(255, 175, 44, 155),
    fontSize: 13,
  ),
),

                    const SizedBox(height: 4),

                Text(
  _verseOfTheDay?.kashmiriTranslation ?? "",
  maxLines: 5,
  overflow: TextOverflow.ellipsis,
  style: const TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w600,
    height: 1.45,
  ),
),
const SizedBox(height: 12),
/*
InkWell(
  onTap: () {
    // We'll connect this next
  },
  borderRadius: BorderRadius.circular(20),
  child: Row(
    mainAxisSize: MainAxisSize.min,
    children: const [
      Text(
        "Read Full Verse",
        style: TextStyle(
          color: Color(0xff0E5A56),
          fontWeight: FontWeight.w700,
        ),
      ),
      SizedBox(width: 6),
      Icon(
        Icons.arrow_forward_rounded,
        color: Color(0xff0E5A56),
        size: 18,
      ),
    ],
  ),
),
 */
                  ],
                ),
              ),
            ),

_todayJourneyCard(),

_dailyAzkaarCard(),

const SizedBox(height: 20),

_hadithOfTheDayCard(),

const SizedBox(height: 20),

_duaOfTheDayCard(),

const SizedBox(height: 20),

_todayRecitationCard(),

const SizedBox(height: 20),
            

          ],
        ),
      ),
    );
  }
  Widget _todayJourneyCard() {
  return Container();
}

Widget _dailyAzkaarCard() {
  return Container(
    margin: const EdgeInsets.symmetric(horizontal: 20),
    padding: const EdgeInsets.all(22),
    decoration: BoxDecoration(
      borderRadius: BorderRadius.circular(30),
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
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [

        /// Header
        Row(
          children: [
            Container(
              height: 48,
              width: 48,
              decoration: BoxDecoration(
                color: const Color(0xff0E5A56).withOpacity(.12),
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Icon(
                Icons.auto_awesome,
                color: Color(0xff0E5A56),
              ),
            ),

            const SizedBox(width: 14),

            const Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [

                  Text(
                    "Daily Azkaar",
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                    ),
                  ),

                  SizedBox(height: 2),

                  Text(
                    "Morning remembrance",
                    style: TextStyle(
                      color: Colors.black54,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),

            Container(
              padding: const EdgeInsets.symmetric(
                  horizontal: 12, vertical: 7),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Text(
                "12 Left",
                style: TextStyle(
                  color: Color(0xff0E5A56),
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),

        const SizedBox(height: 22),

        /// Current Dhikr
        const Text(
          "Current Dhikr",
          style: TextStyle(
            color: Colors.black54,
            fontSize: 13,
          ),
        ),

        const SizedBox(height: 8),

        const Text(
          "سُبْحَانَ اللّٰهِ وَبِحَمْدِهِ",
          textAlign: TextAlign.right,
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            height: 1.8,
          ),
        ),

        const SizedBox(height: 8),

        const Text(
          "SubhanAllahi wa bihamdihi",
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),

        const SizedBox(height: 6),

        const Text(
          "Glory be to Allah and all praise belongs to Him.",
          style: TextStyle(
            color: Colors.black54,
            height: 1.5,
          ),
        ),

        const SizedBox(height: 24),

        /// Progress
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: const [

            Text(
              "Progress",
              style: TextStyle(fontWeight: FontWeight.w600),
            ),

            Text(
              "21 / 33",
              style: TextStyle(
                color: Color(0xff0E5A56),
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),

        const SizedBox(height: 10),

        ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: LinearProgressIndicator(
            value: 21 / 33,
            minHeight: 9,
            backgroundColor: Colors.white,
            valueColor: const AlwaysStoppedAnimation(
              Color(0xff0E5A56),
            ),
          ),
        ),

        const SizedBox(height: 24),

        /// Button
        SizedBox(
          width: double.infinity,
          height: 54,
          child: ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              elevation: 0,
              backgroundColor: const Color(0xff0E5A56),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(18),
              ),
            ),
            onPressed: () {},
            icon: const Icon(Icons.play_arrow_rounded),
            label: const Text(
              "Continue Azkaar",
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
      ],
    ),
  );
}

Widget _hadithOfTheDayCard() {
  return Container(
    margin: const EdgeInsets.symmetric(horizontal: 20),
    decoration: BoxDecoration(
      color: const Color(0xff0E5A56),
      borderRadius: BorderRadius.circular(32),
      boxShadow: [
        BoxShadow(
          color: const Color(0xff0E5A56).withOpacity(.22),
          blurRadius: 24,
          offset: const Offset(0, 12),
        ),
      ],
    ),
    child: Stack(
      children: [

        /// Decorative Quote
        Positioned(
          right: -15,
          top: -20,
          child: Icon(
            Icons.format_quote,
            size: 130,
            color: Colors.white.withOpacity(.06),
          ),
        ),

        Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [

              /// Top Badge
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(.12),
                  borderRadius: BorderRadius.circular(30),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [

                    Icon(
                      Icons.menu_book_rounded,
                      size: 18,
                      color: Color(0xffE8C76A),
                    ),

                    SizedBox(width: 8),

                    Text(
                      "Hadith of the Day",
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 28),

              /// Quote
              const Text(
                '"The best among you are those who learn the Qur’an and teach it."',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 23,
                  fontWeight: FontWeight.w600,
                  height: 1.55,
                ),
              ),

              const SizedBox(height: 18),

              Container(
                width: 70,
                height: 4,
                decoration: BoxDecoration(
                  color: const Color(0xffE8C76A),
                  borderRadius: BorderRadius.circular(20),
                ),
              ),

              const SizedBox(height: 18),

              const Text(
                "— Sahih al-Bukhari 5027",
                style: TextStyle(
                  color: Color(0xffE8C76A),
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                ),
              ),

              const SizedBox(height: 26),

              Row(
                children: [

                  Expanded(
                    child: OutlinedButton.icon(
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.white,
                        side: BorderSide(
                          color: Colors.white.withOpacity(.25),
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(18),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                      onPressed: () {},
                      icon: const Icon(Icons.share_rounded),
                      label: const Text("Share"),
                    ),
                  ),

                  const SizedBox(width: 14),

                  Expanded(
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xffE8C76A),
                        foregroundColor: const Color(0xff0E5A56),
                        elevation: 0,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(18),
                        ),
                      ),
                      onPressed: () {},
                      icon: const Icon(Icons.arrow_forward_rounded),
                      label: const Text(
                        "Read More",
                        style: TextStyle(
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
      ],
    ),
  );
}

Widget _duaOfTheDayCard() {
  return Container(
    margin: const EdgeInsets.symmetric(horizontal: 20),
    padding: const EdgeInsets.all(24),
    decoration: BoxDecoration(
      borderRadius: BorderRadius.circular(32),
      gradient: const LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          Color(0xffFFFDF7),
          Color(0xffF8F1DE),
        ],
      ),
      border: Border.all(
        color: const Color(0xffE5D3A1),
        width: 1.5,
      ),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(.05),
          blurRadius: 20,
          offset: const Offset(0, 10),
        ),
      ],
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [

        Row(
          children: [

            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xff0E5A56).withOpacity(.1),
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Icon(
                Icons.volunteer_activism_rounded,
                color: Color(0xff0E5A56),
              ),
            ),

            const SizedBox(width: 14),

            const Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [

                  Text(
                    "Dua of the Day",
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                    ),
                  ),

                  SizedBox(height: 3),

                  Text(
                    "A prayer for peace & guidance",
                    style: TextStyle(
                      color: Colors.black54,
                    ),
                  ),
                ],
              ),
            ),

            IconButton(
              onPressed: () {},
              icon: const Icon(Icons.bookmark_border_rounded),
            ),
          ],
        ),

        const SizedBox(height: 24),

        Center(
          child: Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 20,
              vertical: 22,
            ),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(
                color: const Color(0xffE9D7AA),
              ),
            ),
            child: const Text(
              "رَبِّ زِدْنِي عِلْمًا",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 34,
                height: 1.8,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),

        const SizedBox(height: 22),

        const Center(
          child: Text(
            "Rabbi Zidni Ilma",
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),

        const SizedBox(height: 10),

        const Text(
          "\"My Lord, increase me in knowledge.\"",
          textAlign: TextAlign.center,
          style: TextStyle(
            height: 1.7,
            color: Colors.black54,
            fontSize: 16,
          ),
        ),

        const SizedBox(height: 28),

        Row(
          children: [

            Expanded(
              child: TextButton.icon(
                onPressed: () {},
                icon: const Icon(Icons.volume_up_rounded),
                label: const Text("Listen"),
              ),
            ),

            const SizedBox(width: 12),

            Expanded(
              flex: 2,
              child: ElevatedButton.icon(
                onPressed: () {},
                icon: const Icon(Icons.favorite_outline),
                label: const Text("Make This Today's Dua"),
                style: ElevatedButton.styleFrom(
                  elevation: 0,
                  backgroundColor: const Color(0xff0E5A56),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(18),
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    ),
  );
}

Widget _todayRecitationCard() {
  return Container(
    margin: const EdgeInsets.fromLTRB(20, 0, 20, 24),
    padding: const EdgeInsets.all(22),
    decoration: BoxDecoration(
      borderRadius: BorderRadius.circular(32),
      gradient: const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          Color(0xff0C4A48),
          Color(0xff15726D),
        ],
      ),
      boxShadow: [
        BoxShadow(
          color: const Color(0xff0C4A48).withOpacity(.28),
          blurRadius: 28,
          offset: const Offset(0, 14),
        ),
      ],
    ),
    child: Column(
      children: [

        /// Header
        Row(
          children: [

            Container(
              height: 62,
              width: 62,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(.12),
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Icon(
                Icons.graphic_eq_rounded,
                color: Color(0xffF2D27C),
                size: 34,
              ),
            ),

            const SizedBox(width: 16),

            const Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [

                  Text(
                    "Today's Recitation",
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 13,
                    ),
                  ),

                  SizedBox(height: 5),

                  Text(
                    "Surah Ar-Rahman",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  SizedBox(height: 2),

                  Text(
                    "Mishary Rashid Alafasy",
                    style: TextStyle(
                      color: Colors.white60,
                    ),
                  ),
                ],
              ),
            ),

            Container(
              height: 58,
              width: 58,
              decoration: const BoxDecoration(
                color: Color(0xffF2D27C),
                shape: BoxShape.circle,
              ),
              child: IconButton(
                onPressed: () {},
                icon: const Icon(
                  Icons.play_arrow_rounded,
                  color: Color(0xff0C4A48),
                  size: 34,
                ),
              ),
            ),
          ],
        ),

        const SizedBox(height: 26),

        /// Waveform
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: List.generate(
            28,
            (index) {
              final heights = [
                8.0, 15.0, 20.0, 12.0, 24.0, 30.0, 16.0,
                28.0, 10.0, 22.0, 18.0, 32.0, 14.0, 26.0,
                20.0, 30.0, 16.0, 25.0, 12.0, 27.0, 19.0,
                29.0, 13.0, 24.0, 18.0, 28.0, 15.0, 22.0,
              ];

              return Container(
                width: 4,
                height: heights[index],
                decoration: BoxDecoration(
                  color: index < 16
                      ? const Color(0xffF2D27C)
                      : Colors.white24,
                  borderRadius: BorderRadius.circular(10),
                ),
              );
            },
          ),
        ),

        const SizedBox(height: 22),

        /// Duration
        Row(
          children: const [

            Text(
              "03:42",
              style: TextStyle(color: Colors.white60),
            ),

            Spacer(),

            Text(
              "10:18",
              style: TextStyle(color: Colors.white60),
            ),
          ],
        ),

        const SizedBox(height: 22),

        Container(
          padding: const EdgeInsets.symmetric(
            horizontal: 18,
            vertical: 14,
          ),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(.08),
            borderRadius: BorderRadius.circular(18),
          ),
          child: const Row(
            children: [

              Icon(
                Icons.headphones_rounded,
                color: Color(0xffF2D27C),
              ),

              SizedBox(width: 12),

              Expanded(
                child: Text(
                  "Continue listening where you left off",
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),

              Icon(
                Icons.arrow_forward_ios_rounded,
                size: 16,
                color: Colors.white70,
              ),
            ],
          ),
        ),
      ],
    ),
  );
}
  String _formatDuration(Duration duration) {
    final hours = duration.inHours;
    final minutes = duration.inMinutes.remainder(60);
    final seconds = duration.inSeconds.remainder(60);

    return "${hours.toString().padLeft(2, '0')}:"
        "${minutes.toString().padLeft(2, '0')}:"
        "${seconds.toString().padLeft(2, '0')}";
  }
}
