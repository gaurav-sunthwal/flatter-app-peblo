import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:confetti/confetti.dart';
import 'story_quiz_provider.dart';
import 'shake_widget.dart';

class StoryBuddyScreen extends StatefulWidget {
  const StoryBuddyScreen({super.key});

  @override
  State<StoryBuddyScreen> createState() => _StoryBuddyScreenState();
}

class _StoryBuddyScreenState extends State<StoryBuddyScreen> with SingleTickerProviderStateMixin {
  late ConfettiController _confettiController;
  late AnimationController _floatingController;

  @override
  void initState() {
    super.initState();
    _confettiController = ConfettiController(duration: const Duration(seconds: 2));
    _floatingController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _confettiController.dispose();
    _floatingController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<StoryQuizProvider>(context);

    // Listen to changes to trigger confetti on success state
    if (provider.isCorrect == true) {
      _confettiController.play();
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF7F9FC),
      body: Stack(
        children: [
          // Background soft decor
          Positioned(
            top: -100,
            right: -100,
            child: CircleAvatar(
              radius: 150,
              backgroundColor: const Color(0x15FF7043),
            ),
          ),
          Positioned(
            bottom: -50,
            left: -50,
            child: CircleAvatar(
              radius: 120,
              backgroundColor: const Color(0x1029B6F6),
            ),
          ),
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
              physics: const BouncingScrollPhysics(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Header
                  _buildHeader(),
                  const SizedBox(height: 20),

                  // AI Buddy Animation & State Character
                  _buildBuddyCharacter(provider),
                  const SizedBox(height: 20),

                  // Story Narrator Card (with word-by-word highlighting)
                  _buildStoryCard(provider),
                  const SizedBox(height: 20),

                  // Narrate Button / Progress Indicator
                  _buildNarrateButton(provider),
                  const SizedBox(height: 30),

                  // Interactive Quiz Section
                  if (provider.showQuiz) ...[
                    AnimatedOpacity(
                      opacity: provider.showQuiz ? 1.0 : 0.0,
                      duration: const Duration(milliseconds: 600),
                      child: _buildQuizSection(provider),
                    ),
                  ],
                ],
              ),
            ),
          ),

