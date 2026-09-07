import '../models/practice_item.dart';

// ডেইলি ব্যবহারের কিছু স্যাম্পল ভোকাবুলারি (এখন ১৫টি শব্দ দেওয়া হলো)
final List<PracticeItem> sampleVocabulary = [
  PracticeItem(
      id: 'v1',
      english: 'Appointment',
      bengaliMeaning: 'অ্যাপয়েন্টমেন্ট / সাক্ষাতের সময়',
      category: 'Vocabulary',
      exampleSentence: 'I have an appointment with the doctor at 5 PM.',
      synonyms: ['Meeting', 'Engagement'],
      antonyms: ['Cancellation']),
  PracticeItem(
      id: 'v2',
      english: 'Convenient',
      bengaliMeaning: 'সুবিধাজনক',
      category: 'Vocabulary',
      exampleSentence: 'Is this time convenient for you?',
      synonyms: ['Suitable', 'Handy'],
      antonyms: ['Inconvenient', 'Awkward']),
  PracticeItem(
      id: 'v3',
      english: 'Reschedule',
      bengaliMeaning: 'সময়সূচী পরিবর্তন করা',
      category: 'Vocabulary',
      exampleSentence: 'Can we reschedule our meeting to tomorrow?',
      synonyms: ['Postpone', 'Rearrange'],
      antonyms: ['Confirm']),
  PracticeItem(
      id: 'v4',
      english: 'Grocery',
      bengaliMeaning: 'মুদি সদাই',
      category: 'Vocabulary',
      exampleSentence: 'I need to buy some groceries after work.',
      synonyms: ['Provisions', 'Supplies'],
      antonyms: ['Luxuries']),
  PracticeItem(
      id: 'v5',
      english: 'Commute',
      bengaliMeaning: 'যাতায়াত করা',
      category: 'Vocabulary',
      exampleSentence: 'My daily commute takes about an hour.',
      synonyms: ['Travel', 'Journey'],
      antonyms: ['Stay']),

  // নতুন যোগ করা শব্দগুলো
  PracticeItem(
      id: 'v6',
      english: 'Essential',
      bengaliMeaning: 'অপরিহার্য / অত্যন্ত প্রয়োজনীয়',
      category: 'Vocabulary',
      exampleSentence: 'Water is essential for life.',
      synonyms: ['Crucial', 'Necessary'],
      antonyms: ['Unnecessary']),
  PracticeItem(
      id: 'v7',
      english: 'Opportunity',
      bengaliMeaning: 'সুযোগ',
      category: 'Vocabulary',
      exampleSentence: 'This is a great opportunity for you.',
      synonyms: ['Chance', 'Prospect'],
      antonyms: ['Disadvantage']),
  PracticeItem(
      id: 'v8',
      english: 'Challenge',
      bengaliMeaning: 'চ্যালেঞ্জ / প্রতিদ্বন্দ্বিতা',
      category: 'Vocabulary',
      exampleSentence: 'I am ready to face the challenge.',
      synonyms: ['Difficulty', 'Obstacle'],
      antonyms: ['Advantage']),
  PracticeItem(
      id: 'v9',
      english: 'Success',
      bengaliMeaning: 'সাফল্য',
      category: 'Vocabulary',
      exampleSentence: 'Hard work is the key to success.',
      synonyms: ['Achievement', 'Victory'],
      antonyms: ['Failure']),
  PracticeItem(
      id: 'v10',
      english: 'Knowledge',
      bengaliMeaning: 'জ্ঞান',
      category: 'Vocabulary',
      exampleSentence: 'Reading books improves our knowledge.',
      synonyms: ['Wisdom', 'Understanding'],
      antonyms: ['Ignorance']),
  PracticeItem(
      id: 'v11',
      english: 'Confidence',
      bengaliMeaning: 'আত্মবিশ্বাস',
      category: 'Vocabulary',
      exampleSentence: 'You need confidence to speak English.',
      synonyms: ['Certainty', 'Assurance'],
      antonyms: ['Doubt', 'Fear']),
  PracticeItem(
      id: 'v12',
      english: 'Environment',
      bengaliMeaning: 'পরিবেশ',
      category: 'Vocabulary',
      exampleSentence: 'We must protect our environment.',
      synonyms: ['Surroundings', 'Nature'],
      antonyms: []),
  PracticeItem(
      id: 'v13',
      english: 'Preparation',
      bengaliMeaning: 'প্রস্তুতি',
      category: 'Vocabulary',
      exampleSentence: 'Good preparation is needed for the exam.',
      synonyms: ['Readiness', 'Arrangement'],
      antonyms: []),
  PracticeItem(
      id: 'v14',
      english: 'Experience',
      bengaliMeaning: 'অভিজ্ঞতা',
      category: 'Vocabulary',
      exampleSentence: 'He has 5 years of experience in this field.',
      synonyms: ['Expertise', 'Practice'],
      antonyms: ['Inexperience']),
  PracticeItem(
      id: 'v15',
      english: 'Improvement',
      bengaliMeaning: 'উন্নতি',
      category: 'Vocabulary',
      exampleSentence: 'There is a big improvement in your speaking.',
      synonyms: ['Progress', 'Development'],
      antonyms: ['Decline']),
];

