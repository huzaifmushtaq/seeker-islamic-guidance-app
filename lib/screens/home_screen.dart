

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
// ignore: unused_element
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
      colors: [
        Color(0xff0E5A56),
        Color(0xff176C66),
      ],
    ),
  ),

  child: SafeArea(
    bottom: false,
    child: Padding(
      padding: const EdgeInsets.fromLTRB(22, 18, 22, 0),

      child: Stack(
  children: [

    /// Top Row
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
              cityName,
              style: const TextStyle(
                color: Color.fromARGB(248, 236, 237, 239),
                fontWeight: FontWeight.w600,
                fontSize: 15,
              ),
            ),
          ),

          Text(
            getHijriDate(),
            style: const TextStyle(
              color: Color.fromARGB(235, 248, 249, 247),
              fontSize: 15,
              fontWeight: FontWeight.w300
            ),
          ),
        ],
      ),
    ),

    /// Center Prayer
Center(
  child: Column(
    mainAxisSize: MainAxisSize.min,
    children: [

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
  ),
),

Positioned(
  left: 24,
  right: 24,
  bottom: 35, // <-- change this value to move it up/down
  child: Container(
    padding: const EdgeInsets.symmetric(
      horizontal: 14,
      vertical: 0,
    ),
    decoration: BoxDecoration(
      color: Colors.white.withOpacity(.12),
      borderRadius: BorderRadius.circular(18),
      border: Border.all(
        color: const Color.fromARGB(255, 162, 131, 131).withOpacity(.12),
      ),
    ),
    child: Row(
      children: [

        Expanded(
          child: InkWell(
            onTap: () {},
            borderRadius: BorderRadius.circular(14),
            child: const Padding(
  padding: EdgeInsets.symmetric(vertical: 8),
  child: Row(
    mainAxisAlignment: MainAxisAlignment.center,
    children: [

      Icon(
        Icons.alarm_rounded,
        color: Color.fromARGB(255, 226, 223, 25),
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

        Expanded(
          child: InkWell(
            onTap: () {
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
            borderRadius: BorderRadius.circular(14),
            child: const Padding(
  padding:  EdgeInsets.symmetric(vertical: 8),
  child: Row(
    mainAxisAlignment: MainAxisAlignment.center,
    children: const [

      Icon(
        Icons.schedule_rounded,
        color: Color.fromARGB(255, 216, 216, 26),
        size: 18,
      ),

      SizedBox(width: 8),

      Text(
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
                padding: const EdgeInsets.only(
                  top: 24,
                  bottom: 30,
                ),
                child: Column(
                  children: [

                    const PrayerTrackerCard(),

                    const SizedBox(height: 20),

                   const DailyAzkaarCard(),

                    const SizedBox(height: 20),

                     _duaCard(),

                    const SizedBox(height: 20),

                    _hadithOfTheDayCard(),

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
  final List<Map<String, dynamic>> wisdoms = [
  {
    "icon": Icons.menu_book_rounded,
    "title": "Quran",
    "quote":
        "\"Indeed, in the remembrance of Allah do hearts find rest.\"",
    "reference": "— Quran 13:28",
  },
  {
    "icon": Icons.auto_stories_rounded,
    "title": "Hadith",
    "quote":
        "\"The best among you are those who learn the Qur’an and teach it.\"",
    "reference": "— Sahih al-Bukhari 5027",
  },
];

final wisdom = wisdoms[DateTime.now().day % wisdoms.length];
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
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [

                   Icon(
  wisdom["icon"] as IconData,
  size: 18,
  color: const Color(0xffE8C76A),
),

                    SizedBox(width: 8),

                   Text(
  "${wisdom["title"]} • Wisdom of the Day",
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
             Text(
  wisdom["quote"] as String,
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

             Text(
  wisdom["reference"] as String,
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
Widget _duaCard() {
  return InkWell(
    borderRadius: BorderRadius.circular(24),
    onTap: () {
      // Navigate to Dua Screen
    },
    child: Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.symmetric(
        horizontal: 18,
        vertical: 16,
      ),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xff5A3F98),
            Color(0xff7B58C8),
          ],
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: const Color(0xff5A3F98).withOpacity(.22),
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
              color: Colors.white.withOpacity(.15),
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
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),

          Container(
            height: 42,
            width: 42,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(.18),
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
      border: Border.all(
        color: const Color(0xffE8DFC8),
      ),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(.05),
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
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
          ),
        ),

        const SizedBox(height: 6),

        const Text(
          "Quick access to your daily tools",
          style: TextStyle(
            color: Colors.black54,
            fontSize: 13,
          ),
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

Widget _tool(
  IconData icon,
  String title,
  Color color,
) {
  return InkWell(
    borderRadius: BorderRadius.circular(18),
    onTap: () {},
    child: Container(
      padding: const EdgeInsets.symmetric(vertical: 16),
      decoration: BoxDecoration(
        color: color.withOpacity(.08),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        children: [

          Container(
            height: 48,
            width: 48,
            decoration: BoxDecoration(
              color: color.withOpacity(.15),
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              color: color,
            ),
          ),

          const SizedBox(height: 10),

          Text(
            title,
            style: const TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 13,
            ),
          ),
        ],
      ),
    ),
  );
}

  
}
