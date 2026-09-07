import 'package:flutter/material.dart';

class GrammarFullNoteScreen extends StatelessWidget {
  final int dayNumber;
  final String titleEn;
  final String fullText;

  const GrammarFullNoteScreen({
    super.key,
    required this.dayNumber,
    required this.titleEn,
    required this.fullText,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Day $dayNumber সম্পূর্ণ নোট')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: SelectableText(
          fullText,
          style: const TextStyle(fontSize: 15, height: 1.5),
        ),
      ),
    );
  }
}
