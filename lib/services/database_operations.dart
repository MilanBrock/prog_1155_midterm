import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/task.dart';

class DBOperations {
  static Future<Database> _getDatabase() async {
    final dbPath = await getDatabasesPath();
    return openDatabase(
      join(dbPath, 'tasks.db'),
      version: 1,
      onCreate: (db, version) {
        return db.execute(
          '''
          CREATE TABLE tasks (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            name TEXT NOT NULL,
            dueDate TEXT NOT NULL,
            priority TEXT NOT NULL
          )
          ''',
        );
      },
    );
  }

  static Future<int> insertTask(Task task) async {
    final db = await _getDatabase();
    return await db.insert('tasks', task.toMap());
  }

  static Future<List<Task>> getTasks({String sortBy = 'dueDate'}) async {
    final db = await _getDatabase();
    final result = await db.query(
      'tasks',
      orderBy: sortBy,
    );
    return result.map((map) => Task.fromMap(map)).toList();
  }

  static Future<int> updateTask(Task task) async {
    final db = await _getDatabase();
    return await db.update(
      'tasks',
      task.toMap(),
      where: 'id = ?',
      whereArgs: [task.id],
    );
  }

  static Future<int> deleteTask(int id) async {
    final db = await _getDatabase();
    return await db.delete(
      'tasks',
      where: 'id = ?',
      whereArgs: [id],
    );
  }
}
