import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../services/tts_service.dart';
import '../services/stt_service.dart';

// ইউজার ও এআই উভয়ের টেক্সট ট্রান্সলেট করার হেল্পার (Google Translate)
class TranslationHelper {
  static Future<String> translate(String text) async {
    bool isBengali = RegExp(r'[\u0980-\u09FF]').hasMatch(text);
    String targetLang = isBengali ? 'en' : 'bn';

    try {
      final uri = Uri.parse(
          'https://translate.googleapis.com/translate_a/single?client=gtx&sl=auto&tl=$targetLang&dt=t&q=${Uri.encodeComponent(text)}');
      final res = await http.get(uri).timeout(const Duration(seconds: 4));

      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);
        String result = '';
        for (var item in data[0]) {
          result += item[0].toString();
        }
        return '($result)';
      }
    } catch (_) {}
    return '';
  }
}

class RoleplayAiService {
  // 🔒 সিকিউরিটির জন্য এপিআই কি ফাকা রাখা হয়েছে, এখানে তোমার আসল কি বসিয়ে নিও বা পরিবেশ ভেরিয়েবল ব্যবহার করো
  static const String _apiKey = '';
  static const String _endpoint =
      'https://api.groq.com/openai/v1/chat/completions';
  static final List<Map<String, String>> _history = [];

  static void initRole(String systemInstruction) {
    _history.clear();
    // এআইকে কড়া নির্দেশ দেওয়া হচ্ছে যেন সে বাংলিশ বা হিন্দি ব্যবহার না করে
    String advancedInstruction = systemInstruction +
        "\n\nCRITICAL RULE: You must reply in pure English if the user types in English letters, and in pure Bengali script (বাংলা লিপি) if the user types in Bengali. NEVER use Romanized Bengali, Hindi, or Banglish (e.g., do not write 'Kripya', 'Kemon acho'). Additionally, you MUST provide the exact translation of your reply in the OTHER language enclosed in parentheses on a new line. Format: \n[Main Reply]\n([Translation])";
    _history.add({"role": "system", "content": advancedInstruction});
  }

  static Future<String> sendMessage(String userMessage) async {
    final newUserMsg = {"role": "user", "content": userMessage};
    final requestHistory = List<Map<String, String>>.from(_history)
      ..add(newUserMsg);

    try {
      final res = await http.post(
        Uri.parse(_endpoint),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $_apiKey'
        },
        body: jsonEncode(
            {"model": "openai/gpt-oss-20b", "messages": requestHistory}),
      );
      if (res.statusCode == 200) {
        final reply = jsonDecode(utf8.decode(res.bodyBytes))['choices'][0]
            ['message']['content'] as String;
        _history.add(newUserMsg);
        _history.add({"role": "assistant", "content": reply});
        return reply.trim();
      }
      return "দুঃখিত, কোনো সমস্যা হয়েছে।\n(Sorry, something went wrong.)";
    } catch (_) {
      return "ইন্টারনেট কানেকশন চেক করুন।\n(Please check your internet connection.)";
    }
  }
}

class ChatMsg {
  final String text;
  final String? translation;
  final bool isUser;
  ChatMsg({required this.text, this.translation, required this.isUser});
}

class RoleplayScreen extends StatefulWidget {
  final dynamic roleData;
  const RoleplayScreen({super.key, required this.roleData});

  @override
  State<RoleplayScreen> createState() => _RoleplayScreenState();
}

class _RoleplayScreenState extends State<RoleplayScreen> {
  final List<ChatMsg> _messages = [];
  final TextEditingController _controller = TextEditingController();
  bool _isThinking = false;
  bool _isListening = false;
  String _liveText = '';

  @override
  void initState() {
    super.initState();
    RoleplayAiService.initRole(widget.roleData['system_instruction']);

    final firstMsg = widget.roleData['first_message'] as String;
    _messages.add(ChatMsg(text: firstMsg, isUser: false));

    TranslationHelper.translate(firstMsg).then((trans) {
      if (trans.isNotEmpty && mounted) {
        setState(() {
          _messages[0] =
              ChatMsg(text: firstMsg, translation: trans, isUser: false);
        });
      }
    });
  }

