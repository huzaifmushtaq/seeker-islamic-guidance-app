import 'package:flutter/material.dart';

import '/screens/auth/login_screen.dart';

Future<void> showAuthPrompt(BuildContext context) {
  return showGeneralDialog(
    context: context,
    barrierDismissible: true,
    barrierLabel: "Authentication",
    barrierColor: Colors.black54,
    transitionDuration: const Duration(milliseconds: 300),

    transitionBuilder: (context, animation, secondaryAnimation, child) {
      return SlideTransition(
        position: Tween<Offset>(begin: const Offset(0, -1), end: Offset.zero)
            .animate(
              CurvedAnimation(parent: animation, curve: Curves.easeOutCubic),
            ),
        child: FadeTransition(opacity: animation, child: child),
      );
    },

    pageBuilder: (context, animation, secondaryAnimation) {
      return SafeArea(
        child: Align(
          alignment: Alignment.topCenter,
          child: Material(
            color: Colors.transparent,
            child: Container(
              margin: const EdgeInsets.all(20),
              padding: const EdgeInsets.all(24),

              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(28),
                boxShadow: const [
                  BoxShadow(
                    color: Colors.black26,
                    blurRadius: 20,
                    offset: Offset(0, 10),
                  ),
                ],
              ),

              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Align(
                    alignment: Alignment.topRight,
                    child: IconButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      icon: const Icon(Icons.close),
                    ),
                  ),

                  const Icon(
                    Icons.auto_awesome,
                    color: Color(0xFF0B4B4B),
                    size: 50,
                  ),

                  const SizedBox(height: 18),

                  const Text(
                    "Continue Your Journey",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF0B4B4B),
                    ),
                  ),

                  const SizedBox(height: 12),

                  const Text(
                    "Create a free account for personalized experience.",
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.grey, height: 1.5),
                  ),

                  const SizedBox(height: 25),

                  const Row(
                    children: [
                      Icon(Icons.check_circle, color: Color(0xFF0B4B4B)),
                      SizedBox(width: 10),
                      Text("Save your progress"),
                    ],
                  ),

                  const SizedBox(height: 10),

                  const Row(
                    children: [
                      Icon(Icons.check_circle, color: Color(0xFF0B4B4B)),
                      SizedBox(width: 10),
                      Text("Bookmark books & duas"),
                    ],
                  ),

                  const SizedBox(height: 10),

                  const Row(
                    children: [
                      Icon(Icons.check_circle, color: Color(0xFF0B4B4B)),
                      SizedBox(width: 10),
                      Text("Continue learning"),
                    ],
                  ),

                  const SizedBox(height: 10),

                  const Row(
                    children: [
                      Icon(Icons.check_circle, color: Color(0xFF0B4B4B)),
                      SizedBox(width: 10),
                      Text("Sync across devices"),
                    ],
                  ),

                  const SizedBox(height: 28),

                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pop(context);

                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) =>
                                const LoginScreen(startWithLogin: true),
                          ),
                        );
                      },

                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFF4D17D),
                        foregroundColor: const Color(0xFF0B4B4B),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),

                      child: const Text(
                        "Continue",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 12),

                  TextButton(
                    onPressed: () {
                      Navigator.pop(context);

                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) =>
                              const LoginScreen(startWithLogin: false),
                        ),
                      );
                    },

                    child: const Text(
                      "Create Account",
                      style: TextStyle(
                        color: Color(0xFF0B4B4B),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    },
  );
}
