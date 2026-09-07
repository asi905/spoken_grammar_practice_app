import 'package:flutter/material.dart';

class GrammarRule {
  final String titleEn;
  final String explanationBn;
  final List<String> examples;

  GrammarRule({
    required this.titleEn,
    required this.explanationBn,
    required this.examples,
  });
}

enum QuestionType { mcq, fillBlank, errorCorrection, translation }

class GrammarQuestion {
  final QuestionType type;
  final String question;
  final List<String>? options; // শুধু mcq-এর জন্য
  final int? correctIndex; // শুধু mcq-এর জন্য
  final String?
      correctAnswerText; // fillBlank/errorCorrection/translation-এর জন্য
  final String explanationBn;

  GrammarQuestion({
    this.type = QuestionType.mcq,
    required this.question,
    this.options,
    this.correctIndex,
    this.correctAnswerText,
    required this.explanationBn,
  });
}

class GrammarDay {
  final int levelNumber;
  final int dayNumber;
  final String titleEn;
  final String titleBn;
  final IconData icon;
  final List<GrammarRule> rules;
  final List<GrammarQuestion> questions;

  GrammarDay({
    required this.levelNumber,
    required this.dayNumber,
    required this.titleEn,
    required this.titleBn,
    required this.icon,
    required this.rules,
    required this.questions,
  });
}

class GrammarLevelInfo {
  final int levelNumber;
  final String titleEn;
  final String titleBn;
  final IconData icon;
  final Color color;
  final int completionPoints;

  GrammarLevelInfo({
    required this.levelNumber,
    required this.titleEn,
    required this.titleBn,
    required this.icon,
    required this.color,
    required this.completionPoints,
  });
}