// ডেইলি কনভারসেশন প্র্যাকটিসের জন্য প্র্যাকটিস বাক্য
final List<PracticeItem> dailyConversationPractice = [
  PracticeItem(
      id: 'd1',
      english: 'How was your day?',
      bengaliMeaning: 'আপনার দিনটা কেমন গেল?',
      category: 'Daily Conversation'),
  PracticeItem(
      id: 'd2',
      english: 'What time does the meeting start?',
      bengaliMeaning: 'মিটিং কয়টায় শুরু হবে?',
      category: 'Daily Conversation'),
  PracticeItem(
      id: 'd3',
      english: 'Could you please repeat that?',
      bengaliMeaning: 'আপনি কি আবার বলতে পারবেন?',
      category: 'Daily Conversation'),
];

// একটা স্যাম্পল রোলপ্লে সিনারিও: রেস্টুরেন্টে অর্ডার করা (২ জন)
final RoleplayScenario restaurantRoleplay = RoleplayScenario(
  id: 'r1',
  title: 'Ordering Food at a Restaurant',
  description:
      'কল্পনা করুন আপনি একটা রেস্টুরেন্টে বসে আছেন এবং ওয়েটারকে অর্ডার দিচ্ছেন.',
  lines: [
    RoleplayLine(
        speaker: 'App',
        text:
            'Good evening! Welcome to our restaurant. Are you ready to order?'),
    RoleplayLine(
        speaker: 'You',
        text: 'Yes, I would like to order the grilled chicken, please.'),
    RoleplayLine(
        speaker: 'App',
        text: 'Great choice! Would you like anything to drink?'),
    RoleplayLine(speaker: 'You', text: 'Just a glass of water, thank you.'),
    RoleplayLine(
        speaker: 'App',
        text: 'Sure. Your order will be ready in about fifteen minutes.'),
  ],
);

// নতুন: গ্রুপ রোলপ্লে - ৩ জন চরিত্র নিয়ে একটা কনভারসেশন
final RoleplayScenario groupRoleplay = RoleplayScenario(
  id: 'r2',
  title: 'Planning a Weekend Trip (Group)',
  description:
      'আপনি আর আপনার দুই বন্ধু মিলে উইকেন্ড ট্রিপ প্ল্যান করছেন। আপনি "You" এর অংশটা বলবেন।',
  lines: [
    RoleplayLine(
        speaker: 'Rafi', text: 'Hey guys, should we plan a trip this weekend?'),
    RoleplayLine(
        speaker: 'Mim', text: 'That sounds great! Where should we go?'),
    RoleplayLine(
        speaker: 'You',
        text: 'How about the beach? The weather looks perfect.'),
    RoleplayLine(
        speaker: 'Rafi', text: 'I love that idea. What time should we leave?'),
    RoleplayLine(
        speaker: 'You', text: 'Let\'s leave early, around 7 in the morning.'),
    RoleplayLine(
        speaker: 'Mim',
        text: 'Perfect, I will bring some snacks for the trip.'),
  ],
);

// সব রোলপ্লে
final List<RoleplayScenario> sampleRoleplays = [
  restaurantRoleplay,
  groupRoleplay,
];
