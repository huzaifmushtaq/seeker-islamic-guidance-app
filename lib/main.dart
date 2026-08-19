import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';

import 'theme/app_theme.dart';
import 'firebase_options.dart';
import 'services/prayer_notification_service.dart';
import 'screens/auth/auth_wrapper.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
await PrayerNotificationService.instance.initialize();
  runApp(const SeekerApp());
}

class SeekerApp extends StatelessWidget {
  const SeekerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,

      title: 'Seeker',

      theme: AppTheme.darkTheme,

      home: const AuthWrapper(),
    );
  }
}