          // Confetti overlay on success
          Align(
            alignment: Alignment.topCenter,
            child: ConfettiWidget(
              confettiController: _confettiController,
              blastDirectionality: BlastDirectionality.explosive,
              shouldLoop: false,
              colors: const [
                Colors.green,
                Colors.blue,
                Colors.pink,
                Colors.orange,
                Colors.purple,
                Colors.yellow,
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: const Color(0xFFFFECE5),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(
                Icons.face_retouching_natural,
                color: Color(0xFFFF7043),
                size: 28,
              ),
            ),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Text(
                  "Peblo",
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w900,
                    color: Color(0xFF2C3E50),
                    letterSpacing: 0.5,
                  ),
                ),
                Text(
                  "AI Story Buddy",
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ],
        ),
        IconButton(
          onPressed: () {
            Provider.of<StoryQuizProvider>(context, listen: false).resetAll();
            _confettiController.stop();
          },
          icon: const Icon(Icons.refresh, color: Color(0xFF7F8C8D)),
          tooltip: 'Reset Session',
        ),
      ],
    );
  }

  Widget _buildBuddyCharacter(StoryQuizProvider provider) {
    String bubbleText = "Hi! Let's read a fun story together. Press the button!";
    Color buddyColor = const Color(0xFF29B6F6);
    BuddyFaceState faceState = BuddyFaceState.happy;

    if (provider.narrationState == NarrationState.loading) {
      bubbleText = "Mmm... getting the storytelling voice ready!";
      buddyColor = const Color(0xFFFFCA28);
      faceState = BuddyFaceState.thinking;
    } else if (provider.narrationState == NarrationState.playing) {
      bubbleText = "Listening closely... I love this story!";
      buddyColor = const Color(0xFF66BB6A);
      faceState = BuddyFaceState.listening;
    } else if (provider.narrationState == NarrationState.completed && provider.selectedAnswer == null) {
      bubbleText = "Wow! Now can you answer my question?";
      buddyColor = const Color(0xFFAB47BC);
      faceState = BuddyFaceState.excited;
    } else if (provider.isCorrect == false) {
      bubbleText = "Oops! That's not quite right. Try again, you can do it!";
      buddyColor = const Color(0xFFEF5350);
      faceState = BuddyFaceState.sad;
    } else if (provider.isCorrect == true) {
      bubbleText = "YAY! You got it right! You are super smart!";
      buddyColor = const Color(0xFFFF7043);
      faceState = BuddyFaceState.victory;
    }

    return Column(
      children: [
        // Dialogue Bubble
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 16.0),
          padding: const EdgeInsets.all(16.0),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24.0),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              Text(
                bubbleText,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF34495E),
                ),
              ),
              Positioned(
                bottom: -24,
                left: 0,
                right: 0,
                child: Center(
                  child: CustomPaint(
                    painter: BubblePointerPainter(color: Colors.white),
                    size: const Size(20, 10),
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),
        // Floating premium Buddy vector Graphic
        AnimatedBuilder(
          animation: _floatingController,
          builder: (context, child) {
            return Transform.translate(
              offset: Offset(0, -6 * _floatingController.value),
              child: CustomPaint(
                painter: StoryBuddyVectorPainter(
                  color: buddyColor,
                  faceState: faceState,
                ),
                size: const Size(120, 120),
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildStoryCard(StoryQuizProvider provider) {
    return Card(
      elevation: 4,
      shadowColor: Colors.black.withOpacity(0.1),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24.0)),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24.0),
          gradient: const LinearGradient(
            colors: [Colors.white, Color(0xFFFAFBFC)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.auto_stories, color: Color(0xFFFF7043)),
                SizedBox(width: 8),
                Text(
                  "Today's Story Adventure",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF2C3E50),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildStoryHighlightText(provider),
          ],
        ),
      ),
    );
  }

  Widget _buildStoryHighlightText(StoryQuizProvider provider) {
    if (provider.narrationState != NarrationState.playing ||
        (provider.currentWordStart == 0 && provider.currentWordEnd == 0)) {
      return Text(
        provider.storyText,
        textAlign: TextAlign.center,
        style: const TextStyle(
          fontSize: 18,
          height: 1.6,
          fontWeight: FontWeight.w600,
          color: Color(0xFF4A5568),
        ),
      );
    }

    final text = provider.storyText;
    final start = provider.currentWordStart;
    final end = provider.currentWordEnd;

    // Boundary safeties
    if (start < 0 || end > text.length || start > end) {
      return Text(
        text,
        textAlign: TextAlign.center,
        style: const TextStyle(
          fontSize: 18,
          height: 1.6,
          fontWeight: FontWeight.w600,
          color: Color(0xFF4A5568),
        ),
      );
    }

    final before = text.substring(0, start);
    final word = text.substring(start, end);
    final after = text.substring(end);

    return RichText(
      textAlign: TextAlign.center,
      text: TextSpan(
        style: const TextStyle(
          fontSize: 18,
          height: 1.6,
          fontWeight: FontWeight.w600,
          color: Color(0xFF4A5568),
          fontFamily: 'Roboto',
        ),
        children: [
          TextSpan(text: before),
          TextSpan(
            text: word,
            style: const TextStyle(
              color: Color(0xFFFF7043),
              fontWeight: FontWeight.w900,
              backgroundColor: Color(0xFFFFF0EB),
            ),
          ),
          TextSpan(text: after),
        ],
      ),
    );
  }

  Widget _buildNarrateButton(StoryQuizProvider provider) {
    final state = provider.narrationState;
    String btnText = "Read Me a Story! 🔊";
    Color btnColor = const Color(0xFFFF7043);
    bool isLoading = false;

    if (state == NarrationState.loading) {
      btnText = "Preparing...";
      btnColor = const Color(0xFFFFCA28);
      isLoading = true;
    } else if (state == NarrationState.playing) {
      btnText = "Stop Narration 🛑";
      btnColor = const Color(0xFFEF5350);
    } else if (state == NarrationState.completed) {
      btnText = "Listen Again 🔁";
      btnColor = const Color(0xFF66BB6A);
    } else if (state == NarrationState.error) {
      btnText = "Retry Narration ⚠️";
      btnColor = const Color(0xFFEF5350);
    }

    return Column(
      children: [
        if (state == NarrationState.error)
          Padding(
            padding: const EdgeInsets.only(bottom: 8.0),
            child: Text(
              provider.errorMessage,
              style: const TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
          ),
        ElevatedButton(
          onPressed: isLoading ? null : () => provider.readStory(),
          style: ElevatedButton.styleFrom(
            backgroundColor: btnColor,
            foregroundColor: Colors.white,
            elevation: 6,
            shadowColor: btnColor.withOpacity(0.3),
            padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 36),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (isLoading)
                const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 3, color: Colors.white),
                )
              else
                Text(
                  btnText,
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
                ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildQuizSection(StoryQuizProvider provider) {
    if (provider.quizData == null) return const SizedBox.shrink();

    final question = provider.quizData!['question'] as String;
    final options = List<String>.from(provider.quizData!['options'] as List);

    return ShakeWidget(
      trigger: provider.shakeTrigger,
      child: Card(
        elevation: 6,
        shadowColor: Colors.black.withOpacity(0.1),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24.0)),
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                "QUIZ TIME! 🤔",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w900,
                  color: Color(0xFF2C3E50),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                question,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF34495E),
                ),
              ),
              const SizedBox(height: 20),
              ...options.map((option) {
                final isSelected = provider.selectedAnswer == option;
                Color optColor = Colors.white;
                Color textColor = const Color(0xFF2C3E50);
                IconData? feedbackIcon;

                if (isSelected) {
                  if (provider.isCorrect == true) {
                    optColor = const Color(0xFFE8F5E9);
                    textColor = const Color(0xFF2E7D32);
                    feedbackIcon = Icons.check_circle;
                  } else if (provider.isCorrect == false) {
                    optColor = const Color(0xFFFFEBEE);
                    textColor = const Color(0xFFC62828);
                    feedbackIcon = Icons.cancel;
                  }
                }

                return Padding(
                  padding: const EdgeInsets.only(bottom: 12.0),
                  child: OutlinedButton(
                    onPressed: () {
                      HapticFeedback.mediumImpact();
                      provider.checkAnswer(option);
                    },
                    style: OutlinedButton.styleFrom(
                      backgroundColor: optColor,
                      side: BorderSide(
                        color: isSelected
                            ? (provider.isCorrect == true ? Colors.green : Colors.red)
                            : const Color(0xFFE0E0E0),
                        width: 2.5,
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            option,
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              color: textColor,
                            ),
                          ),
                        ),
                        if (feedbackIcon != null)
                          Icon(feedbackIcon, color: provider.isCorrect == true ? Colors.green : Colors.red),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ],
          ),
        ),
      ),
    );
  }
}

