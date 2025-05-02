// lib/models/subject.dart
import 'package:flutter/material.dart';

enum SubjectType { tables, addition, soustraction, multiplication, division }

class Subject {
  final String name;
  final String description;
  final SubjectType type;
  final IconData icon;
  final List<String> classLevels;
  final Color color;
  final String? shortName;

  Subject({
    required this.name,
    required this.description,
    required this.type,
    required this.icon,
    required this.classLevels,
    required this.color,
    this.shortName,
  });

  static List<Subject> getAllSubjects() {
    return [
      Subject(
        name: "Tables de multiplication",
        description: "Apprendre les tables de multiplication",
        type: SubjectType.tables,
        icon: Icons.grid_on,
        classLevels: ["CE2", "CM1", "CM2"],
        color: Colors.purple,
        shortName: "Tables",
      ),
      Subject(
        name: "Addition",
        description: "Apprendre à additionner",
        type: SubjectType.addition,
        icon: Icons.add,
        classLevels: ["CP", "CE1", "CE2", "CM1", "CM2"],
        color: Colors.blue,
      ),
      Subject(
        name: "Soustraction",
        description: "Apprendre à soustraire",
        type: SubjectType.soustraction,
        icon: Icons.remove,
        classLevels: ["CP", "CE1", "CE2", "CM1", "CM2"],
        color: Colors.red,
      ),
      Subject(
        name: "Multiplication",
        description: "Apprendre à multiplier",
        type: SubjectType.multiplication,
        icon: Icons.close,
        classLevels: ["CE2", "CM1", "CM2"],
        color: Colors.green,
      ),
      Subject(
        name: "Division",
        description: "Apprendre à diviser",
        type: SubjectType.division,
        icon: Icons.border_vertical,
        classLevels: ["CE2", "CM1", "CM2"],
        color: Colors.orange,
      ),
    ];
  }

  static Subject getSubjectByType(SubjectType type) {
    return getAllSubjects().firstWhere((subject) => subject.type == type);
  }
}
