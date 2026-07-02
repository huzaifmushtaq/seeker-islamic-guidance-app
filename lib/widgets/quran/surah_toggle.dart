import 'package:flutter/material.dart';

class SurahToggle extends StatelessWidget {
  final bool isSurahSelected;
  final ValueChanged<bool> onChanged;

  const SurahToggle({
    super.key,
    required this.isSurahSelected,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 50,
      decoration: BoxDecoration(
        color: const Color(0xFFEAF2F2),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Expanded(
            child: GestureDetector(
              onTap: () => onChanged(true),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 220),
                margin: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: isSurahSelected
                      ? Colors.white
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: isSurahSelected
                      ? [
                          BoxShadow(
                            color: Colors.black.withOpacity(.06),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ]
                      : [],
                ),
                child: const Center(
                  child: Text(
                    "Surah",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF0B4B4B),
                    ),
                  ),
                ),
              ),
            ),
          ),
          Expanded(
            child: GestureDetector(
              onTap: () => onChanged(false),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 220),
                margin: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: !isSurahSelected
                      ? Colors.white
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: !isSurahSelected
                      ? [
                          BoxShadow(
                            color: Colors.black.withOpacity(.06),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ]
                      : [],
                ),
                child: const Center(
                  child: Text(
                    "Juz",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF0B4B4B),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}