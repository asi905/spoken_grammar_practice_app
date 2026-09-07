// This is a basic Flutter widget test.

import 'package:flutter_test/flutter_test.dart';

import 'package:spoken_grammar_practice/main.dart';

void main() {
  testWidgets('App launches without crashing', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const SpeakPracticeApp());

    // Just verify the app builds successfully and shows something on screen.
    expect(find.byType(SpeakPracticeApp), findsOneWidget);
  });
}
