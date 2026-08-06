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
  double get prayerProgress {
  final now = DateTime.now();

  DateTime startTime;
  DateTime endTime;

  switch (currentPrayer.toLowerCase()) {
    case 'fajr':
      startTime = fajr;
      endTime = dhuhr;
      break;

    case 'dhuhr':
      startTime = dhuhr;
      endTime = asr;
      break;

    case 'asr':
      startTime = asr;
      endTime = maghrib;
      break;

    case 'maghrib':
      startTime = maghrib;
      endTime = isha;
      break;

    case 'isha':
      startTime = isha;

      // Tomorrow's fajr
      endTime = fajr.add(const Duration(days: 1));
      break;

    default:
      return 0;
  }

  final total = endTime.difference(startTime).inSeconds;
  final elapsed = now.difference(startTime).inSeconds;

  return (elapsed / total).clamp(0.0, 1.0);
}
}
