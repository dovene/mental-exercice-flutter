import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:learning/screens/history_page.dart';
import 'package:learning/screens/settings_page.dart';
import 'package:learning/widgets/number_keyboard.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:speech_to_text/speech_to_text.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:audioplayers/audioplayers.dart';
import 'models/exercise_history.dart';
import 'services/database_helper.dart';
import 'services/audio_service.dart';

void main() {
  runApp(const MultiplicationApp());
}

class MultiplicationApp extends StatelessWidget {
  const MultiplicationApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Tables de Multiplication',
      theme: ThemeData(
        primarySwatch: Colors.purple,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      debugShowCheckedModeBanner: false, // Add this line
      home: const HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with TickerProviderStateMixin {
  final SpeechToText _speechToText = SpeechToText();
  final AudioService _audioService = AudioService();
  Timer? _listenTimer;
  Timer? _countdownTimer;
  bool _isListening = false;
  int _selectedTable = 0;
  int _waitingTime = 5;
  String _lastAnswer = '';
  bool? _isCorrect;
  int _currentNumber1 = 0;
  int _currentNumber2 = 0;
  bool _isKeyboardMode = true;
  String _currentInput = '';
  int _remainingTime = 0;

  late AnimationController _scoreController;
  late Animation<double> _scoreAnimation;
  int _score = 0;
  int _streak = 0;

  @override
  void initState() {
    super.initState();
    _initSpeechToText();
    _loadSettings();
    _scoreController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    _scoreAnimation = Tween<double>(begin: 1, end: 1.5).animate(
      CurvedAnimation(parent: _scoreController, curve: Curves.elasticOut),
    );
  }

  @override
  void dispose() {
    _cancelListenTimer();
    _scoreController.dispose();
    super.dispose();
  }

  Future<void> _initSpeechToText() async {
    await _requestPermissions();
    bool available = await _speechToText.initialize(
      debugLogging: true,
      onError: (error) {
        debugPrint("Speech recognition error: ${error.errorMsg}");
        if (error.errorMsg == "error_no_match") {
          setState(() {
            _isListening = false;
            _lastAnswer = ' - Texte non reconnu - ';
            _checkAnswer();
          });
        }
      },
      onStatus: (status) {
        debugPrint("Speech recognition status: $status");
      },
    );
    if (!available) {
      debugPrint("Speech recognition not available.");
    }
  }

  Future<void> _requestPermissions() async {
    await Permission.microphone.request();
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _selectedTable = prefs.getInt('selectedTable') ?? 0;
      _waitingTime = prefs.getInt('waitingTime') ?? 5;
    });
  }

  void _cancelListenTimer() {
    _listenTimer?.cancel();
    _listenTimer = null;
  }

  void _handleKeyPress(String key) {
    if (_currentInput.length < 4) {
      setState(() {
        _currentInput += key;
      });
    }
  }

  void _handleDelete() {
    if (_currentInput.isNotEmpty) {
      setState(() {
        _currentInput = _currentInput.substring(0, _currentInput.length - 1);
      });
    }
  }

  void _checkKeyboardAnswer() {
    setState(() {
      _lastAnswer = _currentInput;
    });
    _checkAnswer();
  }

