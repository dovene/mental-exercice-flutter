import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:path/path.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../models/exercise_history.dart';
import '../../../models/subject.dart';
import '../../../services/audio_service.dart';
import '../../../services/database_helper.dart';
import '../../../services/speech_service.dart';
import '../../helper/app_constants.dart';
import '../../models/operations_settings.dart';
import '../../services/problem_generator.dart';

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
  double _currentNumber1 = 0;
  double _currentNumber2 = 0;
  bool _isKeyboardMode = true;
  String _currentInput = '';
  bool _isFirstAttempt = true; // Flag to track if it's the first attempt

  int _exerciseRemainingTime = 0; // Timer countdown for exercise
  bool _isTimerEnabled = false; // Flag for timer enable/disable
  bool _isExerciseActive = false; // Flag to track if exercise has started

  int _score = 0;
  int _streak = 0;

  double? _previousNumber1;
  double? _previousNumber2;
  Random _random = Random();

  // Animation control
  bool _showAnswerAnimation = false;
  final bool _useFrenchLocale = AppConstants.useFrenchLocale;

  // Getters
  bool get isListening => _isListening;
  String get lastAnswer => _lastAnswer;
  bool? get isCorrect => _isCorrect;
  double get currentNumber1 => _currentNumber1;
  double get currentNumber2 => _currentNumber2;
  bool get isKeyboardMode => _isKeyboardMode;
  String get currentInput => _currentInput;
  bool get isFirstAttempt => _isFirstAttempt;

  int get exerciseRemainingTime => _exerciseRemainingTime;
  bool get isTimerEnabled => _isTimerEnabled;
  int get score => _score;
  int get streak => _streak;
  OperationSettings get settings => _settings;
  bool get showAnswerAnimation => _showAnswerAnimation;

  final ProblemGenerator _problemGenerator = ProblemGenerator();
  MathProblem? _currentProblem;
  MathProblem? get currentProblem => _currentProblem;
  bool get useFrenchLocale => _useFrenchLocale;

  BuildContext? _currentContext;

  ExerciseController(this.subjectType) {
    _loadSettings();
    _loadScore();
    _loadTimerPreference();
  }

  void setContext(BuildContext context) {
    _currentContext = context;
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    final baseKey = 'settings_${subjectType.toString()}';

    // Check if any settings for this subject exist
    bool hasSettings = false;
    for (String key in prefs.getKeys()) {
      if (key.startsWith('${baseKey}_')) {
        hasSettings = true;
        break;
      }
    }

    if (hasSettings) {
      final Map<String, dynamic> savedSettings = {};
      prefs
          .getKeys()
          .where((key) => key.startsWith('${baseKey}_'))
          .forEach((key) {
        final subKey = key.substring(baseKey.length + 1);

        if (subKey == SettingName.isHardMode.name ||
            subKey == SettingName.simpleMode.name ||
            subKey == SettingName.multiDigitMode.name ||
            subKey == SettingName.decimalMode.name ||
            subKey == SettingName.includeAddition.name ||
            subKey == SettingName.includeSubtraction.name ||
            subKey == SettingName.includeMultiplication.name ||
            subKey == SettingName.includeDivision.name) {
          savedSettings[subKey] = prefs.getBool(key);
        } else if (subKey == SettingName.selectedNumber.name ||
            subKey == SettingName.waitingTime.name) {
          savedSettings[subKey] = prefs.getInt(key);
        }
      });

      if (savedSettings.isNotEmpty) {
        _settings = OperationSettings.fromMap(savedSettings);
        debugPrint(
            'Loaded settings for ${subjectType.toString()}: ${savedSettings.toString()}');
        notifyListeners();
      }
    } else {
      // If no settings exist yet, save default settings
      _saveSettings();
      debugPrint(
          'No settings found for ${subjectType.toString()}, saving defaults');
    }
  }

  // Load timer preference
  Future<void> _loadTimerPreference() async {
    final prefs = await SharedPreferences.getInstance();
    _isTimerEnabled =
        prefs.getBool('timer_enabled_${subjectType.toString()}') ?? false;

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
        debugPrint('Saved bool setting: $prefKey = $value');
      } else if (value is int) {
        prefs.setInt(prefKey, value);
        debugPrint('Saved int setting: $prefKey = $value');
      }
    });

    // Also save a marker key to indicate settings exist for this subject
    //prefs.setBool('${settingsKey}_exists', true);
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
    debugPrint(
        'Settings updated for ${subjectType.toString()}: ${newSettings.toMap().toString()}');
    notifyListeners();
  }

  void toggleInputMode(bool voiceMode, BuildContext context) {
    setContext(context);
    // Only update input mode without initializing speech
    _isKeyboardMode = !voiceMode;

    // if switching to voice mode, check if permissions are not granted and request them
    if (!_isKeyboardMode) {
      // Check if permissions are granted
      _speechService.checkPermission(context).then((granted) {
        if (!granted) {
          _isKeyboardMode = true;
          notifyListeners();
        }
      });
    }

    // If switching to keyboard mode, stop speech recognition
    if (_isKeyboardMode && _isListening) {
      _speechService.stop();
      _isListening = false;
    }

    notifyListeners();
  }

  void startExercise() {
    if (_isFirstAttempt) {
      _isFirstAttempt = false;
    }

    // Cancel any existing timers first
    _exerciseTimer?.cancel();

    // Set active flag to true
    _isExerciseActive = true;

    // Generate new question and start countdown
    if (subjectType == SubjectType.problemes) {
      _generateNewProblem();
    } else {
      _generateNewQuestion();
    }

    _startExerciseTimer();

    // Exercise timer will be started after countdown completes
    notifyListeners();
  }

  void _generateNewQuestion() {
    double num1, num2;

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

  double _generateFirstNumber() {
    // Si un nombre spécifique est sélectionné (pour les tables), l'utiliser
    if (_settings.selectedNumber > 0 &&
        (subjectType == SubjectType.tables ||
            subjectType == SubjectType.multiplication)) {
      return _settings.selectedNumber.toDouble();
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

    // Generate integer or decimal number based on settings
    if (_settings.decimalMode) {
      // Generate decimal number with 1 or 2 decimal places
      double baseNumber = _random.nextInt(maxNum) + 1;
      double decimal = (_random.nextInt(100) / 100); // 0.00 to 0.99
      return double.parse((baseNumber + decimal)
          .toStringAsFixed(2)); // Round to 2 decimal places
    } else {
      return _random.nextInt(maxNum) + 1.0; // Entre 1 et maxNum as double
    }
  }

  double _generateSecondNumber(double firstNumber) {
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
        maxNum =
            48; // Divisions limitées pour obtenir des résultats raisonnables
      }
    } else if (_settings.isHardMode) {
      maxNum = 9999; // Mode difficile
    }

    // For integer operations
    if (!_settings.decimalMode) {
      // Pour les soustractions et divisions, s'assurer que le résultat est positif et entier
      if (subjectType == SubjectType.soustraction) {
        int num2 =
            _random.nextInt(firstNumber.toInt()) + 1; // Entre 1 et firstNumber
        return num2.toDouble();
      } else if (subjectType == SubjectType.division) {
        // Créer une liste de diviseurs possibles
        List<int> divisors = [];
        int intFirst = firstNumber.toInt();
        for (int i = 1; i <= min(intFirst, maxNum); i++) {
          if (intFirst % i == 0) {
            divisors.add(i);
          }
        }

        if (divisors.isEmpty) {
          return 1.0; // Fallback
        }

        return divisors[_random.nextInt(divisors.length)].toDouble();
      } else {
        return (_random.nextInt(maxNum - minNum + 1) + minNum)
            .toDouble(); // Entre minNum et maxNum
      }
    }
    // For decimal operations
    else {
      if (subjectType == SubjectType.soustraction) {
        // Ensure result is positive by making second number smaller than first
        double maxValue =
            firstNumber * 0.9; // Ensure we don't get too close to zero
        return double.parse(
            (_random.nextDouble() * maxValue).toStringAsFixed(2));
      } else if (subjectType == SubjectType.division) {
        // For division, use simpler divisors to get clean results
        List<double> decimalDivisors = [0.5, 1.0, 2.0, 2.5, 4.0, 5.0, 10.0];
        return decimalDivisors[_random.nextInt(decimalDivisors.length)];
      } else {
        // For addition and multiplication
        double baseNumber = _random.nextInt(maxNum) + 1;
        double decimal = (_random.nextInt(100) / 100); // 0.00 to 0.99
        return double.parse((baseNumber + decimal)
            .toStringAsFixed(2)); // Round to 2 decimal places
      }
    }
  }

  // static method to format a double to a string with 2 decimal places if there are decimals without trailing zeros
  static String formatDouble(double value, bool useFrenchLocale) {
    String result;
    if (value == value.toInt()) {
      result = value.toInt().toString();
    } else {
      result = value.toStringAsFixed(2).replaceAll(RegExp(r'\.0+$'), '');
    }

    // Replace decimal point with comma for French locale
    if (useFrenchLocale) {
      result = result.replaceAll('.', ',');
    }

    return result;
  }

  void handleKeyPress(String key) {
    // Handle decimal separators
    if (key == '.' || key == ',') {
      if (!_settings.decimalMode) return; // Decimal not allowed
      if (_currentInput.contains(key)) return; // Separator already present
    }

    // Append key and notify listeners
    _currentInput += key;
    notifyListeners();
  }

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

  Future<void> _startListening() async {
    if (_isListening) return;

    // Get BuildContext from the closest Navigator
    final context = _getNavigatorContext();
    if (context == null) {
      debugPrint("Context not available for speech permissions");
      // Fall back to keyboard mode
      _isKeyboardMode = true;
      notifyListeners();
      return;
    }

    // Try to start listening with permissions handling
    bool success = await _speechService.listen((result) {
      _lastAnswer = result;
      notifyListeners();
    }, context: context);

    // Update UI based on permission status
    if (success) {
      _isListening = true;
      notifyListeners();

      // Arrêter l'écoute après 5 secondes
      _listenTimer = Timer(const Duration(seconds: 10), () {
        _stopListening();
        triggerAnswerCheck();
      });
    } else {
      // Fall back to keyboard mode if permission denied
      _isKeyboardMode = true;
      notifyListeners();
    }
  }

  BuildContext? _getNavigatorContext() {
    // This method needs to be called from a place where context is available
    // For this, you'll need to modify ExercisePage to pass context to controller
    // This is a placeholder that will be filled by the context passed from ExercisePage
    return _currentContext;
  }

  void _stopListening() {
    if (!_isListening) return;

    _isListening = false;
    _speechService.stop();
    _listenTimer?.cancel();

    notifyListeners();
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
        final double userAnswer =
            double.parse(_lastAnswer.replaceAll(',', '.'));
        final double correctAnswer = getCorrectAnswer();

        // For decimal mode, allow small rounding differences
        if (_settings.decimalMode) {
          _isCorrect = (userAnswer - correctAnswer).abs() < 0.01;
        } else {
          _isCorrect = userAnswer == correctAnswer;
        }

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

  double getCorrectAnswer() {
    double result;

    switch (subjectType) {
      case SubjectType.tables:
      case SubjectType.multiplication:
        result = _currentNumber1 * _currentNumber2;
        break;
      case SubjectType.addition:
        result = _currentNumber1 + _currentNumber2;
        break;
      case SubjectType.soustraction:
        // Fix for floating-point precision issues in subtraction
        String num1Str = _currentNumber1.toStringAsFixed(2);
        String num2Str = _currentNumber2.toStringAsFixed(2);
        double n1 = double.parse(num1Str);
        double n2 = double.parse(num2Str);
        result = double.parse((n1 - n2).toStringAsFixed(2));
        break;
      case SubjectType.division:
        // Fix for floating-point precision issues in division
        if (_settings.decimalMode) {
          String num1Str = _currentNumber1.toStringAsFixed(2);
          String num2Str = _currentNumber2.toStringAsFixed(2);
          double n1 = double.parse(num1Str);
          double n2 = double.parse(num2Str);
          result = double.parse((n1 / n2).toStringAsFixed(2));
        } else {
          result = _currentNumber1 / _currentNumber2;
        }
        break;
      case SubjectType.problemes:
        result = _currentProblem?.answer ?? 0;
        break;
    }

    // Ensure we return a clean value without floating point errors
    if (_settings.decimalMode) {
      return double.parse(result.toStringAsFixed(2));
    }
    return result;
  }

  // Format the answer for display based on decimal mode
  String getFormattedAnswer() {
    double answer = getCorrectAnswer();
    if (_settings.decimalMode) {
      // Show up to 2 decimal places for decimal mode
      return answer.toStringAsFixed(2).replaceAll(RegExp(r'\.0+$'), '');
    } else {
      // For integer mode, always display as integer
      return answer.toInt().toString();
    }
  }

  // Add a method to format displayed numbers based on locale
  static String formatNumberForDisplay(String number, bool useFrenchLocale) {
    if (useFrenchLocale) {
      // Replace dots with commas for display in French locale
      return number.replaceAll('.', ',');
    }
    return number;
  }

  Future<void> _saveExerciseHistory() async {
    if (subjectType != SubjectType.problemes &&
        (_currentNumber1 == 0 || _currentNumber2 == 0)) return;

    try {
      final history = ExerciseHistory(
        id: DateTime.now().millisecondsSinceEpoch,
        number1: subjectType == SubjectType.problemes
            ? _currentProblem!.answer
            : _currentNumber1,
        number2: subjectType == SubjectType.problemes ? 0 : _currentNumber2,
        isCorrect: _isCorrect ?? false,
        givenAnswer: _lastAnswer,
        date: DateTime.now(),
        subjectType: subjectType,
        problemText: _currentProblem?.text,
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

  void _generateNewProblem() {
    // Clear previous state
    _currentInput = '';
    _isCorrect = null;
    _lastAnswer = '';
    _showAnswerAnimation = false;

    // Generate a new problem
    if (_settings.isHardMode) {
      // For hard mode, 60% normal problems, 20% train problems, 20% two-step problems
      int problemType = (DateTime.now().millisecondsSinceEpoch % 5);
      if (problemType == 0) {
        _currentProblem = _problemGenerator.generateTrainProblem();
      } else if (problemType == 1) {
        _currentProblem = _problemGenerator.generateTwoStepProblem();
      } else {
        _currentProblem = _problemGenerator.generateProblem(_settings);
      }
    } else {
      _currentProblem = _problemGenerator.generateProblem(_settings);
    }

    notifyListeners();
  }
}
