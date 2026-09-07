import 'package:flutter/material.dart';
import '../models/practice_item.dart';
import '../data/progress_service.dart';
import '../services/tts_service.dart';
import '../services/stt_service.dart';
import '../services/daily_vocabulary_service.dart';
import '../services/dictionary_api_service.dart';
import '../services/daily_sentence_api_service.dart';
import '../services/last_activity_service.dart';
import '../widgets/practice_timer.dart';

class VocabularyScreen extends StatefulWidget {
  final String title;
  final List<PracticeItem> items;
  final bool useUnlimitedSource;
  final bool useSentenceApiSource;

  const VocabularyScreen({
    super.key,
    required this.title,
    required this.items,
    this.useUnlimitedSource = false,
    this.useSentenceApiSource = false,
  });

  @override
  State<VocabularyScreen> createState() => _VocabularyScreenState();
}

class _VocabularyScreenState extends State<VocabularyScreen> {
  static const int _unlimitedMarker = 999999;

  int _currentIndex = 0;
  bool _showMeaning = false;
  final ProgressService _progressService = ProgressService();

  bool _isListening = false;
  String _spokenText = '';
  bool? _pronunciationCorrect;

  bool _initializing = true;
  bool _loadingNext = false;
  int _target = 0;
  int _seenToday = 0;
  bool _stoppedForToday = false;

  PracticeItem? _apiItem;
  // API মোডে আগের শব্দে ফিরে যাওয়ার জন্য হিস্টোরি লিস্ট
  final List<PracticeItem> _apiHistory = [];
  int _apiHistoryIndex = -1;

  bool get _isApiMode =>
      widget.useUnlimitedSource || widget.useSentenceApiSource;

  bool get _isUnlimitedMode => _target == _unlimitedMarker;

  String get _category => widget.title;

  PracticeItem get _current =>
      _isApiMode ? _apiItem! : widget.items[_currentIndex];

  @override
  void initState() {
    super.initState();
    _init();
  }

  Future<PracticeItem> _fetchApiItem() {
    if (widget.useUnlimitedSource) {
      return DictionaryApiService.fetchRandomPracticeItem();
    }
    return DailySentenceApiService.fetchOneRandomSentence();
  }

  Future<void> _init() async {
    if (widget.title == 'Vocabulary') {
      await LastActivityService.setLastCategory('Vocabulary');
    }

    final progress = await DailyVocabularyService.loadTodayProgress(_category);
    _seenToday = progress['count']!;
    _target = progress['target']!;

    if (_target == 0) {
      final chosen = await _askDailyTarget();
      _target = chosen;
      await DailyVocabularyService.setTarget(_category, _target);
    }

    if (_isApiMode) {
      if (_target > 0 && _seenToday < _target) {
        _apiItem = await _fetchApiItem();
        _apiHistory.add(_apiItem!);
        _apiHistoryIndex = 0;
      }
    } else {
      final startIndex = await DailyVocabularyService.getStartIndex(_category);
      if (widget.items.isNotEmpty) {
        _currentIndex = startIndex % widget.items.length;
      }
    }

    if (mounted) {
      setState(() => _initializing = false);
    }
  }

