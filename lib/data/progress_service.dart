import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/practice_item.dart';

// ইউজারের প্রোগ্রেস (কী কী শব্দ/বাক্য শেষ করলো, কবে) ট্র্যাক করার জন্য সার্ভিস।
class ProgressService {
  static const _completedKey = 'completed_items_v2';
  static const _legacyCompletedKey = 'completed_item_ids';

  Future<void> markCompleted(PracticeItem item) async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getStringList(_completedKey) ?? [];

    raw.removeWhere((e) {
      final decoded = jsonDecode(e) as Map<String, dynamic>;
      return decoded['english'].toString().toLowerCase() ==
          item.english.toLowerCase();
    });

    raw.add(jsonEncode({
      'id': item.id,
      'english': item.english,
      'bengaliMeaning': item.bengaliMeaning,
      'category': item.category,
      'exampleSentence': item.exampleSentence,
      'synonyms': item.synonyms,
      'antonyms': item.antonyms,
      'completedAt': DateTime.now().millisecondsSinceEpoch,
    }));

    await prefs.setStringList(_completedKey, raw);

    final legacyIds = prefs.getStringList(_legacyCompletedKey) ?? [];
    if (!legacyIds.contains(item.id)) {
      legacyIds.add(item.id);
      await prefs.setStringList(_legacyCompletedKey, legacyIds);
    }
  }

  Future<List<Map<String, dynamic>>> _getAllCompletedRaw() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getStringList(_completedKey) ?? [];
    return raw.map((e) => jsonDecode(e) as Map<String, dynamic>).toList();
  }

  Future<List<String>> getCompletedIds() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getStringList(_legacyCompletedKey) ?? [];
  }

  Future<int> getCompletedCount() async {
    final all = await _getAllCompletedRaw();
    return all.length;
  }

  /// গত [days] দিনে যেসব শব্দ/বাক্য প্র্যাকটিস করা হয়েছে, PracticeItem হিসেবে ফেরত দেয়।
  Future<List<PracticeItem>> getItemsCompletedInLastDays(int days) async {
    final all = await _getAllCompletedRaw();
    final cutoff = DateTime.now().subtract(Duration(days: days));

    final filtered = all.where((e) {
      final completedAt =
          DateTime.fromMillisecondsSinceEpoch(e['completedAt'] as int? ?? 0);
      return completedAt.isAfter(cutoff);
    }).toList();

    return filtered
        .map((e) => PracticeItem(
              id: e['id'] as String,
              english: e['english'] as String,
              bengaliMeaning: e['bengaliMeaning'] as String,
              category: e['category'] as String? ?? '',
              exampleSentence: e['exampleSentence'] as String?,
              synonyms: (e['synonyms'] as List?)?.cast<String>() ?? [],
              antonyms: (e['antonyms'] as List?)?.cast<String>() ?? [],
            ))
        .toList();
  }

  /// শেষ [days] দিনের প্রতিদিনের practice সংখ্যা, সবচেয়ে পুরনো দিন থেকে
  /// আজ পর্যন্ত ক্রমে সাজানো (Weekly Progress bar chart-এর জন্য)।
  Future<List<int>> getDailyCountsForLastDays(int days) async {
    final all = await _getAllCompletedRaw();
    final today = DateTime.now();
    final todayOnly = DateTime(today.year, today.month, today.day);

    final counts = List<int>.filled(days, 0);

    for (final e in all) {
      final completedAt =
          DateTime.fromMillisecondsSinceEpoch(e['completedAt'] as int? ?? 0);
      final dayOnly =
          DateTime(completedAt.year, completedAt.month, completedAt.day);
      final diff = todayOnly.difference(dayOnly).inDays;
      if (diff >= 0 && diff < days) {
        counts[days - 1 - diff]++;
      }
    }

    return counts;
  }
}
