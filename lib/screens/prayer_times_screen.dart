import 'dart:async';

import 'package:flutter/material.dart';
import 'package:hijri/hijri_calendar.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/prayer_notification_service.dart';
import '../models/prayer_model.dart';

class PrayerTimesScreen extends StatefulWidget {
  final PrayerModel prayerModel;
  final String city;

  const PrayerTimesScreen({
    super.key,
    required this.prayerModel,
    required this.city,
  });

  @override
  State<PrayerTimesScreen> createState() => _PrayerTimesScreenState();
}

class _PrayerTimesScreenState extends State<PrayerTimesScreen>
    with WidgetsBindingObserver {
  Timer? _timer;

  // ------------------------------------------------------------
  // Seeker colours
  // ------------------------------------------------------------

  static const Color _background = Color(0xffFBF8F1);
  static const Color _text = Color(0xff182C2A);
  static const Color _teal = Color(0xff0B4B4B);
  static const Color _gold = Color(0xffF5C76B);

  // ------------------------------------------------------------
  // Notification preferences
  // ------------------------------------------------------------

  final Map<String, bool> _notifications = {
    'fajr': true,
    'dhuhr': true,
    'asr': true,
    'maghrib': true,
    'isha': true,
  };

 Future<void> _schedulePrayerNotification(
  String prayer,
) async {
  DateTime? prayerTime;

  switch (prayer) {
    case 'fajr':
      prayerTime =
          widget.prayerModel.fajr;
      break;

    case 'dhuhr':
      prayerTime =
          widget.prayerModel.dhuhr;
      break;

    case 'asr':
      prayerTime =
          widget.prayerModel.asr;
      break;

    case 'maghrib':
      prayerTime =
          widget.prayerModel.maghrib;
      break;

    case 'isha':
      prayerTime =
          widget.prayerModel.isha;
      break;
  }

  if (prayerTime == null) {
    return;
  }

  final id =
      _notificationIdForPrayer(
    prayer,
  );

  final displayName =
      prayer[0].toUpperCase() +
          prayer.substring(1);

  await PrayerNotificationService
      .instance
      .schedulePrayer(
    id: id,
    prayerName: displayName,
    prayerTime: prayerTime,
  );
}

Future<void> _cancelPrayerNotification(
  String prayer,
) async {
  final id =
      _notificationIdForPrayer(
    prayer,
  );

  await PrayerNotificationService
      .instance
      .cancelPrayer(
    id,
  );
}

int _notificationIdForPrayer(
  String prayer,
) {
  switch (prayer) {
    case 'fajr':
      return 1001;

    case 'dhuhr':
      return 1002;

    case 'asr':
      return 1003;

    case 'maghrib':
      return 1004;

    case 'isha':
      return 1005;

    default:
      return 1099;
  }
}

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addObserver(this);

    _loadNotificationPreferences();

    // Keeps countdown updated every second.
    _timer = Timer.periodic(
      const Duration(seconds: 1),
      (_) {
        if (mounted) {
          setState(() {});
        }
      },
    );
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _timer?.cancel();
    super.dispose();
  }

  // ------------------------------------------------------------
  // App lifecycle
  // ------------------------------------------------------------

  @override
  void didChangeAppLifecycleState(
    AppLifecycleState state,
  ) {
    if (state == AppLifecycleState.resumed) {
      _loadNotificationPreferences();
    }
  }

  // ------------------------------------------------------------
  // Persistent notification preferences
  // ------------------------------------------------------------

  Future<void> _loadNotificationPreferences() async {
    final prefs = await SharedPreferences.getInstance();

    if (!mounted) return;

    setState(() {
      _notifications['fajr'] =
          prefs.getBool('prayer_notification_fajr') ?? true;

      _notifications['dhuhr'] =
          prefs.getBool('prayer_notification_dhuhr') ?? true;

      _notifications['asr'] =
          prefs.getBool('prayer_notification_asr') ?? true;

      _notifications['maghrib'] =
          prefs.getBool('prayer_notification_maghrib') ?? true;

      _notifications['isha'] =
          prefs.getBool('prayer_notification_isha') ?? true;

     
    });
     await _scheduleEnabledPrayerNotifications();
  }
  Future<void> _scheduleEnabledPrayerNotifications() async {
  final prayers = <String>[
    'fajr',
    'dhuhr',
    'asr',
    'maghrib',
    'isha',
  ];

  for (final prayer in prayers) {
    if (notificationEnabled(prayer)) {
      await _schedulePrayerNotification(
        prayer,
      );
    } else {
      await _cancelPrayerNotification(
        prayer,
      );
    }
  }
}

 Future<void> _toggleNotification(
  String prayer,
) async {
  final newValue =
      !(_notifications[prayer] ?? true);

  setState(() {
    _notifications[prayer] = newValue;
  });

  final prefs =
      await SharedPreferences.getInstance();

  await prefs.setBool(
    'prayer_notification_$prayer',
    newValue,
  );

  if (newValue) {
    await _schedulePrayerNotification(
      prayer,
    );
  } else {
    await _cancelPrayerNotification(
      prayer,
    );
  }
}

    /*
      IMPORTANT:

      The actual Android scheduled notification will be
      connected here in the next step.

      When enabled:
        prayer time -> Allahu Akbar x4

      When disabled:
        scheduled notification -> cancelled
    */

  // ------------------------------------------------------------
  // Time helpers
  // ------------------------------------------------------------

  String formatTime(
    BuildContext context,
    DateTime time,
  ) {
    return TimeOfDay.fromDateTime(time).format(context);
  }

  static const int ishraqOffsetMinutes = 20;

  DateTime getIshraqTime() {
    return widget.prayerModel.sunrise.add(
      const Duration(
        minutes: ishraqOffsetMinutes,
      ),
    );
  }

  DateTime getSunsetTime() {
    return widget.prayerModel.maghrib;
  }

  String getHijriDate() {
    HijriCalendar.setLocal("en");

    final hijri = HijriCalendar.now();

    return "${hijri.hDay} "
        "${hijri.longMonthName} "
        "${hijri.hYear} AH";
  }

  // ------------------------------------------------------------
  // Current prayer
  // ------------------------------------------------------------

  String getCurrentPrayerName() {
    final prayer = widget.prayerModel.currentPrayer;

    if (prayer == 'morning') {
      return 'Morning';
    }

    if (prayer.isEmpty) {
      return 'Morning';
    }

    return prayer[0].toUpperCase() +
        prayer.substring(1);
  }

  String getNextPrayerName() {
    final prayer = widget.prayerModel.nextPrayer;

    if (prayer.isEmpty) {
      return 'Fajr';
    }

    return prayer[0].toUpperCase() +
        prayer.substring(1);
  }

  // ------------------------------------------------------------
  // Countdown
  // ------------------------------------------------------------

  Duration getRemainingDuration() {
    final now = DateTime.now();

    final target =
        widget.prayerModel.nextPrayerTime;

    if (target.isBefore(now)) {
      return Duration.zero;
    }

    return target.difference(now);
  }

  String formatCountdown(
    Duration duration,
  ) {
    final hours = duration.inHours;

    final minutes =
        duration.inMinutes.remainder(60);

    final seconds =
        duration.inSeconds.remainder(60);

    return '${hours.toString().padLeft(2, '0')}:'
        '${minutes.toString().padLeft(2, '0')}:'
        '${seconds.toString().padLeft(2, '0')}';
  }

  // ------------------------------------------------------------
  // Prayer notification status
  // ------------------------------------------------------------

  bool notificationEnabled(
    String prayer,
  ) {
    return _notifications[prayer] ?? true;
  }

  // ------------------------------------------------------------
  // Build
  // ------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();

    final date =
        DateFormat(
          "EEEE, d MMMM yyyy",
        ).format(now);

    final remaining =
        getRemainingDuration();

    return Scaffold(
      backgroundColor: _background,

      body: SafeArea(
        child: SingleChildScrollView(
          physics:
            const ClampingScrollPhysics(),

          child: Column(
            children: [

              // ==================================================
              // HEADER
              // ==================================================

              Container(
                width: double.infinity,

                padding:
                    const EdgeInsets.fromLTRB(
                  18,
                  14,
                  18,
                  28,
                ),

                decoration:
                    const BoxDecoration(
                  color: _teal,

                  borderRadius:
                      BorderRadius.only(
                    bottomLeft:
                        Radius.circular(34),
                    bottomRight:
                        Radius.circular(34),
                  ),
                ),

                child: Column(
                  children: [

                    // ------------------------------------------------
                    // App bar
                    // ------------------------------------------------

                    Row(
                      children: [

                        _HeaderIconButton(
                          icon: Icons
                              .arrow_back_ios_new_rounded,

                          onTap: () {
                            Navigator.pop(
                              context,
                            );
                          },
                        ),

                        const Spacer(),

                        const Text(
                          'Prayer Times',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 21,
                            fontWeight:
                                FontWeight.w800,
                          ),
                        ),

                        const Spacer(),

                        _HeaderIconButton(
                          icon:
                              Icons.tune_rounded,
                          onTap:
                              _showPrayerSettings,
                        ),
                      ],
                    ),

                    const SizedBox(
                      height: 20,
                    ),

                    // ------------------------------------------------
                    // Date
                    // ------------------------------------------------

                    Text(
                      date,
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 14,
                        fontWeight:
                            FontWeight.w500,
                      ),
                    ),

                    const SizedBox(
                      height: 5,
                    ),

                    Text(
                      getHijriDate(),
                      style: const TextStyle(
                        color: _gold,
                        fontSize: 13,
                        fontWeight:
                            FontWeight.w700,
                      ),
                    ),

                    const SizedBox(
                      height: 22,
                    ),

                    // ==================================================
                    // CURRENT PRAYER HERO
                    // ==================================================

                    Container(
                      width: double.infinity,

                      padding:
                          const EdgeInsets.fromLTRB(
                        22,
                        22,
                        22,
                        20,
                      ),

                      decoration:
                          BoxDecoration(
                        color: Colors.white
                            .withValues(
                          alpha: .10,
                        ),

                        borderRadius:
                            BorderRadius.circular(
                          26,
                        ),

                        border: Border.all(
                          color: Colors.white
                              .withValues(
                            alpha: .10,
                          ),
                        ),
                      ),

                      child: Column(
                        children: [

                          Row(
                            mainAxisAlignment:
                                MainAxisAlignment
                                    .center,

                            children: [

                              Container(
                                width: 8,
                                height: 8,

                                decoration:
                                    const BoxDecoration(
                                  color: _gold,
                                  shape:
                                      BoxShape.circle,
                                ),
                              ),

                              const SizedBox(
                                width: 8,
                              ),

                              const Text(
                                'NEXT PRAYER',
                                style: TextStyle(
                                  color:
                                      Colors.white70,
                                  fontSize: 10,
                                  fontWeight:
                                      FontWeight.w800,
                                  letterSpacing:
                                      1.5,
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(
                            height: 10,
                          ),

                          Text(
                            getNextPrayerName(),
                            style:
                                const TextStyle(
                              color: Colors.white,
                              fontSize: 30,
                              fontWeight:
                                  FontWeight.w800,
                            ),
                          ),

                          const SizedBox(
                            height: 5,
                          ),

                          Text(
                            formatTime(
                              context,
                              widget.prayerModel
                                  .nextPrayerTime,
                            ),
                            style:
                                const TextStyle(
                              color: _gold,
                              fontSize: 16,
                              fontWeight:
                                  FontWeight.w700,
                            ),
                          ),

                          const SizedBox(
                            height: 18,
                          ),

                          Text(
                            formatCountdown(
                              remaining,
                            ),
                            style:
                                const TextStyle(
                              color: Colors.white,
                              fontSize: 38,
                              fontWeight:
                                  FontWeight.w700,
                              letterSpacing: 2,
                            ),
                          ),

                          const SizedBox(
                            height: 2,
                          ),

                          const Text(
                            'remaining',
                            style: TextStyle(
                              color:
                                  Colors.white54,
                              fontSize: 11,
                              fontWeight:
                                  FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(
                      height: 16,
                    ),

                    // ==================================================
                    // LOCATION
                    // ==================================================

                    Container(
                      width: double.infinity,

                      padding:
                          const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 13,
                      ),

                      decoration:
                          BoxDecoration(
                        color: Colors.white
                            .withValues(
                          alpha: .08,
                        ),
                        borderRadius:
                            BorderRadius.circular(
                          17,
                        ),
                      ),

                      child: Row(
                        children: [

                          const Icon(
                            Icons.location_on_rounded,
                            color: _gold,
                            size: 20,
                          ),

                          const SizedBox(
                            width: 10,
                          ),

                          Expanded(
                            child: Column(
                              crossAxisAlignment:
                                  CrossAxisAlignment
                                      .start,

                              children: [

                                const Text(
                                  'Prayer times for',
                                  style: TextStyle(
                                    color:
                                        Colors.white54,
                                    fontSize: 10,
                                    fontWeight:
                                        FontWeight.w600,
                                  ),
                                ),

                                const SizedBox(
                                  height: 2,
                                ),

                                Text(
                                  widget.city,
                                  maxLines: 1,
                                  overflow:
                                      TextOverflow
                                          .ellipsis,

                                  style:
                                      const TextStyle(
                                    color:
                                        Colors.white,
                                    fontSize: 14,
                                    fontWeight:
                                        FontWeight.w700,
                                  ),
                                ),
                              ],
                            ),
                          ),

                          const Icon(
                            Icons
                                .chevron_right_rounded,
                            color:
                                Colors.white38,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              // ==================================================
              // CONTENT
              // ==================================================

              Padding(
                padding:
                    const EdgeInsets.fromLTRB(
                  18,
                  22,
                  18,
                  30,
                ),

                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.start,

                  children: [

                    // ------------------------------------------------
                    // Prayer times heading
                    // ------------------------------------------------

                    const Padding(
                      padding:
                          EdgeInsets.symmetric(
                        horizontal: 3,
                      ),

                      child: Row(
                        children: [

                          Text(
                            'PRAYER TIMES',
                            style: TextStyle(
                              color: _text,
                              fontSize: 12,
                              fontWeight:
                                  FontWeight.w800,
                              letterSpacing: 1.2,
                            ),
                          ),

                          Spacer(),

                          Text(
                            'ALERT',
                            style: TextStyle(
                              color: Colors.black38,
                              fontSize: 9,
                              fontWeight:
                                  FontWeight.w700,
                              letterSpacing: 1,
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(
                      height: 10,
                    ),

                    // ==================================================
                    // PRAYER LIST
                    // ==================================================

                    Container(
                      width: double.infinity,

                      decoration:
                          BoxDecoration(
                        color: Colors.white,

                        borderRadius:
                            BorderRadius.circular(
                          24,
                        ),

                        boxShadow: [
                          BoxShadow(
                            color: Colors.black
                                .withValues(
                              alpha: .045,
                            ),
                            blurRadius: 18,
                            offset:
                                const Offset(
                              0,
                              6,
                            ),
                          ),
                        ],
                      ),

                      child: Column(
                        children: [

                          PrayerRow(
                            icon:
                                Icons.nightlight_round,
                            title: 'Fajr',
                            subtitle:
                                'Morning prayer',
                            time: formatTime(
                              context,
                              widget.prayerModel
                                  .fajr,
                            ),
                            isCurrent:
                                widget.prayerModel
                                        .currentPrayer ==
                                    'fajr',
                            notificationEnabled:
                                notificationEnabled(
                              'fajr',
                            ),
                            onNotificationTap:
                                () =>
                                    _toggleNotification(
                              'fajr',
                            ),
                          ),

                          PrayerRow(
                            icon:
                                Icons.wb_sunny_rounded,
                            title: 'Dhuhr',
                            subtitle:
                                'Midday prayer',
                            time: formatTime(
                              context,
                              widget.prayerModel
                                  .dhuhr,
                            ),
                            isCurrent:
                                widget.prayerModel
                                        .currentPrayer ==
                                    'dhuhr',
                            notificationEnabled:
                                notificationEnabled(
                              'dhuhr',
                            ),
                            onNotificationTap:
                                () =>
                                    _toggleNotification(
                              'dhuhr',
                            ),
                          ),

                          PrayerRow(
                            icon:
                                Icons.cloud_outlined,
                            title: 'Asr',
                            subtitle:
                                'Afternoon prayer',
                            time: formatTime(
                              context,
                              widget.prayerModel
                                  .asr,
                            ),
                            isCurrent:
                                widget.prayerModel
                                        .currentPrayer ==
                                    'asr',
                            notificationEnabled:
                                notificationEnabled(
                              'asr',
                            ),
                            onNotificationTap:
                                () =>
                                    _toggleNotification(
                              'asr',
                            ),
                          ),

                          PrayerRow(
                            icon:
                                Icons.wb_twilight_rounded,
                            title: 'Maghrib',
                            subtitle:
                                'Sunset prayer',
                            time: formatTime(
                              context,
                              widget.prayerModel
                                  .maghrib,
                            ),
                            isCurrent:
                                widget.prayerModel
                                        .currentPrayer ==
                                    'maghrib',
                            notificationEnabled:
                                notificationEnabled(
                              'maghrib',
                            ),
                            onNotificationTap:
                                () =>
                                    _toggleNotification(
                              'maghrib',
                            ),
                          ),

                          PrayerRow(
                            icon:
                                Icons.dark_mode_rounded,
                            title: 'Isha',
                            subtitle:
                                'Night prayer',
                            time: formatTime(
                              context,
                              widget.prayerModel
                                  .isha,
                            ),
                            isCurrent:
                                widget.prayerModel
                                        .currentPrayer ==
                                    'isha',
                            notificationEnabled:
                                notificationEnabled(
                              'isha',
                            ),
                            onNotificationTap:
                                () =>
                                    _toggleNotification(
                              'isha',
                            ),
                            isLast: true,
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(
                      height: 24,
                    ),

                    // ==================================================
                    // SUN & ISHRAQ
                    // ==================================================

                    const Padding(
                      padding:
                          EdgeInsets.symmetric(
                        horizontal: 3,
                      ),

                      child: Text(
                        'SUN & NAFILAH',
                        style: TextStyle(
                          color: _text,
                          fontSize: 12,
                          fontWeight:
                              FontWeight.w800,
                          letterSpacing: 1.2,
                        ),
                      ),
                    ),

                    const SizedBox(
                      height: 10,
                    ),

                    Container(
                      width: double.infinity,

                      padding:
                          const EdgeInsets.all(
                        18,
                      ),

                      decoration:
                          BoxDecoration(
                        color: Colors.white,

                        borderRadius:
                            BorderRadius.circular(
                          22,
                        ),

                        boxShadow: [
                          BoxShadow(
                            color: Colors.black
                                .withValues(
                              alpha: .04,
                            ),
                            blurRadius: 15,
                            offset:
                                const Offset(
                              0,
                              5,
                            ),
                          ),
                        ],
                      ),

                      child: Row(
                        children: [

                          Expanded(
                            child: _SunTime(
                              icon:
                                  Icons.wb_sunny_outlined,
                              title: 'Sunrise',
                              time: formatTime(
                                context,
                                widget.prayerModel
                                    .sunrise,
                              ),
                            ),
                          ),

                          Container(
                            width: 1,
                            height: 42,
                            color:
                                Colors.black12,
                          ),

                          Expanded(
                            child: _SunTime(
                              icon:
                                  Icons.wb_sunny_rounded,
                              title: 'Ishraq',
                              time: formatTime(
                                context,
                                getIshraqTime(),
                              ),
                            ),
                          ),

                          Container(
                            width: 1,
                            height: 42,
                            color:
                                Colors.black12,
                          ),

                          Expanded(
                            child: _SunTime(
                              icon:
                                  Icons
                                      .wb_twilight_rounded,
                              title: 'Sunset',
                              time: formatTime(
                                context,
                                getSunsetTime(),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(
                      height: 24,
                    ),

                    // ==================================================
                    // NOTIFICATION INFO
                    // ==================================================

                 
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ------------------------------------------------------------
  // Settings
  // ------------------------------------------------------------

  void _showPrayerSettings() {
    showModalBottomSheet<void>(
      context: context,

      backgroundColor:
          _background,

      shape:
          const RoundedRectangleBorder(
        borderRadius:
            BorderRadius.vertical(
          top: Radius.circular(28),
        ),
      ),

      builder: (context) {
        return SafeArea(
          child: Padding(
            padding:
                const EdgeInsets.fromLTRB(
              22,
              14,
              22,
              28,
            ),

            child: Column(
              mainAxisSize:
                  MainAxisSize.min,

              crossAxisAlignment:
                  CrossAxisAlignment.start,

              children: [

                Center(
                  child: Container(
                    width: 42,
                    height: 4,

                    decoration:
                        BoxDecoration(
                      color: Colors.black12,
                      borderRadius:
                          BorderRadius.circular(
                        5,
                      ),
                    ),
                  ),
                ),

                const SizedBox(
                  height: 22,
                ),

                const Text(
                  'Prayer Settings',
                  style: TextStyle(
                    color: _text,
                    fontSize: 20,
                    fontWeight:
                        FontWeight.w800,
                  ),
                ),

                const SizedBox(
                  height: 18,
                ),

                _SettingsTile(
                  icon:
                      Icons.calculate_outlined,
                  title:
                      'Calculation Method',
                  subtitle:
                      'Prayer calculation settings',
                  onTap: () {
                    Navigator.pop(context);

                    ScaffoldMessenger.of(
                      this.context,
                    ).showSnackBar(
                      const SnackBar(
                        content: Text(
                          'Calculation method settings will be connected to the prayer service.',
                        ),
                      ),
                    );
                  },
                ),

            
              ],
            ),
          ),
        );
      },
    );
  }
}

// ============================================================================
// HEADER BUTTON
// ============================================================================

class _HeaderIconButton
    extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;

  const _HeaderIconButton({
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color:
          Colors.white.withValues(
        alpha: .10,
      ),

      borderRadius:
          BorderRadius.circular(14),

      child: InkWell(
        onTap: onTap,

        borderRadius:
            BorderRadius.circular(14),

        child: SizedBox(
          width: 42,
          height: 42,

          child: Icon(
            icon,
            color: Colors.white,
            size: 19,
          ),
        ),
      ),
    );
  }
}

// ============================================================================
// PRAYER ROW
// ============================================================================

class PrayerRow
    extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final String time;
  final bool isCurrent;
  final bool notificationEnabled;
  final VoidCallback onNotificationTap;
  final bool isLast;

  const PrayerRow({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.time,
    required this.isCurrent,
    required this.notificationEnabled,
    required this.onNotificationTap,
    this.isLast = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding:
          const EdgeInsets.symmetric(
        horizontal: 17,
        vertical: 15,
      ),

      decoration: BoxDecoration(
        border: isLast
            ? null
            : Border(
                bottom: BorderSide(
                  color: Colors.black
                      .withValues(
                    alpha: .055,
                  ),
                ),
              ),
      ),

      child: Row(
        children: [

          // --------------------------------------------------------
          // Prayer icon
          // --------------------------------------------------------

          Container(
            width: 42,
            height: 42,

            decoration: BoxDecoration(
              color: isCurrent
                  ? const Color(0xffF5C76B)
                      .withValues(
                      alpha: .18,
                    )
                  : const Color(0xff0B4B4B)
                      .withValues(
                      alpha: .055,
                    ),

              borderRadius:
                  BorderRadius.circular(
                13,
              ),
            ),

            child: Icon(
              icon,

              color: isCurrent
                  ? const Color(0xffB48719)
                  : const Color(0xff0B4B4B),

              size: 20,
            ),
          ),

          const SizedBox(
            width: 13,
          ),

          // --------------------------------------------------------
          // Name
          // --------------------------------------------------------

          Expanded(
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,

              children: [

                Row(
                  children: [

                    Text(
                      title,
                      style: TextStyle(
                        color: isCurrent
                            ? const Color(
                                0xff0B4B4B,
                              )
                            : const Color(
                                0xff182C2A,
                              ),

                        fontSize: 15,
                        fontWeight: isCurrent
                            ? FontWeight.w800
                            : FontWeight.w600,
                      ),
                    ),

                    if (isCurrent) ...[
                      const SizedBox(
                        width: 7,
                      ),

                      Container(
                        padding:
                            const EdgeInsets
                                .symmetric(
                          horizontal: 7,
                          vertical: 3,
                        ),

                        decoration:
                            BoxDecoration(
                          color:
                              const Color(
                            0xffF5C76B,
                          ),

                          borderRadius:
                              BorderRadius.circular(
                            8,
                          ),
                        ),

                        child:
                            const Text(
                          'NOW',
                          style:
                              TextStyle(
                            color:
                                Color(
                              0xff654C12,
                            ),
                            fontSize: 8,
                            fontWeight:
                                FontWeight
                                    .w800,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),

                const SizedBox(
                  height: 3,
                ),

                Text(
                  subtitle,
                  style: const TextStyle(
                    color:
                        Colors.black38,
                    fontSize: 10,
                    fontWeight:
                        FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),

          // --------------------------------------------------------
          // Time
          // --------------------------------------------------------

          Text(
            time,
            style: TextStyle(
              color: isCurrent
                  ? const Color(
                      0xff0B4B4B,
                    )
                  : const Color(
                      0xff182C2A,
                    ),

              fontSize: 14,
              fontWeight:
                  FontWeight.w800,
            ),
          ),

          const SizedBox(
            width: 12,
          ),

          // --------------------------------------------------------
          // Notification
          // --------------------------------------------------------

          GestureDetector(
            onTap:
                onNotificationTap,

            child: AnimatedContainer(
              duration:
                  const Duration(
                milliseconds: 180,
              ),

              width: 38,
              height: 38,

              decoration: BoxDecoration(
                color: notificationEnabled
                    ? const Color(
                        0xff0B4B4B,
                      )
                    : const Color(
                        0xffF0EEE8,
                      ),

                borderRadius:
                    BorderRadius.circular(
                  12,
                ),
              ),

              child: Icon(
                notificationEnabled
                    ? Icons
                        .notifications_active_rounded
                    : Icons
                        .notifications_off_outlined,

                color: notificationEnabled
                    ? Colors.white
                    : Colors.black38,

                size: 18,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ============================================================================
// SUN TIME
// ============================================================================

class _SunTime
    extends StatelessWidget {
  final IconData icon;
  final String title;
  final String time;

  const _SunTime({
    required this.icon,
    required this.title,
    required this.time,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [

        Icon(
          icon,
          color:
              const Color(0xff0B4B4B),
          size: 21,
        ),

        const SizedBox(
          height: 8,
        ),

        Text(
          title,
          style: const TextStyle(
            color: Colors.black45,
            fontSize: 10,
            fontWeight:
                FontWeight.w600,
          ),
        ),

        const SizedBox(
          height: 3,
        ),

        Text(
          time,
          style: const TextStyle(
            color:
                Color(0xff182C2A),
            fontSize: 12,
            fontWeight:
                FontWeight.w800,
          ),
        ),
      ],
    );
  }
}

// ============================================================================
// SETTINGS TILE
// ============================================================================

class _SettingsTile
    extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _SettingsTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,

      borderRadius:
          BorderRadius.circular(17),

      child: InkWell(
        onTap: onTap,

        borderRadius:
            BorderRadius.circular(17),

        child: Padding(
          padding:
              const EdgeInsets.all(14),

          child: Row(
            children: [

              Container(
                width: 42,
                height: 42,

                decoration:
                    BoxDecoration(
                  color:
                      const Color(
                    0xff0B4B4B,
                  ).withValues(
                    alpha: .07,
                  ),

                  borderRadius:
                      BorderRadius.circular(
                    13,
                  ),
                ),

                child: Icon(
                  icon,
                  color:
                      const Color(
                    0xff0B4B4B,
                  ),
                ),
              ),

              const SizedBox(
                width: 13,
              ),

              Expanded(
                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment
                          .start,

                  children: [

                    Text(
                      title,
                      style:
                          const TextStyle(
                        color:
                            Color(
                          0xff182C2A,
                        ),
                        fontSize: 13,
                        fontWeight:
                            FontWeight.w800,
                      ),
                    ),

                    const SizedBox(
                      height: 3,
                    ),

                    Text(
                      subtitle,
                      style:
                          const TextStyle(
                        color:
                            Colors.black45,
                        fontSize: 10,
                      ),
                    ),
                  ],
                ),
              ),

              const Icon(
                Icons
                    .chevron_right_rounded,
                color:
                    Colors.black26,
              ),
            ],
          ),
        ),
      ),
    );
  }
}