import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

import '../models/prayer_model.dart';

class PrayerNotificationService {
  PrayerNotificationService._();

  static final PrayerNotificationService instance =
      PrayerNotificationService._();

  final FlutterLocalNotificationsPlugin _notifications =
      FlutterLocalNotificationsPlugin();

  // ============================================================
  // CHANNEL
  // ============================================================

  static const String channelId = 'seeker_prayer_alerts';

  static const String channelName = 'Prayer Alerts';

  static const String channelDescription =
      'Prayer time notifications from Seeker';

  // ============================================================
  // TODAY NOTIFICATION IDS
  // ============================================================

  static const int fajrId = 1001;
  static const int dhuhrId = 1002;
  static const int asrId = 1003;
  static const int maghribId = 1004;
  static const int ishaId = 1005;

  // ============================================================
  // TOMORROW NOTIFICATION IDS
  //
  // Separate IDs are important.
  //
  // If we used the same ID for today and tomorrow, scheduling
  // tomorrow's Fajr could replace today's Fajr notification.
  // ============================================================

  static const int tomorrowFajrId = 2001;
  static const int tomorrowDhuhrId = 2002;
  static const int tomorrowAsrId = 2003;
  static const int tomorrowMaghribId = 2004;
  static const int tomorrowIshaId = 2005;

  // ============================================================
  // INITIALIZE
  // ============================================================

  Future<void> initialize() async {
    tz.initializeTimeZones();

    const androidSettings =
        AndroidInitializationSettings(
      '@mipmap/ic_launcher',
    );

    const initializationSettings =
        InitializationSettings(
      android: androidSettings,
    );

    await _notifications.initialize(
      settings: initializationSettings,
    );

    await _createPrayerChannel();

    await _requestPermissions();
  }

  // ============================================================
  // ANDROID NOTIFICATION CHANNEL
  // ============================================================

  Future<void> _createPrayerChannel() async {
    const channel = AndroidNotificationChannel(
      channelId,
      channelName,
      description: channelDescription,

      importance: Importance.max,

      playSound: true,

      sound: RawResourceAndroidNotificationSound(
        'allahu_akbar_4x',
      ),

      enableVibration: true,
    );

    final androidPlugin =
        _notifications
            .resolvePlatformSpecificImplementation<
                AndroidFlutterLocalNotificationsPlugin>();

    await androidPlugin?.createNotificationChannel(
      channel,
    );
  }

  // ============================================================
  // PERMISSIONS
  // ============================================================

  Future<void> _requestPermissions() async {
    final androidPlugin =
        _notifications
            .resolvePlatformSpecificImplementation<
                AndroidFlutterLocalNotificationsPlugin>();

    await androidPlugin?.requestNotificationsPermission();

    await androidPlugin?.requestExactAlarmsPermission();
  }

  // ============================================================
  // SCHEDULE ONE PRAYER
  // ============================================================

  Future<void> schedulePrayer({
    required int id,
    required String prayerName,
    required DateTime prayerTime,
  }) async {
    final scheduledTime =
        tz.TZDateTime.from(
      prayerTime,
      tz.local,
    );

    final now =
        tz.TZDateTime.now(
      tz.local,
    );

    // Do not schedule an already-passed prayer.
    if (scheduledTime.isBefore(now)) {
      return;
    }

    const androidDetails =
        AndroidNotificationDetails(
      channelId,
      channelName,

      channelDescription:
          channelDescription,

      importance: Importance.max,
      priority: Priority.max,

      playSound: true,

      sound:
          RawResourceAndroidNotificationSound(
        'allahu_akbar_4x',
      ),

      enableVibration: true,

      category:
          AndroidNotificationCategory.alarm,

      autoCancel: true,
    );

    const notificationDetails =
        NotificationDetails(
      android: androidDetails,
    );

    await _notifications.zonedSchedule(
      id: id,

      title:
          '$prayerName Prayer',

      body:
          'It is time for $prayerName prayer.',

      scheduledDate:
          scheduledTime,

      notificationDetails:
          notificationDetails,

      androidScheduleMode:
          AndroidScheduleMode
              .exactAllowWhileIdle,

      payload:
          'prayer:$prayerName',
    );
  }

  // ============================================================
  // SCHEDULE TODAY + TOMORROW
  //
  // enabledPrayers should contain:
  //
  // fajr
  // dhuhr
  // asr
  // maghrib
  // isha
  //
  // Only enabled prayers are scheduled.
  // ============================================================

