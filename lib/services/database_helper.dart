// lib/services/database_helper.dart
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

import '../models/exercise_history.dart';
import '../models/subject.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('math_exercises.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(
      path, 
      version: 2, 
      onCreate: _createDB,
      onUpgrade: _upgradeDB,
    );
  }

  Future _createDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE exercises(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        number1 INTEGER NOT NULL,
        number2 INTEGER NOT NULL,
        isCorrect INTEGER NOT NULL,
        givenAnswer TEXT NOT NULL,
        date TEXT NOT NULL,
        subjectType INTEGER DEFAULT 0
      )
    ''');
  }

  // Pour gérer la migration des données existantes
  Future _upgradeDB(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      // Ajouter la colonne subjectType si elle n'existe pas
      await db.execute('ALTER TABLE exercises ADD COLUMN subjectType INTEGER DEFAULT 0');
    }
  }

  Future<void> insertExercise(ExerciseHistory exercise) async {
    final db = await database;
    await db.insert('exercises', exercise.toMap());
  }

  Future<List<ExerciseHistory>> getHistory({SubjectType? subjectType}) async {
    final db = await database;
    
    String? whereClause;
    List<Object>? whereArgs;
    
    if (subjectType != null) {
      whereClause = 'subjectType = ?';
      whereArgs = [subjectType.index];
    }
    
    final List<Map<String, dynamic>> maps = await db.query(
      'exercises',
      where: whereClause,
      whereArgs: whereArgs,
      orderBy: 'date DESC',
      limit: 50,
    );

    return List.generate(maps.length, (i) => ExerciseHistory.fromMap(maps[i]));
  }

  Future<Map<String, dynamic>> getStats({SubjectType? subjectType}) async {
    final db = await database;
    String? whereClause;
    List<Object>? whereArgs;
    
    if (subjectType != null) {
      whereClause = 'subjectType = ?';
      whereArgs = [subjectType.index];
    }
    
    // Total des exercices
    final total = Sqflite.firstIntValue(await db.rawQuery(
      'SELECT COUNT(*) FROM exercises ${whereClause != null ? 'WHERE $whereClause' : ''}',
      whereArgs,
    )) ?? 0;
    
    // Exercices corrects
    final correct = Sqflite.firstIntValue(await db.rawQuery(
      'SELECT COUNT(*) FROM exercises WHERE isCorrect = 1 ${whereClause != null ? 'AND $whereClause' : ''}',
      whereArgs,
    )) ?? 0;
    
    return {
      'total': total,
      'correct': correct,
      'percentage': total > 0 ? (correct / total * 100).round() : 0,
    };
  }

  Future<void> clearHistory({SubjectType? subjectType}) async {
    final db = await database;
    
    if (subjectType != null) {
      await db.delete(
        'exercises',
        where: 'subjectType = ?',
        whereArgs: [subjectType.index],
      );
    } else {
      await db.delete('exercises');
    }
  }
}