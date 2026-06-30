class PrayerModel {
  final DateTime fajr;
  final DateTime sunrise;
  final DateTime dhuhr;
  final DateTime asr;
  final DateTime maghrib;
  final DateTime isha;

  final String currentPrayer;
  final String nextPrayer;

  final DateTime nextPrayerTime;

  final Duration remainingDuration;

  PrayerModel({
    required this.fajr,
    required this.sunrise,
    required this.dhuhr,
    required this.asr,
    required this.maghrib,
    required this.isha,
    required this.currentPrayer,
    required this.nextPrayer,
    required this.nextPrayerTime,
    required this.remainingDuration,
  });
}