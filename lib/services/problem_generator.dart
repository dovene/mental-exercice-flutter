import 'dart:math';

import '../models/operations_settings.dart';
import 'dart:math';

import '../models/operations_settings.dart';

class MathProblem {
  final String text;
  final double answer; // Changed from int to double to support decimal answers
  final double num1; // Changed from int to double
  final double num2; // Changed from int to double

  MathProblem({
    required this.text,
    required this.answer,
    required this.num1,
    this.num2 = 0,
  });

  // Helper method to format numbers for display
  String formatNumber(double num) {
    if (num == num.truncate()) {
      return num.toInt().toString();
    } else {
      return num.toStringAsFixed(2)
          .replaceAll(RegExp(r'0+$'), '')
          .replaceAll(RegExp(r'\.$'), '');
    }
  }
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
    {'name': 'litres d\'eau', 'unit': 'L'},
    {'name': 'kilogrammes', 'unit': 'kg'},
    {'name': 'mètres', 'unit': 'm'},
  ];

  // Generate a decimal number with specified range and decimal places
  double _generateDecimalNumber(double min, double max, int decimalPlaces) {
    double value = min + (_random.nextDouble() * (max - min));
    return double.parse(value.toStringAsFixed(decimalPlaces));
  }

  // Format number as string for use in problem text
  String _formatNumberForText(double number, bool isDecimalMode) {
    if (!isDecimalMode || number == number.truncate()) {
      return number.toInt().toString();
    } else {
      return number
          .toStringAsFixed(2)
          .replaceAll(RegExp(r'0+$'), '')
          .replaceAll(RegExp(r'\.$'), '');
    }
  }

  // Generate a random problem based on settings
  MathProblem generateProblem(OperationSettings settings) {
    if (settings.isHardMode) {
      return _generateHardProblem(settings.decimalMode);
    } else {
      return _generateSimpleProblem(settings.decimalMode);
    }
  }

  MathProblem _generateSimpleProblem(bool useDecimals) {
    // Choose a random problem type (0-3)
    int problemType = _random.nextInt(4);

    switch (problemType) {
      case 0:
        return _generateAdditionProblem(false, useDecimals);
      case 1:
        return _generateSubtractionProblem(false, useDecimals);
      case 2:
        return _generateMultiplicationProblem(false, useDecimals);
      case 3:
        return _generateDivisionProblem(false, useDecimals);
      default:
        return _generateAdditionProblem(false, useDecimals);
    }
  }

  MathProblem _generateHardProblem(bool useDecimals) {
    // Choose a random problem type (0-3)
    int problemType = _random.nextInt(4);

    switch (problemType) {
      case 0:
        return _generateAdditionProblem(true, useDecimals);
      case 1:
        return _generateSubtractionProblem(true, useDecimals);
      case 2:
        return _generateMultiplicationProblem(true, useDecimals);
      case 3:
        return _generateDivisionProblem(true, useDecimals);
      default:
        return _generateAdditionProblem(true, useDecimals);
    }
  }

  MathProblem _generateAdditionProblem(bool isHard, bool useDecimals) {
    double num1, num2;

    if (useDecimals) {
      num1 = isHard
          ? _generateDecimalNumber(100.0, 1000.0, 2)
          : _generateDecimalNumber(10.0, 50.0, 1);
      num2 = isHard
          ? _generateDecimalNumber(100.0, 1000.0, 2)
          : _generateDecimalNumber(10.0, 50.0, 1);
    } else {
      num1 = isHard
          ? (_random.nextInt(9000) + 1000).toDouble()
          : (_random.nextInt(90) + 10).toDouble();
      num2 = isHard
          ? (_random.nextInt(9000) + 1000).toDouble()
          : (_random.nextInt(90) + 10).toDouble();
    }

    final double answer = num1 + num2;
    final String name = _names[_random.nextInt(_names.length)];
    final Map<String, dynamic> item = _items[_random.nextInt(_items.length)];

    // Format numbers for text display
    final String num1Text = _formatNumberForText(num1, useDecimals);
    final String num2Text = _formatNumberForText(num2, useDecimals);

    final String text =
        "$name a $num1Text ${item['name']}. Son ami lui donne $num2Text ${item['name']} de plus. Combien $name a-t-il de ${item['name']} maintenant ?";

    return MathProblem(
      text: text,
      answer: answer,
      num1: answer,
    );
  }

  MathProblem _generateSubtractionProblem(bool isHard, bool useDecimals) {
    double answer, total;

    if (useDecimals) {
      answer = isHard
          ? _generateDecimalNumber(100.0, 1000.0, 2)
          : _generateDecimalNumber(10.0, 50.0, 1);

      // Make sure total is larger than answer
      double minAddition = isHard ? 100.0 : 10.0;
      double maxAddition = isHard ? 1000.0 : 50.0;
      double addition =
          _generateDecimalNumber(minAddition, maxAddition, useDecimals ? 2 : 0);

      total = answer + addition;
    } else {
      answer = isHard
          ? (_random.nextInt(9000) + 1000).toDouble()
          : (_random.nextInt(90) + 10).toDouble();

      total = answer +
          (isHard
              ? (_random.nextInt(9000) + 1000).toDouble()
              : (_random.nextInt(90) + 10).toDouble());
    }

    final String name = _names[_random.nextInt(_names.length)];
    final Map<String, dynamic> item = _items[_random.nextInt(_items.length)];

    // Format numbers for text display
    final String totalText = _formatNumberForText(total, useDecimals);
    final String answerText = _formatNumberForText(answer, useDecimals);

    final String text =
        "$name avait $totalText ${item['name']}. Il a donné quelques ${item['name']} à ses amis et maintenant il lui reste $answerText ${item['name']}. Combien de ${item['name']} a-t-il donné ?";

    return MathProblem(
      text: text,
      answer: total - answer,
      num1: total - answer,
    );
  }

  MathProblem _generateMultiplicationProblem(bool isHard, bool useDecimals) {
    double num1, num2;

    if (useDecimals) {
      if (isHard) {
        num1 = _generateDecimalNumber(10.0, 50.0, 1);
        num2 = _generateDecimalNumber(2.0, 10.0, 1);
      } else {
        // For simpler problems, keep one number as integer
        num1 = (_random.nextInt(9) + 2).toDouble();
        num2 = _generateDecimalNumber(1.5, 5.0, 1);
      }
    } else {
      num1 = isHard
          ? (_random.nextInt(90) + 10).toDouble()
          : (_random.nextInt(9) + 2).toDouble();
      num2 = isHard
          ? (_random.nextInt(90) + 10).toDouble()
          : (_random.nextInt(9) + 2).toDouble();
    }

    final double answer = num1 * num2;
    final String name = _names[_random.nextInt(_names.length)];
    final Map<String, dynamic> item = _items[_random.nextInt(_items.length)];

    // Format numbers for text display
    final String num1Text = _formatNumberForText(num1, useDecimals);
    final String num2Text = _formatNumberForText(num2, useDecimals);

    final String text =
        "$name a $num1Text boîtes contenant chacune $num2Text ${item['name']}. Combien de ${item['name']} a-t-il au total ?";

    return MathProblem(
      text: text,
      answer: answer,
      num1: answer,
      num2: 0,
    );
  }

  MathProblem _generateDivisionProblem(bool isHard, bool useDecimals) {
    double divisor, quotient, total;

    if (useDecimals) {
      if (isHard) {
        // For hard problems, generate decimal quotient
        divisor = (_random.nextInt(10) + 2).toDouble();
        quotient = _generateDecimalNumber(10.0, 50.0, 1);
        total = divisor * quotient;
      } else {
        // For simpler problems, use decimals but ensure cleaner results
        List<double> simpleDivisors = [2.0, 4.0, 5.0, 10.0];
        divisor = simpleDivisors[_random.nextInt(simpleDivisors.length)];
        quotient = (_random.nextInt(9) + 2).toDouble();
        total = divisor * quotient;
      }
    } else {
      divisor = isHard
          ? (_random.nextInt(20) + 10).toDouble()
          : (_random.nextInt(8) + 2).toDouble();
      quotient = isHard
          ? (_random.nextInt(90) + 10).toDouble()
          : (_random.nextInt(9) + 2).toDouble();
      total = divisor * quotient;
    }

    final String name = _names[_random.nextInt(_names.length)];
    final Map<String, dynamic> item = _items[_random.nextInt(_items.length)];

    // Format numbers for text display
    final String totalText = _formatNumberForText(total, useDecimals);
    final String divisorText = _formatNumberForText(divisor, useDecimals);

    final String text =
        "$name veut partager ses $totalText ${item['name']} également entre $divisorText amis. Combien de ${item['name']} chaque ami recevra-t-il ?";

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
    final double answer = (initialPassengers + boardingPassengers).toDouble();

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
    final double answer = (intermediate - secondOperation).toDouble();

    final String text =
        "$name avait $initialAmount ${item['name']}. Il a gagné $firstOperation ${item['name']} supplémentaires, puis a dépensé $secondOperation ${item['name']}. Combien de ${item['name']} lui reste-t-il ?";

    return MathProblem(
      text: text,
      answer: answer,
      num1: answer,
    );
  }

  // Decimal-specific problem types
  MathProblem generateDecimalProblem(OperationSettings settings) {
    // Choose problem type based on subject preference
    int problemType = _random.nextInt(4);

    switch (problemType) {
      case 0: // Money problems
        return _generateMoneyProblem(settings.isHardMode);
      case 1: // Measurement problems
        return _generateMeasurementProblem(settings.isHardMode);
      case 2: // Weight problems
        return _generateWeightProblem(settings.isHardMode);
      case 3: // Volume problems
        return _generateLiquidProblem(settings.isHardMode);
      default:
        return _generateMoneyProblem(settings.isHardMode);
    }
  }

  MathProblem _generateMoneyProblem(bool isHard) {
    final String name = _names[_random.nextInt(_names.length)];

    double price1 =
        _generateDecimalNumber(isHard ? 10.0 : 1.0, isHard ? 100.0 : 10.0, 2);
    double price2 =
        _generateDecimalNumber(isHard ? 5.0 : 1.0, isHard ? 50.0 : 5.0, 2);
    double total = price1 + price2;

    final String text =
        "$name achète un livre à ${price1.toStringAsFixed(2)}€ et un cahier à ${price2.toStringAsFixed(2)}€. Combien dépense-t-il au total ?";

    return MathProblem(
      text: text,
      answer: total,
      num1: total,
    );
  }

  MathProblem _generateMeasurementProblem(bool isHard) {
    final String name = _names[_random.nextInt(_names.length)];

    double length1 =
        _generateDecimalNumber(isHard ? 10.0 : 1.0, isHard ? 100.0 : 10.0, 2);
    double length2 =
        _generateDecimalNumber(isHard ? 5.0 : 1.0, isHard ? 50.0 : 5.0, 2);
    double total = length1 + length2;

    final String text =
        "$name mesure une ficelle de ${length1.toStringAsFixed(2)} mètres puis y ajoute un morceau de ${length2.toStringAsFixed(2)} mètres. Quelle est la longueur totale de la ficelle ?";

    return MathProblem(
      text: text,
      answer: total,
      num1: total,
    );
  }

  MathProblem _generateWeightProblem(bool isHard) {
    final String name = _names[_random.nextInt(_names.length)];

    double weight1 =
        _generateDecimalNumber(isHard ? 0.5 : 0.1, isHard ? 5.0 : 1.0, 2);
    double weight2 =
        _generateDecimalNumber(isHard ? 0.3 : 0.1, isHard ? 2.0 : 0.5, 2);
    double total = weight1 + weight2;

    final String text =
        "$name pèse un paquet de ${weight1.toStringAsFixed(2)} kg puis y ajoute un article de ${weight2.toStringAsFixed(2)} kg. Quel est le poids total ?";

    return MathProblem(
      text: text,
      answer: total,
      num1: total,
    );
  }

  MathProblem _generateLiquidProblem(bool isHard) {
    final String name = _names[_random.nextInt(_names.length)];

    double volume1 =
        _generateDecimalNumber(isHard ? 0.5 : 0.25, isHard ? 5.0 : 2.0, 2);
    double volume2 =
        _generateDecimalNumber(isHard ? 0.3 : 0.25, isHard ? 2.0 : 1.0, 2);
    double total = volume1 + volume2;

    final String text =
        "$name a une bouteille contenant ${volume1.toStringAsFixed(2)} litres d'eau. Il y ajoute ${volume2.toStringAsFixed(2)} litres. Quelle quantité d'eau contient la bouteille maintenant ?";

    return MathProblem(
      text: text,
      answer: total,
      num1: total,
    );
  }
}
