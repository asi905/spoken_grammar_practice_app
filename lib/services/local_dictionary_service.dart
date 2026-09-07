import 'dart:convert';
import 'package:flutter/foundation.dart' show compute;
import 'package:flutter/services.dart' show rootBundle;

// বড় JSON ফাইলটা background isolate-এ decode করা হয় (main thread ব্লক না হয়ে)
List<dynamic> _decodeJson(String jsonStr) {
  return jsonDecode(jsonStr) as List<dynamic>;
}

/// অ্যাপে বান্ডল করা বড় (১,০৩,৬৫০ শব্দের) ইংরেজি-বাংলা ডিকশনারি
/// (assets/dictionary/bengali_dictionary.json) লোড, পার্স ও ক্যাশ করে।
/// প্রথমবার সার্চ করার সময় লোড হয়, তারপর মেমোরিতে থেকে যায় —
/// দ্বিতীয়বার থেকে সার্চ হয় তাৎক্ষণিক।
class LocalDictionaryService {
  static Map<String, Map<String, dynamic>>? _cache;
  static Future<Map<String, Map<String, dynamic>>>? _loadingFuture;

  static Future<Map<String, Map<String, dynamic>>> _load() async {
    if (_cache != null) return _cache!;
    if (_loadingFuture != null) return _loadingFuture!;

    _loadingFuture = () async {
      final jsonStr = await rootBundle
          .loadString('assets/dictionary/bengali_dictionary.json');

      // পার্সিং (CPU-heavy কাজ) একটা আলাদা isolate-এ করা হয়
      final List<dynamic> list = await compute(_decodeJson, jsonStr);

      final Map<String, Map<String, dynamic>> map = {};
      for (final item in list) {
        if (item is Map<String, dynamic>) {
          final en = (item['en'] as String?)?.toLowerCase().trim();
          if (en != null && en.isNotEmpty && !map.containsKey(en)) {
            map[en] = item;
          }
        }
      }

      _cache = map;
      return map;
    }();

    return _loadingFuture!;
  }

  /// অ্যাপ চালু হওয়ার সময় (বা প্রথম স্ক্রিনে) কল করলে ডিকশনারিটা আগে
  /// থেকেই ব্যাকগ্রাউন্ডে লোড হয়ে থাকবে, সার্চের সময় অপেক্ষা করতে হবে না।
  static Future<void> preload() async {
    await _load();
  }

  /// একটা শব্দ খুঁজে তার সম্পূর্ণ ডিকশনারি এন্ট্রি রিটার্ন করে
  /// (bn, en_syns, bn_syns, pron, sents সহ), না পেলে null।
  static Future<Map<String, dynamic>?> lookup(String word) async {
    final map = await _load();
    return map[word.toLowerCase().trim()];
  }
}
