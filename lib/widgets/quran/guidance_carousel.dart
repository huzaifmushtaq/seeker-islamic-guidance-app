import 'dart:async';

import 'package:flutter/material.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

import '../../models/guidance_model.dart';

class GuidanceCarousel extends StatefulWidget {
  const GuidanceCarousel({super.key});

  @override
  State<GuidanceCarousel> createState() => _GuidanceCarouselState();
}

class _GuidanceCarouselState extends State<GuidanceCarousel> {
  final PageController _controller = PageController(viewportFraction: 1);

  Timer? _timer;

  int currentPage = 0;

  final List<GuidanceModel> items = const [
    GuidanceModel(
      title: "Feeling Depressed",
      subtitle: "Calm your soul with the recitation of Surah Ar-Ra'd",
      image: "assets/images/guidance/quranbg.png",
      buttonText: "Reflect Now",
    ),

    GuidanceModel(
      title: "Difficulty Sleeping",
      subtitle: "Listen to Surah Al-Mulk before sleeping",
      image: "assets/images/guidance/quranbg.png",
      buttonText: "Listen Tonight",
    ),

    GuidanceModel(
      title: "Feeling Anxiety",
      subtitle: "Find peace through the remembrance of Allah",
      image: "assets/images/guidance/quranbg.png",
      buttonText: "Find Peace",
    ),

    GuidanceModel(
      title: "Need Hope",
      subtitle: "Read verses that remind you of Allah's Mercy",
      image: "assets/images/guidance/quranbg.png",
      buttonText: "Read Verses",
    ),
    GuidanceModel(
      title: "Seeking Forgiveness",
      subtitle: "Turn back to Allah with verses encouraging repentance.",
      image: "assets/images/guidance/quranbg.png",
      buttonText: "Repent Today",
    ),

    GuidanceModel(
      title: "Need Patience",
      subtitle: "Strengthen your heart with verses about patience.",
      image: "assets/images/guidance/quranbg.png",
      buttonText: "Be Patient",
    ),

    GuidanceModel(
      title: "Seeking Protection",
      subtitle: "Recite the Qur'an for Allah's protection and tranquility.",
      image: "assets/images/guidance/quranbg.png",
      buttonText: "Seek Protection",
    ),
  ];
  @override
  void initState() {
    super.initState();

    _timer = Timer.periodic(const Duration(seconds: 10), (_) {
      if (!mounted) return;

      currentPage++;

      if (currentPage >= items.length) {
        currentPage = 0;
      }

      _controller.animateToPage(
        currentPage,
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeInOut,
      );
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          height: 160,

          child: PageView.builder(
            controller: _controller,

            onPageChanged: (index) {
              setState(() {
                currentPage = index;
              });
            },

            itemCount: items.length,

            itemBuilder: (context, index) {
              final item = items[index];

              return Container(
                margin: const EdgeInsets.symmetric(horizontal: 2),

                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(24),

                  image: DecorationImage(
                    image: AssetImage(item.image),
                    fit: BoxFit.cover,
                  ),
                ),

                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(24),

                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,

                      colors: [
                        Colors.black.withValues(alpha: .15),
                        Colors.black.withValues(alpha: .75),
                      ],
                    ),
                  ),

                  padding: const EdgeInsets.all(20),

                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,

                    children: [
                      Text(
                        item.title,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),

                      const SizedBox(height: 8),

                      Text(
                        item.subtitle,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 13,
                          height: 1.4,
                        ),
                      ),

                      const SizedBox(height: 16),

                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 8,
                            ),

                            decoration: BoxDecoration(
                              color: Colors.white24,
                              borderRadius: BorderRadius.circular(20),
                            ),

                            child: Text(
                              item.buttonText,
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),

                          const Spacer(),

                          const Icon(
                            Icons.arrow_forward_ios,
                            color: Colors.white,
                            size: 18,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),

        const SizedBox(height: 14),

        SmoothPageIndicator(
          controller: _controller,
          count: items.length,

          effect: WormEffect(
            dotHeight: 8,
            dotWidth: 8,
            activeDotColor: const Color(0xFF0B4B4B),
            dotColor: Colors.grey.shade300,
          ),
        ),
      ],
    );
  }
}
