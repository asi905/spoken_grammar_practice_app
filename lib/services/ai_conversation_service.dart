import 'dart:convert';
import 'package:http/http.dart' as http;

class AiConversationService {
  // 🔒 সিকিউরিটির জন্য এপিআই কি ফাকা রাখা হয়েছে, এখানে আপনার আসল কি বসিয়ে নিন
  static const String _apiKey = '';
  static const String _endpoint =
      'https://api.groq.com/openai/v1/chat/completions';

  static final List<Map<String, String>> _history = [];

  static void resetConversation() {
    _history.clear();
  }

  static Future<String> translateText(
      String text, String targetLanguage) async {
    try {
      final response = await http.post(
        Uri.parse(_endpoint),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $_apiKey',
        },
        body: jsonEncode({
          "model": "openai/gpt-oss-20b",
          "messages": [
            {
              "role": "system",
              "content":
                  "You are a strict translator. Translate the given text to $targetLanguage. Provide ONLY the final translated text. No quotes, no intro, no explanation, no brackets."
            },
            {"role": "user", "content": text}
          ]
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['choices'][0]['message']['content'].toString().trim();
      }
      return "";
    } catch (e) {
      return "";
    }
  }

  static Future<String> sendMessage(String userMessage,
      {String mode = 'Eng-Eng'}) async {
    String systemInstruction = "";

    if (mode == 'Eng-Eng') {
      systemInstruction = "You are an English tutor. "
          "RULES:\n"
          "1. You MUST reply ONLY in English.\n"
          "2. After your English reply, you MUST provide the Bengali translation of your reply inside square brackets.\n"
          "3. Keep it short (1-2 sentences).\n"
          "Example format: I am doing fine! [আমি ভালো আছি!]";
    } else if (mode == 'Bng-Eng') {
      systemInstruction = "You are an English tutor. "
          "The user will speak to you in Bengali. "
          "RULES:\n"
          "1. You MUST reply ONLY in English.\n"
          "2. After your English reply, you MUST provide the Bengali translation of your reply inside square brackets.\n"
          "3. Keep it short (1-2 sentences).\n"
          "Example format: How are you today? [আজ আপনি কেমন আছেন?]";
    } else if (mode == 'Eng-Bng') {
      systemInstruction = "You are a language tutor. "
          "The user will speak to you in English. "
          "RULES:\n"
          "1. You MUST reply ONLY in Bengali language (Bengali script).\n"
          "2. After your Bengali reply, you MUST provide the exact English translation of your reply inside square brackets.\n"
          "3. Keep it short (1-2 sentences).\n"
          "Example format: আমি ভালো আছি, ধন্যবাদ! [I am fine, thank you!]";
    }

    if (_history.isEmpty ||
        _history.first['role'] == 'system' &&
            _history.first['content'] != systemInstruction) {
      if (_history.isNotEmpty && _history.first['role'] == 'system') {
        _history[0] = {"role": "system", "content": systemInstruction};
      } else {
        _history.insert(0, {"role": "system", "content": systemInstruction});
      }
    }

    final newUserMessage = {"role": "user", "content": userMessage};
    final requestHistory = List<Map<String, String>>.from(_history)
      ..add(newUserMessage);

    final body = {
      "model": "openai/gpt-oss-20b",
      "messages": requestHistory,
      "temperature": 0.5,
    };

    try {
      final response = await http.post(
        Uri.parse(_endpoint),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $_apiKey',
        },
        body: jsonEncode(body),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final reply = data['choices'][0]['message']['content'] as String;

        _history.add(newUserMessage);
        _history.add({"role": "assistant", "content": reply});

        return reply.trim();
      } else {
        try {
          final errorData = jsonDecode(response.body);
          final errorMsg = errorData['error']['message'] ?? 'Unknown Error';
          return "API Error (${response.statusCode}):$errorMsg";
        } catch (_) {
          return "API Error (${response.statusCode}):${response.body}";
        }
      }
    } catch (e) {
      return "Please check your internet connection. [অনুগ্রহ করে ইন্টারনেট চেক করুন।]";
    }
  }

  static Future<Map<String, dynamic>> evaluateAnswer(
      String question, String answer) async {
    try {
      final response = await http.post(
        Uri.parse(_endpoint),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $_apiKey',
        },
        body: jsonEncode({
          "model": "openai/gpt-oss-20b",
          "messages": [
            {
              "role": "system",
              "content": "You are a helpful English teacher. "
                  "The user was asked this question: '$question'. "
                  "The user answered: '$answer'. "
                  "Evaluate if the answer makes logical sense and is grammatically understandable in the context of the question. "
                  "You MUST respond ONLY in valid JSON format exactly like this: "
                  "{\"correct\": true or false, \"feedback\": \"A short friendly feedback in Bengali explaining why it is right or wrong\"}"
            }
          ],
          "temperature": 0.3,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final content =
            data['choices'][0]['message']['content'].toString().trim();

        String jsonStr = content;
        if (jsonStr.startsWith("```json")) {
          jsonStr =
              jsonStr.replaceAll("```json", "").replaceAll("```", "").trim();
        } else if (jsonStr.startsWith("```")) {
          jsonStr = jsonStr.replaceAll("```", "").trim();
        }

        final result = jsonDecode(jsonStr);
        return {
          'correct': result['correct'] ?? false,
          'feedback': result['feedback'] ?? 'কোনো ফিডব্যাক পাওয়া যায়নি।'
        };
      } else {
        return {
          'correct': false,
          'feedback': 'API Error: ${response.statusCode}'
        };
      }
    } catch (e) {
      return {
        'correct': false,
        'feedback': 'ইন্টারনেট কানেকশন চেক করুন বা আবার চেষ্টা করুন।'
      };
    }
  }
}
