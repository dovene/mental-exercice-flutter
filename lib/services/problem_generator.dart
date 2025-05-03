// lib/services/problem_generator.dart
import 'dart:math';

import '../models/operations_settings.dart';

class MathProblem {
  final String text;
  final int answer;
  final int num1; // Store for history
  final int num2; // Store for history if applicable

  MathProblem({
    required this.text,
    required this.answer,
    required this.num1,
    this.num2 = 0,
  });
}

class ProblemGenerator {
  final Random _random = Random();

  // Cities for contextual problems
  final List<String> _cities = [
    'Paris',
    'Lyon',
    'Marseille',
    'Bordeaux',
    'Lille',
    'Strasbourg',
    'Nice',
    'Nantes',
    'Toulouse',
    'Montpellier',
    'Le Havre',
    'Rennes',
    'Rouen',
    'Grenoble',
    'Dijon'
  ];

  // Names for contextual problems
  final List<String> _names = [
    'Lucas',
    'Emma',
    'Léo',
    'Jade',
    'Hugo',
    'Chloé',
    'Louis',
    'Sarah',
    'Jules',
    'Lina',
    'Thomas',
    'Inès',
    'Raphaël',
    'Léa',
    'Arthur'
  ];

  // Items for problems
  final List<Map<String, dynamic>> _items = [
    {'name': 'billes', 'unit': ''},
    {'name': 'livres', 'unit': ''},
    {'name': 'cahiers', 'unit': ''},
    {'name': 'stylos', 'unit': ''},
    {'name': 'cartes', 'unit': ''},
    {'name': 'bonbons', 'unit': ''},
    {'name': 'euros', 'unit': '€'},
    {'name': 'centimes', 'unit': 'centimes'},
    {'name': 'pommes', 'unit': ''},
    {'name': 'gâteaux', 'unit': ''},
  ];

  // Generate a random problem based on settings
  MathProblem generateProblem(OperationSettings settings) {
    if (settings.isHardMode) {
      return _generateHardProblem();
    } else {
      return _generateSimpleProblem();
    }
  }

  MathProblem _generateSimpleProblem() {
    // Choose a random problem type (0-3)
    int problemType = _random.nextInt(4);

    switch (problemType) {
      case 0:
        return _generateAdditionProblem(false);
      case 1:
        return _generateSubtractionProblem(false);
      case 2:
        return _generateMultiplicationProblem(false);
      case 3:
        return _generateDivisionProblem(false);
      default:
        return _generateAdditionProblem(false);
    }
  }

  MathProblem _generateHardProblem() {
    // Choose a random problem type (0-3)
    int problemType = _random.nextInt(4);

    switch (problemType) {
      case 0:
        return _generateAdditionProblem(true);
      case 1:
        return _generateSubtractionProblem(true);
      case 2:
        return _generateMultiplicationProblem(true);
      case 3:
        return _generateDivisionProblem(true);
      default:
        return _generateAdditionProblem(true);
    }
  }

  MathProblem _generateAdditionProblem(bool isHard) {
    final int num1 =
        isHard ? _random.nextInt(9000) + 1000 : _random.nextInt(90) + 10;
    final int num2 =
        isHard ? _random.nextInt(9000) + 1000 : _random.nextInt(90) + 10;
    final int answer = num1 + num2;

    final String name = _names[_random.nextInt(_names.length)];
    final Map<String, dynamic> item = _items[_random.nextInt(_items.length)];

    final String text =
        "$name a $num1 ${item['name']}. Son ami lui donne $num2 ${item['name']} de plus. Combien $name a-t-il de ${item['name']} maintenant ?";

    return MathProblem(
      text: text,
      answer: answer,
      num1: answer,
    );
  }

