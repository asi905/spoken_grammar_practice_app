import 'package:shared_preferences/shared_preferences.dart';

// Level ও Day-ভিত্তিক লক/আনলক আর পয়েন্ট হিসাব রাখে
class GrammarProgressService {
  static const _kUnlockedLevelKey = 'grammar_unlocked_level';
  static const _kTotalPointsKey = 'grammar_total_points';
  static String _unlockedDayKey(int level) =>
      'grammar_unlocked_day_level_$level';
  static String _completedKey(int level, int day) =>
      'grammar_completed_${level}_$day';

  static const Map<int, int> levelCompletionPoints = {
    1: 50,
    2: 100,
    3: 150,
    4: 200,
  };

  static const int perDayPoints = 20;

  // এখন পর্যন্ত সর্বোচ্চ কোন Level আনলক (ডিফল্ট: শুধু Level 1)
  static Future<int> getUnlockedLevel() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_kUnlockedLevelKey) ?? 1;
  }

  // নির্দিষ্ট level-এ কোন day পর্যন্ত আনলক (ডিফল্ট: Day 1)
  static Future<int> getUnlockedDay(int level) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_unlockedDayKey(level)) ?? 1;
  }

  static Future<int> getTotalPoints() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_kTotalPointsKey) ?? 0;
  }

  static Future<bool> _isDayCompleted(int level, int day) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_completedKey(level, day)) ?? false;
  }

  // একটা Day-এর টেস্ট শেষ হলে কল হয়। প্রথমবার সম্পূর্ণ হলে পয়েন্ট দেয় আর পরের day/level আনলক করে।
  // রিটার্ন করে {'dayPoints': ..., 'levelBonus': ...}
  static Future<Map<String, int>> completeDay(int level, int day) async {
    final prefs = await SharedPreferences.getInstance();
    final alreadyCompleted = await _isDayCompleted(level, day);

    int earnedDayPoints = 0;
    int earnedLevelBonus = 0;

    if (!alreadyCompleted) {
      await prefs.setBool(_completedKey(level, day), true);
      earnedDayPoints = perDayPoints;

      final currentTotal = prefs.getInt(_kTotalPointsKey) ?? 0;
      await prefs.setInt(_kTotalPointsKey, currentTotal + perDayPoints);

      // এই level-এর মধ্যে পরের day আনলক করা
      final currentUnlockedDay = prefs.getInt(_unlockedDayKey(level)) ?? 1;
      if (day + 1 > currentUnlockedDay && day < 10) {
        await prefs.setInt(_unlockedDayKey(level), day + 1);
      }

      // এই level-এর ১০ নম্বর day হলে → level বোনাস + পরের level আনলক
      if (day == 10) {
        earnedLevelBonus = levelCompletionPoints[level] ?? 0;
        final total2 = prefs.getInt(_kTotalPointsKey) ?? 0;
        await prefs.setInt(_kTotalPointsKey, total2 + earnedLevelBonus);

        final currentUnlockedLevel = prefs.getInt(_kUnlockedLevelKey) ?? 1;
        if (level + 1 > currentUnlockedLevel && level < 4) {
          await prefs.setInt(_kUnlockedLevelKey, level + 1);
        }
      }
    }

    return {
      'dayPoints': earnedDayPoints,
      'levelBonus': earnedLevelBonus,
    };
  }
}
