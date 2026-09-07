import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/ai_conversation_service.dart';
import '../services/tts_service.dart';
import '../services/stt_service.dart';

class ChatMessage {
  final String text;
  final bool isUser;
  ChatMessage({required this.text, required this.isUser});
}

class LiveConversationScreen extends StatefulWidget {
  const LiveConversationScreen({super.key});

  @override
  State<LiveConversationScreen> createState() => _LiveConversationScreenState();
}

class _LiveConversationScreenState extends State<LiveConversationScreen> {
  final List<ChatMessage> _messages = [];
  bool _isListening = false;
  bool _isThinking = false;
  String _liveText = '';

  String _selectedMode = 'Eng-Eng';

  @override
  void initState() {
    super.initState();
    _loadModeAndInitialize();
  }

  Future<void> _loadModeAndInitialize() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _selectedMode = prefs.getString('live_chat_mode') ?? 'Eng-Eng';
    });

    AiConversationService.resetConversation();

    setState(() {
      _messages.add(ChatMessage(
        text:
            "Hi there! I'm your English practice partner. Tap the mic and start talking to me about anything! [হ্যালো! আমি আপনার ইংরেজি প্র্যাকটিস পার্টনার। মাইক চেপে কথা বলা শুরু করুন!]",
        isUser: false,
      ));
    });
  }

  Future<void> _startListening() async {
    setState(() {
      _isListening = true;
      _liveText = '';
    });

    await SttService.startListening((text) {
      setState(() => _liveText = text);
    }, mode: _selectedMode);

    await Future.delayed(const Duration(seconds: 5));
    await SttService.stopListening();

    setState(() => _isListening = false);

    if (_liveText.trim().isEmpty) return;

    final userText = _liveText.trim();
    setState(() {
      _messages.add(ChatMessage(text: userText, isUser: true));
      _isThinking = true;
    });

    String userTargetLang = 'Bengali';
    if (_selectedMode == 'Bng-Eng') {
      userTargetLang = 'English';
    }

    // 🟢 আপডেট: একসাথে না পাঠিয়ে একটার পর একটা রিকোয়েস্ট পাঠানো হচ্ছে
    final userTranslation =
        await AiConversationService.translateText(userText, userTargetLang);
    final reply =
        await AiConversationService.sendMessage(userText, mode: _selectedMode);

    if (mounted) {
      setState(() {
        if (userTranslation.isNotEmpty) {
          _messages[_messages.length - 1] = ChatMessage(
            text: "$userText [$userTranslation]",
            isUser: true,
          );
        }

        _messages.add(ChatMessage(text: reply, isUser: false));
        _isThinking = false;
      });

      final textToSpeak = reply.replaceAll(RegExp(r'\[.*?\]'), '').trim();
      TtsService.speak(textToSpeak);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Live Conversation')),
      body: Column(
        children: [
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
                    child: Text(
                      msg.text,
                      style: TextStyle(
                          color: msg.isUser ? Colors.white : Colors.black87),
                    ),
                  ),
                );
              },
            ),
          ),
          if (_isThinking)
            const Padding(
              padding: EdgeInsets.all(8),
              child: Text('ভাবছে...', style: TextStyle(color: Colors.grey)),
            ),
          if (_isListening)
            Padding(
              padding: const EdgeInsets.all(8),
              child: Text(
                _liveText.isEmpty ? 'শুনছি...' : _liveText,
                style: const TextStyle(color: Colors.red),
              ),
            ),
          Padding(
            padding: const EdgeInsets.all(20),
            child: GestureDetector(
              onTap: (_isListening || _isThinking) ? null : _startListening,
              child: CircleAvatar(
                radius: 32,
                backgroundColor: _isListening ? Colors.red : Colors.indigo,
                child: Icon(
                  _isListening ? Icons.mic : Icons.mic_none,
                  color: Colors.white,
                  size: 32,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
