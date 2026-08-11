import 'package:flutter/material.dart';

class ClassesScreen extends StatelessWidget {
  const ClassesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F7F8),

      body: SingleChildScrollView(
        child: Column(
          children: [
            SafeArea(
              bottom: false,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 18, 20, 0),
                child: Container(
                  padding: const EdgeInsets.all(22),
                  decoration: BoxDecoration(
                    color: const Color(0xFF134E4A),
                    borderRadius: BorderRadius.circular(28),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: .08),
                        blurRadius: 18,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: const Color(
                                0xFFD4AF37,
                              ).withValues(alpha: .15),
                              borderRadius: BorderRadius.circular(14),
                            ),
                            child: const Icon(
                              Icons.menu_book_rounded,
                              color: Color(0xFFD4AF37),
                              size: 24,
                            ),
                          ),

                          const SizedBox(width: 12),

                          const Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "Continue Learning",
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 19,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),

                                SizedBox(height: 2),

                                Text(
                                  "Resume where you left off",
                                  style: TextStyle(
                                    color: Colors.white70,
                                    fontSize: 13,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 26),

                      const Text(
                        "Quran Learning",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 23,
                          fontWeight: FontWeight.bold,
                        ),
                      ),

                      const SizedBox(height: 6),

                      const Text(
                        "Lesson 12 of 48 • 18 min remaining",
                        style: TextStyle(color: Colors.white70, fontSize: 14),
                      ),

                      const SizedBox(height: 20),

                      ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: const LinearProgressIndicator(
                          value: .42,
                          minHeight: 7,
                          backgroundColor: Color(0xFF2A6D67),
                          valueColor: AlwaysStoppedAnimation(Color(0xFFD4AF37)),
                        ),
                      ),

                      const SizedBox(height: 15),

                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          onPressed: () {},

                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFD4AF37),
                            foregroundColor: const Color(0xFF12314A),
                            elevation: 0,
                            padding: const EdgeInsets.symmetric(vertical: 15),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                          ),

                          icon: const Icon(Icons.play_arrow_rounded),

                          label: const Text(
                            "Resume Learning",
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 15,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            Padding(
              padding: const EdgeInsets.fromLTRB(20, 25, 20, 14),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    "Live Classes",
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1A2B3C),
                    ),
                  ),
                ],
              ),
            ),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: const Color(0xFF12314A),
                  borderRadius: BorderRadius.circular(26),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: .08),
                      blurRadius: 18,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),

                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 5,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.red.shade600,
                            borderRadius: BorderRadius.circular(30),
                          ),

                          child: const Row(
                            children: [
                              Icon(Icons.circle, size: 8, color: Colors.white),
                              SizedBox(width: 6),
                              Text(
                                "LIVE NOW",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),

                        const Spacer(),

                        IconButton(
                          onPressed: () {},
                          icon: const Icon(
                            Icons.calendar_month_rounded,
                            color: Color(0xFFD4AF37),
                          ),
                        ),
                      ],
                    ),

                    const Text(
                      "Weekly Quran Circle",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 6),

                    const Text(
                      "By Peer Sahib",
                      style: TextStyle(color: Colors.white70, fontSize: 14),
                    ),

                    const SizedBox(height: 18),

                    Row(
                      children: [
                        const Icon(
                          Icons.schedule,
                          color: Color(0xFFD4AF37),
                          size: 18,
                        ),

                        const SizedBox(width: 8),

                        const Text(
                          "Today • 7:30 PM",
                          style: TextStyle(color: Colors.white),
                        ),

                        const Spacer(),

                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 5,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white10,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: const Text(
                            "Zoom",
                            style: TextStyle(
                              color: Colors.white70,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 10),

                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: () {},

                        style: ElevatedButton.styleFrom(
                          elevation: 0,
                          backgroundColor: const Color(0xFFD4AF37),
                          foregroundColor: const Color(0xFF12314A),
                          padding: const EdgeInsets.symmetric(vertical: 15),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),

                        icon: const Icon(Icons.video_call_rounded),

                        label: const Text(
                          "Join Live Class",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 15,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            Padding(
              padding: const EdgeInsets.fromLTRB(20, 25, 20, 14),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    "Learning Paths",
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1A2B3C),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(
              height: 210,
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                scrollDirection: Axis.horizontal,
                children: [
                  _learningPathCard(
                    icon: Icons.menu_book_rounded,
                    title: "Quran Learning",
                    subtitle: "From Alif to Advanced Tajweed",
                    lessons: "48 Lessons",
                    color: const Color(0xFF12314A),
                  ),

                  _learningPathCard(
                    icon: Icons.mosque_rounded,
                    title: "Perfect Your Salah",
                    subtitle: "Prayer from basics to Khushu",
                    lessons: "26 Lessons",
                    color: const Color(0xFF0B6B61),
                  ),

                  _learningPathCard(
                    icon: Icons.favorite_rounded,
                    title: "Soul Purification ",
                    subtitle: "Tazkiyah & Spiritual Growth",
                    lessons: "31 Lessons",
                    color: const Color(0xFF5E4B8B),
                  ),

                  _learningPathCard(
                    icon: Icons.auto_stories_rounded,
                    title: "Foundations of Islam",
                    subtitle: "Faith • Seerah • Aqeedah",
                    lessons: "40 Lessons",
                    color: const Color(0xFF8B5A2B),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 13),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 15),

              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,

                children: [
                  const Text(
                    "Featured Series",
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1A2B3C),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 10),
            SizedBox(
              height: 280,

              child: ListView(
                scrollDirection: Axis.horizontal,

                padding: const EdgeInsets.symmetric(horizontal: 15),

                children: [
                  _lessonCard(
                    "assets/images/lsn1.jpeg",
                    "Makharij of Letters",
                    "4 Lessons",
                    "18:30",
                  ),

                  _lessonCard(
                    "assets/images/lsn2.jpeg",
                    "Rules of Noon Saakin",
                    "10 Lessons ",
                    "15:20",
                  ),

                  _lessonCard(
                    "assets/images/lsn3.jpeg",
                    "How To Read Arabic",
                    "20 Lessons ",
                    "12:45",
                  ),
                ],
              ),
            ),

            const SizedBox(height: 13),

            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                children: [
                  Text(
                    "Need Guidance?",
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1A2B3C),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 14),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: _guidanceCard(),
            ),

            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }
}

Widget _lessonCard(
  String image,
  String title,
  String lessons,
  String duration,
) {
  return Container(
    width: 250,
    margin: const EdgeInsets.only(right: 18),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(28),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withValues(alpha: .05),
          blurRadius: 14,
          offset: const Offset(0, 8),
        ),
      ],
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ClipRRect(
          borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
          child: Stack(
            children: [
              Image.asset(
                image,
                height: 145,
                width: double.infinity,
                fit: BoxFit.cover,
              ),

              Positioned.fill(
                child: Center(
                  child: Container(
                    width: 58,
                    height: 58,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: .90),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.play_arrow_rounded,
                      color: Color(0xFF12314A),
                      size: 34,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),

        Expanded(
          child: Padding(
            padding: const EdgeInsets.all(18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1A2B3C),
                  ),
                ),

                const SizedBox(height: 10),

                Row(
                  children: [
                    const Icon(
                      Icons.menu_book_rounded,
                      size: 16,
                      color: Color(0xFF0B6B61),
                    ),

                    const SizedBox(width: 6),

                    Text(
                      lessons,
                      style: const TextStyle(
                        color: Colors.black54,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),

                const Spacer(),

                const Divider(height: 1),

                const SizedBox(height: 14),

                Row(
                  children: [
                    const Icon(
                      Icons.schedule_rounded,
                      size: 16,
                      color: Colors.grey,
                    ),

                    const SizedBox(width: 6),

                    Text(
                      duration,
                      style: const TextStyle(color: Colors.black54),
                    ),

                    const Spacer(),

                    const Text(
                      "Continue",
                      style: TextStyle(
                        color: Color(0xFF0B6B61),
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const SizedBox(width: 4),

                    const Icon(
                      Icons.arrow_forward_rounded,
                      color: Color(0xFF0B6B61),
                      size: 18,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ],
    ),
  );
}

Widget _learningPathCard({
  required IconData icon,
  required String title,
  required String subtitle,
  required String lessons,
  required Color color,
}) {
  return Container(
    width: 240,
    margin: const EdgeInsets.only(right: 16),
    decoration: BoxDecoration(
      color: color,
      borderRadius: BorderRadius.circular(28),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.08),
          blurRadius: 16,
          offset: const Offset(0, 8),
        ),
      ],
    ),
    child: Padding(
      padding: const EdgeInsets.all(22),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(icon, color: const Color(0xFFD4AF37), size: 28),
          ),

          const Spacer(),

          Text(
            title,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
              height: 1.2,
            ),
            maxLines: 2,
          ),

          const SizedBox(height: 8),

          Text(
            subtitle,
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.75),
              fontSize: 11,
              height: 1.4,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),

          const SizedBox(height: 18),

          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  lessons,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),

              const Spacer(),

              const CircleAvatar(
                radius: 18,
                backgroundColor: Color(0xFFD4AF37),
                child: Icon(
                  Icons.arrow_forward_rounded,
                  color: Color(0xFF12314A),
                  size: 20,
                ),
              ),
            ],
          ),
        ],
      ),
    ),
  );
}