  Future<void> schedulePrayerNotifications({
    required PrayerModel today,
    required PrayerModel tomorrow,
    required Set<String> enabledPrayers,
  }) async {
    // ----------------------------------------------------------
    // First remove existing prayer notifications.
    //
    // This prevents duplicate or outdated alarms when prayer
    // times/location are recalculated.
    // ----------------------------------------------------------

    await cancelAllPrayerNotifications();

    // ==========================================================
    // TODAY
    // ==========================================================

    if (enabledPrayers.contains('fajr')) {
      await schedulePrayer(
        id: fajrId,
        prayerName: 'Fajr',
        prayerTime: today.fajr,
      );
    }

    if (enabledPrayers.contains('dhuhr')) {
      await schedulePrayer(
        id: dhuhrId,
        prayerName: 'Dhuhr',
        prayerTime: today.dhuhr,
      );
    }

    if (enabledPrayers.contains('asr')) {
      await schedulePrayer(
        id: asrId,
        prayerName: 'Asr',
        prayerTime: today.asr,
      );
    }

    if (enabledPrayers.contains('maghrib')) {
      await schedulePrayer(
        id: maghribId,
        prayerName: 'Maghrib',
        prayerTime: today.maghrib,
      );
    }

    if (enabledPrayers.contains('isha')) {
      await schedulePrayer(
        id: ishaId,
        prayerName: 'Isha',
        prayerTime: today.isha,
      );
    }

    // ==========================================================
    // TOMORROW
    // ==========================================================

    if (enabledPrayers.contains('fajr')) {
      await schedulePrayer(
        id: tomorrowFajrId,
        prayerName: 'Fajr',
        prayerTime: tomorrow.fajr,
      );
    }

    if (enabledPrayers.contains('dhuhr')) {
      await schedulePrayer(
        id: tomorrowDhuhrId,
        prayerName: 'Dhuhr',
        prayerTime: tomorrow.dhuhr,
      );
    }

    if (enabledPrayers.contains('asr')) {
      await schedulePrayer(
        id: tomorrowAsrId,
        prayerName: 'Asr',
        prayerTime: tomorrow.asr,
      );
    }

    if (enabledPrayers.contains('maghrib')) {
      await schedulePrayer(
        id: tomorrowMaghribId,
        prayerName: 'Maghrib',
        prayerTime: tomorrow.maghrib,
      );
    }

    if (enabledPrayers.contains('isha')) {
      await schedulePrayer(
        id: tomorrowIshaId,
        prayerName: 'Isha',
        prayerTime: tomorrow.isha,
      );
    }
  }

  // ============================================================
  // CANCEL ONE PRAYER
  //
  // Cancels BOTH today's and tomorrow's alarm for that prayer.
  // ============================================================

 // ============================================================
// CANCEL ONE NOTIFICATION BY ID
// ============================================================

Future<void> cancelPrayer(int id) async {
  await _notifications.cancel(
    id: id,
  );
}
// ============================================================
// CANCEL TODAY + TOMORROW FOR ONE PRAYER
// ============================================================

Future<void> cancelPrayerByName(
  String prayerName,
) async {
  switch (prayerName.toLowerCase()) {
    case 'fajr':
      await _cancelIds(
        fajrId,
        tomorrowFajrId,
      );
      break;

    case 'dhuhr':
      await _cancelIds(
        dhuhrId,
        tomorrowDhuhrId,
      );
      break;

    case 'asr':
      await _cancelIds(
        asrId,
        tomorrowAsrId,
      );
      break;

    case 'maghrib':
      await _cancelIds(
        maghribId,
        tomorrowMaghribId,
      );
      break;

    case 'isha':
      await _cancelIds(
        ishaId,
        tomorrowIshaId,
      );
      break;
  }
}

  // ============================================================
  // CANCEL TWO IDS
  // ============================================================

  Future<void> _cancelIds(
    int firstId,
    int secondId,
  ) async {
    await _notifications.cancel(
      id: firstId,
    );

    await _notifications.cancel(
      id: secondId,
    );
  }

  // ============================================================
  // CANCEL ALL PRAYER NOTIFICATIONS
  // ============================================================

  Future<void> cancelAllPrayerNotifications() async {
    const ids = <int>[
      fajrId,
      dhuhrId,
      asrId,
      maghribId,
      ishaId,
      tomorrowFajrId,
      tomorrowDhuhrId,
      tomorrowAsrId,
      tomorrowMaghribId,
      tomorrowIshaId,
    ];

    for (final id in ids) {
      await _notifications.cancel(
        id: id,
      );
    }
  }

  // ============================================================
  // GET PENDING NOTIFICATIONS
  // ============================================================

  Future<List<PendingNotificationRequest>>
      getPendingNotifications() async {
    return await _notifications
        .pendingNotificationRequests();
  }

  // ============================================================
  // CHECK NOTIFICATION PERMISSION
  // ============================================================

  Future<bool> areNotificationsEnabled() async {
    final androidPlugin =
        _notifications
            .resolvePlatformSpecificImplementation<
                AndroidFlutterLocalNotificationsPlugin>();

    return await androidPlugin
            ?.areNotificationsEnabled() ??
        false;
  }

  // ============================================================
  // REQUEST NOTIFICATION PERMISSION
  // ============================================================

  Future<void> openNotificationSettings() async {
    final androidPlugin =
        _notifications
            .resolvePlatformSpecificImplementation<
                AndroidFlutterLocalNotificationsPlugin>();

    await androidPlugin
        ?.requestNotificationsPermission();
  }
}