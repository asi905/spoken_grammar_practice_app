import 'package:flutter/material.dart';
import 'dart:math';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/stt_service.dart';
import '../services/ai_conversation_service.dart';

class DailyConversationScreen extends StatefulWidget {
  const DailyConversationScreen({super.key});

  @override
  State<DailyConversationScreen> createState() =>
      _DailyConversationScreenState();
}

class _DailyConversationScreenState extends State<DailyConversationScreen> {
  List<Map<String, String>> todaysConversations = [];
  bool _loading = true;

  final FlutterTts flutterTts = FlutterTts();

  // প্রতিটা কার্ডের নিজস্ব state আলাদাভাবে রাখা হয়
  final Map<int, bool> _isVoiceModeByIndex = {}; // true = voice, false = typing
  final Map<int, TextEditingController> _controllers = {};
  final Map<int, bool> _isListeningByIndex = {};
  final Map<int, bool> _isCheckingByIndex = {};
  final Map<int, bool?> _correctByIndex = {};
  final Map<int, String> _feedbackByIndex = {};

  final List<Map<String, String>> allConversations = [
    {
      'title': 'Meeting a Friend',
      'en': 'Tell me, how has your day been so far?',
      'bn': 'বলো তো, আজ তোমার দিনটা কেমন কাটছে?'
    },
    {
      'title': 'At the Restaurant',
      'en': 'What would you like to order today?',
      'bn': 'আজ তুমি কী অর্ডার করতে চাও?'
    },
    {
      'title': 'Asking for Directions',
      'en': 'Can you tell me how to get to the nearest bank?',
      'bn': 'তুমি কি বলতে পারবে কাছের ব্যাংকে কীভাবে যাওয়া যায়?'
    },
    {
      'title': 'At the Hospital',
      'en': 'What seems to be the problem today?',
      'bn': 'আজ তোমার সমস্যাটা কী বলে মনে হচ্ছে?'
    },
    {
      'title': 'Shopping',
      'en': 'What kind of clothes are you looking for?',
      'bn': 'তুমি কী ধরনের পোশাক খুঁজছো?'
    },
    {
      'title': 'Job Interview',
      'en': 'Tell me a little about yourself.',
      'bn': 'আপনার সম্পর্কে আমাকে একটু বলুন।'
    },
    {
      'title': 'Travel',
      'en': 'Where are you planning to travel next?',
      'bn': 'তুমি পরবর্তীতে কোথায় ভ্রমণ করার পরিকল্পনা করছো?'
    },
    {
      'title': 'Phone Call',
      'en': 'Who would you like to speak to?',
      'bn': 'তুমি কার সাথে কথা বলতে চাও?'
    },
    {
      'title': 'Weather Talk',
      'en': 'What do you think the weather will be like today?',
      'bn': 'আজ আবহাওয়া কেমন হতে পারে বলে তোমার মনে হয়?'
    },
    {
      'title': 'Apologizing',
      'en': 'Why were you late today?',
      'bn': 'আজ তুমি কেন দেরি করলে?'
    },
    {
      'title': 'Saying Goodbye',
      'en': 'How was it talking to me today?',
      'bn': 'আজ আমার সাথে কথা বলে কেমন লাগলো?'
    },
    {
      'title': 'Asking for Help',
      'en': 'What kind of help do you need right now?',
      'bn': 'এখন তোমার কী ধরনের সাহায্য দরকার?'
    },
    {
      'title': 'Morning Greetings',
      'en': 'Did you sleep well last night?',
      'bn': 'গতরাতে তোমার ঘুম কেমন হয়েছে?'
    },
    {
      'title': 'At the Airport',
      'en': 'Where are you flying to today?',
      'bn': 'আজ তুমি কোথায় যাচ্ছো (উড়োজাহাজে)?'
    },
    {
      'title': 'Ordering Coffee',
      'en': 'What kind of coffee do you usually drink?',
      'bn': 'তুমি সাধারণত কী ধরনের কফি খাও?'
    },
  ];

