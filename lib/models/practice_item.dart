class PracticeItem {
  final String id;
  final String english; // ইংরেজি শব্দ/বাক্য
  final String bengaliMeaning; // বাংলা অর্থ
  final String category; // যেমন: "Daily Conversation", "Vocabulary", "Roleplay"
  final String? exampleSentence;
  final List<String> synonyms;
  final List<String> antonyms;

  PracticeItem({
    required this.id,
    required this.english,
    required this.bengaliMeaning,
    required this.category,
    this.exampleSentence,
    this.synonyms = const [],
    this.antonyms = const [],
  });
}

// একটা রোলপ্লে সিনারিওর একটা লাইন/সংলাপ
class RoleplayLine {
  final String speaker; // "App" অথবা "You"
  final String text;

  RoleplayLine({required this.speaker, required this.text});
}

class RoleplayScenario {
  final String id;
  final String title;
  final String description;
  final List<RoleplayLine> lines;

  RoleplayScenario({
    required this.id,
    required this.title,
    required this.description,
    required this.lines,
  });
}
