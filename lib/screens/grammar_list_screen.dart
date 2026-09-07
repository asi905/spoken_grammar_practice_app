import 'package:flutter/material.dart';
import '../data/grammar_days_data.dart';
import '../services/grammar_progress_service.dart';
import 'grammar_level_days_screen.dart';

class GrammarListScreen extends StatefulWidget {
  const GrammarListScreen({super.key});

  @override
  State<GrammarListScreen> createState() => _GrammarListScreenState();
}

class _GrammarListScreenState extends State<GrammarListScreen> {
  int _unlockedLevel = 1;
  int _totalPoints = 0;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final unlockedLevel = await GrammarProgressService.getUnlockedLevel();
    final points = await GrammarProgressService.getTotalPoints();
    if (mounted) {
      setState(() {
        _unlockedLevel = unlockedLevel;
        _totalPoints = points;
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Grammar Course')),
      body: Column(
        children: [
          Container(
            width: double.infinity,
            margin: const EdgeInsets.all(16),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                  colors: [Color(0xFF5B4FE9), Color(0xFF7C6EF2)]),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              children: [
                const Icon(Icons.star, color: Colors.amber, size: 32),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('মোট পয়েন্ট',
                        style: TextStyle(color: Colors.white70, fontSize: 12)),
                    Text('$_totalPoints',
                        style: const TextStyle(
                            color: Colors.white,
                            fontSize: 22,
                            fontWeight: FontWeight.bold)),
                  ],
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: grammarLevels.length,
              itemBuilder: (context, index) {
                final level = grammarLevels[index];
                final isUnlocked = level.levelNumber <= _unlockedLevel;
                final isCompleted = level.levelNumber < _unlockedLevel;
                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  elevation: isUnlocked ? 2 : 0,
                  color: isUnlocked ? null : Colors.grey.shade100,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14)),
                  child: ListTile(
                    contentPadding: const EdgeInsets.all(14),
                    leading: CircleAvatar(
                      radius: 26,
                      backgroundColor: isCompleted
                          ? Colors.green.shade50
                          : (isUnlocked
                              ? level.color.withOpacity(0.15)
                              : Colors.grey.shade300),
                      child: Icon(
                        isCompleted
                            ? Icons.check
                            : (isUnlocked ? level.icon : Icons.lock),
                        color: isCompleted
                            ? Colors.green
                            : (isUnlocked ? level.color : Colors.grey),
                      ),
                    ),
                    title: Text('Level ${level.levelNumber}: ${level.titleEn}',
                        style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: isUnlocked ? Colors.black87 : Colors.grey)),
                    subtitle: Text(
                        '${level.titleBn} • সম্পূর্ণ করলে ${level.completionPoints} পয়েন্ট',
                        style: TextStyle(
                            color: isUnlocked ? Colors.black54 : Colors.grey)),
                    trailing: isUnlocked
                        ? const Icon(Icons.arrow_forward_ios, size: 14)
                        : null,
                    onTap: isUnlocked
                        ? () async {
                            await Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (_) =>
                                      GrammarLevelDaysScreen(levelInfo: level)),
                            );
                            _load();
                          }
                        : () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                  content: Text(
                                      'আগের Level সম্পূর্ণ করলে এটা খুলবে')),
                            );
                          },
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
