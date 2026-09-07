import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
// ✅ স্কোরবোর্ডের জন্য ফায়ারবেস ইম্পোর্ট করা হলো
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart'; // ✅ Auth ইম্পোর্ট করা হলো

class GamificationService extends ChangeNotifier {
  GamificationService._internal();
  static final GamificationService instance = GamificationService._internal();

  static const _kPoints = 'gami_points';
  static const _kStreak = 'gami_streak';
  static const _kLongestStreak = 'gami_longest_streak';
  static const _kLastPracticeDate = 'gami_last_practice_date';
  static const _kTotalSeconds = 'gami_total_seconds';

  int totalPoints = 0;
  int currentStreak = 0;
  int longestStreak = 0;
  int totalPracticeSeconds = 0;
  DateTime? lastPracticeDate;

  bool _initialized = false;

  int pointsForLevel(int level) => 100 * level;

  int get level {
    int lvl = 1;
    int remaining = totalPoints;
    while (remaining >= pointsForLevel(lvl)) {
      remaining -= pointsForLevel(lvl);
      lvl++;
    }
    return lvl;
  }

  int get pointsIntoCurrentLevel {
    int lvl = 1;
    int remaining = totalPoints;
    while (remaining >= pointsForLevel(lvl)) {
      remaining -= pointsForLevel(lvl);
      lvl++;
    }
    return remaining;
  }

  int get pointsNeededForNextLevel => pointsForLevel(level);

  Future<void> init() async {
    if (_initialized) return;
    final prefs = await SharedPreferences.getInstance();
    totalPoints = prefs.getInt(_kPoints) ?? 0;
    currentStreak = prefs.getInt(_kStreak) ?? 0;
    longestStreak = prefs.getInt(_kLongestStreak) ?? 0;
    totalPracticeSeconds = prefs.getInt(_kTotalSeconds) ?? 0;
    final dateStr = prefs.getString(_kLastPracticeDate);
    lastPracticeDate = dateStr != null ? DateTime.tryParse(dateStr) : null;

    _checkStreakBreak();
    _initialized = true;
    notifyListeners();
  }

  Future<void> _save() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_kPoints, totalPoints);
    await prefs.setInt(_kStreak, currentStreak);
    await prefs.setInt(_kLongestStreak, longestStreak);
    await prefs.setInt(_kTotalSeconds, totalPracticeSeconds);
    if (lastPracticeDate != null) {
      await prefs.setString(
        _kLastPracticeDate,
        _dateOnly(lastPracticeDate!).toIso8601String(),
      );
    }

    // ✅ ফিক্স: এখন আর নাম দিয়ে নয়, ইউজারের আসল UID দিয়ে ডেটা সেভ হবে!
    try {
      final User? user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        await FirebaseFirestore.instance.collection('users').doc(user.uid).set({
          'name': user.displayName ?? 'Learner',
          'score': totalPoints,
          'lastUpdated': FieldValue.serverTimestamp(),
        }, SetOptions(merge: true));
      }
    } catch (e) {
      debugPrint('Firebase Scoreboard Update Error: $e');
    }
  }

  DateTime _dateOnly(DateTime d) => DateTime(d.year, d.month, d.day);

  void _checkStreakBreak() {
    if (lastPracticeDate == null) return;
    final today = _dateOnly(DateTime.now());
    final last = _dateOnly(lastPracticeDate!);
    final diff = today.difference(last).inDays;
    if (diff > 1) {
      currentStreak = 0;
    }
  }

  Future<int> recordPracticeSession(
    Duration duration, {
    double accuracyBonus = 0,
  }) async {
    await init();

    final seconds = duration.inSeconds;
    if (seconds <= 0) return 0;

    totalPracticeSeconds += seconds;

    int earned = (seconds / 10).floor();
    if (earned < 1) earned = 1;

    earned += (earned * accuracyBonus.clamp(0, 1)).round();

    totalPoints += earned;
    _updateStreak();

    await _save();
    notifyListeners();
    return earned;
  }

  void _updateStreak() {
    final today = _dateOnly(DateTime.now());
    if (lastPracticeDate == null) {
      currentStreak = 1;
    } else {
      final last = _dateOnly(lastPracticeDate!);
      final diff = today.difference(last).inDays;
      if (diff == 0) {
        // already practiced today
      } else if (diff == 1) {
        currentStreak += 1;
      } else {
        currentStreak = 1;
      }
    }
    if (currentStreak > longestStreak) longestStreak = currentStreak;
    lastPracticeDate = DateTime.now();
  }

  Future<void> addPoints(int points) async {
    await addBonusPoints(points);
  }

  Future<void> addBonusPoints(int points) async {
    await init();
    totalPoints += points;
    await _save();
    notifyListeners();
  }

  Future<void> resetAll() async {
    totalPoints = 0;
    currentStreak = 0;
    longestStreak = 0;
    totalPracticeSeconds = 0;
    lastPracticeDate = null;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_kPoints);
    await prefs.remove(_kStreak);
    await prefs.remove(_kLongestStreak);
    await prefs.remove(_kTotalSeconds);
    await prefs.remove(_kLastPracticeDate);
    notifyListeners();
  }
}
