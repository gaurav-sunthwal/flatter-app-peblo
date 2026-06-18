import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'story_quiz_provider.dart';
import 'story_buddy_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => StoryQuizProvider(),
      child: MaterialApp(
        title: 'Peblo AI Story Buddy',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          useMaterial3: true,
          colorScheme: ColorScheme.fromSeed(
            seedColor: const Color(0xFFFF7043),
            primary: const Color(0xFFFF7043),
            secondary: const Color(0xFF29B6F6),
          ),
          fontFamily: 'Roboto', // Premium fallback clean typography
        ),
        home: const StoryBuddyScreen(),
      ),
    );
  }
}
