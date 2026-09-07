import 'dart:convert';
import 'dart:math';
import 'package:http/http.dart' as http;
import '../models/practice_item.dart';
import 'local_dictionary_service.dart';

class DictionaryApiService {
  // "আজকের শব্দ" ফিচারের জন্য (random word feature) — অপরিবর্তিত
  static final Map<String, String> _bengaliMeanings = {
    'happy': 'খুশি / সুখী',
    'journey': 'যাত্রা',
    'brave': 'সাহসী',
    'gentle': 'ভদ্র / নম্র',
    'curious': 'কৌতূহলী',
    'honest': 'সৎ',
    'freedom': 'স্বাধীনতা',
    'wisdom': 'জ্ঞান / প্রজ্ঞা',
    'patience': 'ধৈর্য',
    'courage': 'সাহস',
    'kindness': 'দয়া',
    'generous': 'উদার',
    'humble': 'বিনয়ী',
    'diligent': 'পরিশ্রমী',
    'creative': 'সৃজনশীল',
    'reliable': 'নির্ভরযোগ্য',
    'confident': 'আত্মবিশ্বাসী',
    'genuine': 'প্রকৃত / আন্তরিক',
    'sincere': 'আন্তরিক',
    'resilient': 'সহনশীল / স্থিতিস্থাপক',
    'grateful': 'কৃতজ্ঞ',
    'ambitious': 'উচ্চাকাঙ্ক্ষী',
    'cheerful': 'প্রফুল্ল',
    'loyal': 'বিশ্বস্ত',
    'modest': 'বিনয়ী / শালীন',
    'optimistic': 'আশাবাদী',
    'passionate': 'অনুরাগী / আবেগপ্রবণ',
    'thoughtful': 'চিন্তাশীল',
    'vibrant': 'প্রাণবন্ত',
    'wholesome': 'স্বাস্থ্যকর / নির্মল',
    'authentic': 'প্রকৃত / খাঁটি',
    'compassionate': 'সহানুভূতিশীল',
    'determined': 'দৃঢ়প্রতিজ্ঞ',
    'flexible': 'নমনীয়',
    'graceful': 'সুন্দর / মার্জিত',
    'harmonious': 'সুরেলা / সামঞ্জস্যপূর্ণ',
    'innovative': 'উদ্ভাবনী',
    'joyful': 'আনন্দময়',
    'meticulous': 'খুঁতখুঁতে / সূক্ষ্ম',
    'nurturing': 'পরিচর্যাকারী',
    'persistent': 'অবিচল / দৃঢ়',
    'radiant': 'উজ্জ্বল',
    'serene': 'শান্ত',
    'tranquil': 'প্রশান্ত',
    'vivid': 'উজ্জ্বল / স্পষ্ট',
    'zealous': 'উদ্যমী',
    'benevolent': 'দয়ালু',
    'candid': 'অকপট',
    'diplomatic': 'কূটনৈতিক',
    'earnest': 'আন্তরিক / সিরিয়াস',
    'fervent': 'উত্সাহী',
  };

  static final Random _random = Random();
  static String? _lastWord;

  static String _pickRandomWord() {
    final words = _bengaliMeanings.keys.toList();
    String word;
    do {
      word = words[_random.nextInt(words.length)];
    } while (word == _lastWord && words.length > 1);
    _lastWord = word;
    return word;
  }

  static Future<Map<String, dynamic>?> _fetchDefinition(String word) async {
    try {
      final res = await http
          .get(Uri.parse(
              'https://api.dictionaryapi.dev/api/v2/entries/en/$word'))
          .timeout(const Duration(seconds: 4));
      if (res.statusCode == 200) {
        final list = jsonDecode(res.body) as List;
        if (list.isNotEmpty) return list.first as Map<String, dynamic>;
      }
    } catch (_) {}
    return null;
  }

  static Future<List<String>> _fetchSynonymsFromDatamuse(String word) async {
    try {
      final res = await http
          .get(Uri.parse('https://api.datamuse.com/words?rel_syn=$word&max=6'))
          .timeout(const Duration(seconds: 4));
      if (res.statusCode == 200) {
        final list = jsonDecode(res.body) as List;
        return list.map((e) => e['word'].toString()).toList();
      }
    } catch (_) {}
    return [];
  }

  static Future<List<String>> _fetchAntonymsFromDatamuse(String word) async {
    try {
      final res = await http
          .get(Uri.parse('https://api.datamuse.com/words?rel_ant=$word&max=6'))
          .timeout(const Duration(seconds: 4));
      if (res.statusCode == 200) {
        final list = jsonDecode(res.body) as List;
        return list.map((e) => e['word'].toString()).toList();
      }
    } catch (_) {}
    return [];
  }