  @override
  void initState() {
    super.initState();
    _setupTts();
    _generateConversationsForThisUser();
  }

  Future<void> _setupTts() async {
    await flutterTts.setLanguage("en-US");
    await flutterTts.setSpeechRate(0.5);
    await flutterTts.setVolume(1.0);
    await flutterTts.setPitch(1.0);
  }

  Future<void> _speakText(String text) async {
    await flutterTts.stop();
    await flutterTts.speak(text);
  }

  @override
  void dispose() {
    flutterTts.stop();
    for (final c in _controllers.values) {
      c.dispose();
    }
    super.dispose();
  }

  Future<int> _getOrCreateUserSeed() async {
    final prefs = await SharedPreferences.getInstance();
    int? seed = prefs.getInt('conversation_user_seed');
    if (seed == null) {
      seed = Random().nextInt(1000000000);
      await prefs.setInt('conversation_user_seed', seed);
    }
    return seed;
  }

  Future<void> _generateConversationsForThisUser() async {
    final userSeed = await _getOrCreateUserSeed();
    final random = Random(userSeed);

    List<Map<String, String>> shuffledList = List.from(allConversations);
    shuffledList.shuffle(random);

    if (mounted) {
      setState(() {
        todaysConversations = shuffledList.take(10).toList();
        _loading = false;
      });
    }
  }

  TextEditingController _controllerFor(int index) {
    return _controllers.putIfAbsent(index, () => TextEditingController());
  }

  Future<void> _startVoiceAnswer(int index) async {
    setState(() {
      _isListeningByIndex[index] = true;
      _correctByIndex[index] = null;
      _feedbackByIndex[index] = '';
      _controllerFor(index).clear();
    });

    await SttService.startListening((text) {
      setState(() {
        _controllerFor(index).text = text;
      });
    });

    await Future.delayed(const Duration(seconds: 5));
    await SttService.stopListening();

    if (mounted) {
      setState(() {
        _isListeningByIndex[index] = false;
      });
      if (_controllerFor(index).text.trim().isNotEmpty) {
        await _submitAnswer(index);
      }
    }
  }

  Future<void> _submitAnswer(int index) async {
    final answer = _controllerFor(index).text.trim();
    if (answer.isEmpty) return;

    final question = todaysConversations[index]['en']!;

    setState(() {
      _isCheckingByIndex[index] = true;
      _correctByIndex[index] = null;
      _feedbackByIndex[index] = '';
    });

    final result = await AiConversationService.evaluateAnswer(question, answer);

    if (mounted) {
      setState(() {
        _isCheckingByIndex[index] = false;
        _correctByIndex[index] = result['correct'] as bool;
        _feedbackByIndex[index] = result['feedback'] as String;
      });
    }
  }

