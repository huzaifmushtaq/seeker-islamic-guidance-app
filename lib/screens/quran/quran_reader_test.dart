import 'package:flutter/material.dart';
import 'package:qcf_quran/qcf_quran.dart';

class QuranReaderTest extends StatelessWidget {
  const QuranReaderTest({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: PageviewQuran(
        initialPageNumber: 1,
      ),
    );
  }
}
