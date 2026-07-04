import 'package:flutter/material.dart';

class LastReadCard extends StatelessWidget {
  const LastReadCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 145,
      width: double.infinity,

      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        gradient: const LinearGradient(
          colors: [Color.fromARGB(255, 238, 227, 127), Color(0xFF166B6B)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),

      child: Stack(
        children: [
          Positioned(
            right: -20,
            top: -20,
            child: Container(
              width: 130,
              height: 132,

              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: .05),
                shape: BoxShape.circle,
              ),
            ),
          ),

          Padding(
            padding: const EdgeInsets.all(20),

            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,

              children: [
                const Text(
                  "Continue Reading",
                  style: TextStyle(color: Colors.white70, fontSize: 14,
                  fontWeight: FontWeight.bold
                  ),
                  
                ),

                const SizedBox(height: 6),

                const Text(
                  "Al-Ma'idah",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const Text("Ayah 52", style: TextStyle(color: Colors.white70,
                fontWeight: FontWeight.bold
                )
                ),

                const Spacer(),

                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 7,
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
        ],
      ),
    );
  }
}
