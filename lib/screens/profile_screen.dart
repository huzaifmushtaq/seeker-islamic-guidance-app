import 'package:flutter/material.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 93, 112, 113),
      body: SingleChildScrollView(
        child: Column(
          children: [
            /// HEADER
            Stack(
              children: [
                Container(
                  height: 240,

                  decoration: const BoxDecoration(
                    image: DecorationImage(
                      image: AssetImage("assets/images/profile.png"),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),

                SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.all(20),

                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,

                          children: [
                            Container(
                              width: 20,
                              height: 20,

                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.15),

                                borderRadius: BorderRadius.circular(16),
                              ),

                              child: const Icon(
                                Icons.settings,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),

                        Row(
                          children: [
                            CircleAvatar(
                              radius: 35,
                              backgroundColor: Colors.white,

                              backgroundImage: const AssetImage(
                                "assets/images/profile.png",
                              ),
                            ),

                            const SizedBox(width: 14),

                            const Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,

                                children: [
                                  Text(
                                    "Abdul Rahman",
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),

                                  SizedBox(height: 4),

                                  Text(
                                    "Indeed Allah loves truthfulness.",
                                    style: TextStyle(
                                      color: Colors.white70,
                                      fontSize: 10,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Transform.translate(
              offset: const Offset(0, -14),

              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 14),

                child: Row(
                  children: [
                    Expanded(
                      child: _journeyCard(
                        Icons.local_fire_department,
                        "21",
                        "Streak",
                      ),
                    ),

                    const SizedBox(width: 10),

                    Expanded(
                      child: _journeyCard(Icons.favorite, "4782", "Dhikr"),
                    ),

                    const SizedBox(width: 10),

                    Expanded(
                      child: _journeyCard(Icons.menu_book, "12", "Lessons"),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 6),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),

              child: Row(
                children: [
                  /// TODAY'S PROGRESS
                  Expanded(
                    child: Container(
                      height: 215,

                      padding: const EdgeInsets.all(16),

                      decoration: BoxDecoration(
                        color: const Color.fromARGB(255, 235, 242, 44),
                        borderRadius: BorderRadius.circular(24),

                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.04),
                            blurRadius: 10,
                          ),
                        ],
                      ),

                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,

                        children: [
                          const Text(
                            "Today's Progress",
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              fontStyle: FontStyle.italic,
                              color: Color(0xFF0B4B4B),
                            ),
                          ),

                          const SizedBox(height: 15),

                          _progressItem(true, "Fajr Prayer"),

                          _progressItem(true, "Morning Dhikr"),

                          _progressItem(true, "Verse Read"),

                          _progressItem(false, "Attend Class"),

                          _progressItem(false, "Evening Dhikr"),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(width: 12),

                  /// CONTINUE LEARNING
                  Expanded(
                    child: Container(
                      height: 215,

                      padding: const EdgeInsets.all(16),

                      decoration: BoxDecoration(
                        color: const Color.fromARGB(255, 212, 28, 117),
                        borderRadius: BorderRadius.circular(24),

                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.04),
                            blurRadius: 10,
                          ),
                        ],
                      ),

                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,

                        children: [
                          const Text(
                            "Continue Lessons",
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Color.fromARGB(255, 213, 171, 19),
                              fontStyle: FontStyle.italic,
                            ),
                          ),

                          const SizedBox(height: 8),

                          Row(
                            children: [
                              const SizedBox(width: 8),

                              const Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,

                                  children: [
                                    Text(
                                      "Noorani Qaida",
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 17,
                                        fontStyle: FontStyle.italic,
                                      ),
                                    ),

                                    SizedBox(height: 6),

                                    Text(
                                      "Lesson 7",
                                      style: TextStyle(
                                        color: Color.fromARGB(
                                          133,
                                          218,
                                          187,
                                          14,
                                        ),
                                      ),
                                    ),

                                    SizedBox(height: 6),

                                    Text(
                                      "60% Complete",
                                      style: TextStyle(
                                        color: Color.fromARGB(255, 13, 21, 176),
                                        fontSize: 12,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),

                          const Spacer(),

                          ClipRRect(
                            borderRadius: BorderRadius.circular(20),

                            child: LinearProgressIndicator(
                              value: 0.6,
                              minHeight: 6,

                              backgroundColor: Colors.grey.shade300,

                              valueColor: const AlwaysStoppedAnimation(
                                Color(0xFF0B4B4B),
                              ),
                            ),
                          ),

                          const SizedBox(height: 12),

                          Container(
                            height: 42,

                            decoration: BoxDecoration(
                              color: const Color(0xFF0B4B4B),

                              borderRadius: BorderRadius.circular(18),
                            ),

                            child: const Center(
                              child: Text(
                                "Resume",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 18),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),

              child: Container(
                padding: const EdgeInsets.all(18),

                decoration: BoxDecoration(
                  color: const Color.fromARGB(255, 25, 215, 215),
                  borderRadius: BorderRadius.circular(24),

                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.05),
                      blurRadius: 10,
                    ),
                  ],
                ),

                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,

                  children: [
                    const Text(
                      "My Journey",
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Color.fromARGB(255, 10, 19, 11),
                      ),
                    ),

                    const SizedBox(height: 18),

                    _journeyProgress(
                      "Quran Learning",
                      0.65,
                      "65%",
                      Icons.menu_book,
                    ),

                    const SizedBox(height: 16),

                    _journeyProgress(
                      "Classes Completed",
                      0.40,
                      "8 / 20",
                      Icons.video_library,
                    ),

                    const SizedBox(height: 16),

                    _journeyProgress(
                      "Books Read",
                      0.80,
                      "8 Books",
                      Icons.library_books,
                    ),

                    const SizedBox(height: 16),

                    _journeyProgress(
                      "Audio Sessions",
                      0.30,
                      "12 Hours",
                      Icons.headphones,
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 18),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),

              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,

                children: [
                  GridView.count(
                    crossAxisCount: 3,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                    childAspectRatio: 0.95,

                    children: const [
                      _SettingCard(
                        icon: Icons.notifications_none,
                        title: "Alerts",
                      ),

                      _SettingCard(
                        icon: Icons.download_rounded,
                        title: "Downloads",
                      ),

                      _SettingCard(icon: Icons.language, title: "Language"),

                      _SettingCard(icon: Icons.support_agent, title: "Support"),

                      _SettingCard(icon: Icons.info_outline, title: "About"),

                      _SettingCard(icon: Icons.logout, title: "Logout"),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 18),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),

              child: Container(
                height: 200,
                width: double.infinity,

                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(24),

                  image: const DecorationImage(
                    image: AssetImage("assets/images/about.png"),
                    fit: BoxFit.cover,
                  ),
                ),

                child: Padding(
                  padding: const EdgeInsets.all(22),

                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,

                    children: [
                      const Text(
                        "A Step Towards Allah",
                        style: TextStyle(
                          color: Color(0xFF0B4B4B),
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),

                      const SizedBox(height: 8),

                      const SizedBox(
                        width: 220,
                        child: Text(
                          "Every prayer, every verse and every act of remembrance brings you closer to Allah.",
                          style: TextStyle(
                            color: Colors.black87,
                            fontSize: 14,
                            height: 1.5,
                          ),
                        ),
                      ),

                      const SizedBox(height: 14),
                    ],
                  ),
                ),
              ),
            ),

            const SizedBox(height: 10),
          ],
        ),
      ),
    );
  }
}

Widget _journeyCard(IconData icon, String value, String title) {
  return Container(
    height: 95,

    decoration: BoxDecoration(
      color: const Color(0xFF0F5A58),

      borderRadius: BorderRadius.circular(18),

      border: Border.all(color: Colors.white24),
    ),

    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,

      children: [
        Icon(icon, color: const Color(0xFFF4D17D), size: 22),

        const SizedBox(height: 6),

        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),

        const SizedBox(height: 2),

        Text(
          title,
          style: const TextStyle(color: Colors.white70, fontSize: 11),
        ),
      ],
    ),
  );
}

Widget _progressItem(bool completed, String title) {
  return Padding(
    padding: const EdgeInsets.only(bottom: 8),

    child: Row(
      children: [
        Icon(
          completed ? Icons.check_circle : Icons.radio_button_unchecked,

          size: 18,

          color: completed ? const Color(0xFF0B4B4B) : Colors.grey,
        ),

        const SizedBox(width: 8),

        Text(title, style: const TextStyle(fontSize: 14)),
      ],
    ),
  );
}

Widget _journeyProgress(
  String title,
  double progress,
  String value,
  IconData icon,
) {
  return Column(
    children: [
      Row(
        children: [
          Container(
            width: 42,
            height: 42,

            decoration: BoxDecoration(
              color: const Color(0xFFF5E8C8),
              borderRadius: BorderRadius.circular(14),
            ),

            child: Icon(icon, color: const Color(0xFF0B4B4B)),
          ),

          const SizedBox(width: 12),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,

              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                  ),
                ),

                const SizedBox(height: 8),

                ClipRRect(
                  borderRadius: BorderRadius.circular(10),

                  child: LinearProgressIndicator(
                    value: progress,
                    minHeight: 8,

                    backgroundColor: Colors.grey.shade300,

                    valueColor: const AlwaysStoppedAnimation(Color(0xFF0B4B4B)),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(width: 12),

          Text(
            value,
            style: const TextStyle(
              color: Color(0xFF0B4B4B),
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    ],
  );
}

class _SettingCard extends StatelessWidget {
  final IconData icon;
  final String title;

  const _SettingCard({required this.icon, required this.title});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: const Color.fromARGB(255, 28, 6, 6),

        borderRadius: BorderRadius.circular(22),

        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 10,
          ),
        ],
      ),

      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,

        children: [
          Container(
            width: 46,
            height: 46,

            decoration: BoxDecoration(
              color: const Color(0xFFF5E8C8),

              borderRadius: BorderRadius.circular(14),
            ),

            child: Icon(icon, color: const Color(0xFF0B4B4B), size: 24),
          ),

          const SizedBox(height: 12),

          Text(
            title,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: Color(0xFF0B4B4B),
            ),
          ),
        ],
      ),
    );
  }
}