  // কিছু common contraction এর জন্য নির্ভরযোগ্য লোকাল অর্থ (fallback হিসেবে থাকে)
  static final Map<String, String> _knownShortWords = {
    "let's": 'চলো / এসো আমরা',
    "don't": 'করো না',
    "can't": 'পারি না',
    "won't": 'করবে না',
    "it's": 'এটা',
    "i'm": 'আমি',
    "you're": 'তুমি',
    "we're": 'আমরা',
    "they're": 'তারা',
    "isn't": 'নয়',
    "aren't": 'নয়',
    "wasn't": 'ছিলো না',
    "weren't": 'ছিলো না',
    "haven't": 'হয়নি',
    "hasn't": 'হয়নি',
    "didn't": 'করিনি',
  };

  // অনুবাদে যদি এই ধরনের অনুপযুক্ত শব্দ চলে আসে, সেটা বাতিল করে দেওয়া হয়
  static final List<String> _blockedWords = [
    'চুদ',
    'চোদ',
    'বেশ্যা',
    'খানকি',
    'মাগি',
    'রেন্ডি',
  ];

  static bool _containsBlockedWord(String text) {
    for (final blocked in _blockedWords) {
      if (text.contains(blocked)) return true;
    }
    return false;
  }

  // একটা টেক্সট MyMemory API দিয়ে বাংলায় অনুবাদ করে (fallback হিসেবে ব্যবহৃত হয়,
  // শুধু তখনই যখন শব্দটা বড় লোকাল ডিকশনারিতে পাওয়া যায়নি)
  static Future<String> _translateText(String text) async {
    for (int i = 0; i < 2; i++) {
      try {
        final uri = Uri.parse(
            'https://api.mymemory.translated.net/get?q=${Uri.encodeComponent(text)}&langpair=en|bn');
        final res = await http.get(uri).timeout(const Duration(seconds: 5));
        if (res.statusCode == 200) {
          final data = jsonDecode(res.body);
          final translated = data['responseData']?['translatedText'];
          if (translated != null && translated.toString().isNotEmpty) {
            final result = translated.toString();
            if (result.toUpperCase().contains('QUERY LENGTH')) continue;
            if (_containsBlockedWord(result)) continue;
            return result;
          }
        }
      } catch (_) {}
    }
    return '';
  }

  static Future<String> _getFallbackBengaliMeaning(
      String word, String? englishDefinition) async {
    final lower = word.toLowerCase();
    if (_knownShortWords.containsKey(lower)) return _knownShortWords[lower]!;
    if (_bengaliMeanings.containsKey(lower)) return _bengaliMeanings[lower]!;

    if (englishDefinition != null && englishDefinition.trim().isNotEmpty) {
      final translated = await _translateText(englishDefinition);
      if (translated.isNotEmpty) return translated;
    }
    return await _translateText(word);
  }

  static String _stripHtmlTags(String text) {
    return text.replaceAll(RegExp(r'<[^>]*>'), '');
  }

  static Future<PracticeItem> fetchRandomPracticeItem() async {
    final word = _pickRandomWord();
    final bengali = _bengaliMeanings[word]!;

    final results = await Future.wait([
      _fetchDefinition(word),
      _fetchSynonymsFromDatamuse(word),
      _fetchAntonymsFromDatamuse(word),
    ]);

    final entry = results[0] as Map<String, dynamic>?;
    List<String> datamuseSynonyms = results[1] as List<String>;
    List<String> datamuseAntonyms = results[2] as List<String>;

    String? example;
    List<String> dictSynonyms = [];
    List<String> dictAntonyms = [];

    if (entry != null) {
      final meanings = entry['meanings'] as List?;
      if (meanings != null) {
        for (final meaning in meanings) {
          final defs = meaning['definitions'] as List?;
          if (defs != null) {
            for (final def in defs) {
              example ??= def['example'] as String?;
              dictSynonyms
                  .addAll((def['synonyms'] as List?)?.cast<String>() ?? []);
              dictAntonyms
                  .addAll((def['antonyms'] as List?)?.cast<String>() ?? []);
            }
          }
          dictSynonyms
              .addAll((meaning['synonyms'] as List?)?.cast<String>() ?? []);
          dictAntonyms
              .addAll((meaning['antonyms'] as List?)?.cast<String>() ?? []);
        }
      }
    }

    final synonyms = (dictSynonyms.isNotEmpty ? dictSynonyms : datamuseSynonyms)
        .toSet()
        .take(5)
        .toList();
    final antonyms = (dictAntonyms.isNotEmpty ? dictAntonyms : datamuseAntonyms)
        .toSet()
        .take(5)
        .toList();

    return PracticeItem(
      id: 'api_${word}_${DateTime.now().millisecondsSinceEpoch}',
      english: word,
      bengaliMeaning: bengali,
      category: 'Unlimited Vocabulary',
      exampleSentence: example,
      synonyms: synonyms,
      antonyms: antonyms,
    );
  }