enum BuddyFaceState {
  happy,
  thinking,
  listening,
  excited,
  sad,
  victory,
}

class StoryBuddyVectorPainter extends CustomPainter {
  final Color color;
  final BuddyFaceState faceState;

  StoryBuddyVectorPainter({required this.color, required this.faceState});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;

    // Draw Buddy body shadow
    final shadowPaint = Paint()
      ..color = Colors.black.withOpacity(0.08)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8);
    canvas.drawCircle(center + const Offset(0, 6), radius, shadowPaint);

    // Draw main Buddy body
    final bodyPaint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;
    canvas.drawCircle(center, radius, bodyPaint);

    // Draw shiny highlight (kid-friendly 3D feel)
    final highlightPaint = Paint()
      ..color = Colors.white.withOpacity(0.15)
      ..style = PaintingStyle.fill;
    canvas.drawCircle(center - Offset(radius * 0.3, radius * 0.3), radius * 0.4, highlightPaint);

    // Draw cheeks
    final cheekPaint = Paint()
      ..color = Colors.pinkAccent.withOpacity(0.4)
      ..style = PaintingStyle.fill;
    canvas.drawCircle(Offset(center.dx - radius * 0.5, center.dy + radius * 0.1), radius * 0.15, cheekPaint);
    canvas.drawCircle(Offset(center.dx + radius * 0.5, center.dy + radius * 0.1), radius * 0.15, cheekPaint);

    // Draw Eyes & Mouth based on state
    final eyePaint = Paint()
      ..color = const Color(0xFF2C3E50)
      ..style = PaintingStyle.fill;

    final mouthPaint = Paint()
      ..color = const Color(0xFF2C3E50)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4.0
      ..strokeCap = StrokeCap.round;

    final leftEye = Offset(center.dx - radius * 0.3, center.dy - radius * 0.1);
    final rightEye = Offset(center.dx + radius * 0.3, center.dy - radius * 0.1);

    switch (faceState) {
      case BuddyFaceState.happy:
        // Regular friendly eyes & smile
        canvas.drawCircle(leftEye, radius * 0.08, eyePaint);
        canvas.drawCircle(rightEye, radius * 0.08, eyePaint);
        // Smile arc
        final smilePath = Path()
          ..arcTo(
            Rect.fromLTWH(center.dx - radius * 0.25, center.dy - radius * 0.05, radius * 0.5, radius * 0.3),
            0,
            3.14,
            false,
          );
        canvas.drawPath(smilePath, mouthPaint);
        break;

      case BuddyFaceState.listening:
        // Closed happy eyes & content smile
        final closedEyePathLeft = Path()
          ..arcTo(
            Rect.fromCircle(center: leftEye, radius: radius * 0.08),
            3.14,
            3.14,
            false,
          );
        final closedEyePathRight = Path()
          ..arcTo(
            Rect.fromCircle(center: rightEye, radius: radius * 0.08),
            3.14,
            3.14,
            false,
          );
        canvas.drawPath(closedEyePathLeft, mouthPaint);
        canvas.drawPath(closedEyePathRight, mouthPaint);

        // Smile arc
        final smallSmile = Path()
          ..arcTo(
            Rect.fromLTWH(center.dx - radius * 0.15, center.dy + radius * 0.02, radius * 0.3, radius * 0.2),
            0,
            3.14,
            false,
          );
        canvas.drawPath(smallSmile, mouthPaint);
        break;

      case BuddyFaceState.thinking:
        // Wide curious eyes
        canvas.drawCircle(leftEye, radius * 0.1, eyePaint);
        canvas.drawCircle(rightEye, radius * 0.1, eyePaint);
        // Small "O" mouth
        final mouthO = Paint()
          ..color = const Color(0xFF2C3E50)
          ..style = PaintingStyle.fill;
        canvas.drawCircle(Offset(center.dx, center.dy + radius * 0.15), radius * 0.08, mouthO);
        break;

      case BuddyFaceState.excited:
      case BuddyFaceState.victory:
        // Star/Excited eyes (represented by happy upward curves)
        final leftArc = Path()
          ..arcTo(
            Rect.fromCircle(center: leftEye, radius: radius * 0.09),
            3.14,
            3.14,
            false,
          );
        final rightArc = Path()
          ..arcTo(
            Rect.fromCircle(center: rightEye, radius: radius * 0.09),
            3.14,
            3.14,
            false,
          );
        canvas.drawPath(leftArc, mouthPaint);
        canvas.drawPath(rightArc, mouthPaint);

        // Huge happy open mouth
        final happyMouthPaint = Paint()
          ..color = const Color(0xFFEF5350)
          ..style = PaintingStyle.fill;
        final openMouthRect = Rect.fromLTWH(
          center.dx - radius * 0.25,
          center.dy + radius * 0.05,
          radius * 0.5,
          radius * 0.3,
        );
        canvas.drawArc(openMouthRect, 0, 3.14, true, happyMouthPaint);
        break;

      case BuddyFaceState.sad:
        // Worried eyes and sad downward arc
        canvas.drawCircle(leftEye, radius * 0.08, eyePaint);
        canvas.drawCircle(rightEye, radius * 0.08, eyePaint);
        final sadPath = Path()
          ..arcTo(
            Rect.fromLTWH(center.dx - radius * 0.2, center.dy + radius * 0.15, radius * 0.4, radius * 0.2),
            3.14,
            3.14,
            false,
          );
        canvas.drawPath(sadPath, mouthPaint);
        break;
    }
  }

  @override
  bool shouldRepaint(covariant StoryBuddyVectorPainter oldDelegate) {
    return oldDelegate.color != color || oldDelegate.faceState != faceState;
  }
}

class BubblePointerPainter extends CustomPainter {
  final Color color;
  BubblePointerPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    final path = Path()
      ..moveTo(0, 0)
      ..lineTo(size.width / 2, size.height)
      ..lineTo(size.width, 0)
      ..close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
