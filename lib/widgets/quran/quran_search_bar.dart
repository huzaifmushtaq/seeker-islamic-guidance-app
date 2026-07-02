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
      height: 50,

      decoration: BoxDecoration(
        color: const Color(0xFFF4D17D),
        borderRadius: BorderRadius.circular(18),
      ),

      child: TextField(
        onChanged: onChanged,

        decoration: const InputDecoration(
          hintText: "Search Surah...",

          hintStyle: TextStyle(
            color: Color.fromARGB(255, 123, 33, 128),
            fontSize: 15,
          ),

          prefixIcon: Icon(
            Icons.search,
            color: Color(0xFF0B4B4B),
          ),

          border: InputBorder.none,

          contentPadding: EdgeInsets.symmetric(
            vertical: 16,
          ),
        ),
      ),
    );
  }
}