  Future<int> _askDailyTarget() async {
    final choice = await showDialog<int>(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: Text('আজকে কয়টা "${widget.title}" প্র্যাকটিস করবে?'),
        content: const Text('১০টা ফিক্সড, নাকি যতক্ষণ ইচ্ছা প্র্যাকটিস করবে?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, 10),
            child: const Text('১০টা'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, _unlimitedMarker),
            child: const Text('১০+ (যতক্ষণ ইচ্ছা)'),
          ),
        ],
      ),
    );
    return choice ?? 10;
  }

  bool get _isCompleted =>
      _stoppedForToday ||
      (_target > 0 && !_isUnlimitedMode && _seenToday >= _target);

  Future<void> _stopForToday() async {
    await DailyVocabularyService.setTarget(_category, _seenToday);
    if (mounted) {
      setState(() {
        _target = _seenToday;
        _stoppedForToday = true;
      });
    }
  }

  // নতুন Previous বাটন লজিক
  Future<void> _previous() async {
    setState(() {
      _showMeaning = false;
      _spokenText = '';
      _pronunciationCorrect = null;
    });

    if (_isApiMode) {
      if (_apiHistoryIndex > 0) {
        setState(() {
          _apiHistoryIndex--;
          _apiItem = _apiHistory[_apiHistoryIndex];
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('No previous item!'),
            duration: Duration(seconds: 1),
          ),
        );
      }
    } else {
      setState(() {
        if (_currentIndex > 0) {
          _currentIndex--;
        } else {
          _currentIndex = widget.items.length - 1;
        }
      });
      await DailyVocabularyService.saveIndex(_category, _currentIndex);
    }
  }

  Future<void> _next() async {
    if (_isCompleted) return;

    // API Mode-এ হিস্টোরি দিয়ে മുന്നে যাওয়ার লজিক
    if (_isApiMode && _apiHistoryIndex < _apiHistory.length - 1) {
      setState(() {
        _showMeaning = false;
        _spokenText = '';
        _pronunciationCorrect = null;
        _apiHistoryIndex++;
        _apiItem = _apiHistory[_apiHistoryIndex];
      });
      return;
    }

    final updatedCount = await DailyVocabularyService.incrementCount(_category);

    if (_isApiMode) {
      setState(() {
        _loadingNext = true;
        _showMeaning = false;
        _spokenText = '';
        _pronunciationCorrect = null;
        _seenToday = updatedCount;
      });

      if (_isUnlimitedMode || _seenToday < _target) {
        final newItem = await _fetchApiItem();
        if (mounted) {
          setState(() {
            _apiItem = newItem;
            _apiHistory.add(newItem);
            _apiHistoryIndex++;
            _loadingNext = false;
          });
        }
      } else {
        if (mounted) setState(() => _loadingNext = false);
      }
    } else {
      setState(() {
        _showMeaning = false;
        _spokenText = '';
        _pronunciationCorrect = null;
        _seenToday = updatedCount;
        if (_currentIndex < widget.items.length - 1) {
          _currentIndex++;
        } else {
          _currentIndex = 0;
        }
      });
      await DailyVocabularyService.saveIndex(_category, _currentIndex);
    }
  }

  Future<void> _markLearned() async {
    await _progressService.markCompleted(_current);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Marked as Learned ✓'),
            duration: Duration(seconds: 1)),
      );
    }
    await _next();
  }

  Future<void> _startPronunciationPractice() async {
    setState(() {
      _isListening = true;
      _spokenText = '';
      _pronunciationCorrect = null;
    });

    await SttService.startListening((text) {
      setState(() {
        _spokenText = text;
      });
    });

    await Future.delayed(const Duration(seconds: 4));
    await SttService.stopListening();

    if (mounted) {
      setState(() {
        _isListening = false;
        if (_spokenText.isNotEmpty) {
          _pronunciationCorrect =
              SttService.isMatch(_spokenText, _current.english);
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_initializing) {
      return Scaffold(
        appBar: AppBar(title: Text(widget.title)),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(title: Text(widget.title)),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            if (_isUnlimitedMode && !_isCompleted)
              Text(
                'আজকে এখন পর্যন্ত: $_seenToday টা',
                style: TextStyle(color: Colors.grey.shade600, fontSize: 16),
              )
            else if (_target > 0)
              Text(
                'আজকের প্রোগ্রেস: $_seenToday / $_target',
                style: TextStyle(color: Colors.grey.shade600, fontSize: 16),
              ),
            const SizedBox(height: 16),
            if (_isCompleted)
              _buildCompletedView()
            else if (_loadingNext)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 60),
                child: Center(child: CircularProgressIndicator()),
              )
            else
              GestureDetector(
                onTap: () => setState(() => _showMeaning = !_showMeaning),
                child: Card(
                  elevation: 3,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16)),
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Daily Word ${_seenToday + 1}',
                          style: TextStyle(
                              fontSize: 13,
                              color: Colors.grey.shade500,
                              fontWeight: FontWeight.w600),
                        ),
                        const SizedBox(height: 10),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Flexible(
                              child: Text(
                                _current.english,
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                    fontSize: 28, fontWeight: FontWeight.bold),
                              ),
                            ),
                            IconButton(
                              onPressed: () =>
                                  TtsService.speak(_current.english),
                              icon: const Icon(Icons.volume_up,
                                  color: Colors.indigo),
                              iconSize: 28,
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),
                        if (_showMeaning) ...[
                          Text(
                            _current.bengaliMeaning,
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                                fontSize: 20, color: Colors.indigo),
                          ),
                          if (_current.exampleSentence != null) ...[
                            const SizedBox(height: 16),
                            Text(
                              '"${_current.exampleSentence!}"',
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                  fontStyle: FontStyle.italic,
                                  color: Colors.grey),
                            ),
                          ],
                          if (_current.synonyms.isNotEmpty) ...[
                            const SizedBox(height: 16),
                            _buildWordChipsRow(
                              label: 'Synonyms',
                              words: _current.synonyms,
                              color: Colors.green,
                            ),
                          ],
                          if (_current.antonyms.isNotEmpty) ...[
                            const SizedBox(height: 12),
                            _buildWordChipsRow(
                              label: 'Antonyms',
                              words: _current.antonyms,
                              color: Colors.redAccent,
                            ),
                          ],
                        ] else
                          Text(
                            'অর্থ দেখতে ট্যাপ করুন',
                            style: TextStyle(color: Colors.grey.shade400),
                          ),
                        if (_isListening) ...[
                          const SizedBox(height: 16),
                          const Text('শুনছি... এখন বলুন',
                              style: TextStyle(color: Colors.red)),
                        ],
                        if (!_isListening && _spokenText.isNotEmpty) ...[
                          const SizedBox(height: 16),
                          Text('আপনি বলেছেন: "$_spokenText"',
                              style: const TextStyle(color: Colors.grey)),
                          const SizedBox(height: 8),
                          if (_pronunciationCorrect == true)
                            const Text('✅ সঠিক উচ্চারণ!',
                                style: TextStyle(
                                    color: Colors.green,
                                    fontWeight: FontWeight.bold)),
                          if (_pronunciationCorrect == false)
                            const Text('❌ আবার চেষ্টা করুন',
                                style: TextStyle(
                                    color: Colors.red,
                                    fontWeight: FontWeight.bold)),
                        ],
                      ],
                    ),
                  ),
                ),
              ),
            const SizedBox(height: 20),
            if (!_isCompleted && !_loadingNext) ...[
              // এখানে Previous, Next এবং Learned বাটন দেওয়া হয়েছে
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: _previous,
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                      child: const Text('Previous',
                          style: TextStyle(
                              fontSize: 13, fontWeight: FontWeight.bold)),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: OutlinedButton(
                      onPressed: _next,
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                      child: const Text('Next',
                          style: TextStyle(
                              fontSize: 13, fontWeight: FontWeight.bold)),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _markLearned,
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                      child: const Text('Learned',
                          style: TextStyle(
                              fontSize: 13, fontWeight: FontWeight.bold)),
                    ),
                  ),
                ],
              ),
              if (_isUnlimitedMode) ...[
                const SizedBox(height: 8),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: _stopForToday,
                    icon: const Icon(Icons.stop_circle_outlined),
                    label: const Text('Stop for Today'),
                    style:
                        OutlinedButton.styleFrom(foregroundColor: Colors.red),
                  ),
                ),
              ],
              const SizedBox(height: 8),
              TextButton.icon(
                onPressed: _isListening ? null : _startPronunciationPractice,
                icon: Icon(_isListening ? Icons.mic : Icons.mic_none),
                label:
                    Text(_isListening ? 'শুনছি...' : 'উচ্চারণ প্র্যাকটিস করুন'),
              ),
            ],
            const SizedBox(height: 12),
            const PracticeTimer(),
          ],
        ),
      ),
    );
  }

  Widget _buildCompletedView() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 40),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.celebration, size: 64, color: Colors.green),
          const SizedBox(height: 16),
          Text(
            'আজকের $_target টা শেষ! 🎉',
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          const Text(
            'কাল আবার নতুন করে প্র্যাকটিস করতে এসো।',
            style: TextStyle(color: Colors.grey),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildWordChipsRow({
    required String label,
    required List<String> words,
    required Color color,
  }) {
    return Column(
      children: [
        Text(label,
            style: TextStyle(
                fontSize: 12, color: color, fontWeight: FontWeight.bold)),
        const SizedBox(height: 6),
        Wrap(
          alignment: WrapAlignment.center,
          spacing: 8,
          runSpacing: 6,
          children: words
              .map((w) => Chip(
                    label: Text(w, style: const TextStyle(fontSize: 13)),
                    backgroundColor: color.withOpacity(0.12),
                    side: BorderSide(color: color.withOpacity(0.3)),
                  ))
              .toList(),
        ),
      ],
    );
  }
}
