import 'package:flutter/material.dart';

class HomeScreenV2 extends StatelessWidget {
  const HomeScreenV2({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F7F7),

      body: SingleChildScrollView(
        child: Column(
          children: [
            /// HEADER
            SizedBox(
              height: 120,
              width: double.infinity,

              child: SafeArea(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),

                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,

                    children: [
                      Container(
                        width: 50,
                        height: 50,

                        decoration: BoxDecoration(
                          color: const Color(0xFF0B4B4B),

                          borderRadius: BorderRadius.circular(16),
                        ),

                        child: const Icon(Icons.menu, color: Colors.white),
                      ),

                      const Text(
                        "Home",
                        style: TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF0B4B4B),
                        ),
                      ),

                      Container(
                        width: 50,
                        height: 50,

                        decoration: BoxDecoration(
                          color: const Color(0xFF0B4B4B),

                          borderRadius: BorderRadius.circular(16),
                        ),

                        child: const Icon(
                          Icons.notifications_none,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),

              child: Container(
                height: 220,
                width: double.infinity,

                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(28),

                  image: const DecorationImage(
                    image: AssetImage("assets/images/homebg.png"),
                    fit: BoxFit.cover,
                  ),
                ),

                child: Padding(
                  padding: const EdgeInsets.all(20),

                  child: Row(
                    children: [
                      /// LEFT SIDE
                      Expanded(
                        flex: 3,

                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,

                          children: [
                            const Text(
                              "NEXT PRAYER",
                              style: TextStyle(
                                color: Color(0xFFF4D17D),
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 1,
                              ),
                            ),

                            const SizedBox(height: 10),

                            const Text(
                              "Maghrib",
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 38,
                                fontWeight: FontWeight.bold,
                              ),
                            ),

                            const SizedBox(height: 10),

                            const Text(
                              "02:14:21",
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 34,
                                fontWeight: FontWeight.bold,
                              ),
                            ),

                            const Text(
                              "Remaining",
                              style: TextStyle(
                                color: Colors.white70,
                                fontSize: 14,
                              ),
                            ),

                            const Spacer(),

                            Row(
                              children: [
                                const Icon(
                                  Icons.access_time,
                                  color: Color(0xFFF4D17D),
                                  size: 18,
                                ),

                                const SizedBox(width: 5),

                                const Text(
                                  "6:57 PM",
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 13,
                                  ),
                                ),

                                const SizedBox(width: 12),

                                const Icon(
                                  Icons.location_on,
                                  color: Color(0xFFF4D17D),
                                  size: 18,
                                ),

                                const SizedBox(width: 4),

                                const Text(
                                  "Srinagar",
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 13,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),

                      /// RIGHT SIDE DATE BOX
                      Container(
                        width: 110,
                        height: 70,

                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.12),

                          borderRadius: BorderRadius.circular(18),
                        ),

                        child: const Column(
                          mainAxisAlignment: MainAxisAlignment.center,

                          children: [
                            Text(
                              "21 Jun",
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),

                            SizedBox(height: 4),

                            Text(
                              "1447 AH",
                              style: TextStyle(
                                color: Colors.white70,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            const SizedBox(height: 18),
          ],
        ),
      ),
    );
  }
}
