import 'subject.dart';

class ExerciseHistory {
  final int id;
  final int number1;
  final int number2;
  final bool isCorrect;
  final String givenAnswer;
  final DateTime date;
  final SubjectType subjectType;
  final String? problemText;

  ExerciseHistory({
    required this.id,
    required this.number1,
    required this.number2,
    required this.isCorrect,
    required this.givenAnswer,
    required this.date,
    required this.subjectType,
    this.problemText, // Optional for non-problem exercises
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'number1': number1,
      'number2': number2,
      'isCorrect': isCorrect ? 1 : 0,
      'givenAnswer': givenAnswer,
      'date': date.toIso8601String(),
      'subjectType': subjectType.index,
      'problemText': problemText, // Store problem text if present
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
          : SubjectType.tables, // Default value for backward compatibility
      problemText: map['problemText'], // Load problem text if present
    );
  }

  // Helper for displaying the operation
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
      case SubjectType.problemes:
        return problemText ?? "Problème";
    }
  }

  // Helper for calculating the correct answer
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
        return number1 ~/ number2; // Integer division
      case SubjectType.problemes:
        return number1; // For problems, we store the answer in number1
    }
  }
}
