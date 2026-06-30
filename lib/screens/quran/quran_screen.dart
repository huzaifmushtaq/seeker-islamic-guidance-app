import 'package:flutter/material.dart';
import '../../widgets/quran/last_read_card.dart';
import '../../widgets/quran/guidance_carousel.dart';

class QuranScreen extends StatelessWidget {
  const QuranScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7F7),

      appBar: AppBar(
        backgroundColor: const Color(0xFF0B4B4B),
        elevation: 0,
        centerTitle: true,

        title: const Text(
          "Al-Quran",
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),

        iconTheme: const IconThemeData(color: Colors.white),
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(18),

        child: const Column(
          children: [LastReadCard(), SizedBox(height: 18), GuidanceCarousel()],
        ),
      ),
    );
  }
}
