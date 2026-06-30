import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../../services/auth_service.dart';
import '../main_navigation_screen.dart';

class VerifyEmailScreen extends StatefulWidget {
  const VerifyEmailScreen({super.key});

  @override
  State<VerifyEmailScreen> createState() => _VerifyEmailScreenState();
}

class _VerifyEmailScreenState extends State<VerifyEmailScreen> {
  bool isLoading = false;

  Future<void> checkVerification() async {
    final currentUser = FirebaseAuth.instance.currentUser;

    if (currentUser == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Please sign in again.")));
      return;
    }

    setState(() {
      isLoading = true;
    });

    try {
      await currentUser.reload();
    } on FirebaseAuthException catch (e) {
      if (!mounted) return;

      setState(() {
        isLoading = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.message ?? "Unable to check verification.")),
      );
      return;
    }

    final user = FirebaseAuth.instance.currentUser;

    if (!mounted) return;

    setState(() {
      isLoading = false;
    });

    if (user != null && user.emailVerified) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const MainNavigationScreen()),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Your email is not verified yet.")),
      );
    }
  }

  Future<void> resendEmail() async {
    try {
      final currentUser = FirebaseAuth.instance.currentUser;

      if (currentUser == null) {
        if (!mounted) return;

        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text("Please sign in again.")));
        return;
      }

      await currentUser.sendEmailVerification();

      if (!mounted) return;

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Verification email sent.")));
    } on FirebaseAuthException catch (e) {
      if (!mounted) return;

      String message = "Something went wrong.";

      switch (e.code) {
        case "too-many-requests":
          message = "Too many requests. Please wait a while and try again.";
          break;

        default:
          message = e.message ?? message;
      }

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(message)));
    }
  }

  @override
  Widget build(BuildContext context) {
    final email = FirebaseAuth.instance.currentUser?.email ?? "";

    return Scaffold(
      backgroundColor: const Color(0xFFF7F6F2),

      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),

            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,

              children: [
                const Icon(
                  Icons.mark_email_read_outlined,
                  color: Color(0xFF0B4B4B),
                  size: 90,
                ),

                const SizedBox(height: 25),

                const Text(
                  "Verify Your Email",
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF0B4B4B),
                  ),
                ),

                const SizedBox(height: 15),

                Text(
                  "We've sent a verification link to\n$email",

                  textAlign: TextAlign.center,

                  style: const TextStyle(
                    fontSize: 16,
                    color: Colors.grey,
                    height: 1.6,
                  ),
                ),

                const SizedBox(height: 35),

                SizedBox(
                  width: double.infinity,
                  height: 55,

                  child: ElevatedButton(
                    onPressed: isLoading ? null : checkVerification,

                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFF4D17D),
                    ),

                    child: isLoading
                        ? const CircularProgressIndicator(color: Colors.white)
                        : const Text(
                            "I've Verified",
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.black,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                  ),
                ),

                const SizedBox(height: 15),

                TextButton(
                  onPressed: resendEmail,

                  child: const Text("Resend Email"),
                ),

                TextButton(
                  onPressed: () async {
                    await AuthService().logout();
                  },

                  child: const Text("Logout"),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
