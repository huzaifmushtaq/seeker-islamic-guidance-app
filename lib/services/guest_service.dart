import 'package:shared_preferences/shared_preferences.dart';

class GuestService {
  static const String _guestKey = "isGuest";

  Future<void> loginAsGuest() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_guestKey, true);
  }

  Future<void> logoutGuest() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_guestKey);
  }

  Future<bool> isGuest() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_guestKey) ?? false;
  }
}
