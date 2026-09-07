import 'dart:math';
import 'package:shared_preferences/shared_preferences.dart';

// প্রতিদিনের (ক্যালেন্ডার দিন অনুযায়ী, মধ্যরাত ১২টায়) ভোকাবুলারি
// প্র্যাকটিসের হিসাব রাখে।
// "category" প্যারামিটার দিয়ে প্রতিটা স্ক্রিন আলাদাভাবে নিজস্ব
// target/count/index হিসাব রাখে, একে অপরকে প্রভাবিত করে না।
class DailyVocabularyService {
  static String _dateKey(String category) => 'vocab_practice_date_$category';
  static String _countKey(String category) => 'vocab_practice_count_$category';
  static String _targetKey(String category) =>
      'vocab_practice_target_$category';
  static String _indexKey(String category) => 'vocab_practice_index_$category';

  static String _todayString() {
    final now = DateTime.now();
    return '${now.year}-${now.month}-${now.day}';
  }

  // আজকের প্রোগ্রেস লোড করে (নির্দিষ্ট category-এর জন্য)। ক্যালেন্ডারে
  // নতুন দিন (মধ্যরাত ১২টার পর) হলে count আর target রিসেট হয়ে যায়,
  // কিন্তু index (কোন শব্দ থেকে পরে শুরু হবে) রিসেট হয় না।
  static Future<Map<String, int>> loadTodayProgress(String category) async {
    final prefs = await SharedPreferences.getInstance();
    final savedDate = prefs.getString(_dateKey(category));
    final today = _todayString();

    if (savedDate != today) {
      await prefs.setString(_dateKey(category), today);
      await prefs.setInt(_countKey(category), 0);
      await prefs.setInt(
          _targetKey(category), 0); // ০ মানে আজকের target এখনো বাছা হয়নি
    }

    final count = prefs.getInt(_countKey(category)) ?? 0;
    final target = prefs.getInt(_targetKey(category)) ?? 0;
    return {'count': count, 'target': target};
  }

  static Future<void> setTarget(String category, int target) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_targetKey(category), target);
  }

  static Future<int> incrementCount(String category) async {
    final prefs = await SharedPreferences.getInstance();
    final current = prefs.getInt(_countKey(category)) ?? 0;
    final updated = current + 1;
    await prefs.setInt(_countKey(category), updated);
    return updated;
  }

  static Future<int> getStartIndex(String category) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_indexKey(category)) ?? 0;
  }

  static Future<void> saveIndex(String category, int index) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_indexKey(category), index);
  }

  static const _kUserSeedKey = 'vocab_user_seed';

  // প্রতিটা ফোন/ইনস্টলের জন্য একটা স্থায়ী random সংখ্যা রিটার্ন করে,
  // যাতে প্রতিটা ইউজার আলাদা কনভারসেশন সেট পায় (একবার তৈরি হলে আর বদলায় না)
  static Future<int> getOrCreateUserSeed() async {
    final prefs = await SharedPreferences.getInstance();
    int? seed = prefs.getInt(_kUserSeedKey);
    if (seed == null) {
      seed = Random().nextInt(1000000);
      await prefs.setInt(_kUserSeedKey, seed);
    }
    return seed;
  }
}
