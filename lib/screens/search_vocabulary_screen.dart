import 'package:flutter/material.dart';
import '../models/practice_item.dart';
import '../services/dictionary_api_service.dart';
import '../services/tts_service.dart';

class SearchVocabularyScreen extends StatefulWidget {
  const SearchVocabularyScreen({super.key});

  @override
  State<SearchVocabularyScreen> createState() => _SearchVocabularyScreenState();
}

class _SearchVocabularyScreenState extends State<SearchVocabularyScreen> {
  final TextEditingController _controller = TextEditingController();
  PracticeItem? _result;
  bool _loading = false;
  bool _notFound = false;

  Future<void> _search() async {
    final word = _controller.text.trim();
    if (word.isEmpty) return;

    setState(() {
      _loading = true;
      _notFound = false;
      _result = null;
    });

    final item = await DictionaryApiService.fetchWordDetails(word);

    if (mounted) {
      setState(() {
        _loading = false;
        _result = item;
        _notFound = item == null;
      });
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('শব্দ খুঁজুন')),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    decoration: const InputDecoration(
                      hintText: 'একটা ইংরেজি শব্দ লিখো...',
                      border: OutlineInputBorder(),
                    ),
                    onSubmitted: (_) => _search(),
                    textInputAction: TextInputAction.search,
                  ),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: _loading ? null : _search,
                  child: const Icon(Icons.search),
                ),
              ],
            ),
            const SizedBox(height: 24),
            Expanded(
              child: _loading
                  ? const Center(child: CircularProgressIndicator())
                  : _notFound
                      ? const Center(
                          child: Text(
                            'শব্দটা খুঁজে পাওয়া যায়নি। বানান চেক করে আবার চেষ্টা করো।',
                            textAlign: TextAlign.center,
                            style: TextStyle(color: Colors.grey),
                          ),
                        )
                      : _result == null
                          ? const Center(
                              child: Text(
                                'যেকোনো ইংরেজি শব্দ লিখে সার্চ করো।',
                                style: TextStyle(color: Colors.grey),
                              ),
                            )
                          : _buildResultCard(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildResultCard() {
    final item = _result!;
    return SingleChildScrollView(
      child: Card(
        elevation: 3,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Flexible(
                    child: Text(
                      item.english,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                          fontSize: 26, fontWeight: FontWeight.bold),
                    ),
                  ),
                  IconButton(
                    onPressed: () => TtsService.speak(item.english),
                    icon: const Icon(Icons.volume_up, color: Colors.indigo),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Text(
                item.bengaliMeaning,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 20, color: Colors.indigo),
              ),
              if (item.exampleSentence != null) ...[
                const SizedBox(height: 16),
                Text(
                  '"${item.exampleSentence!}"',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                      fontStyle: FontStyle.italic, color: Colors.grey),
                ),
              ],
              if (item.synonyms.isNotEmpty) ...[
                const SizedBox(height: 16),
                _buildChips('Synonyms', item.synonyms, Colors.green),
              ],
              if (item.antonyms.isNotEmpty) ...[
                const SizedBox(height: 12),
                _buildChips('Antonyms', item.antonyms, Colors.redAccent),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildChips(String label, List<String> words, Color color) {
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
