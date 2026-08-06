import 'dart:io';

import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:share_plus/share_plus.dart';
import 'package:flutter/services.dart';

class HadithPdfService {
  Future<void> generate({
    required String arabic,
    required String narrator,
    required String english,
    required String collection,
    required String chapter,
    required int hadithNumber,
  }) async {
      arabic = arabic.replaceAll(
    "ﷺ",
    "صلى الله عليه وسلم",
  );
  english = english.replaceAll("ﷺ", "peace be upon him");

final arabicFont = pw.Font.ttf(
  await rootBundle.load(
    "assets/fonts/Amiri-Regular.ttf",
    
  ),
);
final englishFont = pw.Font.ttf(
  await rootBundle.load(
    "assets/fonts/NotoSans-Regular.ttf",
  ),
);

final englishBold = pw.Font.ttf(
  await rootBundle.load(
    "assets/fonts/NotoSans-Bold.ttf",
  ),
);
    final pdf = pw.Document();

    pdf.addPage(
      pw.MultiPage(
        pageTheme: pw.PageTheme(
          margin: const pw.EdgeInsets.all(40),
        ),
        build: (context) => [

          pw.Center(
            child: pw.Text(
              "SEEKER",
              style: pw.TextStyle(
                fontSize: 28,
                fontWeight: pw.FontWeight.bold,
                color: PdfColors.green900,
              ),
            ),
          ),

          pw.SizedBox(height: 15),

          pw.Center(
            child: pw.Text(
  collection.toUpperCase(),
  style: pw.TextStyle(
    font: englishBold,
    fontSize: 18,
  ),
),
          ),

          pw.SizedBox(height: 10),

          pw.Center(
            child: pw.Text(
  chapter,
  style: pw.TextStyle(
    font: englishFont,
  ),),
          ),

          pw.Divider(),

          pw.SizedBox(height: 20),

        pw.Directionality(
  textDirection: pw.TextDirection.rtl,
  child: pw.Text(
    arabic,
    textAlign: pw.TextAlign.right,
    style: pw.TextStyle(
      font: arabicFont,
      fontSize: 22,
      lineSpacing: 6,
    ),
  ),
),
          pw.SizedBox(height: 20),

          if (narrator.isNotEmpty)
            pw.Text(
              arabic,
              style: pw.TextStyle(
  font: englishBold,
)
            ),

          pw.SizedBox(height: 20),

         pw.Text(
  english,
  style: pw.TextStyle(
    font: englishFont,
    fontSize: 14,
    lineSpacing: 5,
  ),
),

          pw.SizedBox(height: 40),

          pw.Divider(),

        pw.Text(
  "Hadith #$hadithNumber",
  style: pw.TextStyle(
    font: englishBold,
  ),
),

          pw.SizedBox(height: 10),

         pw.Text(
  "SEEKER",
  style: pw.TextStyle(
    font: englishBold,
    fontSize: 28,
    color: PdfColors.green900,
  ),
),
        ],
      ),
    );

    final directory = await getTemporaryDirectory();

    final file = File(
      "${directory.path}/hadith.pdf",
    );

    await file.writeAsBytes(
      await pdf.save(),
    );

    await Share.shareXFiles(
      [XFile(file.path)],
    );
  }
  
}