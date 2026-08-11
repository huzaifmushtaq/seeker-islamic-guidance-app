import 'package:shared_preferences/shared_preferences.dart';

class AzkarProgressService {
  static const String _dateKey = 'daily_azkar_date';
  static const String _azkarIdKey = 'daily_azkar_id';
  static const String _countKey = 'daily_azkar_count';

  /// Save today's Azkar and the user's current repetition count.
  Future<void> saveProgress({
    required String azkarId,
    required int count,
  }) async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.setString(_dateKey, _todayKey());

    await prefs.setString(_azkarIdKey, azkarId);

    await prefs.setInt(_countKey, count);
  }

  /// Load today's saved progress.
  ///
  /// Returns null if there is no progress for today.
  Future<Map<String, dynamic>?> loadProgress() async {
    final prefs = await SharedPreferences.getInstance();

    final savedDate = prefs.getString(_dateKey);

    // Nothing saved yet.
    if (savedDate == null) {
      return null;
    }

    // Saved progress belongs to another day.
    if (savedDate != _todayKey()) {
      await resetProgress();
      return null;
    }

    return {
      'azkarId': prefs.getString(_azkarIdKey),
      'count': prefs.getInt(_countKey) ?? 0,
    };
  }

  /// Reset today's progress.
  Future<void> resetProgress() async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.remove(_dateKey);
    await prefs.remove(_azkarIdKey);
    await prefs.remove(_countKey);
  }

  /// Returns today's date as YYYY-MM-DD.
  String _todayKey() {
    final now = DateTime.now();

    return '${now.year}-'
        '${now.month.toString().padLeft(2, '0')}-'
        '${now.day.toString().padLeft(2, '0')}';
  }
}
