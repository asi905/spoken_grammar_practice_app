import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/practice_item.dart';
import '../services/tts_service.dart';

class DailyMcqScreen extends StatefulWidget {
  final String title;
  final List<PracticeItem> practicedItems;
  final int questionCount;
  // পুরো টেস্ট শেষ হলে (স্কোর দেখানোর সময়) এই key দিয়ে lock সেভ করা হয়।
  // null হলে কোনো lock সেভ হয় না।
  final String? lockKey;

  const DailyMcqScreen({
    super.key,
    required this.title,
    required this.practicedItems,
    this.questionCount = 10,
    this.lockKey,
  });

  @override
  State<DailyMcqScreen> createState() => _DailyMcqScreenState();
}

class _DailyMcqScreenState extends State<DailyMcqScreen> {
  int _currentIndex = 0;
  int _score = 0;
  bool _answered = false;
  int? _selectedOptionIndex;
  final List<Map<String, dynamic>> _mcqQuestions = [];

  Timer? _timer;
  int _timeLeft = 15;

  @override
  void initState() {
    super.initState();
    _generateMcqQuestions();
    _startTimer();
  }

  void _startTimer() {
    _timeLeft = 15;
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) return;
      setState(() {
        if (_timeLeft > 0) {
          _timeLeft--;
        } else {
          _timer?.cancel();
          if (_currentIndex < _mcqQuestions.length - 1) {
            _nextQuestion();
          } else {
            _showScoreDialog();
          }
        }
      });
    });
  }

  Map<String, dynamic>? _buildMeaningQuestion(
      PracticeItem current, List<PracticeItem> allItems) {
    final wrongOptions = allItems
        .where((item) => item.english != current.english)
        .map((item) => item.bengaliMeaning)
        .toSet()
        .toList();
    if (wrongOptions.length < 3) return null;

    wrongOptions.shuffle();
    final options = [current.bengaliMeaning, ...wrongOptions.take(3)];
    options.shuffle();

    return {
      'type': 'meaning',
      'prompt': 'এই শব্দটির সঠিক বাংলা অর্থ কোনটি?',
      'question': current.english,
      'options': options,
      'correctIndex': options.indexOf(current.bengaliMeaning),
    };
  }

  Map<String, dynamic>? _buildSynonymQuestion(
      PracticeItem current, List<PracticeItem> allItems) {
    if (current.synonyms.isEmpty) return null;
    final correctAnswer = current.synonyms.first;

    final wrongOptions = allItems
        .where((item) => item.english != current.english)
        .expand((item) => [...item.synonyms, ...item.antonyms, item.english])
        .where((w) => w.toLowerCase() != correctAnswer.toLowerCase())
        .toSet()
        .toList();
    if (wrongOptions.length < 3) return null;

    wrongOptions.shuffle();
    final options = [correctAnswer, ...wrongOptions.take(3)];
    options.shuffle();

    return {
      'type': 'synonym',
      'prompt': 'এই শব্দটির Synonym (সমার্থক শব্দ) কোনটি?',
      'question': current.english,
      'options': options,
      'correctIndex': options.indexOf(correctAnswer),
    };
  }

  Map<String, dynamic>? _buildAntonymQuestion(
      PracticeItem current, List<PracticeItem> allItems) {
    if (current.antonyms.isEmpty) return null;
    final correctAnswer = current.antonyms.first;

    final wrongOptions = allItems
        .where((item) => item.english != current.english)
        .expand((item) => [...item.synonyms, ...item.antonyms, item.english])
        .where((w) => w.toLowerCase() != correctAnswer.toLowerCase())
        .toSet()
        .toList();
    if (wrongOptions.length < 3) return null;

    wrongOptions.shuffle();
    final options = [correctAnswer, ...wrongOptions.take(3)];
    options.shuffle();

    return {
      'type': 'antonym',
      'prompt': 'এই শব্দটির Antonym (বিপরীত শব্দ) কোনটি?',
      'question': current.english,
      'options': options,
      'correctIndex': options.indexOf(correctAnswer),
    };
  }

  void _generateMcqQuestions() {
    if (widget.practicedItems.isEmpty) return;

    final allItems = widget.practicedItems;
    final random = Random();
    final pool = <Map<String, dynamic>>[];

    for (final item in allItems) {
      final meaningQ = _buildMeaningQuestion(item, allItems);
      if (meaningQ != null) pool.add(meaningQ);

      final synonymQ = _buildSynonymQuestion(item, allItems);
      if (synonymQ != null) pool.add(synonymQ);

      final antonymQ = _buildAntonymQuestion(item, allItems);
      if (antonymQ != null) pool.add(antonymQ);
    }

    pool.shuffle(random);
    setState(() {
      _mcqQuestions.addAll(pool.take(widget.questionCount));
    });
  }

  void _checkAnswer(int selectedIndex) {
    if (_answered) return;
    _timer?.cancel();
    setState(() {
      _answered = true;
      _selectedOptionIndex = selectedIndex;
      if (selectedIndex == _mcqQuestions[_currentIndex]['correctIndex']) {
        _score++;
      }
    });
  }

  void _nextQuestion() {
    if (_currentIndex < _mcqQuestions.length - 1) {
      setState(() {
        _currentIndex++;
        _answered = false;
        _selectedOptionIndex = null;
      });
      _startTimer();
    } else {
      _timer?.cancel();
      _showScoreDialog();
    }
  }

  Future<void> _showScoreDialog() async {
    final prefs = await SharedPreferences.getInstance();
    int previousScore = prefs.getInt('total_mcq_score') ?? 0;
    await prefs.setInt('total_mcq_score', previousScore + _score);

    // পুরো টেস্ট শেষ পর্যন্ত পৌঁছালে তবেই lock সেভ হয় — মাঝপথে বের হয়ে
    // গেলে lock হবে না, ইউজার আবার ঢুকে সম্পূর্ণ করতে পারবে।
    if (widget.lockKey != null) {
      await prefs.setBool(widget.lockKey!, true);
    }

    double percentage = (_score / _mcqQuestions.length) * 100;
    String percentageText = '${percentage.toStringAsFixed(1)}%';

    if (!mounted) return;
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('টেস্ট সম্পন্ন! 🎉', textAlign: TextAlign.center),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.emoji_events, color: Colors.amber, size: 60),
            const SizedBox(height: 16),
            Text(
              'আপনার স্কোর: ${_mcqQuestions.length} এর মধ্যে $_score',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              'সফলতার হার: $percentageText',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: percentage >= 80
                    ? Colors.green
                    : (percentage >= 50 ? Colors.orange : Colors.red),
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'স্কোরবোর্ডে পয়েন্ট যোগ হয়েছে!',
              style: TextStyle(color: Colors.grey),
            )
          ],
        ),
        actions: [
          Center(
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.indigo,
                foregroundColor: Colors.white,
                padding:
                    const EdgeInsets.symmetric(horizontal: 30, vertical: 12),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10)),
              ),
              onPressed: () {
                Navigator.pop(context);
                Navigator.pop(context);
              },
              child: const Text('ফিরে যান', style: TextStyle(fontSize: 16)),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_mcqQuestions.isEmpty) {
      return Scaffold(
        appBar: AppBar(title: Text(widget.title)),
        body: const Center(
            child: Padding(
          padding: EdgeInsets.all(20),
          child: Text(
            'যথেষ্ট প্র্যাকটিস করা শব্দ পাওয়া যায়নি! আরো প্র্যাকটিস করে আবার চেষ্টা করুন।',
            textAlign: TextAlign.center,
          ),
        )),
      );
    }

    final currentQ = _mcqQuestions[_currentIndex];
    List<String> options = currentQ['options'];
    List<String> banglaNumbers = ['১', '২', '৩', '৪'];

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        backgroundColor: Colors.indigo,
        foregroundColor: Colors.white,
        actions: [
          Center(
            child: Container(
              margin: const EdgeInsets.only(right: 16),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: _timeLeft <= 5
                    ? Colors.redAccent
                    : Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                '⏱ $_timeLeft সেঃ',
                style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white),
              ),
            ),
          )
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            LinearProgressIndicator(
              value: (_currentIndex + 1) / _mcqQuestions.length,
              backgroundColor: Colors.grey.shade200,
              color: Colors.indigo,
              minHeight: 8,
              borderRadius: BorderRadius.circular(10),
            ),
            const SizedBox(height: 20),
            Center(
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.indigo.shade50,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  'প্রশ্ন: ${_currentIndex + 1} / ${_mcqQuestions.length}',
                  style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.indigo.shade700),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Card(
              elevation: 4,
              shadowColor: Colors.indigo.withOpacity(0.2),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16)),
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  children: [
                    Text(
                      currentQ['prompt'],
                      textAlign: TextAlign.center,
                      style: const TextStyle(color: Colors.grey, fontSize: 14),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Flexible(
                          child: Text(
                            currentQ['question'],
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                                fontSize: 26,
                                fontWeight: FontWeight.bold,
                                color: Colors.indigo),
                          ),
                        ),
                        const SizedBox(width: 8),
                        IconButton(
                          icon: const Icon(Icons.volume_up,
                              color: Colors.indigo, size: 28),
                          onPressed: () =>
                              TtsService.speak(currentQ['question']),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 30),
            ...List.generate(options.length, (index) {
              Color btnColor = Colors.white;
              Color textColor = Colors.black87;
              IconData? iconData;

              if (_answered) {
                if (index == currentQ['correctIndex']) {
                  btnColor = Colors.green.shade50;
                  textColor = Colors.green.shade900;
                  iconData = Icons.check_circle;
                } else if (index == _selectedOptionIndex) {
                  btnColor = Colors.red.shade50;
                  textColor = Colors.red.shade900;
                  iconData = Icons.cancel;
                }
              }

              return Container(
                margin: const EdgeInsets.only(bottom: 16),
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: btnColor,
                    foregroundColor: textColor,
                    padding: const EdgeInsets.symmetric(
                        vertical: 18, horizontal: 20),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                      side: BorderSide(
                          color: _answered &&
                                  (index == currentQ['correctIndex'] ||
                                      index == _selectedOptionIndex)
                              ? textColor
                              : Colors.grey.shade300,
                          width: 1.5),
                    ),
                    elevation: 0,
                  ),
                  onPressed: () => _checkAnswer(index),
                  child: Row(
                    children: [
                      Text(
                        '${banglaNumbers[index]}. ',
                        style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.indigo),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          options[index],
                          style: const TextStyle(
                              fontSize: 18, fontWeight: FontWeight.w600),
                        ),
                      ),
                      if (iconData != null)
                        Icon(iconData, color: textColor, size: 24),
                    ],
                  ),
                ),
              );
            }),
            const SizedBox(height: 20),
            if (_answered)
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.indigo,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                  elevation: 2,
                ),
                onPressed: _nextQuestion,
                child: Text(
                  _currentIndex < _mcqQuestions.length - 1
                      ? 'পরবর্তী প্রশ্ন'
                      : 'ফলাফল ও পার্সেন্টেজ দেখুন',
                  style: const TextStyle(
                      fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
