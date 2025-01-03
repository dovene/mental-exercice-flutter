class ExerciseHistory {
  final int id;
  final int number1;
  final int number2;
  final bool isCorrect;
  final String givenAnswer;
  final DateTime date;

  ExerciseHistory({
    required this.id,
    required this.number1,
    required this.number2,
    required this.isCorrect,
    required this.givenAnswer,
    required this.date,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'number1': number1,
      'number2': number2,
      'isCorrect': isCorrect ? 1 : 0,
      'givenAnswer': givenAnswer,
      'date': date.toIso8601String(),
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
    );
  }
}