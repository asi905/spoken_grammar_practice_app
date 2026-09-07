import 'package:shared_preferences/shared_preferences.dart';
// ✅ GamificationService ইম্পোর্ট করা হলো (যাতে ফায়ারবেসে পয়েন্ট পাঠানো যায়)
import 'gamification_service.dart';

// প্রথমবার প্রোফাইল তৈরি (নাম সেভ) করলে একবারই ৫০ পয়েন্ট বোনাস দেয়।
// একই ফোনে পরে নাম বদলালে আর দ্বিতীয়বার বোনাস দেয় না।
class WelcomeBonusService {
  static const _kBonusGivenKey = 'welcome_bonus_given';
  static const int bonusPoints = 50;

  static Future<void> awardIfFirstTime() async {
    final prefs = await SharedPreferences.getInstance();
    final alreadyGiven = prefs.getBool(_kBonusGivenKey) ?? false;

    // যদি আগেই বোনাস পেয়ে থাকে, তাহলে আর কিছুই করবে না
    if (alreadyGiven) return;

    // ✅ GamificationService-এর মাধ্যমে বোনাস পয়েন্ট যোগ করা হচ্ছে (লোকাল + ফায়ারবেস)
    await GamificationService.instance.addBonusPoints(bonusPoints);

    // বোনাস দেওয়া হয়ে গেছে, সেটা সেভ করে রাখছি যাতে দ্বিতীয়বার না দেয়
    await prefs.setBool(_kBonusGivenKey, true);
  }
}
