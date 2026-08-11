import 'dart:convert';

import 'package:flutter/services.dart';

import '../models/azkar_model.dart';

class AzkarService {
  /// Loads the complete Azkar collection.
  Future<List<AzkarModel>> loadAzkar() async {
    final jsonString = await rootBundle.loadString(
      'assets/azkar/azkar.json',
    );

    final List<dynamic> jsonData =
        json.decode(jsonString);

    return List.generate(
      jsonData.length,
      (index) {
        final item = Map<String, dynamic>.from(
          jsonData[index],
        );

        return AzkarModel.fromJson({
          ...item,
          'id': 'azkar_$index',
        });
      },
    );
  }

  /// Returns exactly ONE Azkar for today.
  Future<AzkarModel?> getTodayAzkar() async {
    final azkar = await loadAzkar();

    if (azkar.isEmpty) {
      return null;
    }

    final now = DateTime.now();

    /// Number of days since a fixed date.
    final dayNumber = DateTime(
      now.year,
      now.month,
      now.day,
    ).difference(
      DateTime(2026, 1, 1),
    ).inDays;

    /// Move to the next Azkar each day.
    final index = dayNumber % azkar.length;

    return azkar[index];
    
  }
  
}
