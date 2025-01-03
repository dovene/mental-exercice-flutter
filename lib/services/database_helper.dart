import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

import '../models/exercise_history.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('multiplication_history.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(path, version: 1, onCreate: _createDB);
  }

  Future _createDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE exercises(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        number1 INTEGER NOT NULL,
        number2 INTEGER NOT NULL,
        isCorrect INTEGER NOT NULL,
        givenAnswer TEXT NOT NULL,
        date TEXT NOT NULL
      )
    ''');
  }

  Future<void> insertExercise(ExerciseHistory exercise) async {
    final db = await database;
    await db.insert('exercises', exercise.toMap());
  }

  Future<List<ExerciseHistory>> getHistory() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'exercises',
      orderBy: 'date DESC',
      limit: 50,
    );

    return List.generate(maps.length, (i) => ExerciseHistory.fromMap(maps[i]));
  }

  Future<void> clearHistory() async {
    final db = await database;
    await db.delete('exercises');
  }
}