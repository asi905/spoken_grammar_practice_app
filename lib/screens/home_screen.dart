import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/practice_item.dart';
import '../data/progress_service.dart';
import '../data/sample_data.dart';
import '../services/gamification_service.dart';
import '../services/last_activity_service.dart';
import '../services/daily_vocabulary_service.dart';
import '../services/welcome_bonus_service.dart';
import '../widgets/stats_bar.dart';

import 'daily_mcq_screen.dart';
import 'vocabulary_screen.dart';
import 'scoreboard_screen.dart';
import 'live_conversation_screen.dart';
import 'search_vocabulary_screen.dart';
import 'roleplay_list_screen.dart';
import 'progress_screen.dart';
import 'daily_conversation_screen.dart';
import 'grammar_list_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String _userName = 'Learner';
  List<int> _weeklyCounts = List.filled(7, 0);
  String? _lastCategory;
  bool _dashboardLoading = true;
  bool _isDarkMode = false;

  int _vocabTarget = 0;
  int _vocabCount = 0;
  int _convoTarget = 0;
  int _convoCount = 0;

  @override
  void initState() {
    super.initState();
    GamificationService.instance.init();
    _loadDashboardData();
  }

  Future<void> _loadDashboardData() async {
    final prefs = await SharedPreferences.getInstance();
    final name = prefs.getString('student_name_v2');
    final isDark = prefs.getBool('is_dark_mode') ?? false;

    final progressService = ProgressService();
    final weekly = await progressService.getDailyCountsForLastDays(7);
    final lastCategory = await LastActivityService.getLastCategory();

    final vocabProgress =
        await DailyVocabularyService.loadTodayProgress('Vocabulary');
    final convoProgress =
        await DailyVocabularyService.loadTodayProgress('Daily Conversation');

    if (mounted) {
      setState(() {
        _isDarkMode = isDark;
        _userName = (name != null && name.trim().isNotEmpty) ? name : 'Learner';
        _weeklyCounts = weekly;
        _lastCategory = lastCategory;
        _vocabTarget = vocabProgress['target']!;
        _vocabCount = vocabProgress['count']!;
        _convoTarget = convoProgress['target']!;
        _convoCount = convoProgress['count']!;
        _dashboardLoading = false;
      });
    }
  }

  void _toggleTheme() async {
    setState(() {
      _isDarkMode = !_isDarkMode;
    });
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('is_dark_mode', _isDarkMode);
  }

  bool _isCategoryDone(int target, int count) {
    if (target == 0) return false;
    if (target == 999999) return false;
    return count >= target;
  }

  String get _todayStatusMessage {
    final vocabStarted = _vocabTarget > 0;
    final convoStarted = _convoTarget > 0;

    if (!vocabStarted && !convoStarted) {
      return 'চলো শুরু করি!';
    }

    final vocabDone = _isCategoryDone(_vocabTarget, _vocabCount);
    final convoDone = _isCategoryDone(_convoTarget, _convoCount);

    final allStartedDone =
        (!vocabStarted || vocabDone) && (!convoStarted || convoDone);

    if (allStartedDone && (vocabStarted || convoStarted)) {
      return 'আজকের সব কাজ সম্পন্ন! 🎉';
    }

    return 'আজকের কাজ এখনো সম্পূর্ণ হয়নি, চালিয়ে যাও!';
  }

  String get _greeting {
    final now = DateTime.now();
    final minutes = now.hour * 60 + now.minute;

    if (minutes >= 3 * 60 && minutes < 6 * 60) {
      return 'শুভ ভোর / Good Dawn';
    }
    if (minutes >= 6 * 60 && minutes < 11 * 60) {
      return 'শুভ সকাল / Good Morning';
    }
    if (minutes >= 11 * 60 && minutes < 15 * 60) {
      return 'শুভ দুপুর / Good Noon';
    }
    if (minutes >= 15 * 60 && minutes < (17 * 60 + 45)) {
      return 'শুভ বিকেল / Good Afternoon';
    }
    if (minutes >= (17 * 60 + 45) && minutes < (19 * 60 + 30)) {
      return 'শুভ সন্ধ্যা / Good Evening';
    }
    if (minutes >= (19 * 60 + 30) && minutes < 24 * 60) {
      return 'শুভ রাত্রি / Good Night';
    }
    return 'শুভ মধ্যরাত / Good Midnight';
  }

  @override
  Widget build(BuildContext context) {
    final bgColor = _isDarkMode ? const Color(0xFF121212) : Colors.white;
    final textColor = _isDarkMode ? Colors.white : Colors.black87;
    final subTextColor = _isDarkMode ? Colors.white54 : Colors.grey;
    final cardBgColor =
        _isDarkMode ? const Color(0xFF1E1E1E) : Colors.grey.shade50;
    final cardBorderColor =
        _isDarkMode ? Colors.grey.shade800 : Colors.grey.shade200;

    // ✅ রেস্পন্সিভ লেআউট (Responsive Layout) এর জন্য স্ক্রিনের চওড়া মাপা হচ্ছে
    final screenWidth = MediaQuery.of(context).size.width;

    int crossAxisCount = 2; // ডিফল্ট (ফোনের জন্য)
    double childAspectRatio =
        1.35; // কার্ডের উচ্চতা কমানোর জন্য রেট বাড়ানো হয়েছে

    if (screenWidth >= 900) {
      crossAxisCount = 4; // ওয়েবসাইটের জন্য ৪ কলাম
      childAspectRatio = 1.5;
    } else if (screenWidth >= 600) {
      crossAxisCount = 3; // ট্যাবলেটের জন্য ৩ কলাম
      childAspectRatio = 1.4;
    }

    return Scaffold(
      backgroundColor: bgColor,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 4),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '$_greeting, $_userName! 👋',
                            style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: textColor),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'আজ ইংরেজি প্র্যাকটিস করার পালা!',
                            style: TextStyle(fontSize: 13, color: subTextColor),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    IconButton(
                      icon: Icon(
                        _isDarkMode ? Icons.light_mode : Icons.dark_mode,
                        color:
                            _isDarkMode ? Colors.amber : Colors.grey.shade600,
                        size: 28,
                      ),
                      onPressed: _toggleTheme,
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    ),
                  ],
                ),
              ),
              StatsBar(isDarkMode: _isDarkMode),
              const SizedBox(height: 8),
              if (!_dashboardLoading) ...[
                _buildTodayGoalCard(),
                const SizedBox(height: 16),
                _buildWeeklyProgressCard(
                    cardBgColor, cardBorderColor, textColor, subTextColor),
                const SizedBox(height: 16),
                if (_lastCategory != null) _buildContinuePracticeCard(),
                if (_lastCategory != null) const SizedBox(height: 16),
              ],
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Text(
                  'সব প্র্যাকটিস',
                  style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color:
                          _isDarkMode ? Colors.white70 : Colors.grey.shade700),
                ),
              ),
              const SizedBox(height: 10),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: GridView.count(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisCount: crossAxisCount, // ✅ রেস্পন্সিভ কলাম
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  childAspectRatio: childAspectRatio, // ✅ কার্ডের পারফেক্ট সাইজ
                  children: [
                    _buildGridCard(
                      title: 'Vocabulary\nভোকাভুলারি',
                      icon: Icons.menu_book,
                      iconColor: Colors.indigo,
                      cardBgColor: cardBgColor,
                      textColor: textColor,
                      onTap: () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => const VocabularyScreen(
                                    title: 'Vocabulary',
                                    items: [],
                                    useUnlimitedSource: true)));
                      },
                    ),
                    _buildGridCard(
                      title: 'Daily Conversation\nডেইলি কনভারসেশন',
                      icon: Icons.chat_bubble_outline,
                      iconColor: Colors.teal,
                      cardBgColor: cardBgColor,
                      textColor: textColor,
                      onTap: () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) =>
                                    const DailyConversationScreen()));
                      },
                    ),
                    _buildGridCard(
                      title: 'Grammar\nগ্রামার',
                      icon: Icons.rule,
                      iconColor: Colors.deepOrange,
                      cardBgColor: cardBgColor,
                      textColor: textColor,
                      onTap: () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) =>
                                    const GrammarListScreen()));
                      },
                    ),
                    _buildGridCard(
                      title: 'Live Conversation\nলাইভ কনভারসেশন',
                      icon: Icons.record_voice_over,
                      iconColor: Colors.pink,
                      cardBgColor: cardBgColor,
                      textColor: textColor,
                      onTap: () => _showLiveConversationOptions(context),
                    ),
                    _buildGridCard(
                      title: 'Word Search\nশব্দ খুঁজুন',
                      icon: Icons.search,
                      iconColor: Colors.blueGrey,
                      cardBgColor: cardBgColor,
                      textColor: textColor,
                      onTap: () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) =>
                                    const SearchVocabularyScreen()));
                      },
                    ),
                    _buildGridCard(
                      title: 'MCQ Test\nএমসিকিউ টেস্ট',
                      icon: Icons.quiz,
                      iconColor: Colors.deepPurple,
                      cardBgColor: cardBgColor,
                      textColor: textColor,
                      onTap: () => _showMcqOptions(context),
                    ),
                    _buildGridCard(
                      title: 'Scoreboard\nস্কোরবোর্ড',
                      icon: Icons.leaderboard,
                      iconColor: Colors.amber.shade700,
                      cardBgColor: cardBgColor,
                      textColor: textColor,
                      onTap: () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) =>
                                    const ScoreboardScreen()));
                      },
                    ),
                    _buildGridCard(
                      title: 'Roleplay\nরোলপ্লে',
                      icon: Icons.theater_comedy,
                      iconColor: Colors.orange,
                      cardBgColor: cardBgColor,
                      textColor: textColor,
                      onTap: () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) =>
                                    const RoleplayListScreen()));
                      },
                    ),
                    _buildGridCard(
                      title: 'Profile\nপ্রোফাইল',
                      icon: Icons.bar_chart,
                      iconColor: Colors.purple,
                      cardBgColor: cardBgColor,
                      textColor: textColor,
                      onTap: () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => const ProgressScreen()));
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTodayGoalCard() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFF5B4FE9), Color(0xFF7C6EF2)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(18),
        ),
        child: Row(
          children: [
            const Icon(Icons.local_fire_department,
                color: Colors.white, size: 32),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('আজকের প্র্যাকটিস',
                      style: TextStyle(color: Colors.white70, fontSize: 12)),
                  const SizedBox(height: 4),
                  Text(
                    _todayStatusMessage,
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 13,
                        fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWeeklyProgressCard(
      Color bgColor, Color borderColor, Color textColor, Color subTextColor) {
    final maxCount = _weeklyCounts.isEmpty
        ? 1
        : _weeklyCounts.reduce((a, b) => a > b ? a : b);
    final safeMax = maxCount == 0 ? 1 : maxCount;
    final today = DateTime.now();

    final dayLabels = List.generate(7, (i) {
      final d = today.subtract(Duration(days: 6 - i));
      const names = ['সোম', 'মঙ্গল', 'বুধ', 'বৃহঃ', 'শুক্র', 'শনি', 'রবি'];
      return names[d.weekday - 1];
    });

    int totalTarget = _vocabTarget + _convoTarget;
    int totalDone = _vocabCount + _convoCount;
    int percent = 0;
    if (totalTarget > 0 && totalTarget < 999999) {
      percent = ((totalDone / totalTarget) * 100).toInt().clamp(0, 100);
    } else if (totalDone > 0) {
      percent = 100;
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: borderColor),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('গত ৭ দিনের প্র্যাকটিস',
                    style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        color: _isDarkMode
                            ? Colors.white70
                            : Colors.grey.shade700)),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: percent == 100
                        ? Colors.green.withValues(alpha: 0.2)
                        : Colors.indigo.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    'আজ: $percent%',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: percent == 100
                          ? (_isDarkMode
                              ? Colors.greenAccent
                              : Colors.green.shade700)
                          : (_isDarkMode
                              ? Colors.indigoAccent.shade100
                              : Colors.indigo.shade700),
                    ),
                  ),
                )
              ],
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: List.generate(7, (i) {
                final value = _weeklyCounts[i];
                final heightFactor = value / safeMax;
                return Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Text('$value',
                        style: TextStyle(fontSize: 10, color: subTextColor)),
                    const SizedBox(height: 4),
                    Container(
                      width: 18,
                      height: 35 * (heightFactor.clamp(0.05, 1.0)),
                      decoration: BoxDecoration(
                        color: value > 0
                            ? const Color(0xFF5B4FE9)
                            : (_isDarkMode
                                ? Colors.grey.shade800
                                : Colors.grey.shade300),
                        borderRadius: BorderRadius.circular(6),
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(dayLabels[i],
                        style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                            color: subTextColor)),
                  ],
                );
              }),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContinuePracticeCard() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () {
          Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => const VocabularyScreen(
                      title: 'Vocabulary',
                      items: [],
                      useUnlimitedSource: true)));
        },
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: _isDarkMode
                ? Colors.indigo.withValues(alpha: 0.15)
                : Colors.indigo.shade50,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Row(
            children: [
              Icon(Icons.play_circle_fill,
                  color: _isDarkMode ? Colors.indigoAccent : Colors.indigo,
                  size: 30),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('যেখানে ছিলে সেখান থেকে চালিয়ে যাও',
                        style: TextStyle(
                            fontSize: 12,
                            color: _isDarkMode
                                ? Colors.indigoAccent.shade100
                                : Colors.indigo.shade400)),
                    Text(_lastCategory ?? 'Vocabulary',
                        style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            color: _isDarkMode
                                ? Colors.indigoAccent
                                : Colors.indigo)),
                  ],
                ),
              ),
              Icon(Icons.arrow_forward_ios,
                  size: 14,
                  color: _isDarkMode ? Colors.indigoAccent : Colors.indigo),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildGridCard(
      {required String title,
      required IconData icon,
      required Color iconColor,
      required Color cardBgColor,
      required Color textColor,
      required VoidCallback onTap}) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        decoration: BoxDecoration(
          color: cardBgColor,
          borderRadius: BorderRadius.circular(16),
          boxShadow: _isDarkMode
              ? []
              : [
                  BoxShadow(
                      color: Colors.grey.shade200,
                      blurRadius: 6,
                      offset: const Offset(0, 3))
                ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon,
                  size: 28, color: iconColor), // আইকনের সাইজ একটু কমানো হয়েছে
              const SizedBox(height: 8),
              Text(title,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: textColor,
                      height: 1.2)),
            ],
          ),
        ),
      ),
    );
  }

  void _showLiveConversationOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: _isDarkMode ? const Color(0xFF1E1E1E) : Colors.white,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) {
        return SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                        color: _isDarkMode
                            ? Colors.grey.shade700
                            : Colors.grey.shade300,
                        borderRadius: BorderRadius.circular(10))),
                const SizedBox(height: 16),
                Text('Select Conversation Mode',
                    style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: _isDarkMode ? Colors.white : Colors.black87),
                    textAlign: TextAlign.center),
                const SizedBox(height: 20),
                _buildLiveModeTile(
                    context,
                    '1. English to English',
                    'ইংরেজিতে কথা বলুন এবং ইংরেজিতেই উত্তর শুনুন',
                    Icons.language,
                    'Eng-Eng'),
                const Divider(),
                _buildLiveModeTile(
                    context,
                    '2. English to Bangla',
                    'ইংরেজিতে কথা বলুন, বাংলায় উত্তর শুনুন',
                    Icons.g_translate,
                    'Eng-Bng'),
                const Divider(),
                _buildLiveModeTile(
                    context,
                    '3. Bangla to English',
                    'বাংলায় কথা বলুন, ইংরেজিতে উত্তর শুনুন',
                    Icons.swap_horiz,
                    'Bng-Eng'),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildLiveModeTile(BuildContext context, String title, String subtitle,
      IconData icon, String mode) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: CircleAvatar(
          backgroundColor: _isDarkMode
              ? Colors.pink.withValues(alpha: 0.2)
              : Colors.pink.shade50,
          child: Icon(icon, color: Colors.pink)),
      title: Text(title,
          style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 15,
              color: _isDarkMode ? Colors.white : Colors.black87)),
      subtitle: Text(subtitle,
          style: TextStyle(
              fontSize: 12,
              color: _isDarkMode ? Colors.white70 : Colors.grey.shade700)),
      trailing: Icon(Icons.arrow_forward_ios,
          size: 14, color: _isDarkMode ? Colors.white54 : Colors.grey),
      onTap: () async {
        Navigator.pop(context);

        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('live_chat_mode', mode);

        if (!context.mounted) return;
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => const LiveConversationScreen()));
      },
    );
  }

  void _showMcqOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: _isDarkMode ? const Color(0xFF1E1E1E) : Colors.white,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) {
        return SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                        color: _isDarkMode
                            ? Colors.grey.shade700
                            : Colors.grey.shade300,
                        borderRadius: BorderRadius.circular(10))),
                const SizedBox(height: 16),
                Text('Select MCQ Test',
                    style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: _isDarkMode ? Colors.white : Colors.black87),
                    textAlign: TextAlign.center),
                const SizedBox(height: 20),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: CircleAvatar(
                      backgroundColor: _isDarkMode
                          ? Colors.indigo.withValues(alpha: 0.2)
                          : Colors.indigo.shade50,
                      radius: 20,
                      child: const Icon(Icons.today,
                          color: Colors.indigo, size: 20)),
                  title: Text('Daily MCQ Test',
                      style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: _isDarkMode ? Colors.white : Colors.black87)),
                  subtitle: Text('আজকের পড়া আইটেম থেকে ১০টা প্রশ্ন',
                      style: TextStyle(
                          fontSize: 13,
                          color: _isDarkMode
                              ? Colors.white70
                              : Colors.grey.shade700)),
                  trailing: Icon(Icons.arrow_forward_ios,
                      size: 14,
                      color: _isDarkMode ? Colors.white54 : Colors.grey),
                  onTap: () {
                    Navigator.pop(context);
                    _startMcqTest(context,
                        days: 1, screenTitle: 'Daily MCQ', questionCount: 10);
                  },
                ),
                const SizedBox(height: 8),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: CircleAvatar(
                      backgroundColor: _isDarkMode
                          ? Colors.teal.withValues(alpha: 0.2)
                          : Colors.teal.shade50,
                      radius: 20,
                      child: const Icon(Icons.calendar_view_week,
                          color: Colors.teal, size: 20)),
                  title: Text('Weekly MCQ Test',
                      style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: _isDarkMode ? Colors.white : Colors.black87)),
                  subtitle: Text('গত ৭ দিনের পড়া আইটেম থেকে ৩০টা প্রশ্ন',
                      style: TextStyle(
                          fontSize: 13,
                          color: _isDarkMode
                              ? Colors.white70
                              : Colors.grey.shade700)),
                  trailing: Icon(Icons.arrow_forward_ios,
                      size: 14,
                      color: _isDarkMode ? Colors.white54 : Colors.grey),
                  onTap: () {
                    Navigator.pop(context);
                    _startMcqTest(context,
                        days: 7, screenTitle: 'Weekly MCQ', questionCount: 30);
                  },
                ),
                const SizedBox(height: 8),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: CircleAvatar(
                      backgroundColor: _isDarkMode
                          ? Colors.deepPurple.withValues(alpha: 0.2)
                          : Colors.deepPurple.shade50,
                      radius: 20,
                      child: const Icon(Icons.emoji_events,
                          color: Colors.deepPurple, size: 20)),
                  title: Text('Monthly Mega Test',
                      style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: _isDarkMode ? Colors.white : Colors.black87)),
                  subtitle: Text('গত ৩০ দিনের ১০০টা প্রশ্ন',
                      style: TextStyle(
                          fontSize: 13,
                          color: _isDarkMode
                              ? Colors.white70
                              : Colors.grey.shade700)),
                  trailing: Icon(Icons.arrow_forward_ios,
                      size: 14,
                      color: _isDarkMode ? Colors.white54 : Colors.grey),
                  onTap: () {
                    Navigator.pop(context);
                    _startMcqTest(context,
                        days: 30,
                        screenTitle: 'Monthly Mega Test',
                        questionCount: 100);
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _startMcqTest(
    BuildContext context, {
    required int days,
    required String screenTitle,
    required int questionCount,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final now = DateTime.now();

    final String lockKey;
    final String alreadyTakenMessage;
    if (days == 1) {
      final todayStr = now.toString().split(' ')[0];
      lockKey = 'mcq_daily_lock_$todayStr';
      alreadyTakenMessage =
          'আপনি আজকে ইতিমধ্যে একবার টেস্ট সম্পন্ন করেছেন! আগামীকাল আবার চেষ্টা করুন।';
    } else if (days == 7) {
      final firstDayOfYear = DateTime(now.year, 1, 1);
      final weekNumber =
          ((now.difference(firstDayOfYear).inDays) / 7).floor() + 1;
      lockKey = 'mcq_weekly_lock_${now.year}_$weekNumber';
      alreadyTakenMessage =
          'আপনি এই সপ্তাহে ইতিমধ্যে একবার টেস্ট সম্পন্ন করেছেন! পরবর্তী সপ্তাহে আবার চেষ্টা করুন।';
    } else {
      lockKey = 'mcq_monthly_lock_${now.year}_${now.month}';
      alreadyTakenMessage =
          'আপনি এই মাসে ইতিমধ্যে একবার Mega Test সম্পন্ন করেছেন! পরের মাসে আবার চেষ্টা করুন।';
    }

    bool alreadyTaken = prefs.getBool(lockKey) ?? false;
    if (alreadyTaken) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(alreadyTakenMessage),
          backgroundColor: Colors.redAccent,
          duration: const Duration(seconds: 3),
        ),
      );
      return;
    }

    final progressService = ProgressService();
    List<PracticeItem> practicedItems =
        await progressService.getItemsCompletedInLastDays(days);

    if (practicedItems.isEmpty) {
      practicedItems = List.from(sampleVocabulary);
    }

    String? userName = prefs.getString('student_name_v2');

    void goToTest() {
      if (!context.mounted) return;
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => DailyMcqScreen(
            title: screenTitle,
            practicedItems: practicedItems,
            questionCount: questionCount,
            lockKey: lockKey,
          ),
        ),
      );
    }

    if (userName == null || userName.isEmpty) {
      TextEditingController nameController = TextEditingController();
      if (!context.mounted) return;
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => AlertDialog(
          backgroundColor: _isDarkMode ? const Color(0xFF1E1E1E) : Colors.white,
          title: Text('আপনার নাম লিখুন',
              style: TextStyle(
                  fontSize: 16,
                  color: _isDarkMode ? Colors.white : Colors.black)),
          content: TextField(
            controller: nameController,
            style: TextStyle(color: _isDarkMode ? Colors.white : Colors.black),
            decoration: InputDecoration(
                hintText: 'উদা: Atikur Rahman',
                hintStyle: TextStyle(
                    color: _isDarkMode ? Colors.white54 : Colors.grey),
                border: const OutlineInputBorder(),
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 5)),
          ),
          actions: [
            ElevatedButton(
              onPressed: () async {
                if (nameController.text.trim().isNotEmpty) {
                  await prefs.setString(
                      'student_name_v2', nameController.text.trim());
                  await WelcomeBonusService.awardIfFirstTime();
                  Navigator.pop(context);
                  goToTest();
                }
              },
              child: const Text('শুরু করুন'),
            ),
          ],
        ),
      );
    } else {
      goToTest();
    }
  }
}
