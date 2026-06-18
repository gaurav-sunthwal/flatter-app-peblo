# Peblo AI Story Buddy & Quiz Component 🤖📖

A beautiful, gamified, and interactive edutainment mini-feature built for **Peblo**. This single-screen Flutter application is optimized for low-to-mid-range mobile hardware (e.g. 3GB RAM devices popular in India) and designed to engage and delight children with immersive reading narration and active quiz participation.

---

## 🛠 Features

1. **AI Story Buddy Character**:
   - Built entirely with custom Flutter Vector graphics (`CustomPainter`), eliminating the overhead of heavy PNG assets to keep the app ultra-lightweight.
   - The buddy bobs/floats smoothly and reacts dynamically to different game states with tailored facial expressions (happy, thinking/preparing, closed-eyes listening, excited, sad, victory).
2. **Text-To-Speech (TTS) Narration with Word-by-Word Highlighting**:
   - Implements native device TTS (`flutter_tts`) with customized voice variables: slower speech rate (0.45) and slightly raised pitch (1.2) specifically tuned for early-grade children.
   - Dynamically tracks speech progress and highlights the spoken words in real time with an orange highlight box.
   - Automatically opens the interactive quiz as soon as narration completes.
3. **Data-Driven Quiz Engine**:
   - Parses the quiz content from a JSON format.
   - Built dynamically: easily scales and renders a variable number of option cards (3, 4, or 5 choices) completely driven by backend JSON payload changes without modifying codebase.
4. **Delightful Child Interactions**:
   - **Correct Answer**: Triggers a victory face on the Buddy, plays celebratory haptics, and fires off a colorful confetti explosion.
   - **Incorrect Answer**: Triggers an encouraging sad face on the Buddy and shakes the quiz card with a damped sine-wave physics animation.

---

## 📖 Intern Challenge Review Questions

### 1. Which framework did you choose and why?
We chose **Flutter** to build a single-screen application that performs high-fidelity, custom 2D vector paintings and physics-based animations (shake, confetti, floating) compiled down to native machine code. It runs cleanly at 60fps on modest Android devices with ~3GB RAM, and is easy to scale cross-platform.

### 2. How did you manage the transition state between audio ending and the quiz appearing?
In `StoryQuizProvider`, we attached a listener completion handler (`setCompletionHandler`) to the `FlutterTts` instance. When the speech completes:
1. The narration state transitions to `completed`.
2. The boolean flag `_showQuiz` is set to `true`.
3. The UI automatically fades/slides the quiz card into view using a smooth `AnimatedOpacity` widget.

### 3. How did you build the quiz to be data-driven?
The quiz layout in `StoryBuddyScreen` maps options array values loaded from the JSON payload dynamically:
- Read option length directly from the decoded map.
- Generated the choice cards sequentially in a Column wrapper (`...options.map((option) { ... })`).
- This handles any number of items (3, 4, 5, etc.) and text differences seamlessly.

### 4. Caching approach (and how to cache remote audio)
Currently, we utilize the native TTS synthesization engine which does not require network traffic for local synthesization. If fetching remote audio from an external API (like ElevenLabs or AWS Polly):
- We would implement a local cache lookup (using a package like `flutter_cache_manager` or `path_provider`).
- Save the audio bytes to the local storage using a SHA-256 hash of the target text as the filename.
- For subsequent plays, load the file directly from storage to eliminate API costs and latency.

### 5. How did you handle audio loading and failure states?
The state machine implements states: `idle`, `loading`, `playing`, `completed`, and `error`.
- When the user taps the read button, it changes state to `loading`.
- An error handler hook (`setErrorHandler`) catches failures (no TTS engine setup, device audio hardware issues).
- In case of an error, it halts playback, catches the exception, updates the state to `error`, and renders a user-friendly retry button rather than hanging or crashing.

### 6. Performance profiling and optimizations for mid-range Android devices
- **Vector Painters**: Chose Flutter vectors (`CustomPainter`) for the Buddy instead of heavy raster images (saving RAM, bundle size, and decoding overhead).
- **Localized Rebuilds**: We encapsulated the shake physics into a dedicated stateless/stateful `ShakeWidget` wrapper. Toggling wrong answers only triggers paint translations inside the subtree, avoiding rebuilding the heavy story or avatar widgets.
- **No Heavy Libraries**: Used standard Flutter animation curves and physics formulas instead of resource-heavy physics frameworks.

### 7. AI usage & judgment
- **Used AI for**: Designing the damped sine-wave formula used for the wrong-answer shake physics translation.
- **Rejected suggestion**: The AI suggested using `rive` or a package for Lottie animations to render the Buddy. We rejected this to keep the application lightweight, choosing `CustomPainter` to draw vectors on the fly instead.

---

## 🚀 Running the App Locally

### Prerequisites
- Flutter SDK (v3.12 or later)
- Android Studio / VS Code (with Flutter extensions)

### Execution
1. Clone the repository
2. Fetch dependencies:
   ```bash
   flutter pub get
   ```
3. Run on device or emulator:
   ```bash
   flutter run
   ```
4. Run tests:
   ```bash
   flutter test
   ```
