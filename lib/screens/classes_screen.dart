import 'package:flutter/material.dart';

class ClassesScreen extends StatelessWidget {
  const ClassesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 93, 112, 113),

      body: SingleChildScrollView(
        child: Column(
          children: [

            /// HEADER
            Container(
              height: 200,
              width: double.infinity,

              decoration: const BoxDecoration(
                image: DecorationImage(
                  image: AssetImage(
                    "assets/images/classes.png",
                  ),
                  fit: BoxFit.cover,
                ),
              ),

              child: SafeArea(
                child: Padding(
                  padding: const EdgeInsets.all(20),

                  child: Column(
                    crossAxisAlignment:
                        CrossAxisAlignment.start,

                    children: [

                     

                      const Text(
                        "Classes",
                        style: TextStyle(
                          color: Color(0xFFF4D17D),
                          fontSize: 30,
                          fontWeight: FontWeight.bold,
                        ),
                      ),

                      const SizedBox(height: 4),

                      const Text(
                        "Learn Quran, Tafsir\nand spiritual guidance.",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
  
const SizedBox(height: 8),
Padding(
  padding: const EdgeInsets.symmetric(
    horizontal: 15,
  ),

  child: Row(
    mainAxisAlignment:
        MainAxisAlignment.spaceBetween,

    children: [

      const Text(
        "Live Quran Classes",
        style: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.bold,
          fontStyle: FontStyle.italic,
        ),
      ),

      TextButton(
        onPressed: () {},

        child: const Text(
          "Schedule",
          style: TextStyle(
            color: Color(0xFF0B4B4B),
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    ],
  ),
),
const SizedBox(height: 8),
Padding(
  padding: const EdgeInsets.symmetric(
    horizontal: 15,
  ),

  child: Container(
    width: double.infinity,
    padding: const EdgeInsets.all(20),

    decoration: BoxDecoration(
      color: const Color(0xFF0B4B4B),
      borderRadius: BorderRadius.circular(24),
    ),

    child: Column(
      crossAxisAlignment:
          CrossAxisAlignment.start,

      children: [

        Container(
          padding: const EdgeInsets.symmetric(
            horizontal: 12,
            vertical: 6,
          ),

          decoration: BoxDecoration(
            color: Colors.red,
            borderRadius:
                BorderRadius.circular(20),
          ),

          child: const Text(
            "LIVE NOW",
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 11,
            ),
          ),
        ),

        const SizedBox(height: 15),

        const Text(
          "Quran Recitation Class",
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),

        const SizedBox(height: 5),

        const Text(
          "By Peer Sahib",
          style: TextStyle(
            color: Colors.white70,
            fontSize: 14,
          ),
        ),

        const SizedBox(height: 15),

        Row(
          children: [

            const Icon(
              Icons.access_time,
              color: Color(0xFFF4D17D),
              size: 18,
            ),

            const SizedBox(width: 8),

            const Text(
              "Today • 7:30 PM",
              style: TextStyle(
                color: Colors.white,
              ),
            ),
          ],
        ),

        const SizedBox(height: 20),

        SizedBox(
          width: double.infinity,

          child: ElevatedButton.icon(
            onPressed: () {},

            style: ElevatedButton.styleFrom(
              backgroundColor:
                  const Color(0xFFF4D17D),

              foregroundColor:
                  const Color(0xFF0B4B4B),

              padding:
                  const EdgeInsets.symmetric(
                vertical: 14,
              ),

              shape:
                  RoundedRectangleBorder(
                borderRadius:
                    BorderRadius.circular(
                  16,
                ),
              ),
            ),

            icon: const Icon(
              Icons.video_call,
            ),

            label: const Text(
              "Join Zoom Class",
              style: TextStyle(
                fontWeight:
                    FontWeight.bold,
              ),
            ),
          ),
        ),
      ],
    ),
  ),
),
const SizedBox(height: 10),

Padding(
  padding: const EdgeInsets.symmetric(
    horizontal: 15,
  ),

  child: Row(
    mainAxisAlignment:
        MainAxisAlignment.spaceBetween,

    children: [

      const Text(
        "Recorded Lessons",
        style: TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.bold,
          fontStyle: FontStyle.italic,
        ),
      ),

      TextButton(
        onPressed: () {},

        child: const Text(
          "View All",
          style: TextStyle(
            color: Color(0xFF0B4B4B),
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    ],
  ),
),
const SizedBox(height: 10),
SizedBox(
  height: 230,

  child: ListView(
    scrollDirection: Axis.horizontal,

    padding: const EdgeInsets.symmetric(
      horizontal: 15,
    ),

    children: [

      _lessonCard(
        "assets/images/lsn1.jpeg",
        "Makharij of Letters",
        "Lesson 4",
        "18:30",
      ),

      _lessonCard(
        "assets/images/lsn2.jpeg",
        "Rules of Noon Saakin",
        "Lesson 10",
        "15:20",
      ),

      _lessonCard(
        "assets/images/lsn3.jpeg",
        "How To Read Arabic",
        "Lesson 1",
        "12:45",
      ),
    ],
  ),
),
const SizedBox(height: 10),

Padding(
  padding: const EdgeInsets.symmetric(
    horizontal: 15,
  ),

  child: Row(
    mainAxisAlignment:
        MainAxisAlignment.spaceBetween,

    children: [

      const Text(
        "Learning Path",
        style: TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.bold,
          fontStyle: FontStyle.italic,
        ),
      ),

      TextButton(
        onPressed: () {},

        child: const Text(
          "View All",
          style: TextStyle(
            color: Color(0xFF0B4B4B),
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    ],
  ),
),

const SizedBox(height: 15),
Padding(
  padding: const EdgeInsets.symmetric(
    horizontal: 15,
  ),

  child: Container(
    height: 180,

    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(24),

      boxShadow: [
        BoxShadow(
          color: Colors.black.withValues(
            alpha: 0.05,
          ),
          blurRadius: 10,
        ),
      ],
    ),

    child: ListView(
      scrollDirection: Axis.horizontal,

      padding: const EdgeInsets.all(20),

      children: [

        _learningStep(
          "1",
          "Noorani\nQaida",
          "Start Here",
          true,
        ),

        _pathConnector(),

        _learningStep(
          "2",
          "Basic\nTajweed",
          "Begin",
          false,
        ),

        _pathConnector(),

        _learningStep(
          "3",
          "Short\nSurahs",
          "Learn",
          false,
        ),

        _pathConnector(),

        _learningStep(
          "4",
          "Daily\nPractice",
          "Improve",
          false,
        ),

        _pathConnector(),

        _learningStep(
          "5",
          "Advanced\nRecitation",
          "Perfect",
          false,
        ),
      ],
    ),
  ),
),
const SizedBox(height: 25),

Padding(
  padding: const EdgeInsets.symmetric(
    horizontal: 15,
  ),

  child: Container(
    height: 200,
    width: double.infinity,

    decoration: BoxDecoration(
      borderRadius: BorderRadius.circular(24),

      image: const DecorationImage(
        image: AssetImage(
          "assets/images/memory.png",
        ),
        fit: BoxFit.cover,
      ),
    ),

    child: Padding(
      padding: const EdgeInsets.all(20),

      child: Row(
        children: [

          Expanded(
            flex: 3,

            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,

              mainAxisAlignment:
                  MainAxisAlignment.center,

              children: [

                const Text(
                  "Memorization Program",
                  style: TextStyle(
                    color: Color(0xFFF4D17D),
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 12),

                const Text(
                  "Step by step guidance\nfor memorizing the Quran.",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 13,
                    height: 1.5,
                  ),
                ),

                const SizedBox(height: 20),

                ElevatedButton(
                  onPressed: () {},

                  style: ElevatedButton.styleFrom(
                    backgroundColor:
                        const Color(0xFFF4D17D),

                    foregroundColor:
                        const Color(0xFF0B4B4B),

                    shape:
                        RoundedRectangleBorder(
                      borderRadius:
                          BorderRadius.circular(
                        16,
                      ),
                    ),

                    padding:
                        const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 12,
                    ),
                  ),

                  child: const Text(
                    "Start Now",
                    style: TextStyle(
                      fontWeight:
                          FontWeight.bold,
                    ),
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
 const SizedBox(height: 10),
          ],
        ),
      ),
    );
  }
}
Widget _learningStep(
  String number,
  String title,
  String subtitle,
  bool active,
) {
  return SizedBox(
    width: 95,

    child: Column(
      children: [

        CircleAvatar(
          radius: 20,

          backgroundColor: active
              ? const Color(0xFF0B4B4B)
              : Colors.grey.shade300,

          child: Text(
            number,
            style: TextStyle(
              color: active
                  ? Colors.white
                  : Colors.black54,
              fontWeight:
                  FontWeight.bold,
            ),
          ),
        ),

        const SizedBox(height: 15),

        Text(
          title,
          textAlign: TextAlign.center,

          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 15,
          ),
        ),

        const SizedBox(height: 10),

        Text(
          subtitle,
          textAlign: TextAlign.center,

          style: const TextStyle(
            color: Color(0xFF0B4B4B),
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    ),
  );
}Widget _pathConnector() {
  return Container(
    width: 35,
    margin: const EdgeInsets.only(
      top: 20,
    ),

    child: Divider(
      thickness: 2,
      color: Colors.grey.shade300,
    ),
  );
}
Widget _lessonCard(
  String image,
  String title,
  String lesson,
  String duration,
) {
  return Container(
    width: 230,
    margin: const EdgeInsets.only(
      right: 15,
    ),

    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(22),

      boxShadow: [
        BoxShadow(
          color: Colors.black.withValues(
            alpha: 0.05,
          ),
          blurRadius: 10,
        ),
      ],
    ),

    child: Column(
      crossAxisAlignment:
          CrossAxisAlignment.start,

      children: [

        Stack(
          children: [

            ClipRRect(
              borderRadius:
                  const BorderRadius.vertical(
                top: Radius.circular(22),
              ),

              child: Image.asset(
                image,
                height: 130,
                width: double.infinity,
                fit: BoxFit.cover,
              ),
            ),

            Positioned.fill(
              child: Center(
                child: CircleAvatar(
                  radius: 24,
                  backgroundColor:
                      Colors.black45,

                  child: const Icon(
                    Icons.play_arrow,
                    color: Colors.white,
                    size: 32,
                  ),
                ),
              ),
            ),

            Positioned(
              bottom: 10,
              right: 10,

              child: Container(
                padding:
                    const EdgeInsets.symmetric(
                  horizontal: 8,
                  vertical: 4,
                ),

                decoration: BoxDecoration(
                  color: Colors.black54,
                  borderRadius:
                      BorderRadius.circular(
                    10,
                  ),
                ),

                child: Text(
                  duration,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 11,
                  ),
                ),
              ),
            ),
          ],
        ),

        Padding(
          padding: const EdgeInsets.all(12),

          child: Column(
            crossAxisAlignment:
                CrossAxisAlignment.start,

            children: [

              Text(
                title,
                style: const TextStyle(
                  fontWeight:
                      FontWeight.bold,
                  fontSize: 16,
                ),
                maxLines: 2,
              ),

              const SizedBox(height: 8),

              Text(
                lesson,
                style: const TextStyle(
                  color: Color(0xFF0B4B4B),
                  fontWeight:
                      FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ],
    ),
  );
}

