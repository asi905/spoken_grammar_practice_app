import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/practice_item.dart';
import '../data/sample_data.dart';

class DailySentenceApiService {
  static final List<String> _topicWords = [
    'weather',
    'family',
    'work',
    'travel',
    'food',
    'time',
    'weekend',
    'health',
    'shopping',
    'friend',
    'school',
    'money',
    'phone',
    'meeting',
    'morning',
    'evening',
    'holiday',
    'traffic',
    'coffee',
    'exercise',
    'restaurant',
    'birthday',
    'movie',
    'music',
    'book',
    'sport',
    'rain',
    'train',
    'airport',
    'hospital',
  ];

  static Future<PracticeItem?> _fetchOne(String query) async {
    try {
      final uri = Uri.parse(
        'https://tatoeba.org/eng/api_v0/search'
        '?from=eng&to=ben&query=$query&trans_filter=limit&trans_link=direct',
      );
      final res = await http.get(uri).timeout(const Duration(seconds: 6));
      if (res.statusCode != 200) return null;

      final data = jsonDecode(res.body);
      final results = data['results'] as List?;
      if (results == null || results.isEmpty) return null;

      results.shuffle();
      for (final item in results) {
        final translations = item['translations'] as List?;
        if (translations == null) continue;
        for (final group in translations) {
          final groupList = group as List?;
          if (groupList == null) continue;
          for (final t in groupList) {
            if (t['lang'] == 'ben' && (t['text'] as String? ?? '').isNotEmpty) {
              return PracticeItem(
                id: 'tatoeba_${item['id']}_${DateTime.now().millisecondsSinceEpoch}',
                english: item['text'] as String,
                bengaliMeaning: t['text'] as String,
                category: 'Daily Conversation',
              );
            }
          }
        }
      }
    } catch (_) {}
    return null;
  }

  /// একটা random ইংরেজি-বাংলা বাক্য জোড়া নিয়ে আসে ইন্টারনেট থেকে।
  /// প্রতিটা ফোন ভিন্ন topic word দিয়ে খোঁজে, তাই ইউজারদের মধ্যে
  /// বাক্য মেলার সম্ভাবনা কম থাকে। ব্যর্থ হলে local list থেকে দেয়।
  static Future<PracticeItem> fetchOneRandomSentence() async {
    final words = List<String>.from(_topicWords)..shuffle();
    for (final word in words.take(5)) {
      final item = await _fetchOne(word);
      if (item != null) return item;
    }

    final localShuffled = List<PracticeItem>.from(dailyConversationPractice)
      ..shuffle();
    return localShuffled.first;
  }
}
