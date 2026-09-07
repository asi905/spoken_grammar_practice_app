import 'package:shared_preferences/shared_preferences.dart';

// ইউজার সবচেয়ে শেষে কোন practice category-তে ছিল, সেটা মনে রাখে —
// Home Screen-এর "Continue Practice" card-এর জন্য।
class LastActivityService {
  static const _kLastCategory = 'last_activity_category';

  static Future<void> setLastCategory(String category) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_kLastCategory, category);
  }

  static Future<String?> getLastCategory() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_kLastCategory);
  }
}