  static Future<PracticeItem?> fetchWordDetails(String word) async {
    final cleanWord = word.trim().toLowerCase();
    if (cleanWord.isEmpty) return null;

    // ---------------------------------------------------------------
    // ধাপ ১: বড়, বান্ডল করা লোকাল ডিকশনারিতে (১,০৩,৬৫০ শব্দ) খোঁজা হয়।
    // এখানে পাওয়া গেলে এটাই সবচেয়ে নির্ভরযোগ্য উৎস — সরাসরি অভিধান
    // থেকে আসা, কোনো machine translation না।
    // ---------------------------------------------------------------
    final localEntry = await LocalDictionaryService.lookup(cleanWord);

    // Antonym এই লোকাল ডেটাসেটে নেই, তাই Datamuse থেকে সবসময় আনা হয়
    final datamuseResults = await Future.wait([
      _fetchSynonymsFromDatamuse(cleanWord),
      _fetchAntonymsFromDatamuse(cleanWord),
    ]);
    final datamuseSynonyms = datamuseResults[0];
    final datamuseAntonyms = datamuseResults[1];

    if (localEntry != null) {
      final bengali = (localEntry['bn'] as String?)?.trim() ?? '';
      final localEnSynonyms =
          (localEntry['en_syns'] as List?)?.cast<String>() ?? [];
      final sents = (localEntry['sents'] as List?)?.cast<String>() ?? [];

      final synonyms =
          (localEnSynonyms.isNotEmpty ? localEnSynonyms : datamuseSynonyms)
              .toSet()
              .take(6)
              .toList();
      final antonyms = datamuseAntonyms.toSet().take(6).toList();

      String? example;
      if (sents.isNotEmpty) {
        example = _stripHtmlTags(sents.first);
      }

      return PracticeItem(
        id: 'search_${cleanWord}_${DateTime.now().millisecondsSinceEpoch}',
        english: (localEntry['en'] as String?) ?? cleanWord,
        bengaliMeaning:
            bengali.isNotEmpty ? bengali : '(বাংলা অর্থ পাওয়া যায়নি)',
        category: 'Search Vocabulary',
        exampleSentence: example,
        synonyms: synonyms,
        antonyms: antonyms,
      );
    }

    // ---------------------------------------------------------------
    // ধাপ ২: লোকাল ডিকশনারিতে না পাওয়া গেলে — আগের fallback পদ্ধতি
    // (Free Dictionary API সংজ্ঞা + translation)
    // ---------------------------------------------------------------
    final entry = await _fetchDefinition(cleanWord);

    String? example;
    String? firstDefinition;
    List<String> dictSynonyms = [];
    List<String> dictAntonyms = [];

    if (entry != null) {
      final meanings = entry['meanings'] as List?;
      if (meanings != null) {
        for (final meaning in meanings) {
          final defs = meaning['definitions'] as List?;
          if (defs != null) {
            for (final def in defs) {
              example ??= def['example'] as String?;
              firstDefinition ??= def['definition'] as String?;
              dictSynonyms
                  .addAll((def['synonyms'] as List?)?.cast<String>() ?? []);
              dictAntonyms
                  .addAll((def['antonyms'] as List?)?.cast<String>() ?? []);
            }
          }
          dictSynonyms
              .addAll((meaning['synonyms'] as List?)?.cast<String>() ?? []);
          dictAntonyms
              .addAll((meaning['antonyms'] as List?)?.cast<String>() ?? []);
        }
      }
    }

    final bengali =
        await _getFallbackBengaliMeaning(cleanWord, firstDefinition);

    if (bengali.isEmpty && entry == null) return null;

    final finalMeaning = bengali.isNotEmpty
        ? '$bengali (আনুমানিক অনুবাদ)'
        : '(বাংলা অর্থ পাওয়া যায়নি)';

    final synonyms = (dictSynonyms.isNotEmpty ? dictSynonyms : datamuseSynonyms)
        .toSet()
        .take(6)
        .toList();
    final antonyms = (dictAntonyms.isNotEmpty ? dictAntonyms : datamuseAntonyms)
        .toSet()
        .take(6)
        .toList();

    String? displayExample = firstDefinition;
    if (example != null) {
      displayExample = firstDefinition != null
          ? '$firstDefinition\nউদাহরণ: "$example"'
          : example;
    }

    return PracticeItem(
      id: 'search_${cleanWord}_${DateTime.now().millisecondsSinceEpoch}',
      english: cleanWord,
      bengaliMeaning: finalMeaning,
      category: 'Search Vocabulary',
      exampleSentence: displayExample,
      synonyms: synonyms,
      antonyms: antonyms,
    );
  }
}
