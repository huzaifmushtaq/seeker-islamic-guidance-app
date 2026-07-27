import 'package:flutter/material.dart';

class QuranSearchBar extends StatelessWidget {
  final ValueChanged<String> onChanged;

  const QuranSearchBar({
    super.key,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 55,

      decoration: BoxDecoration(
        color: const Color.fromARGB(255, 243, 219, 167),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: const Color.fromARGB(255, 23, 22, 22).withOpacity(.06),
          
        ),
      ),

      child: TextField(
        onChanged: onChanged,
        cursorColor: const Color(0xFFD4AF37),
        textAlignVertical: TextAlignVertical.center,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 15,
        ),
decoration: InputDecoration(
  border: InputBorder.none,

  isCollapsed: true,

  hintText: "Search Surah, Ayah...",

  hintStyle: const TextStyle(
    color: Color.fromARGB(255, 10, 19, 35),
    fontSize: 15,
  ),

  prefixIcon: const Center(
  widthFactor: 1,
  child: Icon(
    Icons.search_rounded,
    color: Color(0xFFD4AF37),
    size: 24,
  ),
),
  suffixIcon: IconButton(
    onPressed: () {},
    icon: const Icon(
      Icons.tune_rounded,
      color: Color(0xFFD4AF37),
    ),
  ),

  contentPadding: const EdgeInsets.symmetric(
    vertical: 15,
  ),
),
      ),
    );
  }
}