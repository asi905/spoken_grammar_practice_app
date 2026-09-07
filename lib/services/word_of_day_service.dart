import 'dart:math';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/practice_item.dart';
import '../data/sample_data.dart';

class WordOfDayService {
  static PracticeItem getTodayWord() {
    final now = DateTime.now();
    final dayOfYear = now.difference(DateTime(now.year, 1, 1)).inDays;
    final index = dayOfYear % sampleVocabulary.length;
    return sampleVocabulary[index];
  }

  static List<String> generateOptions(String correctAnswer, bool isSynonym) {
    final random = Random();
    final Set<String> options = {correctAnswer};

    final otherItems = sampleVocabulary.where((item) {
      final list = isSynonym ? item.synonyms : item.antonyms;
      return !list.contains(correctAnswer);
    }).toList();

    otherItems.shuffle(random);

    for (var item in otherItems) {
      if (options.length >= 4) break;
      final list = isSynonym ? item.synonyms : item.antonyms;
      if (list.isNotEmpty) {
        options.add(list[random.nextInt(list.length)]);
      }
    }

    final optionList = options.toList();
    optionList.shuffle(random);
    return optionList;
  }

  static Future<void> saveTodayResult(
      bool synonymCorrect, bool antonymCorrect) async {
    final prefs = await SharedPreferences.getInstance();
    final today = DateTime.now().toIso8601String().split('T')[0];

    await prefs.setBool('test_${today}_synonym', synonymCorrect);
    await prefs.setBool('test_${today}_antonym', antonymCorrect);

    final history = prefs.getStringList('test_history') ?? [];
    if (!history.contains(today)) {
      history.add(today);
      await prefs.setStringList('test_history', history);
    }
  }

  static Future<bool> hasTakenTestToday() async {
    final prefs = await SharedPreferences.getInstance();
    final today = DateTime.now().toIso8601String().split('T')[0];
    return prefs.containsKey('test_${today}_synonym');
  }
}
