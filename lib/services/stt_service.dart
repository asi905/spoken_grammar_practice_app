import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:permission_handler/permission_handler.dart';

// মাইক দিয়ে কথা বলে টেক্সট বানানোর সার্ভিস
class SttService {
  static final stt.SpeechToText _speech = stt.SpeechToText();
  static bool _isInitialized = false;

  // মাইক্রোফোন পারমিশন চাওয়া এবং স্পিচ ইঞ্জিন চালু করা
  static Future<bool> init() async {
    final micStatus = await Permission.microphone.request();
    if (!micStatus.isGranted) return false;

    _isInitialized = await _speech.initialize(
      onError: (error) => print('STT Error: $error'),
      onStatus: (status) => print('STT Status: $status'),
    );
    return _isInitialized;
  }

  static bool get isListening => _speech.isListening;

  // শোনা শুরু করা; মোডের ওপর ভিত্তি করে ভাষা নির্ধারণ হবে
  static Future<void> startListening(Function(String) onResult,
      {String mode = 'Eng-Eng'}) async {
    if (!_isInitialized) {
      final ok = await init();
      if (!ok) return;
    }

    // যদি ইউজার 'Bangla to English' মোডে কথা বলে, তাহলে STT বাংলা ভাষা শুনবে
    String listenLanguage = 'en_US'; // ডিফল্ট ইংরেজি
    if (mode == 'Bng-Eng') {
      listenLanguage = 'bn_BD'; // বাংলা ভাষা
    }

    await _speech.listen(
      onResult: (result) {
        onResult(result.recognizedWords);
      },
      localeId: listenLanguage, // ডায়নামিক ভাষা
    );
  }

  static Future<void> stopListening() async {
    await _speech.stop();
  }

  // ইউজার যা বললো সেটা সঠিক শব্দের সাথে মিলছে কিনা চেক করা (case-insensitive)
  static bool isMatch(String spoken, String target) {
    final cleanSpoken = spoken.trim().toLowerCase();
    final cleanTarget = target.trim().toLowerCase();
    return cleanSpoken == cleanTarget || cleanSpoken.contains(cleanTarget);
  }
}
