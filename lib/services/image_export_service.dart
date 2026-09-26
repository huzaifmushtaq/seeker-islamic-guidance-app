import 'dart:typed_data';

import 'package:flutter/foundation.dart';
import 'package:gal/gal.dart';

class ImageExportService {
  /// Saves a PNG image to the device gallery.
  ///
  /// On Web, this method is not supported by Gal.
  /// The screen should use the web download fallback instead.
  static Future<void> saveImage(
    Uint8List bytes, {
    String name = 'seeker_hadith',
  }) async {
    if (kIsWeb) {
      throw UnsupportedError(
        'Gallery saving is not supported on Web.',
      );
    }

    try {
      final hasAccess = await Gal.hasAccess();

      if (!hasAccess) {
        final granted = await Gal.requestAccess();

        if (!granted) {
          throw Exception(
            'Gallery permission was not granted.',
          );
        }
      }

      await Gal.putImageBytes(
        bytes,
        name: name,
      );
    } catch (e) {
      throw Exception(
        'Could not save image to gallery: $e',
      );
    }
  }
}