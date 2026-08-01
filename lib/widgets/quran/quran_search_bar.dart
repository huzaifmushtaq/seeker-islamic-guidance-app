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
      height: 58,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(.05),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
        border: Border.all(
          color: const Color(0xffE7E2D8),
        ),
      ),
      child: TextField(
        onChanged: onChanged,
        cursorColor: const Color(0xff0E5A56),
        style: const TextStyle(
          color: Color(0xff1D3D3A),
          fontSize: 15,
          fontWeight: FontWeight.w500,
        ),
        textAlignVertical: TextAlignVertical.center,
        decoration: InputDecoration(
          border: InputBorder.none,
          hintText: "Search Surah, Ayah...",
          hintStyle: TextStyle(
            color: Colors.grey.shade500,
            fontSize: 15,
          ),

          prefixIcon: const Icon(
            Icons.search_rounded,
            color: Color(0xff0E5A56),
            size: 24,
          ),

          suffixIcon: Container(
            margin: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: const Color(0xffF6EFD9),
              borderRadius: BorderRadius.circular(14),
            ),
            child: IconButton(
              onPressed: () {},
              icon: const Icon(
                Icons.tune_rounded,
                color: Color(0xff0E5A56),
                size: 20,
              ),
            ),
          ),

          contentPadding: const EdgeInsets.symmetric(
            horizontal: 4,
            vertical: 18,
          ),
        ),
      ),
    );
  }
}