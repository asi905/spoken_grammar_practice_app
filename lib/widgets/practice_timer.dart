import 'dart:async';
import 'package:flutter/material.dart';
import '../services/gamification_service.dart';

class PracticeTimer extends StatefulWidget {
  const PracticeTimer({super.key, this.onSessionComplete});

  final void Function(Duration duration, int pointsEarned)? onSessionComplete;

  @override
  State<PracticeTimer> createState() => _PracticeTimerState();
}

class _PracticeTimerState extends State<PracticeTimer> {
  Duration _elapsed = Duration.zero;
  Timer? _ticker;
  bool _running = false;

  @override
  void dispose() {
    _ticker?.cancel();
    super.dispose();
  }

  void _start() {
    if (_running) return;
    _ticker = Timer.periodic(const Duration(seconds: 1), (_) {
      setState(() => _elapsed += const Duration(seconds: 1));
    });
    setState(() => _running = true);
  }

  void _pause() {
    _ticker?.cancel();
    setState(() => _running = false);
  }

  Future<void> _finish() async {
    _ticker?.cancel();
    final duration = _elapsed;
    setState(() {
      _running = false;
      _elapsed = Duration.zero;
    });

    if (duration.inSeconds == 0) return;

    final earned =
        await GamificationService.instance.recordPracticeSession(duration);
    widget.onSessionComplete?.call(duration, earned);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content:
              Text('${_format(duration)} practice করলে! +$earned পয়েন্ট 🎉'),
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  String _format(Duration d) {
    final m = d.inMinutes.remainder(60).toString().padLeft(2, '0');
    final s = d.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$m:$s';
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.all(12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              _format(_elapsed),
              style: const TextStyle(fontSize: 40, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (!_running)
                  ElevatedButton.icon(
                    onPressed: _start,
                    icon: const Icon(Icons.play_arrow),
                    label: Text(_elapsed == Duration.zero ? 'Start' : 'Resume'),
                  )
                else
                  ElevatedButton.icon(
                    onPressed: _pause,
                    icon: const Icon(Icons.pause),
                    label: const Text('Pause'),
                  ),
                const SizedBox(width: 12),
                OutlinedButton.icon(
                  onPressed: _elapsed == Duration.zero ? null : _finish,
                  icon: const Icon(Icons.stop),
                  label: const Text('Finish'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
