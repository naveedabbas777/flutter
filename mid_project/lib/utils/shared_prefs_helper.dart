import 'package:shared_preferences/shared_preferences.dart';

class SharedPrefsHelper {
  static Future<void> saveStars(int stars) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt("stars", stars);
  }

  static Future<int> loadStars() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt("stars") ?? 0;
  }
}
