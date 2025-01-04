import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../widgets/countdown_timer.dart';
import '../widgets/number_keyboard.dart';
import '../widgets/score_display.dart';
import 'history_page.dart';
import 'home_page_controller.dart';
import 'settings_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with TickerProviderStateMixin {
  late HomeController _controller;
  late AnimationController _scoreController;
  late Animation<double> _scoreAnimation;

  @override
  void initState() {
    super.initState();
    _controller = HomeController();
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
      title: const Text('Mes tables'),
      actions: [
        Consumer<HomeController>(
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
                MaterialPageRoute(builder: (context) => const HistoryPage()),
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
          initialTable: _controller.selectedTable,
          initialTime: _controller.waitingTime,
          onSettingsChanged: (table, time, isHardMode) {
            _controller.updateSettings(table, time, isHardMode);
          },
        ),
      ),
    );
  }

  Widget _buildModeSwitch() {
    return Consumer<HomeController>(
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
                ),
                const Text('Mode voix'),
              ],
            ),
          ),
    );
  }

  Widget _buildTimer() {
    return Consumer<HomeController>(
      builder: (context, controller, child) {
        if (controller.remainingTime > 0) {
          return Padding(
            padding: const EdgeInsets.symmetric(
                horizontal: 16.0, vertical: 8.0),
            child: CountdownTimer(
              totalSeconds: controller.waitingTime,
              remainingSeconds: controller.remainingTime,
            ),
          );
        }
        return const SizedBox.shrink();
      },
    );
  }

  Widget _buildQuestionSection() {
    return Consumer<HomeController>(
      builder: (context, controller, child) =>
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Column(
              children: [
                if (controller.currentNumber1 == 0)
                  const Text(
                    'Prêt à réviser les tables ?',
                    style: TextStyle(fontSize: 24),
                  )
                else
                  Text(
                    'Combien font ${controller.currentNumber1} × ${controller
                        .currentNumber2} ?',
                    style: const TextStyle(fontSize: 24),
                  ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: controller.startExercise,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 40,
                      vertical: 10,
                    ),
                    backgroundColor: Colors.blueAccent,
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

  Widget _buildFeedbackSection() {
    return Consumer<HomeController>(
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

  Widget _buildListeningIndicator(HomeController controller) {
    return Column(
      children: [
        const CircularProgressIndicator(),
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

  Widget _buildAnswerFeedback(HomeController controller) {
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

  String _getFeedbackText(HomeController controller) {
    if (controller.lastAnswer.isEmpty) {
      return 'Vous n\'avez rien proposé, la réponse correcte est '
          '${controller.currentNumber1 * controller.currentNumber2}';
    }
    return controller.isCorrect!
        ? 'Parfait, la réponse est bien : ${controller.lastAnswer}'
        : 'Non, vous avez proposé ${controller.lastAnswer} '
        'mais la bonne réponse est '
        '${controller.currentNumber1 * controller.currentNumber2}';
  }

  Widget _buildStreakDisplay(HomeController controller) {
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
    return Consumer<HomeController>(
      builder: (context, controller, child) {
        if (controller.isKeyboardMode && controller.currentNumber1 != 0) {
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