import 'package:flutter_tts/flutter_tts.dart';

// শব্দ/বাক্য জোরে পড়ে শোনানোর সার্ভিস
class TtsService {
  static final FlutterTts _flutterTts = FlutterTts();
  static bool _isInitialized = false;

  static Future<void> _init() async {
    if (_isInitialized) return;
    await _flutterTts.setLanguage("en-US");
    await _flutterTts.setSpeechRate(0.45);
    await _flutterTts.setPitch(1.0);
    _isInitialized = true;
  }

  // দেওয়া টেক্সটটা জোরে পড়ে শোনায়
  static Future<void> speak(String text) async {
    await _init();
    await _flutterTts.stop();
    await _flutterTts.speak(text);
  }

  static Future<void> stop() async {
    await _flutterTts.stop();
  }
}