  void _retry(int index) {
    setState(() {
      _correctByIndex[index] = null;
      _feedbackByIndex[index] = '';
      _controllerFor(index).clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F9FC),
      appBar: AppBar(
        title: const Text('Daily Conversation',
            style: TextStyle(fontWeight: FontWeight.bold)),
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF0F9D8A), Color(0xFF14B8A6)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Color(0xFFE3FBF8), Color(0xFFF0FFFD)],
                    ),
                  ),
                  child: const Text(
                    'তোমার নিজস্ব প্রশ্নসেট — নিজের মতো করে উত্তর দাও, ভয়েস বা টাইপ করে!',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        fontSize: 14,
                        color: Color(0xFF0F9D8A),
                        fontWeight: FontWeight.w600),
                  ),
                ),
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: todaysConversations.length,
                    itemBuilder: (context, index) {
                      final convo = todaysConversations[index];
                      final isVoiceMode = _isVoiceModeByIndex[index] ?? true;
                      final isListening = _isListeningByIndex[index] ?? false;
                      final isChecking = _isCheckingByIndex[index] ?? false;
                      final isCorrect = _correctByIndex[index];
                      final feedback = _feedbackByIndex[index] ?? '';

                      return Container(
                        margin: const EdgeInsets.only(bottom: 16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(18),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.teal.withOpacity(0.08),
                              blurRadius: 12,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: ExpansionTile(
                          shape: const RoundedRectangleBorder(
                              side: BorderSide.none),
                          leading: CircleAvatar(
                            backgroundColor: const Color(0xFFE3FBF8),
                            child: const Icon(Icons.forum_outlined,
                                color: Color(0xFF0F9D8A)),
                          ),
                          title: Text(convo['title']!,
                              style: const TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 16)),
                          subtitle: const Text('বিস্তারিত দেখতে ট্যাপ করো',
                              style:
                                  TextStyle(fontSize: 12, color: Colors.grey)),
                          children: [
                            Padding(
                              padding: const EdgeInsets.fromLTRB(16, 0, 16, 20),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Container(
                                    width: double.infinity,
                                    padding: const EdgeInsets.all(14),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFF0FFFD),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          children: [
                                            Expanded(
                                              child: Text(
                                                convo['en']!,
                                                style: const TextStyle(
                                                    fontSize: 16,
                                                    fontWeight: FontWeight.bold,
                                                    color: Colors.black87),
                                              ),
                                            ),
                                            IconButton(
                                              icon: const Icon(Icons.volume_up,
                                                  color: Color(0xFF0F9D8A)),
                                              onPressed: () =>
                                                  _speakText(convo['en']!),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          convo['bn']!,
                                          style: const TextStyle(
                                              fontSize: 14,
                                              color: Colors.blueGrey),
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(height: 16),

                                  // Voice / Typing টগল বাটন
                                  Container(
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFF0F0F5),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    padding: const EdgeInsets.all(4),
                                    child: Row(
                                      children: [
                                        Expanded(
                                          child: GestureDetector(
                                            onTap: () => setState(() =>
                                                _isVoiceModeByIndex[index] =
                                                    true),
                                            child: Container(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                      vertical: 10),
                                              decoration: BoxDecoration(
                                                color: isVoiceMode
                                                    ? Colors.white
                                                    : Colors.transparent,
                                                borderRadius:
                                                    BorderRadius.circular(10),
                                                boxShadow: isVoiceMode
                                                    ? [
                                                        BoxShadow(
                                                            color: Colors.black
                                                                .withOpacity(
                                                                    0.06),
                                                            blurRadius: 4)
                                                      ]
                                                    : [],
                                              ),
                                              child: const Center(
                                                child: Text('🎤 ভয়েস',
                                                    style: TextStyle(
                                                        fontWeight:
                                                            FontWeight.w600)),
                                              ),
                                            ),
                                          ),
                                        ),
                                        Expanded(
                                          child: GestureDetector(
                                            onTap: () => setState(() =>
                                                _isVoiceModeByIndex[index] =
                                                    false),
                                            child: Container(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                      vertical: 10),
                                              decoration: BoxDecoration(
                                                color: !isVoiceMode
                                                    ? Colors.white
                                                    : Colors.transparent,
                                                borderRadius:
                                                    BorderRadius.circular(10),
                                                boxShadow: !isVoiceMode
                                                    ? [
                                                        BoxShadow(
                                                            color: Colors.black
                                                                .withOpacity(
                                                                    0.06),
                                                            blurRadius: 4)
                                                      ]
                                                    : [],
                                              ),
                                              child: const Center(
                                                child: Text('⌨️ টাইপ',
                                                    style: TextStyle(
                                                        fontWeight:
                                                            FontWeight.w600)),
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(height: 14),

                                  if (isCorrect == null) ...[
                                    if (isVoiceMode)
                                      SizedBox(
                                        width: double.infinity,
                                        child: ElevatedButton.icon(
                                          onPressed: (isListening || isChecking)
                                              ? null
                                              : () => _startVoiceAnswer(index),
                                          icon: Icon(isListening
                                              ? Icons.mic
                                              : Icons.mic_none),
                                          label: Text(isListening
                                              ? 'শুনছি...'
                                              : 'বলে উত্তর দাও'),
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor:
                                                const Color(0xFF0F9D8A),
                                            foregroundColor: Colors.white,
                                            padding: const EdgeInsets.symmetric(
                                                vertical: 14),
                                            shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(12)),
                                          ),
                                        ),
                                      )
                                    else ...[
                                      TextField(
                                        controller: _controllerFor(index),
                                        decoration: InputDecoration(
                                          hintText: 'তোমার উত্তর টাইপ করো...',
                                          filled: true,
                                          fillColor: const Color(0xFFF7F9FC),
                                          border: OutlineInputBorder(
                                            borderRadius:
                                                BorderRadius.circular(12),
                                            borderSide: BorderSide.none,
                                          ),
                                          contentPadding:
                                              const EdgeInsets.symmetric(
                                                  horizontal: 14, vertical: 12),
                                        ),
                                      ),
                                      const SizedBox(height: 10),
                                      SizedBox(
                                        width: double.infinity,
                                        child: ElevatedButton(
                                          onPressed: isChecking
                                              ? null
                                              : () => _submitAnswer(index),
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor:
                                                const Color(0xFF0F9D8A),
                                            foregroundColor: Colors.white,
                                            padding: const EdgeInsets.symmetric(
                                                vertical: 14),
                                            shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(12)),
                                          ),
                                          child: const Text('চেক করো'),
                                        ),
                                      ),
                                    ],
                                    if (isChecking) ...[
                                      const SizedBox(height: 12),
                                      const Center(
                                          child: SizedBox(
                                        width: 22,
                                        height: 22,
                                        child: CircularProgressIndicator(
                                            strokeWidth: 2),
                                      )),
                                    ],
                                  ] else ...[
                                    // ফলাফল দেখানো (✅ বা ❌)
                                    Container(
                                      width: double.infinity,
                                      padding: const EdgeInsets.all(14),
                                      decoration: BoxDecoration(
                                        color: isCorrect
                                            ? Colors.green.shade50
                                            : Colors.red.shade50,
                                        borderRadius: BorderRadius.circular(12),
                                        border: Border.all(
                                          color: isCorrect
                                              ? Colors.green.shade200
                                              : Colors.red.shade200,
                                        ),
                                      ),
                                      child: Column(
                                        children: [
                                          Icon(
                                            isCorrect
                                                ? Icons.check_circle
                                                : Icons.error,
                                            color: isCorrect
                                                ? Colors.green
                                                : Colors.red,
                                            size: 32,
                                          ),
                                          const SizedBox(height: 8),
                                          Text(
                                            "আপনার উত্তর: ${_controllerFor(index).text}",
                                            style: const TextStyle(
                                              fontWeight: FontWeight.w500,
                                              color: Colors.black87,
                                            ),
                                            textAlign: TextAlign.center,
                                          ),
                                          const SizedBox(height: 8),
                                          Text(
                                            feedback,
                                            textAlign: TextAlign.center,
                                            style: TextStyle(
                                              color: isCorrect
                                                  ? Colors.green.shade700
                                                  : Colors.red.shade700,
                                              fontSize: 15,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                          const SizedBox(height: 12),
                                          OutlinedButton.icon(
                                            onPressed: () => _retry(index),
                                            icon: const Icon(Icons.refresh),
                                            label:
                                                const Text('আবার চেষ্টা করো'),
                                            style: OutlinedButton.styleFrom(
                                              foregroundColor: isCorrect
                                                  ? Colors.green.shade700
                                                  : Colors.red.shade700,
                                              side: BorderSide(
                                                color: isCorrect
                                                    ? Colors.green.shade700
                                                    : Colors.red.shade700,
                                              ),
                                              shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(8),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
    );
  }
}