  void _startTimer() {
    _cancelTimers();
    _remainingTime = _waitingTime;
    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        if (_remainingTime > 0) {
          _remainingTime--;
        } else {
          _cancelTimers();
          if (_isKeyboardMode) {
            _checkKeyboardAnswer();
          } else {
            _stopListening();
            _checkAnswer();
          }
        }
      });
    });
  }

  void _cancelTimers() {
    _countdownTimer?.cancel();
    _listenTimer?.cancel();
  }


  void _startExercise() async {
    _cancelTimers();
    await _audioService.playStart();
    setState(() {
      _isCorrect = null;
      _lastAnswer = '';
      _currentInput = '';
      if (_selectedTable == 0) {
        _currentNumber1 = 2 + (DateTime.now().millisecondsSinceEpoch % 8);
        _currentNumber2 = 1 + (DateTime.now().millisecondsSinceEpoch % 9);
      } else {
        _currentNumber1 = _selectedTable;
        _currentNumber2 = 1 + (DateTime.now().millisecondsSinceEpoch % 9);
      }

      if (_isKeyboardMode) {
        _startTimer();
      } else {
        _startListening();
      }
    });
  }

  void triggerAnswerCheck() {
    _cancelListenTimer();
    _stopListening();
    _checkAnswer();
  }

  void _startListening() async {
    _cancelListenTimer();
    if (!_isListening) {
      setState(() {
        _isListening = true;
        _lastAnswer = '';
        _isCorrect = null;
      });

      try {
        await _speechToText.listen(
          onResult: (result) {
            debugPrint("Speech result: ${result.recognizedWords}");
            setState(() {
              _lastAnswer = result.recognizedWords;
            });

            if (result.finalResult) {
              triggerAnswerCheck();
            }
          },
          listenFor: Duration(seconds: _waitingTime),
          localeId: 'fr_FR',
        );

        _listenTimer = Timer(Duration(seconds: _waitingTime), () {
          if (_isListening) {
            _stopListening();
            _checkAnswer();
          }
        });

      } catch (e) {
        debugPrint("Error during listening: $e");
        setState(() => _isListening = false);
      }
    }
  }

  void _stopListening() {
    _cancelListenTimer();
    if (_isListening) {
      _speechToText.stop();
      setState(() => _isListening = false);
    }
  }

  void _checkAnswer() async {
    if (_lastAnswer.isEmpty) {
      setState(() {
        _isCorrect = false;
        _streak = 0;
        _score = 0;
      });
      await _audioService.playIncorrect();
      return;
    }

    final correctAnswer = _currentNumber1 * _currentNumber2;
    final givenAnswer = int.tryParse(_lastAnswer) ?? -1;
    final isCorrect = givenAnswer == correctAnswer;

    setState(() {
      _isCorrect = isCorrect;
      if (isCorrect) {
        _score += 10 + (_streak * 2);
        _streak++;
        _scoreController.forward(from: 0);
      } else {
        _streak = 0;
        _score = 0;
      }
    });

    if (isCorrect) {
      await _audioService.playCorrect();
    } else {
      await _audioService.playIncorrect();
    }

    await DatabaseHelper.instance.insertExercise(
      ExerciseHistory(
        id: DateTime.now().millisecondsSinceEpoch,
        number1: _currentNumber1,
        number2: _currentNumber2,
        isCorrect: isCorrect,
        givenAnswer: _lastAnswer,
        date: DateTime.now(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mes tables'),
        actions: [
          ScaleTransition(
            scale: _scoreAnimation,
            child: Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Text(
                  '$_score',
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.history),
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const HistoryPage()),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => SettingsPage(
                initialTable: _selectedTable,
                initialTime: _waitingTime,
                onSettingsChanged: (table, time) {
                  setState(() {
                    _selectedTable = table;
                    _waitingTime = time;
                  });
                },
              )),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Top section with mode switch and timer
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                children: [
                  // Mode switch
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Switch(
                        value: !_isKeyboardMode,
                        onChanged: (value) {
                          setState(() {
                            _isKeyboardMode = !value;
                            _cancelTimers();
                            _stopListening();
                            _currentInput = '';
                            _lastAnswer = '';
                            _isCorrect = null;
                          });
                        },
                      ),
                      const Text('Mode voix'),
                    ],
                  ),
                  // Timer display
                  if (_remainingTime > 0)
                    Text(
                      'Temps restant: $_remainingTime s',
                      style: const TextStyle(fontSize: 18),
                    ),
                ],
              ),
            ),

            // Scrollable middle section
            Expanded(
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      if (_currentNumber1 == 0)
                        const Text(
                          'Prêt à réviser les tables ?',
                          style: TextStyle(fontSize: 24),
                        )
                      else
                        Column(
                          children: [
                            Text(
                              'Combien font $_currentNumber1 fois $_currentNumber2 ?',
                              style: const TextStyle(fontSize: 24),
                            ),
                            const SizedBox(height: 20),
                            if (!_isKeyboardMode && _isListening)
                              Column(
                                children: [
                                  const CircularProgressIndicator(),
                                  const SizedBox(height: 10),
                                  Text(
                                    'J\'écoute... ($_lastAnswer)',
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontStyle: FontStyle.italic,
                                    ),
                                  ),
                                ],
                              )
                            else if (_isCorrect != null)
                              AnimatedContainer(
                                duration: const Duration(milliseconds: 500),
                                curve: Curves.elasticOut,
                                transform: Matrix4.identity()
                                  ..scale(_isCorrect! ? 1.2 : 1.0),
                                child: Icon(
                                  _isCorrect! ? Icons.check_circle : Icons.cancel,
                                  color: _isCorrect! ? Colors.green : Colors.red,
                                  size: 60,
                                ),
                              ),
                          ],
                        ),
                      const SizedBox(height: 10),
                      ElevatedButton(
                        onPressed: _startExercise,
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 40,
                            vertical: 20,
                          ),
                          backgroundColor: Colors.blueAccent,
                        ),
                        child: Text(
                          _currentNumber1 == 0 ? 'Démarrer' : 'Nouvelle question',
                          style: const TextStyle(fontSize: 20, color: Colors.white),
                        ),
                      ),
                      const SizedBox(height: 20),
                      if (_isCorrect != null)
                        Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Text(
                            _lastAnswer.isEmpty
                                ? 'Vous n\'avez rien dit...'
                                : _isCorrect!
                                ? 'Parfait la réponse est bien : $_lastAnswer'
                                : 'Non vous avez dit $_lastAnswer mais la réponse correcte est ${_currentNumber1 * _currentNumber2}',
                            style: TextStyle(
                              fontSize: 18,
                              color: _lastAnswer.isEmpty
                                  ? Colors.orange
                                  : _isCorrect!
                                  ? Colors.green
                                  : Colors.red,
                            ),
                          ),
                        ),
                      if (_streak > 0)
                        Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Text(
                            'Série: $_streak 🔥',
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.orange,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ),

            // Bottom keyboard section
            if (_isKeyboardMode && _currentNumber1 != 0)
              NumberKeyboard(
                currentInput: _currentInput,
                onKeyPressed: _handleKeyPress,
                onDelete: _handleDelete,
                onSubmit: () {
                  _cancelTimers();
                  _checkKeyboardAnswer();
                },
              ),
          ],
        ),
      ),
    );
  }
}