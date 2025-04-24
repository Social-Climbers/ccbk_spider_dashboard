import 'package:shared_preferences/shared_preferences.dart';

class LocalStorageService {
  static const String _competitorIdKey = 'competitor_id';

  static Future<void> saveCompetitorId(int id) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_competitorIdKey, id);
  }

  static Future<int?> getCompetitorId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_competitorIdKey);
  }

  static Future<void> clearCompetitorId() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_competitorIdKey);
  }
} 