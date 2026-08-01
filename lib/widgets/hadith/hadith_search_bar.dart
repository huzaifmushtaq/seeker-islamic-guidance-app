import 'package:flutter/material.dart';

class HadithSearchBar extends StatelessWidget {
  final ValueChanged<String>? onChanged;

  const HadithSearchBar({
    super.key,
    this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 62,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: const Color(0xffE6DBC2),
          width: 1.2,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(.04),
            blurRadius: 14,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: TextField(
        onChanged: onChanged,
        cursorColor: const Color(0xff0E5A56),
        style: const TextStyle(
          fontSize: 16,
          color: Color(0xff12372A),
          fontWeight: FontWeight.w500,
        ),
        decoration: InputDecoration(
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(vertical: 18),

          prefixIcon: Padding(
            padding: const EdgeInsets.only(left: 18, right: 10),
            child: Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: const Color(0xffF6EFD9),
                borderRadius: BorderRadius.circular(14),
              ),
              child: const Icon(
                Icons.search_rounded,
                color: Color(0xff0E5A56),
                size: 24,
              ),
            ),
          ),
          prefixIconConstraints: const BoxConstraints(
            minWidth: 76,
          ),

          hintText: "Search By Hadith, Narrator...",
          hintStyle: const TextStyle(
            color: Color(0xffA2A2A2),
            fontSize: 15,
            fontWeight: FontWeight.w500,
          ),

          suffixIcon: Padding(
            padding: const EdgeInsets.only(right: 14),
            child: Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: const Color(0xff0E5A56),
                borderRadius: BorderRadius.circular(14),
              ),
              child: const Icon(
                Icons.tune_rounded,
                color: Colors.white,
                size: 22,
              ),
            ),
          ),
          suffixIconConstraints: const BoxConstraints(
            minWidth: 64,
          ),
        ),
      ),
    );
  }
}