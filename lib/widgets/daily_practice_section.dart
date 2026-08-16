import 'package:flutter/material.dart';

import 'daily_azkaar_card.dart';
import 'daily_amal_card.dart';
import 'daily_muhasabah_card.dart';

class DailyPracticeSection extends StatelessWidget {
  const DailyPracticeSection({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,

      margin: const EdgeInsets.symmetric(
        vertical: 8,
      ),

      padding: const EdgeInsets.only(
        top: 16,
        bottom: 8,
      ),

      decoration: BoxDecoration(
        color: const Color(0xffF8F5EC),

        borderRadius:
            BorderRadius.circular(24),

        border: Border.all(
          color: const Color(0xffE8E1CF),
          width: 1,
        ),
      ),

      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,

        children: [

          // ─────────────────────────────
          // TITLE
          // ─────────────────────────────

          const Padding(
            padding: EdgeInsets.symmetric(
              horizontal: 20,
            ),

            child: Text(
              'DAILY IBADAH : 5 MINUTES ',
              style: TextStyle(
                color: Color(0xff0E5A56),
                fontSize: 13,
                fontWeight: FontWeight.bold,
                letterSpacing: .8,
              ),
            ),
          ),

          const SizedBox(height: 3),

          // ─────────────────────────────
          // SUBTITLE
          // ─────────────────────────────

          const Padding(
            padding: EdgeInsets.symmetric(
              horizontal: 20,
            ),

            child: Text(
              'Three steps closer ! IntentionaL IbadaH',
              style: TextStyle(
                color: Colors.black54,
                fontSize: 11,
                fontWeight: FontWeight.bold
              ),
            ),
          ),

          const SizedBox(height: 12),

          // ─────────────────────────────
          // EXISTING CARDS
          //
          // KEEPING THE ORIGINAL
          // VERTICAL HORIZONTAL-CARD
          // STRUCTURE
          // ─────────────────────────────

          const DailyAzkaarCard(),

          const SizedBox(height: 10),

          const DailyAmalCard(),

          const SizedBox(height: 10),

          const DailyMuhasabahCard(),
        ],
      ),
    );
  }
}