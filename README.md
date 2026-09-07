# Speak Practice — English Speaking & Grammar Practice App (MVP - Phase 1)

## এই ভার্শনে যা আছে
- হোম স্ক্রিন (৪টা ফিচারে যাওয়ার মেনু)
- ভোকাবুলারি প্র্যাকটিস (কার্ড ফ্লিপ করে অর্থ দেখা)
- ডেইলি কনভারসেশন প্র্যাকটিস (একই কার্ড সিস্টেম)
- রোলপ্লে স্ক্রিন (চ্যাট বাবলে সংলাপ দেখানো)
- প্রোগ্রেস ট্র্যাকিং (লোকাল স্টোরেজে সেভ হয়)

## কীভাবে চালাবেন

### ধাপ ১: Flutter ইনস্টল করুন
https://docs.flutter.dev/get-started/install থেকে আপনার OS অনুযায়ী ইনস্টল করুন।
টার্মিনালে চেক করুন:
```
flutter doctor
```

### ধাপ ২: প্রজেক্ট রান করুন
এই ফোল্ডারে গিয়ে (টার্মিনাল/কমান্ড প্রম্পটে):
```
cd spoken_grammar_practice
flutter pub get
flutter run
```
(ফোন USB দিয়ে কানেক্ট করা থাকতে হবে, বা Android Emulator চালু থাকতে হবে)

### Android Studio দিয়েও করতে পারেন
Android Studio ওপেন করে "Open an existing project" থেকে এই `spoken_grammar_practice` ফোল্ডারটা সিলেক্ট করুন। এরপর উপরে ডিভাইস সিলেক্ট করে Run বাটনে ক্লিক করুন।

## ফাইল স্ট্রাকচার
```
spoken_grammar_practice/
├── lib/
│   ├── main.dart                    # অ্যাপ শুরু হয় এখান থেকে
│   ├── models/practice_item.dart    # ডেটা মডেল
│   ├── data/sample_data.dart        # স্যাম্পল ভোকাবুলারি/রোলপ্লে (এখানে নিজের কনটেন্ট যোগ করবেন)
│   ├── data/progress_service.dart   # প্রোগ্রেস সেভ করার লজিক
│   └── screens/                     # সবগুলো স্ক্রিন
└── pubspec.yaml                     # dependencies
```

## পরবর্তী ধাপ (রোডম্যাপে যেমন বলা হয়েছিল)

**Phase 2 — ভয়েস রেকর্ড + উচ্চারণ চেক**
- `speech_to_text` অথবা `record` প্যাকেজ দিয়ে ভয়েস রেকর্ড করা
- Azure Speech Assessment API (pronunciation scoring) অথবা Google Cloud Speech-to-Text ব্যবহার করে উচ্চারণ যাচাই
- ভোকাবুলারি স্ক্রিনের "উচ্চারণ প্র্যাকটিস করুন" বাটনটা এখন শুধু placeholder — এখানে এই ফিচার যুক্ত হবে

**Phase 3 — Firebase দিয়ে প্রোগ্রেস ট্র্যাকিং**
- এখন প্রোগ্রেস শুধু ফোনে লোকালি সেভ হয় (SharedPreferences)
- Firebase Firestore + Firebase Auth যোগ করলে ইউজার লগইন করে যেকোনো ডিভাইস থেকে প্রোগ্রেস দেখতে পারবে

**Phase 4 — ভিডিও/অডিও কনভারসেশন**
- Agora অথবা Twilio SDK দিয়ে রিয়েল-টাইম ভিডিও/অডিও কল ফিচার
- এটা সবচেয়ে জটিল অংশ, তাই শেষে করাই ভালো

## নিজের কনটেন্ট যোগ করবেন কীভাবে
`lib/data/sample_data.dart` ফাইলে গিয়ে নতুন `PracticeItem` বা `RoleplayScenario` যোগ করুন — লিস্টে নতুন এন্ট্রি বসালেই অ্যাপে দেখাবে।
