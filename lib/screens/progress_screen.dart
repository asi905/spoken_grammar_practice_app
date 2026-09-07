import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../data/progress_service.dart';
import '../services/welcome_bonus_service.dart';
import '../services/auth_service.dart';

class ProgressScreen extends StatefulWidget {
  const ProgressScreen({super.key});

  @override
  State<ProgressScreen> createState() => _ProgressScreenState();
}

class _ProgressScreenState extends State<ProgressScreen> {
  int totalLearnedWords = 0;
  int totalMcqScore = 0;
  String userName = "Learner";
  String? profilePicBase64;
  String? profilePicUrl;
  bool isLoading = true;
  bool isLoggedIn = false;

  @override
  void initState() {
    super.initState();
    _loadProgressData();

    FirebaseAuth.instance.authStateChanges().listen((User? user) {
      if (mounted) {
        setState(() {
          isLoggedIn = user != null;
        });
      }
    });
  }

  // ✅ স্কোরের পাশাপাশি Vocab Count-ও ফায়ারবেসে সেভ হবে
  Future<void> _syncScoreToFirebase(int mcqScore, int vocabCount) async {
    try {
      User? user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        await FirebaseFirestore.instance.collection('users').doc(user.uid).set({
          'name': user.displayName ?? 'Learner',
          'photoUrl': user.photoURL ?? '',
          'score': mcqScore,
          'vocabCount': vocabCount,
          'updatedAt': FieldValue.serverTimestamp(),
        }, SetOptions(merge: true));
      }
    } catch (e) {
      debugPrint("Error syncing score: $e");
    }
  }

  Future<void> _loadProgressData() async {
    final prefs = await SharedPreferences.getInstance();

    String name = prefs.getString('student_name_v2') ??
        prefs.getString('user_name') ??
        "Learner";
    int score = prefs.getInt('total_mcq_score') ?? 0;
    String? savedPicBase64 = prefs.getString('user_profile_pic');
    String? savedPicUrl = prefs.getString('user_profile_pic_url');

    User? currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser != null) {
      name = currentUser.displayName ?? name;
      savedPicUrl = currentUser.photoURL ?? savedPicUrl;
    }

    final progressService = ProgressService();
    int learnedWords = await progressService.getCompletedCount();

    if (mounted) {
      setState(() {
        userName = name;
        totalMcqScore = score;
        totalLearnedWords = learnedWords;
        profilePicBase64 = savedPicBase64;
        profilePicUrl = savedPicUrl;
        isLoggedIn = currentUser != null;
        isLoading = false;
      });
    }

    if (currentUser != null) {
      _syncScoreToFirebase(score, learnedWords);
    }
  }

  // ✅ ফিক্স: Try-catch বসানো হয়েছে যেন লগইন ফেইল হলে অ্যাপ ক্র্যাশ বা ফ্রিজ না হয়
  Future<void> _handleGoogleSignIn() async {
    setState(() => isLoading = true);
    try {
      final user = await AuthService.signInWithGoogle();

      if (user != null) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('student_name_v2', user.displayName ?? 'Learner');
        if (user.photoURL != null) {
          await prefs.setString('user_profile_pic_url', user.photoURL!);
        }

        await WelcomeBonusService.awardIfFirstTime();
        final updatedScore = prefs.getInt('total_mcq_score') ?? 0;
        final progressService = ProgressService();
        final updatedVocab = await progressService.getCompletedCount();

        await _syncScoreToFirebase(updatedScore, updatedVocab);

        if (mounted) {
          setState(() {
            userName = user.displayName ?? 'Learner';
            profilePicUrl = user.photoURL;
            isLoggedIn = true;
          });
        }
      }
    } catch (e) {
      debugPrint("Login Error: $e");
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text(
                'লগইন বাতিল হয়েছে বা সমস্যা হয়েছে। আবার চেষ্টা করুন।'),
            backgroundColor: Colors.redAccent,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => isLoading = false);
      }
    }
  }

  Future<void> _handleLogout() async {
    await AuthService.signOut();
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('user_profile_pic_url');
    await prefs.remove('student_name_v2');

    if (mounted) {
      setState(() {
        userName = "Learner";
        profilePicUrl = null;
        isLoggedIn = false;
      });
    }
  }

  ImageProvider? _getProfileImage() {
    if (profilePicUrl != null) {
      return NetworkImage(profilePicUrl!);
    } else if (profilePicBase64 != null) {
      return MemoryImage(base64Decode(profilePicBase64!));
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    int currentLevel = (totalMcqScore / 20).floor() + 1;

    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        title: const Text('প্রোফাইল',
            style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.purple,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          if (isLoggedIn)
            IconButton(
              icon: const Icon(Icons.logout),
              onPressed: _handleLogout,
            )
        ],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator(color: Colors.purple))
          : SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                          colors: [Colors.purple, Colors.deepPurpleAccent],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight),
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                            color: Colors.purple.withOpacity(0.3),
                            blurRadius: 10,
                            offset: const Offset(0, 5))
                      ],
                    ),
                    child: Column(
                      children: [
                        CircleAvatar(
                          radius: 45,
                          backgroundColor: Colors.white,
                          backgroundImage: _getProfileImage(),
                          child: _getProfileImage() == null
                              ? const Icon(Icons.person,
                                  size: 55, color: Colors.purple)
                              : null,
                        ),
                        const SizedBox(height: 12),
                        Text(userName,
                            style: const TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                                color: Colors.white)),
                        const SizedBox(height: 8),
                        if (!isLoggedIn)
                          Padding(
                            padding: const EdgeInsets.only(top: 10),
                            child: ElevatedButton.icon(
                              onPressed: _handleGoogleSignIn,
                              icon: Image.network(
                                  'https://upload.wikimedia.org/wikipedia/commons/thumb/c/c1/Google_%22G%22_logo.svg/120px-Google_%22G%22_logo.svg.png',
                                  height: 24),
                              label: const Text('Continue with Google',
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16)),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.white,
                                foregroundColor: Colors.black87,
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 20, vertical: 12),
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(30)),
                              ),
                            ),
                          )
                        else
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 6),
                            decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(20)),
                            child: Text('Level $currentLevel',
                                style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white)),
                          ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 30),
                  const Text('Your Statistics',
                      style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87)),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                          child: _buildStatCard(
                              title: 'Vocabulary Learned',
                              value: '$totalLearnedWords',
                              icon: Icons.menu_book,
                              color: Colors.indigo)),
                      const SizedBox(width: 16),
                      Expanded(
                          child: _buildStatCard(
                              title: 'Total MCQ Points',
                              value: '$totalMcqScore',
                              icon: Icons.emoji_events,
                              color: Colors.amber.shade700)),
                    ],
                  ),
                  const SizedBox(height: 16),
                  _buildStatCard(
                      title: 'Current Streak',
                      value: '1 Days 🔥',
                      icon: Icons.local_fire_department,
                      color: Colors.deepOrange,
                      isFullWidth: true),
                ],
              ),
            ),
    );
  }

  Widget _buildStatCard(
      {required String title,
      required String value,
      required IconData icon,
      required Color color,
      bool isFullWidth = false}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
      decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
                color: Colors.grey.shade200,
                blurRadius: 8,
                offset: const Offset(0, 4))
          ]),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          CircleAvatar(
              backgroundColor: color.withOpacity(0.1),
              radius: 22,
              child: Icon(icon, color: color, size: 24)),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(value,
                    style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: color)),
                const SizedBox(height: 2),
                Text(title,
                    style: const TextStyle(
                        fontSize: 13,
                        color: Colors.black54,
                        fontWeight: FontWeight.w600),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
