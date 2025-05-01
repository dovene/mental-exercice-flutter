// home_controller.dart
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/exercise_history.dart';
import '../services/audio_service.dart';
import '../services/database_helper.dart';
import '../services/speech_service.dart';

class HomeController with ChangeNotifier {
  final AudioService _audioService = AudioService();
  final SpeechService _speechService;
  Timer? _listenTimer;
  Timer? _countdownTimer;

  bool _isListening = false;
  int _selectedTable = 0;
  int _waitingTime = 5;
  bool _isHardMode = false;

  String _lastAnswer = '';
  bool? _isCorrect;
  int _currentNumber1 = 0;
  int _currentNumber2 = 0;
  bool _isKeyboardMode = true;
  String _currentInput = '';
  int _remainingTime = 0;

  int _score = 0;
  int _streak = 0;

  int? _previousNumber1;
  int? _previousNumber2;

  // Getters
  bool get isListening => _isListening;
  int get selectedTable => _selectedTable;
  int get waitingTime => _waitingTime;
  bool get isHardMode => _isHardMode;
  String get lastAnswer => _lastAnswer;
  bool? get isCorrect => _isCorrect;
  int get currentNumber1 => _currentNumber1;
  int get currentNumber2 => _currentNumber2;
  bool get isKeyboardMode => _isKeyboardMode;
  String get currentInput => _currentInput;
  int get remainingTime => _remainingTime;
  int get score => _score;
  int get streak => _streak;

  HomeController() : _speechService = SpeechService() {
    _init();
  }

  void _init() async {
    await _speechService.init();
    await _loadSettings();
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    _selectedTable = prefs.getInt('selectedTable') ?? 0;
    _waitingTime = prefs.getInt('waitingTime') ?? 5;
    _isHardMode = prefs.getBool('isHardMode') ?? false;
    notifyListeners();
  }

  void updateSettings(int table, int time, bool hardMode) {
    _selectedTable = table;
    _waitingTime = time;
    _isHardMode = hardMode;
    notifyListeners();
  }

  void toggleInputMode(bool useVoice) {
    _isKeyboardMode = !useVoice;
    _cancelTimers();
    if (!_isKeyboardMode) {
      _speechService.stopListening();
    }
    _currentInput = '';
    _lastAnswer = '';
    _isCorrect = null;
    notifyListeners();
  }

  void handleKeyPress(String key) {
    if (_currentInput.length < 4) {
      _currentInput += key;
      notifyListeners();
    }
  }

  void handleDelete() {
    if (_currentInput.isNotEmpty) {
      _currentInput = _currentInput.substring(0, _currentInput.length - 1);
      notifyListeners();
    }
  }

  void _startTimer() {
    _cancelTimers();
    _remainingTime = _waitingTime;
    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_remainingTime > 0) {
        _remainingTime--;
        notifyListeners();
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
  }

  void _cancelTimers() {
    _countdownTimer?.cancel();
    _listenTimer?.cancel();
  }

  Future<void> startExercise() async {
    _cancelTimers();
    _audioService.playStart();

    _isCorrect = null;
    _lastAnswer = '';
    _currentInput = '';

    int newNumber1;
    int newNumber2;

    do {
      if (_selectedTable == 0) {
        if (_isHardMode) {
          newNumber1 = 4 + (DateTime.now().millisecondsSinceEpoch % 6);
          newNumber2 = 4 + (DateTime.now().millisecondsSinceEpoch % 6);
        } else {
          newNumber1 = 2 + (DateTime.now().millisecondsSinceEpoch % 8);
          newNumber2 = 2 + (DateTime.now().millisecondsSinceEpoch % 8);
        }
      } else {
        newNumber1 = _selectedTable;
        if (_isHardMode) {
          newNumber2 = 4 + (DateTime.now().millisecondsSinceEpoch % 6);
        } else {
          newNumber2 = 2 + (DateTime.now().millisecondsSinceEpoch % 8);
        }
      }
    } while (newNumber1 == _previousNumber1 && newNumber2 == _previousNumber2);

    _currentNumber1 = newNumber1;
    _currentNumber2 = newNumber2;
    _previousNumber1 = newNumber1;
    _previousNumber2 = newNumber2;

    if (_isKeyboardMode) {
      _startTimer();
    } else {
      _startListening();
    }

    notifyListeners();
  }

  void _startListening() {
    _cancelTimers();
    _remainingTime = _waitingTime;
    _startTimer();
    _isListening = true;  // Add this line

    _speechService.startListening(
      onResult: (recognizedWords) {
        if (recognizedWords.isNotEmpty) {  // Only update if we got actual words
          _lastAnswer = recognizedWords;
          notifyListeners();
        }
      },
      onFinalResult: triggerAnswerCheck,
      listenDuration: _waitingTime,
    );
  }

  void triggerAnswerCheck() {
    _speechService.stopListening();
    if (_lastAnswer.isNotEmpty) {  // Only check if we have an answer
      _checkAnswer();
    }
  }

  void _stopListening() {
    _cancelTimers();
    _speechService.stopListening();
    _remainingTime = 0;
    _isListening = false;
    notifyListeners();
  }

// In HomeController
  void _checkKeyboardAnswer() {
    // Immediately capture the input and clear it
    final answer = _currentInput;
    _currentInput = '';

    if (answer.isEmpty) {
      _lastAnswer = '';
      _isCorrect = false;
      notifyListeners();
      return;
    }

    _lastAnswer = answer;
    // Call _checkAnswer without awaiting to start the process immediately
    _checkAnswer();
    // Notify listeners right away for the UI update
    notifyListeners();
  }

  Future<void> _checkAnswer() async {
    final correctAnswer = _currentNumber1 * _currentNumber2;
    final givenAnswer = int.tryParse(_lastAnswer) ?? -1;
    final isCorrect = givenAnswer == correctAnswer;

    _isCorrect = isCorrect;

    if (isCorrect) {
      _score += 10 + (_streak * 2);
      _streak++;
      // Don't await these operations
      _audioService.playCorrect();
    } else {
      _streak = 0;
      _score = 0;
      _audioService.playIncorrect();
    }
    notifyListeners();

    // Don't await the database operation
    DatabaseHelper.instance.insertExercise(
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
  void dispose() {
    _speechService.dispose();
    _cancelTimers();
    super.dispose();
  }
}