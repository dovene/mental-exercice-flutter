
// lib/models/subject.dart
import 'package:flutter/material.dart';

enum SubjectType {
  tables,
  addition,
  soustraction,
  multiplication,
  division
}

class Subject {
  final String name;
  final String description;
  final SubjectType type;
  final IconData icon;
  final String classLevel;
  final Color color;

  Subject({
    required this.name,
    required this.description,
    required this.type,
    required this.icon,
    required this.classLevel,
    required this.color,
  });

  static List<Subject> getAllSubjects() {
    return [
      Subject(
        name: "Tables de multiplication",
        description: "Apprendre les tables de multiplication",
        type: SubjectType.tables,
        icon: Icons.grid_on,
        classLevel: "CE2",
        color: Colors.purple,
      ),
      Subject(
        name: "Addition",
        description: "Apprendre à additionner",
        type: SubjectType.addition,
        icon: Icons.add,
        classLevel: "CP",
        color: Colors.blue,
      ),
      Subject(
        name: "Soustraction",
        description: "Apprendre à soustraire",
        type: SubjectType.soustraction,
        icon: Icons.remove,
        classLevel: "CP",
        color: Colors.red,
      ),
      Subject(
        name: "Multiplication",
        description: "Apprendre à multiplier",
        type: SubjectType.multiplication,
        icon: Icons.close,
        classLevel: "CE1",
        color: Colors.green,
      ),
      Subject(
        name: "Division",
        description: "Apprendre à diviser",
        type: SubjectType.division,
        icon: Icons.border_vertical,
        classLevel: "CM1",
        color: Colors.orange,
      ),
    ];
  }

  static Subject getSubjectByType(SubjectType type) {
    return getAllSubjects().firstWhere((subject) => subject.type == type);
  }
}
