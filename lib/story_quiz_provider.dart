import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter_tts/flutter_tts.dart';

enum NarrationState {
  idle,
  loading,
  playing,
  paused,
  completed,
  error,
}

class StoryQuizProvider extends ChangeNotifier {
  final FlutterTts _flutterTts = FlutterTts();

  // Story state
  final String storyText = "Once upon a time, a clever little robot named Pip lost his shiny blue gear in the Whispering Woods...";
  NarrationState _narrationState = NarrationState.idle;
  String _errorMessage = '';

  // Quiz state
  bool _showQuiz = false;
  Map<String, dynamic>? _quizData;
  String? _selectedAnswer;
  bool? _isCorrect;
  int _shakeTrigger = 0; // Incremented on wrong answer to trigger shake animations

  NarrationState get narrationState => _narrationState;
  String get errorMessage => _errorMessage;
  bool get showQuiz => _showQuiz;
  Map<String, dynamic>? get quizData => _quizData;
  String? get selectedAnswer => _selectedAnswer;
  bool? get isCorrect => _isCorrect;
  int get shakeTrigger => _shakeTrigger;

  // Highlight offsets
  int _currentWordStart = 0;
  int _currentWordEnd = 0;

  int get currentWordStart => _currentWordStart;
  int get currentWordEnd => _currentWordEnd;

  StoryQuizProvider() {
    _initTts();
    _loadQuizJson();
  }

  void _initTts() {
    _flutterTts.setStartHandler(() {
      _narrationState = NarrationState.playing;
      _currentWordStart = 0;
      _currentWordEnd = 0;
      notifyListeners();
    });

    _flutterTts.setCompletionHandler(() {
      _narrationState = NarrationState.completed;
      _showQuiz = true; // Automatically reveal quiz on completion
      _currentWordStart = 0;
      _currentWordEnd = 0;
      notifyListeners();
    });

    _flutterTts.setCancelHandler(() {
      _narrationState = NarrationState.idle;
      _currentWordStart = 0;
      _currentWordEnd = 0;
      notifyListeners();
    });

    _flutterTts.setErrorHandler((msg) {
      _narrationState = NarrationState.error;
      _errorMessage = msg.toString();
      _currentWordStart = 0;
      _currentWordEnd = 0;
      notifyListeners();
    });

    _flutterTts.setProgressHandler((String text, int startOffset, int endOffset, String word) {
      _currentWordStart = startOffset;
      _currentWordEnd = endOffset;
      notifyListeners();
    });
  }

  void _loadQuizJson() {
    // Simulated remote JSON payload
    const quizJson = '''
    {
      "question": "What colour was Pip the Robot's lost gear?",
      "options": ["Red", "Green", "Blue", "Yellow"],
      "answer": "Blue"
    }
    ''';
    try {
      _quizData = jsonDecode(quizJson);
    } catch (e) {
      _quizData = null;
      _errorMessage = "Failed to load quiz data.";
    }
  }

  // Load a dynamic JSON payload to prove completely data-driven architecture
  void loadCustomQuizJson(String jsonString) {
    try {
      _quizData = jsonDecode(jsonString);
      resetQuizOnly();
      notifyListeners();
    } catch (e) {
      _errorMessage = "Failed to parse custom quiz JSON.";
      notifyListeners();
    }
  }

  Future<void> readStory() async {
    if (_narrationState == NarrationState.playing) {
      await _flutterTts.stop();
      _narrationState = NarrationState.idle;
      notifyListeners();
      return;
    }

    _narrationState = NarrationState.loading;
    notifyListeners();

    try {
      // Configure TTS for kid-friendly voice settings
      await _flutterTts.setLanguage("en-US");
      await _flutterTts.setPitch(1.2); // Slightly higher pitch for a kid-friendly voice
      await _flutterTts.setSpeechRate(0.45); // Slower speech rate for easy comprehension

      var result = await _flutterTts.speak(storyText);
      if (result == 0) {
        throw Exception("TTS Engine returned failure code.");
      }
    } catch (e) {
      _narrationState = NarrationState.error;
      _errorMessage = "Could not speak story. Please check device TTS or volume settings.";
      notifyListeners();
    }
  }

  void checkAnswer(String option) {
    if (_quizData == null) return;
    _selectedAnswer = option;
    final correctAnswer = _quizData!['answer'] as String;

    if (option.trim().toLowerCase() == correctAnswer.trim().toLowerCase()) {
      _isCorrect = true;
    } else {
      _isCorrect = false;
      _shakeTrigger++; // Incrementing triggers the shake animation in the view
    }
    notifyListeners();
  }

  void resetQuizOnly() {
    _selectedAnswer = null;
    _isCorrect = null;
  }

  void resetAll() {
    _flutterTts.stop();
    _narrationState = NarrationState.idle;
    _showQuiz = false;
    _selectedAnswer = null;
    _isCorrect = null;
    notifyListeners();
  }

  @override
  void dispose() {
    _flutterTts.stop();
    super.dispose();
  }
}
