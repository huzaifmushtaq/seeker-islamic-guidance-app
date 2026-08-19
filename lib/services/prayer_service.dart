import 'package:adhan_dart/adhan_dart.dart';
import 'package:geolocator/geolocator.dart';

import '../models/prayer_model.dart';

class PrayerService {
  // ============================================================
  // CALCULATION PARAMETERS
  // ============================================================

  CalculationParameters _getCalculationParameters() {
    final params = CalculationMethodParameters.karachi();

    params.madhab = Madhab.hanafi;

    return params;
  }

  // ============================================================
  // CURRENT DAY PRAYER MODEL
  // ============================================================

  PrayerModel getPrayerModel(Position position) {
    final now = DateTime.now();

    return getPrayerModelForDate(
      position,
      now,
    );
  }

  // ============================================================
  // PRAYER MODEL FOR A SPECIFIC DATE
  // ============================================================

  PrayerModel getPrayerModelForDate(
    Position position,
    DateTime date,
  ) {
    final now = DateTime.now();

    final coordinates = Coordinates(
      position.latitude,
      position.longitude,
    );

    final params = _getCalculationParameters();

    final prayerTimes = PrayerTimes(
      date: date,
      coordinates: coordinates,
      calculationParameters: params,
    );

    // ============================================================
    // CHECK WHETHER THIS IS TODAY
    // ============================================================

    final isToday =
        date.year == now.year &&
        date.month == now.month &&
        date.day == now.day;

    // ============================================================
    // FUTURE DATE
    // ============================================================

    if (!isToday) {
      final fajr = prayerTimes.fajr.toLocal();

      return PrayerModel(
        fajr: fajr,
        sunrise: prayerTimes.sunrise.toLocal(),
        dhuhr: prayerTimes.dhuhr.toLocal(),
        asr: prayerTimes.asr.toLocal(),
        maghrib: prayerTimes.maghrib.toLocal(),
        isha: prayerTimes.isha.toLocal(),

        currentPrayer: '',
        nextPrayer: 'fajr',

        nextPrayerTime: fajr,

        remainingDuration:
            fajr.difference(now),
      );
    }

    // ============================================================
    // CURRENT PRAYER
    // ============================================================

    final currentPrayer =
        prayerTimes.currentPrayer(
      date: now,
    );

    var currentPrayerName =
        currentPrayer.name;

    if (currentPrayerName == 'sunrise') {
      currentPrayerName = 'morning';
    }

    // ============================================================
    // NEXT PRAYER
    // ============================================================

    final nextPrayer =
        prayerTimes.nextPrayer(
      date: now,
    );

    var nextPrayerName =
        nextPrayer.name;

    DateTime nextPrayerTime =
        prayerTimes
            .timeForPrayer(
              nextPrayer,
            )
            .toLocal();

    // ============================================================
    // AFTER ISHA → TOMORROW'S FAJR
    // ============================================================

    if (nextPrayerTime.isBefore(now)) {
      final tomorrow =
          date.add(
        const Duration(days: 1),
      );

      final tomorrowPrayerTimes =
          PrayerTimes(
        date: tomorrow,
        coordinates: coordinates,
        calculationParameters: params,
      );

      nextPrayerName = 'fajr';

      nextPrayerTime =
          tomorrowPrayerTimes.fajr.toLocal();
    }

    // ============================================================
    // REMAINING TIME
    // ============================================================

    final remaining =
        nextPrayerTime.difference(now);

    // ============================================================
    // RETURN TODAY'S MODEL
    // ============================================================

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

  // ============================================================
  // TOMORROW'S PRAYER MODEL
  // ============================================================

  PrayerModel getTomorrowPrayerModel(
    Position position,
  ) {
    final tomorrow =
        DateTime.now().add(
      const Duration(days: 1),
    );

    return getPrayerModelForDate(
      position,
      tomorrow,
    );
  }
}