  Future<void> _startListening() async {
    setState(() {
      _isListening = true;
      _liveText = '';
    });
    await SttService.startListening((text) {
      setState(() => _liveText = text);
    });
    await Future.delayed(const Duration(seconds: 5));
    await SttService.stopListening();
    setState(() => _isListening = false);

    if (_liveText.trim().isNotEmpty) {
      _handleSend(_liveText.trim());
    }
  }

  Future<void> _handleSend(String text) async {
    if (text.trim().isEmpty) return;
    final userText = text.trim();
    _controller.clear();

    int userMsgIndex = _messages.length;
    setState(() {
      _messages.add(ChatMsg(text: userText, isUser: true));
      _isThinking = true;
    });

    TranslationHelper.translate(userText).then((trans) {
      if (trans.isNotEmpty && mounted) {
        setState(() {
          _messages[userMsgIndex] =
              ChatMsg(text: userText, translation: trans, isUser: true);
        });
      }
    });

    final reply = await RoleplayAiService.sendMessage(userText);

    if (mounted) {
      String mainText = reply;
      String? transText;

      if (reply.contains('\n(') && reply.endsWith(')')) {
        int splitIdx = reply.lastIndexOf('\n(');
        mainText = reply.substring(0, splitIdx).trim();
        transText = reply.substring(splitIdx + 1).trim();
      } else {
        mainText = reply;
      }

      setState(() {
        _messages.add(
            ChatMsg(text: mainText, translation: transText, isUser: false));
        _isThinking = false;
      });
      TtsService.speak(mainText);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.roleData['role_name']),
        backgroundColor: Colors.indigo,
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          Container(
            width: double.infinity,
            color: Colors.indigo.shade50,
            padding: const EdgeInsets.all(12),
            child: Text(
              'Scenario: ${widget.roleData['title']}',
              style: const TextStyle(
                  fontWeight: FontWeight.bold, color: Colors.indigo),
              textAlign: TextAlign.center,
            ),
          ),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final msg = _messages[index];
                return Align(
                  alignment:
                      msg.isUser ? Alignment.centerRight : Alignment.centerLeft,
                  child: Container(
                    margin: const EdgeInsets.symmetric(vertical: 6),
                    padding: const EdgeInsets.all(12),
                    constraints: BoxConstraints(
                        maxWidth: MediaQuery.of(context).size.width * 0.75),
                    decoration: BoxDecoration(
                      color: msg.isUser ? Colors.indigo : Colors.grey.shade200,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      crossAxisAlignment: msg.isUser
                          ? CrossAxisAlignment.end
                          : CrossAxisAlignment.start,
                      children: [
                        Text(
                          msg.text,
                          style: TextStyle(
                            color: msg.isUser ? Colors.white : Colors.black87,
                            fontSize: 16,
                          ),
                        ),
                        if (msg.translation != null &&
                            msg.translation!.isNotEmpty) ...[
                          const SizedBox(height: 4),
                          Text(
                            msg.translation!,
                            style: TextStyle(
                              color:
                                  msg.isUser ? Colors.white70 : Colors.black54,
                              fontStyle: FontStyle.italic,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          if (_isThinking)
            const Padding(
              padding: EdgeInsets.all(8),
              child: Text('Reply টাইপ করছে...',
                  style: TextStyle(color: Colors.grey)),
            ),
          if (_isListening)
            Padding(
              padding: const EdgeInsets.all(8),
              child: Text(
                _liveText.isEmpty ? 'শুনছি...' : _liveText,
                style: const TextStyle(color: Colors.red),
              ),
            ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            color: Colors.white,
            child: Row(
              children: [
                GestureDetector(
                  onTap: _isListening || _isThinking ? null : _startListening,
                  child: CircleAvatar(
                    radius: 24,
                    backgroundColor: _isListening ? Colors.red : Colors.indigo,
                    child: Icon(_isListening ? Icons.mic : Icons.mic_none,
                        color: Colors.white),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextField(
                    controller: _controller,
                    decoration: InputDecoration(
                      hintText: 'Type a message...',
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(24)),
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 12),
                    ),
                    onSubmitted: (_) => _handleSend(_controller.text),
                  ),
                ),
                const SizedBox(width: 8),
                CircleAvatar(
                  radius: 24,
                  backgroundColor: Colors.indigo,
                  child: IconButton(
                    icon: const Icon(Icons.send, color: Colors.white, size: 20),
                    onPressed: () => _handleSend(_controller.text),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
