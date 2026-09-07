import 'package:flutter/material.dart';
import '../services/gamification_service.dart';

class StatsBar extends StatelessWidget {
  final bool isDarkMode;

  const StatsBar({super.key, this.isDarkMode = false});

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: GamificationService.instance,
      builder: (context, _) {
        final g = GamificationService.instance;

        // ----------------------------------------------------
        // আপনার নতুন ৭ দিনের লেভেল-আপ এবং দিনের সাইকেল লজিক
        // ----------------------------------------------------
        int totalDays = g.currentStreak; // ইউজারের মোট প্র্যাকটিসের দিন
        int displayLevel = (totalDays ~/ 7) + 1; // প্রতি ৭ দিনে ১ লেভেল বাড়বে
        int displayDay = totalDays %
            7; // দিনের হিসাব ০ থেকে ৬ পর্যন্ত হবে, ৭ হলে আবার ০ হয়ে যাবে

        // লেভেলের প্রগ্রেস বার (০ থেকে ১ পর্যন্ত হিসাব)
        double progress = displayDay / 7.0;

        // ইউজারের মোট জমানো স্টার
        int totalStars = g.totalPoints;

        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          child: Row(
            children: [
              _StatChip(
                  icon: Icons.star, label: '$totalStars', color: Colors.amber),
              const SizedBox(width: 10),
              _StatChip(
                icon: Icons.local_fire_department,
                label: '$displayDay দিন', // ৭ দিনের সাইকেল দেখাবে
                color: Colors.deepOrange,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Level $displayLevel',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          // ডার্ক মোডের জন্য কালার ফিক্স করা হলো
                          color: isDarkMode ? Colors.white70 : Colors.black87,
                        )),
                    const SizedBox(height: 4),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(6),
                      child: LinearProgressIndicator(
                        value: progress.clamp(0.0, 1.0),
                        minHeight: 6,
                        backgroundColor: isDarkMode
                            ? Colors.grey.shade800
                            : Colors.grey.shade200,
                        color: Colors.deepPurpleAccent,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _StatChip extends StatelessWidget {
  const _StatChip(
      {required this.icon, required this.label, required this.color});
  final IconData icon;
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: color),
          const SizedBox(width: 4),
          Text(label,
              style: TextStyle(
                  color: color, fontWeight: FontWeight.bold, fontSize: 13)),
        ],
      ),
    );
  }
}
