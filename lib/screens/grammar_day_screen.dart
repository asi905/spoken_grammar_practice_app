import 'package:flutter/material.dart';
import '../models/grammar_models.dart';
import '../services/grammar_progress_service.dart';
import '../data/grammar_full_notes.dart';
import 'grammar_full_note_screen.dart';
// ✅ স্কোরবোর্ডে পয়েন্ট যোগ করার জন্য GamificationService ইম্পোর্ট করা হলো
import '../services/gamification_service.dart';

class GrammarDayScreen extends StatefulWidget {
  final GrammarDay day;

  const GrammarDayScreen({super.key, required this.day});

  @override
  State<GrammarDayScreen> createState() => _GrammarDayScreenState();
}

class _GrammarDayScreenState extends State<GrammarDayScreen> {
  bool _testStarted = false;
  int _currentIndex = 0;
  int? _selectedOption; // mcq-এর জন্য
  bool? _answered; // fillBlank/errorCorrection/translation-এর জন্য
  bool _lastAnswerCorrect = false;
  int _correctCount = 0;
  bool _finished = false;
  int _dayPoints = 0;
  int _levelBonus = 0;

  final TextEditingController _textController = TextEditingController();

  GrammarQuestion get _current => widget.day.questions[_currentIndex];

  String _cleanText(String s) {
    return s.trim().toLowerCase().replaceAll(RegExp(r'[^\w\s]'), '');
  }

  void _selectMcqOption(int index) {
    if (_selectedOption != null) return;
    setState(() {
      _selectedOption = index;
      if (index == _current.correctIndex) _correctCount++;
    });
  }

  void _checkTextAnswer() {
    if (_answered == true) return;
    final userInput = _cleanText(_textController.text);
    final correct = _cleanText(_current.correctAnswerText ?? '');
    final isCorrect = userInput.isNotEmpty && userInput == correct;
    setState(() {
      _answered = true;
      _lastAnswerCorrect = isCorrect;
      if (isCorrect) _correctCount++;
    });
  }

  Future<void> _next() async {
    if (_currentIndex < widget.day.questions.length - 1) {
      setState(() {
        _currentIndex++;
        _selectedOption = null;
        _answered = null;
        _textController.clear();
      });
    } else {
      final result = await GrammarProgressService.completeDay(
          widget.day.levelNumber, widget.day.dayNumber);

      final dayPts = result['dayPoints'] ?? 0;
      final lvlBonus = result['levelBonus'] ?? 0;

      // ✅ নতুন নিয়ম: ১টা সঠিক উত্তরের জন্য ১ পয়েন্ট (_correctCount) যোগ করা হলো
      final totalEarned = dayPts + lvlBonus + _correctCount;

      // ✅ ফায়ারবেস এবং স্কোরবোর্ডে পয়েন্ট সেভ করা হচ্ছে
      if (totalEarned > 0) {
        GamificationService.instance.addPoints(totalEarned);
      }

      setState(() {
        // স্ক্রিনে দেখানোর জন্য dayPoints এর সাথে _correctCount যুক্ত করে দিলাম
        _dayPoints = dayPts + _correctCount;
        _levelBonus = lvlBonus;
        _finished = true;
      });
    }
  }

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  String _typeLabel(QuestionType type) {
    switch (type) {
      case QuestionType.mcq:
        return 'MCQ';
      case QuestionType.fillBlank:
        return 'শূন্যস্থান পূরণ করো';
      case QuestionType.errorCorrection:
        return 'ভুল সংশোধন করো';
      case QuestionType.translation:
        return 'বাংলা → English অনুবাদ করো';
    }
  }