  MathProblem _generateSubtractionProblem(bool isHard) {
    final int answer =
        isHard ? _random.nextInt(9000) + 1000 : _random.nextInt(90) + 10;
    final int total = answer +
        (isHard ? _random.nextInt(9000) + 1000 : _random.nextInt(90) + 10);

    final String name = _names[_random.nextInt(_names.length)];
    final Map<String, dynamic> item = _items[_random.nextInt(_items.length)];

    final String text =
        "$name avait $total ${item['name']}. Il a donné quelques ${item['name']} à ses amis et maintenant il lui reste $answer ${item['name']}. Combien de ${item['name']} a-t-il donné ?";

    return MathProblem(
      text: text,
      answer: total - answer,
      num1: total - answer,
    );
  }

  MathProblem _generateMultiplicationProblem(bool isHard) {
    final int num1 = isHard ? _random.nextInt(90) + 10 : _random.nextInt(9) + 2;
    final int num2 = isHard ? _random.nextInt(90) + 10 : _random.nextInt(9) + 2;
    final int answer = num1 * num2;

    final String name = _names[_random.nextInt(_names.length)];
    final Map<String, dynamic> item = _items[_random.nextInt(_items.length)];

    final String text =
        "$name a $num1 boîtes contenant chacune $num2 ${item['name']}. Combien de ${item['name']} a-t-il au total ?";

    return MathProblem(
      text: text,
      answer: answer,
      num1: answer,
      num2: 0,
    );
  }

  MathProblem _generateDivisionProblem(bool isHard) {
    final int divisor =
        isHard ? _random.nextInt(20) + 10 : _random.nextInt(8) + 2;
    final int quotient =
        isHard ? _random.nextInt(90) + 10 : _random.nextInt(9) + 2;
    final int total = divisor * quotient;

    final String name = _names[_random.nextInt(_names.length)];
    final Map<String, dynamic> item = _items[_random.nextInt(_items.length)];

    final String text =
        "$name veut partager ses $total ${item['name']} également entre $divisor amis. Combien de ${item['name']} chaque ami recevra-t-il ?";

    return MathProblem(
      text: text,
      answer: quotient,
      num1: quotient,
    );
  }

  // Special problem types for hard mode
  MathProblem generateTrainProblem() {
    final String departCity = _cities[_random.nextInt(_cities.length)];
    final String arrivalCity = _cities[_random.nextInt(_cities.length)];

    if (departCity == arrivalCity) {
      return generateTrainProblem(); // Recursively try again
    }

    final int initialPassengers = _random.nextInt(1500) + 1000;
    final int boardingPassengers = _random.nextInt(200) + 50;
    final int answer = initialPassengers + boardingPassengers;

    final String midCity = _cities[_random.nextInt(_cities.length)];
    if (midCity == departCity || midCity == arrivalCity) {
      return generateTrainProblem(); // Recursively try again
    }

    final String text =
        "Le train $departCity-$arrivalCity est parti de $departCity avec $initialPassengers personnes. $boardingPassengers personnes sont montées à l'arrêt de $midCity. Combien de personnes compte le train en arrivant à $arrivalCity ?";

    return MathProblem(
      text: text,
      answer: answer,
      num1: answer,
    );
  }

  // Generate a two-step problem for hard mode
  MathProblem generateTwoStepProblem() {
    final String name = _names[_random.nextInt(_names.length)];
    final Map<String, dynamic> item = _items[_random.nextInt(_items.length)];

    final int initialAmount = _random.nextInt(500) + 500;
    final int firstOperation = _random.nextInt(200) + 100;
    final int secondOperation = _random.nextInt(300) + 200;

    final int intermediate = initialAmount + firstOperation;
    final int answer = intermediate - secondOperation;

    final String text =
        "$name avait $initialAmount ${item['name']}. Il a gagné $firstOperation ${item['name']} supplémentaires, puis a dépensé $secondOperation ${item['name']}. Combien de ${item['name']} lui reste-t-il ?";

    return MathProblem(
      text: text,
      answer: answer,
      num1: answer,
    );
  }
}
