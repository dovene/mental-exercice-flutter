import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../models/exercise_history.dart';
import '../../../models/subject.dart';
import '../../../services/audio_service.dart';
import '../../../services/database_helper.dart';
import '../../../services/speech_service.dart';
import '../../models/operations_settings.dart';

class ExerciseController with ChangeNotifier {
  final AudioService _audioService = AudioService();
  final SpeechService _speechService = SpeechService();
  final SubjectType subjectType;

  Timer? _listenTimer;
  Timer? _exerciseTimer; // Timer for exercise time limit

  bool _isListening = false;
  OperationSettings _settings = OperationSettings();

  String _lastAnswer = '';
  bool? _isCorrect;
  int _currentNumber1 = 0;
  int _currentNumber2 = 0;
  bool _isKeyboardMode = true;
  String _currentInput = '';

  int _exerciseRemainingTime = 0; // Timer countdown for exercise
  bool _isTimerEnabled = true; // Flag for timer enable/disable
  bool _isExerciseActive = false; // Flag to track if exercise has started

  int _score = 0;
  int _streak = 0;

  int? _previousNumber1;
  int? _previousNumber2;
  Random _random = Random();

  // Animation control
  bool _showAnswerAnimation = false;

  // Getters
  bool get isListening => _isListening;
  String get lastAnswer => _lastAnswer;
  bool? get isCorrect => _isCorrect;
  int get currentNumber1 => _currentNumber1;
  int get currentNumber2 => _currentNumber2;
  bool get isKeyboardMode => _isKeyboardMode;
  String get currentInput => _currentInput;

  int get exerciseRemainingTime => _exerciseRemainingTime;
  bool get isTimerEnabled => _isTimerEnabled;
  int get score => _score;
  int get streak => _streak;
  OperationSettings get settings => _settings;
  bool get showAnswerAnimation => _showAnswerAnimation;

  ExerciseController(this.subjectType) {
    _loadSettings();
    _loadScore();
    _loadTimerPreference();
    _speechService.initialize();
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    final settingsKey = 'settings_${subjectType.toString()}';

    if (prefs.containsKey(settingsKey)) {
      final Map<String, dynamic> savedSettings = {};
      prefs
          .getKeys()
          .where((key) => key.startsWith(settingsKey))
          .forEach((key) {
        final subKey = key.substring(settingsKey.length + 1);

        if (subKey == 'isHardMode' ||
            subKey == 'simpleMode' ||
            subKey == 'multiDigitMode' ||
            subKey == 'decimalMode') {
          savedSettings[subKey] = prefs.getBool(key);
        } else {
          savedSettings[subKey] = prefs.getInt(key);
        }
      });

      if (savedSettings.isNotEmpty) {
        _settings = OperationSettings.fromMap(savedSettings);
        notifyListeners();
      }
    }
  }

  // Load timer preference
  Future<void> _loadTimerPreference() async {
    final prefs = await SharedPreferences.getInstance();
    _isTimerEnabled =
        prefs.getBool('timer_enabled_${subjectType.toString()}') ?? true;

    notifyListeners();
  }

