import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '/screens/auth/login_screen.dart';
import '/screens/main_navigation_screen.dart';
import '/screens/auth/verify_email_screen.dart';
import '/services/guest_service.dart';

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  Future<bool> _isGuest() async {
    return await GuestService().isGuest();
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),

      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        final user = snapshot.data;

        // Logged in with Firebase
        if (user != null) {
          if (!user.emailVerified) {
            return const VerifyEmailScreen();
          }

          return const MainNavigationScreen();
        }

        // Check Guest Session
        return FutureBuilder<bool>(
          future: _isGuest(),

          builder: (context, guestSnapshot) {
            if (guestSnapshot.connectionState == ConnectionState.waiting) {
              return const Scaffold(
                body: Center(child: CircularProgressIndicator()),
              );
            }

            if (guestSnapshot.data == true) {
              return const MainNavigationScreen();
            }

            return const LoginScreen();
          },
        );
      },
    );
  }
}
