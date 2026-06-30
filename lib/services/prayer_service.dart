// ignore_for_file: unused_import

import 'package:adhan_dart/adhan_dart.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';

import '../models/prayer_model.dart';

class PrayerService {
  PrayerModel getPrayerModel(Position position) {
    final coordinates = Coordinates(
      position.latitude,
      position.longitude,
    );

    final params = CalculationMethodParameters.karachi();

    params.madhab = Madhab.hanafi;

    final prayerTimes = PrayerTimes(
      date: DateTime.now(),
      coordinates: coordinates,
      calculationParameters: params,
    );

   final currentPrayer = prayerTimes.currentPrayer(
  date: DateTime.now(),
);
String currentPrayerName = currentPrayer.name;

if (currentPrayerName == "sunrise") {
  currentPrayerName = "morning";
}

final nextPrayer = prayerTimes.nextPrayer(
  date: DateTime.now(),
);

final nextPrayerTime =
    prayerTimes.timeForPrayer(nextPrayer).toLocal();

final remaining =
    nextPrayerTime.difference(DateTime.now());

return PrayerModel(
  fajr: prayerTimes.fajr.toLocal(),
  sunrise: prayerTimes.sunrise.toLocal(),
  dhuhr: prayerTimes.dhuhr.toLocal(),
  asr: prayerTimes.asr.toLocal(),
  maghrib: prayerTimes.maghrib.toLocal(),
  isha: prayerTimes.isha.toLocal(),

  currentPrayer: currentPrayerName,
  nextPrayer: nextPrayer.name,

  nextPrayerTime: nextPrayerTime,

  remainingDuration: remaining,
);

  }
  }