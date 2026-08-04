import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/rendering.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

class HadithShareService {
  Future<void> share(
    RenderRepaintBoundary boundary,
  ) async {
    final ui.Image image = await boundary.toImage(
      pixelRatio: 4,
    );

    final byteData =
        await image.toByteData(
      format: ui.ImageByteFormat.png,
    );

    if (byteData == null) return;

    final Uint8List pngBytes =
        byteData.buffer.asUint8List();

    final directory =
        await getTemporaryDirectory();

    final file = File(
      "${directory.path}/hadith.png",
    );

    await file.writeAsBytes(pngBytes);

    await Share.shareXFiles(
      [XFile(file.path)],
    );
  }
}