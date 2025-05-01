// lib/screens/exercise_page.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/subject.dart';
import '../widgets/countdown_timer.dart';
import '../widgets/number_keyboard.dart';
import '../widgets/score_display.dart';
import 'controllers/exercise_controller.dart';
import 'history_page.dart';
import 'settings_page.dart';

class ExercisePage extends StatefulWidget {
  final Subject subject;

  const ExercisePage({Key? key, required this.subject}) : super(key: key);

  @override
  _ExercisePageState createState() => _ExercisePageState();
}

class _ExercisePageState extends State<ExercisePage> with TickerProviderStateMixin {
  late ExerciseController _controller;
  late AnimationController _scoreController;
  late Animation<double> _scoreAnimation;

  @override
  void initState() {
    super.initState();
    _controller = ExerciseController(widget.subject.type);
    _initializeScoreController();
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
      child: Scaffold(
        appBar: _buildAppBar(),
        body: SafeArea(
          child: Column(
            children: [
              _buildModeSwitch(),
              _buildTimer(),
              _buildQuestionSection(),
              _buildFeedbackSection(),
              _buildKeyboard(),
            ],
          ),
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      title: Text(widget.subject.name),
      backgroundColor: widget.subject.color,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back),
        onPressed: () => Navigator.pop(context),
      ),
      actions: [
        Consumer<ExerciseController>(
          builder: (context, controller, child) =>
              ScoreDisplay(
                score: controller.score,
                animation: _scoreAnimation,
              ),
        ),
        IconButton(
          icon: const Icon(Icons.history),
          onPressed: () =>
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => HistoryPage(subjectType: widget.subject.type)),
              ),
        ),
        IconButton(
          icon: const Icon(Icons.settings),
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

  Widget _buildModeSwitch() {
    return Consumer<ExerciseController>(
      builder: (context, controller, child) =>
          Padding(
            padding: const EdgeInsets.symmetric(
                vertical: 8.0, horizontal: 16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Switch(
                  value: !controller.isKeyboardMode,
                  onChanged: (value) => controller.toggleInputMode(value),
                  activeColor: widget.subject.color,
                ),
                const Text('Mode voix'),
              ],
            ),
          ),
    );
  }

  Widget _buildTimer() {
    return Consumer<ExerciseController>(
      builder: (context, controller, child) {
        if (controller.remainingTime > 0) {
          return Padding(
            padding: const EdgeInsets.symmetric(
                horizontal: 16.0, vertical: 8.0),
            child: CountdownTimer(
              totalSeconds: controller.settings.waitingTime,
              remainingSeconds: controller.remainingTime,
             // color: widget.subject.color,
            ),
          );
        }
        return const SizedBox.shrink();
      },
    );
  }

  Widget _buildQuestionSection() {
    return Consumer<ExerciseController>(
      builder: (context, controller, child) =>
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Column(
              children: [
                if (controller.currentNumber1 == 0)
                  Text(
                    'Prêt à t\'exercer sur ${widget.subject.name} ?',
                    style: const TextStyle(fontSize: 24),
                    textAlign: TextAlign.center,
                  )
                else
                  Text(
                    _getQuestionText(controller),
                    style: const TextStyle(fontSize: 24),
                    textAlign: TextAlign.center,
                  ),
                const SizedBox(height: 20),
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
                    controller.currentNumber1 == 0
                        ? 'Démarrer'
                        : 'Nouvelle question',
                    style: const TextStyle(fontSize: 20, color: Colors.white),
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
    }
    
    return 'Combien font ${controller.currentNumber1} $operationSymbol ${controller.currentNumber2} ?';
  }

  Widget _buildFeedbackSection() {
    return Consumer<ExerciseController>(
      builder: (context, controller, child) =>
          Expanded(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    if (!controller.isKeyboardMode && controller.isListening)
                      _buildListeningIndicator(controller)
                    else
                      if (controller.isCorrect != null)
                        _buildAnswerFeedback(controller),
                    if (controller.streak > 0)
                      _buildStreakDisplay(controller),
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
      return 'Vous n\'avez rien proposé, la réponse correcte est $correctAnswer';
    }
    
    return controller.isCorrect!
        ? 'Parfait, la réponse est bien : ${controller.lastAnswer}'
        : 'Non, vous avez proposé ${controller.lastAnswer} '
          'mais la bonne réponse est $correctAnswer';
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
        if (controller.isKeyboardMode && controller.currentNumber1 != 0) {
          return NumberKeyboard(
            currentInput: controller.currentInput,
            onKeyPressed: controller.handleKeyPress,
            onDelete: controller.handleDelete,
            onSubmit: () {
              controller.triggerAnswerCheck();
            },
           // color: widget.subject.color,
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