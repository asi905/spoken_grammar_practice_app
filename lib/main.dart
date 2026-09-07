import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

import 'screens/home_screen.dart';
import 'services/gamification_service.dart';

void main() async {
  // ফ্লাটারের কোর ইঞ্জিন চালু করার জন্য
  WidgetsFlutterBinding.ensureInitialized();

  // ফায়ারবেস চালু করার জন্য
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // আপনার আগের গ্যামিফিকেশন সার্ভিস চালু করার জন্য
  await GamificationService.instance.init();

  runApp(const SpeakPracticeApp());
}

class SpeakPracticeApp extends StatelessWidget {
  const SpeakPracticeApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Speak Practice',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.indigo,
        useMaterial3: true,
        fontFamily: 'Roboto',
      ),
      home: const HomeScreen(),
    );
  }
}
