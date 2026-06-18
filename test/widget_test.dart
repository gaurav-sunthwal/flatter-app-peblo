import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:my_app/main.dart';

void main() {
  testWidgets('Story buddy screen initial rendering smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const MyApp());

    // Verify header title exists
    expect(find.text('AI Story Buddy'), findsOneWidget);

    // Verify main storytelling screen loads with the read button
    expect(find.text('Read Me a Story! 🔊'), findsOneWidget);
  });
}
