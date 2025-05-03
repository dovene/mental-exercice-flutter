import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/subject.dart';
import '../services/database_helper.dart';
import '../widgets/achievement_indicator.dart';
import '../widgets/answer_animation.dart';
import '../widgets/countdown_timer.dart';
import '../widgets/number_keyboard.dart';
import 'controllers/exercise_controller.dart';
import 'history_page.dart';
import 'settings_page.dart';

class ExercisePage extends StatefulWidget {
  final Subject subject;

  const ExercisePage({Key? key, required this.subject}) : super(key: key);

  @override
  _ExercisePageState createState() => _ExercisePageState();
}

class _ExercisePageState extends State<ExercisePage>
    with TickerProviderStateMixin {
  late ExerciseController _controller;
  late AnimationController _scoreController;
  late Animation<double> _scoreAnimation;

  // Statistics
  int _totalQuestions = 0;
  int _correctAnswers = 0;
  int _successRate = 0;
  bool _isProblemSuject = false;

  @override
  void initState() {
    super.initState();
    _controller = ExerciseController(widget.subject.type);
    _initializeScoreController();
    _loadSuccessStats();
    _isProblemSuject = widget.subject.type == SubjectType.problemes;
  }

  // Load success stats from the database using the same logic as history page
  Future<void> _loadSuccessStats() async {
    try {
      final stats = await DatabaseHelper.instance
          .getStats(subjectType: widget.subject.type);

      setState(() {
        _totalQuestions = stats['total'] as int;
        _correctAnswers = stats['correct'] as int;
        _successRate = stats['percentage'] as int;
      });
    } catch (e) {
      debugPrint('Error loading success stats: $e');
    }
  }

  void _initializeScoreController() {
    _scoreController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    _scoreAnimation = Tween<double>(begin: 1, end: 1.5).animate(
      CurvedAnimation(parent: _scoreController, curve: Curves.elasticOut),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: _controller,
      child: Consumer<ExerciseController>(
        builder: (context, controller, child) {
          // Listen for changes in controller state to update stats
          if (controller.lastAnswer.isNotEmpty &&
              controller.isCorrect != null &&
              !controller.showAnswerAnimation) {
            // Update only when a new answer has been processed
            _loadSuccessStats();
          }

          // Base content scaffold
          final Widget content = Scaffold(
            appBar: _buildAppBar(),
            body: SafeArea(
              child: Column(
                children: [
                  _buildModeAndTimerSection(),
                  // show timer only if the timer is enabled
                  if (controller.isTimerEnabled) _buildTimer(),
                  _buildQuestionSection(),
                  _buildFeedbackSection(),
                  _buildKeyboard(),
                ],
              ),
            ),
          );

          // Apply the appropriate animation based on answer status
          if (controller.showAnswerAnimation) {
            if (controller.isCorrect != null) {
              // Use correct answer animation when answer is correct
              if (controller.isCorrect!) {
                return CorrectAnswerAnimation(child: content);
              }
              // Use incorrect answer animation when answer is wrong
              else {
                return IncorrectAnswerAnimation(child: content);
              }
            }

            // Reset animation after a delay
            Future.delayed(const Duration(milliseconds: 2000), () {
              if (mounted) {
                controller.resetAnimation();
              }
            });
          }

          return content;
        },
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      title: Text(
        widget.subject.name,
        style: const TextStyle(fontSize: 18),
      ),
      backgroundColor: widget.subject.color,
      leading: IconButton(
        icon: const Icon(
          Icons.arrow_back,
          color: Colors.white,
        ),
        onPressed: () => Navigator.pop(context),
      ),
      actions: [
        IconButton(
          icon: const Icon(
            Icons.history,
            color: Colors.white,
          ),
          onPressed: () => Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) =>
                    HistoryPage(subjectType: widget.subject.type)),
          ),
        ),
        IconButton(
          icon: const Icon(Icons.settings, color: Colors.white),
          onPressed: () => _navigateToSettings(),
        ),
      ],
    );
  }

  Future<void> _navigateToSettings() async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => SettingsPage(
          subject: widget.subject,
          initialSettings: _controller.settings,
          onSettingsChanged: (settings) {
            _controller.updateSettings(settings);
          },
        ),
      ),
    );
  }

  Widget _buildModeAndTimerSection() {
    return Consumer<ExerciseController>(
      builder: (context, controller, child) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                // Voice mode toggle
                Row(
                  children: [
                    Switch(
                      value: !controller.isKeyboardMode,
                      onChanged: (value) => controller.toggleInputMode(value),
                      activeColor: widget.subject.color,
                    ),
                    const Text('Mode voix'),
                  ],
                ),
                // Timer enable/disable
                Row(
                  children: [
                    Switch(
                      value: controller.isTimerEnabled,
                      onChanged: (value) => controller.toggleTimer(value),
                      activeColor: widget.subject.color,
                    ),
                    const Text('Timer'),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 8),
            // Achievement indicator
            AchievementIndicator(
              score: _successRate,
              color: widget.subject.color,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTimer() {
    return Consumer<ExerciseController>(
      builder: (context, controller, child) {
        Widget timerWidget = const SizedBox.shrink();

        // Show initial countdown
        if (controller.exerciseRemainingTime > 0) {
          timerWidget = Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: CountdownTimer(
              totalSeconds: controller.settings.waitingTime,
              remainingSeconds: controller.exerciseRemainingTime,
            ),
          );
        }
        // Show exercise timer if enabled
        else if (controller.isTimerEnabled &&
            controller.exerciseRemainingTime > 0) {
          timerWidget = Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: Column(
              children: [
                Text(
                  'Temps restant: ${controller.exerciseRemainingTime}s',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: controller.exerciseRemainingTime < 10
                        ? Colors.red
                        : Colors.black,
                  ),
                ),
                const SizedBox(height: 4),
                LinearProgressIndicator(
                  value: controller.exerciseRemainingTime / 30,
                  backgroundColor: Colors.grey.shade300,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    controller.exerciseRemainingTime < 10
                        ? Colors.red
                        : widget.subject.color,
                  ),
                ),
              ],
            ),
          );
        }

        return timerWidget;
      },
    );
  }

  Widget _buildQuestionSection() {
    return Consumer<ExerciseController>(
      builder: (context, controller, child) => Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: Column(
          children: [
            if (controller.currentNumber1 != 0 ||
                controller.currentProblem != null)
              Text(
                _getQuestionText(controller),
                style: TextStyle(
                    fontSize: controller.currentProblem != null ? 16 : 24),
                textAlign: TextAlign.center,
              ),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: controller.startExercise,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                  horizontal: 40,
                  vertical: 10,
                ),
                backgroundColor: widget.subject.color,
              ),
              child: Text(
                controller.isFirstAttempt ? 'Démarrer' : 'Nouvelle question',
                style: TextStyle(
                    fontSize: controller.currentProblem != null ? 16 : 20,
                    color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _getQuestionText(ExerciseController controller) {
    String operationSymbol;

    switch (widget.subject.type) {
      case SubjectType.tables:
      case SubjectType.multiplication:
        operationSymbol = "×";
        break;
      case SubjectType.addition:
        operationSymbol = "+";
        break;
      case SubjectType.soustraction:
        operationSymbol = "-";
        break;
      case SubjectType.division:
        operationSymbol = "÷";
        break;
      case SubjectType.problemes:
        return controller.currentProblem?.text ?? '';
        break;
    }

    return 'Combien font ${controller.currentNumber1} $operationSymbol ${controller.currentNumber2} ?';
  }

  Widget _buildFeedbackSection() {
    return Consumer<ExerciseController>(
      builder: (context, controller, child) => Expanded(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                if (!controller.isKeyboardMode && controller.isListening)
                  _buildListeningIndicator(controller)
                else if (controller.isCorrect != null)
                  _buildAnswerFeedback(controller),
                // if (controller.streak > 0) _buildStreakDisplay(controller),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildListeningIndicator(ExerciseController controller) {
    return Column(
      children: [
        CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(widget.subject.color),
        ),
        const SizedBox(height: 10),
        Text(
          'J\'écoute... (${controller.lastAnswer})',
          style: const TextStyle(
            fontSize: 16,
            fontStyle: FontStyle.italic,
          ),
        ),
      ],
    );
  }

  Widget _buildAnswerFeedback(ExerciseController controller) {
    return Column(
      children: [
        AnimatedContainer(
          duration: const Duration(milliseconds: 500),
          curve: Curves.elasticOut,
          transform: Matrix4.identity()
            ..scale(controller.isCorrect! ? 1.2 : 1.0),
          child: Icon(
            controller.isCorrect! ? Icons.check_circle : Icons.cancel,
            color: controller.isCorrect! ? Colors.green : Colors.red,
            size: 60,
          ),
        ),
        const SizedBox(height: 20),
        Text(
          _getFeedbackText(controller),
          style: TextStyle(
            fontSize: 18,
            color: controller.lastAnswer.isEmpty
                ? Colors.orange
                : controller.isCorrect!
                    ? Colors.green
                    : Colors.red,
          ),
        ),
      ],
    );
  }

  String _getFeedbackText(ExerciseController controller) {
    final correctAnswer = controller.getCorrectAnswer();

    if (controller.lastAnswer.isEmpty) {
      return 'Désolé, la bonne réponse était $correctAnswer !';
    }

    return controller.isCorrect!
        ? 'Génial, La bonne réponse était bien : ${controller.lastAnswer}'
        : 'Désolé, vous avez proposé ${controller.lastAnswer} '
            'mais la bonne réponse était $correctAnswer';
  }

  Widget _buildStreakDisplay(ExerciseController controller) {
    return Padding(
      padding: const EdgeInsets.only(top: 16.0),
      child: Text(
        'Série: ${controller.streak} 🔥',
        style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: Colors.orange,
        ),
      ),
    );
  }

  Widget _buildKeyboard() {
    return Consumer<ExerciseController>(
      builder: (context, controller, child) {
        if (controller.isKeyboardMode && controller.currentNumber1 != 0 ||
            controller.currentProblem != null) {
          return NumberKeyboard(
            currentInput: controller.currentInput,
            onKeyPressed: controller.handleKeyPress,
            onDelete: controller.handleDelete,
            onSubmit: () {
              controller.triggerAnswerCheck();
            },
          );
        }
        return const SizedBox.shrink();
      },
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    _scoreController.dispose();
    super.dispose();
  }
}
