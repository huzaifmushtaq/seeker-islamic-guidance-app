import 'dart:convert';
import 'package:flutter/services.dart';

import '../models/wisdom_model.dart';

class WisdomService {
  Future<List<WisdomModel>> loadWisdoms() async {
    final jsonString = await rootBundle.loadString(
      'assets/hadith/wisdoms_200.json',
    );

    final List<dynamic> jsonData = json.decode(jsonString);

    return jsonData.map((item) => WisdomModel.fromJson(item)).toList();
  }
}
