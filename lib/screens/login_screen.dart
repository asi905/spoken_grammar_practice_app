import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/auth_service.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  bool isLoading = false;

  Future<void> _handleGoogleSignIn() async {
    setState(() => isLoading = true);
    final user = await AuthService.signInWithGoogle();

    if (user != null) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('student_name_v2', user.displayName ?? 'Learner');
      if (user.photoURL != null) {
        await prefs.setString('user_profile_pic_url', user.photoURL!);
      }
      // লগইন সফল হলে AuthGate অটোমেটিক তাকে হোম পেজে নিয়ে যাবে
    }

    if (mounted) setState(() => isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.purple.shade50,
      body: Center(
        child: isLoading
            ? const CircularProgressIndicator(color: Colors.purple)
            : Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.school, size: 100, color: Colors.purple),
                  const SizedBox(height: 20),
                  const Text(
                    'Welcome to FluentGo!',
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 40),
                  ElevatedButton.icon(
                    onPressed: _handleGoogleSignIn,
                    icon: Image.network(
                      'https://upload.wikimedia.org/wikipedia/commons/thumb/c/c1/Google_%22G%22_logo.svg/120px-Google_%22G%22_logo.svg.png',
                      height: 24,
                    ),
                    label: const Text(
                      'Continue with Google',
                      style:
                          TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: Colors.black87,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 24, vertical: 12),
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}