  void _openFullNotes() {
    final fullText = grammarFullNotes[widget.day.dayNumber];
    if (fullText == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('এই Day-এর সম্পূর্ণ নোট এখনো যোগ করা হয়নি')),
      );
      return;
    }
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => GrammarFullNoteScreen(
          dayNumber: widget.day.dayNumber,
          titleEn: widget.day.titleEn,
          fullText: fullText,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_finished) {
      final total = widget.day.questions.length;
      return Scaffold(
        appBar: AppBar(title: Text('Day ${widget.day.dayNumber}')),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.emoji_events, size: 64, color: Colors.amber),
              const SizedBox(height: 16),
              Text('তুমি পেয়েছো $_correctCount / $total',
                  style: const TextStyle(
                      fontSize: 22, fontWeight: FontWeight.bold)),
              const SizedBox(height: 12),
              if (_dayPoints > 0)
                Text('+$_dayPoints পয়েন্ট অর্জিত হলো! 🎉',
                    style: const TextStyle(
                        color: Colors.green,
                        fontWeight: FontWeight.bold,
                        fontSize: 16))
              else
                const Text('(আগেই সম্পূর্ণ করা, তাই নতুন পয়েন্ট নেই)',
                    style: TextStyle(color: Colors.grey)),
              if (_levelBonus > 0) ...[
                const SizedBox(height: 8),
                Text('🏆 Level সম্পূর্ণ! বোনাস +$_levelBonus পয়েন্ট',
                    style: const TextStyle(
                        color: Colors.deepOrange,
                        fontWeight: FontWeight.bold,
                        fontSize: 16)),
              ],
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('তালিকায় ফিরে যাও'),
              ),
            ],
          ),
        ),
      );
    }

    if (!_testStarted) {
      return Scaffold(
        appBar: AppBar(
            title: Text('Day ${widget.day.dayNumber}: ${widget.day.titleEn}')),
        body: Column(
          children: [
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: widget.day.rules.length,
                itemBuilder: (context, index) {
                  final rule = widget.day.rules[index];
                  return Card(
                    margin: const EdgeInsets.only(bottom: 12),
                    elevation: 1,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(rule.titleEn,
                              style: const TextStyle(
                                  fontSize: 17, fontWeight: FontWeight.bold)),
                          const SizedBox(height: 6),
                          Text(rule.explanationBn,
                              style: const TextStyle(
                                  fontSize: 14, color: Colors.black87)),
                          const SizedBox(height: 10),
                          ...rule.examples.map((e) => Padding(
                                padding: const EdgeInsets.only(bottom: 4),
                                child: Text('• $e',
                                    style: const TextStyle(
                                        fontStyle: FontStyle.italic,
                                        color: Colors.indigo)),
                              )),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: _openFullNotes,
                      icon: const Icon(Icons.menu_book),
                      label: const Text('সম্পূর্ণ নোট দেখো (হুবহু)'),
                      style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 14)),
                    ),
                  ),
                  const SizedBox(height: 10),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () => setState(() => _testStarted = true),
                      icon: const Icon(Icons.quiz),
                      label: const Text('টেস্ট শুরু করো'),
                      style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 14)),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    }

    final isMcq = _current.type == QuestionType.mcq;
    final hasAnswered = isMcq ? _selectedOption != null : _answered != null;

    return Scaffold(
      appBar: AppBar(title: Text('Day ${widget.day.dayNumber} টেস্ট')),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(
                      'প্রশ্ন ${_currentIndex + 1} / ${widget.day.questions.length}',
                      style: TextStyle(color: Colors.grey.shade600)),
                  const SizedBox(width: 10),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: Colors.indigo.shade50,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(_typeLabel(_current.type),
                        style: const TextStyle(
                            fontSize: 11,
                            color: Colors.indigo,
                            fontWeight: FontWeight.bold)),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(_current.question,
                  style: const TextStyle(
                      fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 20),

              // MCQ হলে অপশন বাটন, নাহলে TextField
              if (isMcq)
                ...List.generate(_current.options!.length, (index) {
                  final isSelected = _selectedOption == index;
                  final isCorrect = index == _current.correctIndex;
                  Color? bgColor;
                  if (_selectedOption != null) {
                    if (isCorrect) {
                      bgColor = Colors.green.shade100;
                    } else if (isSelected) {
                      bgColor = Colors.red.shade100;
                    }
                  }
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: InkWell(
                      onTap: () => _selectMcqOption(index),
                      borderRadius: BorderRadius.circular(10),
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: bgColor ?? Colors.grey.shade100,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                            color: isSelected
                                ? (isCorrect ? Colors.green : Colors.red)
                                : Colors.grey.shade300,
                          ),
                        ),
                        child: Text(_current.options![index]),
                      ),
                    ),
                  );
                })
              else ...[
                TextField(
                  controller: _textController,
                  enabled: _answered != true,
                  decoration: InputDecoration(
                    hintText: 'তোমার উত্তর এখানে লেখো...',
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10)),
                    filled: true,
                    fillColor: _answered == null
                        ? Colors.grey.shade100
                        : (_lastAnswerCorrect
                            ? Colors.green.shade50
                            : Colors.red.shade50),
                  ),
                  minLines: 1,
                  maxLines: 3,
                ),
                const SizedBox(height: 14),
                if (_answered != true)
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        if (_textController.text.trim().isEmpty) return;
                        _checkTextAnswer();
                      },
                      child: const Text('উত্তর চেক করো'),
                    ),
                  )
                else
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: _lastAnswerCorrect
                          ? Colors.green.shade50
                          : Colors.red.shade50,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      _lastAnswerCorrect
                          ? '✅ সঠিক!'
                          : '❌ সঠিক উত্তর: ${_current.correctAnswerText}',
                      style: TextStyle(
                          color: _lastAnswerCorrect
                              ? Colors.green.shade800
                              : Colors.red.shade800,
                          fontWeight: FontWeight.bold),
                    ),
                  ),
              ],

              if (hasAnswered) ...[
                const SizedBox(height: 10),
                Text(_current.explanationBn,
                    style: const TextStyle(color: Colors.indigo, fontSize: 13)),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _next,
                    child: Text(_currentIndex < widget.day.questions.length - 1
                        ? 'পরের প্রশ্ন'
                        : 'ফলাফল দেখো'),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
