import 'subject.dart';

class ExerciseHistory {
  final int id;
  final int number1;
  final int number2;
  final bool isCorrect;
  final String givenAnswer;
  final DateTime date;
  final SubjectType subjectType; // Nouveau champ

  ExerciseHistory({
    required this.id,
    required this.number1,
    required this.number2,
    required this.isCorrect,
    required this.givenAnswer,
    required this.date,
    required this.subjectType, // Nouveau paramètre
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'number1': number1,
      'number2': number2,
      'isCorrect': isCorrect ? 1 : 0,
      'givenAnswer': givenAnswer,
      'date': date.toIso8601String(),
      'subjectType': subjectType.index, // Sauvegarder l'index de l'enum
    };
  }

  static ExerciseHistory fromMap(Map<String, dynamic> map) {
    return ExerciseHistory(
      id: map['id'],
      number1: map['number1'],
      number2: map['number2'],
      isCorrect: map['isCorrect'] == 1,
      givenAnswer: map['givenAnswer'],
      date: DateTime.parse(map['date']),
      subjectType: map['subjectType'] != null
          ? SubjectType.values[map['subjectType']]
          : SubjectType.tables, // Valeur par défaut pour la rétrocompatibilité
    );
  }

  // Helper pour afficher l'opération
  String getOperationText() {
    switch (subjectType) {
      case SubjectType.tables:
      case SubjectType.multiplication:
        return '$number1 × $number2';
      case SubjectType.addition:
        return '$number1 + $number2';
      case SubjectType.soustraction:
        return '$number1 - $number2';
      case SubjectType.division:
        return '$number1 ÷ $number2';
    }
  }

  // Helper pour calculer la réponse correcte
  int getCorrectAnswer() {
    switch (subjectType) {
      case SubjectType.tables:
      case SubjectType.multiplication:
        return number1 * number2;
      case SubjectType.addition:
        return number1 + number2;
      case SubjectType.soustraction:
        return number1 - number2;
      case SubjectType.division:
        return number1 ~/ number2; // Division entière
    }
  }
}