  // Save timer preference
  Future<void> _saveTimerPreference() async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setBool('timer_enabled_${subjectType.toString()}', _isTimerEnabled);
  }

  // Toggle timer enabled/disabled
  void toggleTimer(bool enabled) {
    _isTimerEnabled = enabled;
    _saveTimerPreference();

    // If disabling while exercise is in progress, cancel the timer
    if (!enabled && _exerciseTimer != null) {
      _exerciseTimer?.cancel();
      _exerciseRemainingTime = 0;
    } else if (enabled && _isExerciseActive) {
      // Restart exercise timer if enabling during active exercise
      _startExerciseTimer();
    }

    notifyListeners();
  }

  Future<void> _saveSettings() async {
    final prefs = await SharedPreferences.getInstance();
    final settingsKey = 'settings_${subjectType.toString()}';

    final map = _settings.toMap();
    map.forEach((key, value) {
      final prefKey = '${settingsKey}_$key';

      if (value is bool) {
        prefs.setBool(prefKey, value);
      } else if (value is int) {
        prefs.setInt(prefKey, value);
      }
    });
  }

  Future<void> _loadScore() async {
    try {
      final stats =
          await DatabaseHelper.instance.getStats(subjectType: subjectType);
      _score = stats['percentage'] as int;
      notifyListeners();
    } catch (e) {
      debugPrint('Error loading score: $e');
    }
  }

  void updateSettings(OperationSettings newSettings) {
    _settings = newSettings;
    _saveSettings();
    notifyListeners();
  }

  void toggleInputMode(bool voiceMode) {
    _isKeyboardMode = !voiceMode;
    notifyListeners();
  }

  void startExercise() {
    // Cancel any existing timers first
    _exerciseTimer?.cancel();

    // Set active flag to true
    _isExerciseActive = true;

    // Generate new question and start countdown
    _generateNewQuestion();
    _startExerciseTimer();

    // Exercise timer will be started after countdown completes
    notifyListeners();
  }

  void _generateNewQuestion() {
    int num1, num2;

    // S'assurer que la nouvelle question est différente de la précédente
    do {
      num1 = _generateFirstNumber();
      num2 = _generateSecondNumber(num1);
    } while (_previousNumber1 == num1 && _previousNumber2 == num2);

    _previousNumber1 = _currentNumber1;
    _previousNumber2 = _currentNumber2;

    _currentNumber1 = num1;
    _currentNumber2 = num2;
    _currentInput = '';
    _isCorrect = null;
    _lastAnswer = '';
    _showAnswerAnimation = false;

    notifyListeners();
  }

  int _generateFirstNumber() {
    // Si un nombre spécifique est sélectionné (pour les tables), l'utiliser
    if (_settings.selectedNumber > 0 &&
        (subjectType == SubjectType.tables ||
            subjectType == SubjectType.multiplication)) {
      return _settings.selectedNumber;
    }

    // Sinon, générer un nombre selon les paramètres
    int maxNum = 10;

    if (_settings.multiDigitMode) {
      if (subjectType == SubjectType.addition ||
          subjectType == SubjectType.soustraction) {
        maxNum = 9999; // Additions/soustractions à plusieurs chiffres
      } else {
        maxNum = 9999; // Multiplications/divisions à plusieurs chiffres
      }
    } else if (_settings.isHardMode) {
      maxNum = 9999; // Mode difficile avec des nombres plus grands
    }

    return _random.nextInt(maxNum) + 1; // Entre 1 et maxNum
  }

  int _generateSecondNumber(int firstNumber) {
    int maxNum = 10;
    int minNum = 1;

    // Ajuster selon le mode et le type d'opération
    if (_settings.multiDigitMode) {
      if (subjectType == SubjectType.addition ||
          subjectType == SubjectType.soustraction) {
        maxNum = 9999; // Additions/soustractions à plusieurs chiffres
      } else if (subjectType == SubjectType.multiplication) {
        maxNum = 9999; // Multiplications à plusieurs chiffres
      } else if (subjectType == SubjectType.division) {
        maxNum = 48; // Divisions limitées pour obtenir des résultats entiers
      }
    } else if (_settings.isHardMode) {
      maxNum = 9999; // Mode difficile
    }

    // Pour les soustractions et divisions, s'assurer que le résultat est positif et entier
    if (subjectType == SubjectType.soustraction) {
      int num2 = _random.nextInt(firstNumber) + 1; // Entre 1 et firstNumber
      return num2;
    } else if (subjectType == SubjectType.division) {
      // Créer une liste de diviseurs possibles
      List<int> divisors = [];
      for (int i = 1; i <= min(firstNumber, maxNum); i++) {
        if (firstNumber % i == 0) {
          divisors.add(i);
        }
      }

      if (divisors.isEmpty) {
        return 1; // Fallback
      }

      return divisors[_random.nextInt(divisors.length)];
    } else {
      return _random.nextInt(maxNum - minNum + 1) +
          minNum; // Entre minNum et maxNum
    }
  }

  /*void _startCountdown() {
    _exerciseRemainingTime = _settings.waitingTime;

    _exerciseTimer?.cancel();
    _exerciseTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      _exerciseRemainingTime--;

      if (_exerciseRemainingTime <= 0) {
        timer.cancel();

        // When countdown completes, start the exercise timer
        if (_isTimerEnabled) {
          _startExerciseTimer();
        }

        if (!_isKeyboardMode) {
          // Lancer la reconnaissance vocale en mode voix
          _startListening();
        }
      }

      notifyListeners();
    });
  }*/

  // Start the exercise timer
  void _startExerciseTimer() {
    // Cancel any existing timer
    _exerciseTimer?.cancel();

    // Set the initial time (30 seconds for the exercise)
    _exerciseRemainingTime = _settings.waitingTime;

    if (!_isKeyboardMode) {
      // Lancer la reconnaissance vocale en mode voix
      _startListening();
    }

    // Only start the timer if it's enabled
    if (_isTimerEnabled) {
      _exerciseTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
        if (_exerciseRemainingTime <= 0) {
          timer.cancel();
          // Time's up - record "Pas de réponse" if no answer given
          if (_isCorrect == null) {
            _lastAnswer = "";
            _isCorrect = false;
            _saveExerciseHistory();
            _showAnswerAnimation = true;
            notifyListeners();
          }
        } else {
          _exerciseRemainingTime--;
          notifyListeners();
        }
      });
    }
  }

  void _startListening() {
    if (_isListening) return;

    _isListening = true;
    notifyListeners();

    _speechService.listen((result) {
      _lastAnswer = result;
      notifyListeners();
    });

    // Arrêter l'écoute après 5 secondes
    _listenTimer = Timer(const Duration(seconds: 5), () {
      _stopListening();
      triggerAnswerCheck();
    });
  }

  void _stopListening() {
    if (!_isListening) return;

    _isListening = false;
    _speechService.stop();
    _listenTimer?.cancel();

    notifyListeners();
  }

  void handleKeyPress(String key) {
    if (_currentInput.length < 5) {
      // Limiter à 5 chiffres maximum
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

  void triggerAnswerCheck() {
    if (_isKeyboardMode) {
      _lastAnswer = _currentInput;
    } else {
      _stopListening();
    }

    _checkAnswer();
  }

  void _checkAnswer() {
    if (_lastAnswer.isEmpty) {
      _isCorrect = false;
      _streak = 0; // Réinitialiser la série
    } else {
      try {
        final int userAnswer = int.parse(_lastAnswer);
        final int correctAnswer = getCorrectAnswer();

        _isCorrect = userAnswer == correctAnswer;

        if (_isCorrect!) {
          _streak++;
          // if is not keyboard mode, play sound
          if (!_isKeyboardMode) {
            _audioService.playCorrectSound();
          }
        } else {
          _streak = 0; // Réinitialiser la série
          // if is not keyboard mode, play sound
          if (!_isKeyboardMode) {
            _audioService.playErrorSound();
          }
        }
      } catch (e) {
        // En cas d'erreur de parsing de la réponse
        _isCorrect = false;
        _streak = 0;
      }
    }

    // Cancel exercise timer when answer is submitted
    _exerciseTimer?.cancel();

    // Trigger animation
    _showAnswerAnimation = true;

    // Sauvegarder l'historique
    _saveExerciseHistory();

    notifyListeners();
  }

  int getCorrectAnswer() {
    switch (subjectType) {
      case SubjectType.tables:
      case SubjectType.multiplication:
        return _currentNumber1 * _currentNumber2;
      case SubjectType.addition:
        return _currentNumber1 + _currentNumber2;
      case SubjectType.soustraction:
        return _currentNumber1 - _currentNumber2;
      case SubjectType.division:
        return _currentNumber1 ~/ _currentNumber2; // Division entière
    }
  }

  Future<void> _saveExerciseHistory() async {
    if (_currentNumber1 == 0 || _currentNumber2 == 0) return;

    try {
      final history = ExerciseHistory(
        id: DateTime.now().millisecondsSinceEpoch,
        number1: _currentNumber1,
        number2: _currentNumber2,
        isCorrect: _isCorrect ?? false,
        givenAnswer: _lastAnswer,
        date: DateTime.now(),
        subjectType: subjectType,
      );

      await DatabaseHelper.instance.insertExercise(history);
      _loadScore(); // Recharger le score après ajout d'un exercice
    } catch (e) {
      debugPrint('Error saving exercise history: $e');
    }
  }

  // Method to reset the animation state and prepare for next question
  void resetAnimation() {
    _showAnswerAnimation = false;
    notifyListeners();
  }

  @override
  void dispose() {
    _listenTimer?.cancel();
    _exerciseTimer?.cancel();
    _speechService.dispose();
    super.dispose();
  }
}
