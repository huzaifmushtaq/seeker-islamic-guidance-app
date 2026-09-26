import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:seeker/models/knowledge_card_model.dart';

class KnowledgeCardService {
  static const String _assetPath =
      'assets/hadith/knowledge_cards_50_bukhari_muslim_urdu.json';

  Future<List<KnowledgeCardModel>> loadCards() async {
    final jsonString = await rootBundle.loadString(_assetPath);

    final List<dynamic> jsonList = jsonDecode(jsonString);

    return jsonList
        .map(
          (json) => KnowledgeCardModel.fromJson(
            Map<String, dynamic>.from(json),
          ),
        )
        .toList(growable: false);
  }

  Future<KnowledgeCardModel?> getCardOfTheDay() async {
    final cards = await loadCards();

    if (cards.isEmpty) {
      return null;
    }

    // Changes automatically each day,
    // while remaining stable throughout the same day.
    final dayNumber = DateTime.now().difference(
      DateTime(2025, 1, 1),
    ).inDays;

    return cards[dayNumber % cards.length];
  }
}