// ignore_for_file: unused_import, unnecessary_const

import 'package:flutter/material.dart';
import '../widgets/feature_card.dart';
import 'package:geolocator/geolocator.dart';
import '../widgets/location_permission_dialog.dart';

import '../services/location_service.dart';
import '../services/prayer_service.dart';
import '../models/prayer_model.dart';
import 'dart:async';
import 'prayer_times_screen.dart';
import 'package:hijri/hijri_calendar.dart';
import 'package:Seeker/screens/quran/quran_screen.dart';

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
  

  _countdownTimer = Timer.periodic(
    const Duration(seconds: 1),
    (_) {
      if (!mounted || prayerModel == null) return;

      final remaining =
          prayerModel!.nextPrayerTime.difference(DateTime.now());


         

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
    },
  );
}
Future<void> _loadPrayerTimes() async {

  try {

    // 1. Try saved location first
    final savedLat =
        await _locationService.getSavedLatitude();

    final savedLng =
        await _locationService.getSavedLongitude();

    final savedCity =
        await _locationService.getSavedCity();

    if (savedLat != null &&
        savedLng != null &&
        savedCity != null) {

      final savedPosition =
          _locationService.getSavedPosition(
        latitude: savedLat,
        longitude: savedLng,
      );

      if (savedPosition != null) {

        final model =
            _prayerService.getPrayerModel(savedPosition);

        if (mounted) {
          setState(() {
            prayerModel = model;
            cityName = savedCity;
            isLoadingPrayer = false;
          });
        }
      }
    }

    // 2. Refresh silently using live GPS
    final livePosition =
        await _locationService.getCurrentLocation();

    final liveCity =
        await _locationService.getCityName(livePosition);

    await _locationService.saveLocation(
      latitude: livePosition.latitude,
      longitude: livePosition.longitude,
      city: liveCity,
    );

    final liveModel =
        _prayerService.getPrayerModel(livePosition);

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
    });
  }
}
 Future<void> _checkLocationSetup() async {
  final configured =
      await _locationService.isLocationConfigured();

  if (configured || !mounted) return;

  await Future.delayed(
    const Duration(milliseconds: 700),
  );

  if (!mounted) return;

  showDialog(
    context: context,
    barrierDismissible: false,
    builder: (_) => LocationPermissionDialog(

      onLater: () {
        Navigator.pop(context);
      },

      onAllow: () async {

        Navigator.pop(context);

        try {

          final position =
              await _locationService.getCurrentLocation();

          final city =
              await _locationService.getCityName(position);

          await _locationService.saveLocation(
            latitude: position.latitude,
            longitude: position.longitude,
            city: city,
          );

          await _locationService
              .setLocationConfigured();

          await _loadPrayerTimes();

        } catch (e) {

          debugPrint(e.toString());

        }

      },

    ),
  );
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
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                  ),

                  child: Row(
                    mainAxisAlignment:
                        MainAxisAlignment.spaceBetween,

                    children: [

                      Container(
                        width: 50,
                        height: 50,

                        decoration: BoxDecoration(
                          color: const Color(
                            0xFF0B4B4B,
                          ),

                          borderRadius:
                              BorderRadius.circular(
                            16,
                          ),
                        ),

                        child: const Icon(
                          Icons.menu,
                          color: Colors.white,
                        ),
                      ),

                      const Text(
                        "Home",
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight:
                              FontWeight.bold,
                          color:
                              Color(0xFF0B4B4B),
                        ),
                      ),

                      Container(
                        width: 50,
                        height: 50,

                        decoration: BoxDecoration(
                          color: const Color(
                            0xFF0B4B4B,
                          ),

                          borderRadius:
                              BorderRadius.circular(
                            16,
                          ),
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
    padding: const EdgeInsets.symmetric(
      horizontal: 16,
    ),

    child: Container(
      height: 220,
      width: double.infinity,

      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(28),

        image: const DecorationImage(
          image: AssetImage(
            "assets/images/homebg.png",
          ),
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
                crossAxisAlignment:
                    CrossAxisAlignment.start,

                children: [
                      Text(
  getHijriDate(),
  style: const TextStyle(
    color: Colors.white70,
    fontSize: 12,
    fontWeight: FontWeight.bold
  ),
),
const SizedBox(height: 4),
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

                 const SizedBox(height: 4),

                  Text(
                    prayerModel == null
                        ? "Loading..."
                        : prayerModel!.currentPrayer == "morning"
                            ? "No Prayer"
                            : "${prayerModel!.currentPrayer[0].toUpperCase()}${prayerModel!.currentPrayer.substring(1)}",
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  Text(
                    prayerModel == null
                        ? "--:--:--"
                        : _formatDuration(
                            prayerModel!.remainingDuration,
                          ),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
const SizedBox(height: 5),
                  const Text(
                    "Next Prayer Time",
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 13,
                      fontWeight: FontWeight.bold
                    ),
                  ),

                  const Spacer(),

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
                          fontWeight: FontWeight.bold
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
                          fontWeight: FontWeight.bold
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
  padding: const EdgeInsets.symmetric(
    horizontal: 16,
  ),

  child: Container(
    width: double.infinity,

    padding: const EdgeInsets.all(18),

    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(24),

      boxShadow: [
        BoxShadow(
          color: Colors.black.withValues(
            alpha: 0.05,
          ),
          blurRadius: 10,
        ),
      ],
    ),

    child: Column(
      crossAxisAlignment:
          CrossAxisAlignment.start,

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

        const Text(
          "فَإِنَّ مَعَ الْعُسْرِ يُسْرًا",
          textAlign: TextAlign.right,

          style: TextStyle(
            fontSize: 26,
            fontWeight: FontWeight.bold,
          ),
        ),

        const SizedBox(height: 12),

        const Text(
          "Indeed, with hardship comes ease.",
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),

        const SizedBox(height: 4),

        const Text(
          "Surah Ash-Sharh 94:6",
          style: TextStyle(
            color: Color.fromARGB(255, 175, 44, 155),
            fontSize: 13,
          ),
        ),
      ],
    ),
  ),
),
 GridView.count(
                  shrinkWrap: true,
                  physics:
                      const NeverScrollableScrollPhysics(),
                  crossAxisCount: 3,
                  crossAxisSpacing: 10,
                  mainAxisSpacing: 10,
                  childAspectRatio: 1.35,
                  children: [

                  GestureDetector(
  onTap: () {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const QuranScreen(),
      ),
    );
  },
  child: const FeatureCard(
    imagePath: 'assets/icons/quranshareef.png',
    title: 'Al-Quran',
  ),
),

FeatureCard(
  imagePath: 'assets/icons/Hadith.png',
  title: 'Hadith',
),

FeatureCard(
  imagePath: 'assets/icons/Duas.png',
  title: 'Duas',
),

FeatureCard(
  imagePath: 'assets/icons/Library.png',
  title: 'Books',
),
FeatureCard(
  imagePath: 'assets/icons/Qibla.png',
  title: 'Qibla',
),
FeatureCard(
  imagePath: 'assets/icons/Donation.png',
  title: 'Donation',
),
                  ],
                ),

const SizedBox(height: 15),

Padding(
  padding: const EdgeInsets.symmetric(
    horizontal: 15,
  ),

  child: Container(
    padding: const EdgeInsets.all(18),

    decoration: BoxDecoration(
      color: const Color(0xFF0B4B4B),
      borderRadius: BorderRadius.circular(24),
    ),

    child: Row(
      children: [

        Container(
          width: 55,
          height: 55,

          decoration: BoxDecoration(
            color: const Color(0xFFF4D17D),
            borderRadius:
                BorderRadius.circular(18),
          ),

          child: const Icon(
            Icons.video_call,
            color: Color(0xFF0B4B4B),
            size: 24,
          ),
        ),

        const SizedBox(width: 12),

        const Expanded(
          child: Column(
            crossAxisAlignment:
                CrossAxisAlignment.start,

            children: [

              Text(
                "Upcoming Class",
                style: TextStyle(
                  color: Color.fromARGB(179, 46, 232, 123),
                  fontSize: 12,
                ),
              ),

              SizedBox(height: 4),

              Text(
                "Quran Recitation - Syed Mudasir",
                style: TextStyle(
                  color: Color.fromARGB(255, 207, 171, 61),
                  fontSize: 13,
                  fontWeight:
                      FontWeight.bold,
                      
                ),
              ),

              SizedBox(height: 4),

              Text(
                "Today • 7:30 PM",
                style: TextStyle(
                  color: Color.fromARGB(179, 195, 188, 188),
                  fontSize: 13,
                ),
              ),
            ],
          ),
        ),

        Icon(
          Icons.arrow_forward_ios,
          color: Color(0xFFF4D17D),
          size: 18,
        ),
      ],
    ),
  ),
),
const SizedBox(height: 15),

Padding(
  padding: const EdgeInsets.symmetric(
    horizontal: 15,
  ),

  child: Row(
    children: [

      /// DHIKR
      Expanded(
        child: Container(
          height: 170,

          padding: const EdgeInsets.all(14),

          decoration: BoxDecoration(
            color: const Color(0xFFF5E8C8),
            borderRadius:
                BorderRadius.circular(22),
          ),

          child: Stack(
            children: [

              Column(
                crossAxisAlignment:
                    CrossAxisAlignment.start,

                children: [

                  const Text(
                    "TODAY'S DHIKR",
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight:
                          FontWeight.bold,
                      color:
                          Color(0xFF0B4B4B),
                    ),
                  ),

                  const SizedBox(height: 10),

                  const Text(
                    "SubhanAllah",
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight:
                          FontWeight.bold,
                    ),
                  ),

                 const SizedBox(height: 7),

                  Container(
                    width: 58,
                    height: 58,

                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color:
                            const Color(
                          0xFFD4AF37,
                        ),
                        width: 4,
                      ),
                    ),

                    child: const Center(
                      child: Text(
                        "73/100",
                        textAlign:
                            TextAlign.center,
                        style: TextStyle(
                          fontWeight:
                              FontWeight.bold,
                          fontSize: 11,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 8),

                  Container(
                    padding:
                        const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 4,
                    ),

                    decoration: BoxDecoration(
                      color: const Color(
                        0xFF0B4B4B,
                      ),
                      borderRadius:
                          BorderRadius.circular(
                        20,
                      ),
                    ),

                    child: const Text(
                      "Continue Dhikr",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 11,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),

      const SizedBox(width: 12),

      /// DUA
      Expanded(
        child: Container(
          height: 170,

          padding: const EdgeInsets.all(14),

          decoration: BoxDecoration(
            color: const Color(0xFFF5E8C8),
            borderRadius:
                BorderRadius.circular(22),
          ),

          child: Stack(
            children: [

             
              Column(
                crossAxisAlignment:
                    CrossAxisAlignment.start,

                children: [

                  const Text(
                    "DUA OF THE DAY",
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight:
                          FontWeight.bold,
                      color:
                          Color(0xFF0B4B4B),
                    ),
                  ),

                  const SizedBox(height: 14),

                  const Text(
                    "اللَّهُمَّ اجْعَلِ\nالْقُرْآنَ رَبِيعَ قَلْبِي",
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight:
                          FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 13),

                  const Text(
                    "O Allah, make the Quran the spring of my heart.",
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      height: 1.4,
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
),
const SizedBox(height: 10),


Padding(
  padding: const EdgeInsets.symmetric(
    horizontal: 15,
  ),

  child: Container(
    height: 120,

    decoration: BoxDecoration(
      borderRadius: BorderRadius.circular(26),

      image: const DecorationImage(
        image: AssetImage(
          "assets/images/peace.png",
        ),
        fit: BoxFit.cover,
      ),
    ),

    child: Padding(
      padding: const EdgeInsets.all(21),

      child: Row(
        children: [

          const Expanded(
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,

              mainAxisAlignment:
                  MainAxisAlignment.center,

              children: [

                Text(
                  "Feeling Anxious?",
                  style: TextStyle(
                    color: Color(0xFF0B4B4B),
                    fontSize: 16,
                    fontWeight:
                        FontWeight.bold,
                  ),
                ),

            const SizedBox(height: 8),

                Text(
                  "Calm your soul with Quran recitation.",
                  style: TextStyle(
                    color: Color.fromARGB(221, 0, 0, 0),
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    height: 1.4,
                  ),
                ),

                SizedBox(height: 8),

                Text(
                  "Surah Ar-Rahman",
                  style: TextStyle(
                    color: Color(0xFF0B4B4B),
                    fontWeight:
                        FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),

          Container(
            width: 40,
            height: 40,

            decoration: BoxDecoration(
              color: const Color(0xFF0B4B4B),
              borderRadius:
                  BorderRadius.circular(18),
            ),

            child: const Icon(
              Icons.play_arrow,
              color: Color(0xFFF4D17D),
              size: 20,
            ),
          ),
        ],
      ),
    ),
  ),
),


const SizedBox(height: 20),


          ],
        ),
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