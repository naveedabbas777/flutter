import 'package:shared_preferences/shared_preferences.dart';

class Storage {
  static Future<void> saveScore(String key, int score) async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setInt(key, score);
  }

  static Future<int> getScore(String key) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(key) ?? 0;
  }

  static Future<void> saveTestResult(int score, int total) async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setInt('last_test_score', score);
    prefs.setInt('last_test_total', total);
  }

  static Future<Map<String, int>> getAllScores() async {
    final prefs = await SharedPreferences.getInstance();
    return {
      'multiple_choice': prefs.getInt('multiple_choice') ?? 0,
      'true_false': prefs.getInt('true_false') ?? 0,
      'input_answer': prefs.getInt('input_answer') ?? 0,
      'last_test_score': prefs.getInt('last_test_score') ?? 0,
      'last_test_total': prefs.getInt('last_test_total') ?? 0,
    };
  }

  static Future<void> clearAll() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }
}
