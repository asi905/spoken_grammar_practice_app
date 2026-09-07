import 'package:flutter/material.dart';
import '../data/grammar_days_data.dart';
import '../models/grammar_models.dart';
import '../services/grammar_progress_service.dart';
import 'grammar_day_screen.dart';

class GrammarLevelDaysScreen extends StatefulWidget {
  final GrammarLevelInfo levelInfo;

  const GrammarLevelDaysScreen({super.key, required this.levelInfo});

  @override
  State<GrammarLevelDaysScreen> createState() => _GrammarLevelDaysScreenState();
}

class _GrammarLevelDaysScreenState extends State<GrammarLevelDaysScreen> {
  int _unlockedDay = 1;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final unlocked = await GrammarProgressService.getUnlockedDay(
        widget.levelInfo.levelNumber);
    if (mounted) {
      setState(() {
        _unlockedDay = unlocked;
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final days = grammarDays
        .where((d) => d.levelNumber == widget.levelInfo.levelNumber)
        .toList();

    if (_loading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      appBar: AppBar(
          title: Text(
              'Level ${widget.levelInfo.levelNumber}: ${widget.levelInfo.titleEn}')),
      body: days.isEmpty
          ? const Center(child: Text('এই Level-এর কনটেন্ট শীঘ্রই আসছে'))
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: days.length,
              itemBuilder: (context, index) {
                final day = days[index];
                final isUnlocked = day.dayNumber <= _unlockedDay;
                final isCompleted = day.dayNumber < _unlockedDay;
                return Card(
                  margin: const EdgeInsets.only(bottom: 10),
                  elevation: isUnlocked ? 1 : 0,
                  color: isUnlocked ? null : Colors.grey.shade100,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: isCompleted
                          ? Colors.green.shade50
                          : (isUnlocked
                              ? Colors.indigo.shade50
                              : Colors.grey.shade300),
                      child: Icon(
                        isCompleted
                            ? Icons.check
                            : (isUnlocked ? day.icon : Icons.lock),
                        color: isCompleted
                            ? Colors.green
                            : (isUnlocked ? Colors.indigo : Colors.grey),
                      ),
                    ),
                    title: Text('Day ${day.dayNumber}: ${day.titleEn}',
                        style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: isUnlocked ? Colors.black87 : Colors.grey)),
                    subtitle: Text(day.titleBn,
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
                                  builder: (_) => GrammarDayScreen(day: day)),
                            );
                            _load();
                          }
                        : () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                  content:
                                      Text('আগের Day সম্পূর্ণ করলে এটা খুলবে')),
                            );
                          },
                  ),
                );
              },
            ),
    );
  }
}
