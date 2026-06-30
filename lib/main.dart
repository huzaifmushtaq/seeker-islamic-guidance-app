import 'package:flutter/material.dart';
// ignore: unused_import
import 'package:seeker/screens/main_navigation_screen.dart';
import 'theme/app_theme.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'screens/auth/auth_wrapper.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const SeekerApp());
}

// ignore: camel_case_types
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