Widget _guidanceCard() {
  return Container(
    padding: const EdgeInsets.all(22),
    decoration: BoxDecoration(
      color: const Color.fromARGB(255, 234, 239, 179),
      borderRadius: BorderRadius.circular(28),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withValues(alpha: .05),
          blurRadius: 14,
          offset: const Offset(0, 8),
        ),
      ],
    ),
    child: Row(
      children: [
        Container(
          width: 72,
          height: 72,
          decoration: BoxDecoration(
            color: const Color(0xFF0B6B61).withValues(alpha: .12),
            borderRadius: BorderRadius.circular(20),
          ),
          child: const Icon(
            Icons.forum_rounded,
            color: Color(0xFF0B6B61),
            size: 34,
          ),
        ),

        const SizedBox(width: 18),

        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Ask Your Doubts",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),

              const SizedBox(height: 8),

              const Text(
                "Get authentic answers from trusted scholars.",
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.black54,
                  height: 1.5,
                ),
              ),

              const SizedBox(height: 16),

              FilledButton.icon(
                onPressed: () {},
                style: FilledButton.styleFrom(
                  backgroundColor: const Color(0xFF12314A),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                icon: const Icon(Icons.send_rounded),
                label: const Text("Ask Question"),
              ),
            ],
          ),
        ),
      ],
    ),
  );
}
