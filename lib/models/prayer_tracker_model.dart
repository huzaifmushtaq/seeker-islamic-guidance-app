class PrayerTrackerModel {
  bool fajr;
  bool dhuhr;
  bool asr;
  bool maghrib;
  bool isha;

  PrayerTrackerModel({
    this.fajr = false,
    this.dhuhr = false,
    this.asr = false,
    this.maghrib = false,
    this.isha = false,
  });

  int get completedCount =>
      [fajr, dhuhr, asr, maghrib, isha].where((e) => e).length;
}
