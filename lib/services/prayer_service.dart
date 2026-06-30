import 'package:adhan_dart/adhan_dart.dart';
import 'package:geolocator/geolocator.dart';

import '../models/prayer_model.dart';

class PrayerService {
  PrayerModel getPrayerModel(Position position) {
    final now = DateTime.now();
    final coordinates = Coordinates(position.latitude, position.longitude);

    final params = CalculationMethodParameters.karachi()
      ..madhab = Madhab.hanafi;

    final prayerTimes = PrayerTimes(
      date: now,
      coordinates: coordinates,
      calculationParameters: params,
    );

    final currentPrayer = prayerTimes.currentPrayer(date: now);
    var currentPrayerName = currentPrayer.name;

    if (currentPrayerName == 'sunrise') {
      currentPrayerName = 'morning';
    }

    var nextPrayer = prayerTimes.nextPrayer(date: now);
    var nextPrayerName = nextPrayer.name;
    DateTime nextPrayerTime = prayerTimes.timeForPrayer(nextPrayer).toLocal();

    if (nextPrayerTime.isBefore(now)) {
      final tomorrowPrayerTimes = PrayerTimes(
        date: now.add(const Duration(days: 1)),
        coordinates: coordinates,
        calculationParameters: params,
      );

      nextPrayerName = 'fajr';
      nextPrayerTime = tomorrowPrayerTimes.fajr.toLocal();
    }

    final remaining = nextPrayerTime.difference(now);

    return PrayerModel(
      fajr: prayerTimes.fajr.toLocal(),
      sunrise: prayerTimes.sunrise.toLocal(),
      dhuhr: prayerTimes.dhuhr.toLocal(),
      asr: prayerTimes.asr.toLocal(),
      maghrib: prayerTimes.maghrib.toLocal(),
      isha: prayerTimes.isha.toLocal(),
      currentPrayer: currentPrayerName,
      nextPrayer: nextPrayerName,
      nextPrayerTime: nextPrayerTime,
      remainingDuration: remaining,
    );
  }
}
