import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/task.dart';


// Includes the necessary CRUD operations for the applicaton
class DBOperations {

  // Setup the table
  static Future<Database> _getDatabase() async {
    final dbPath = await getDatabasesPath();
    return openDatabase(
      join(dbPath, 'tasks.db'),
      version: 2,
      onCreate: (db, version) {
        return db.execute('''
          CREATE TABLE tasks (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            name TEXT NOT NULL,
            dueDate TEXT NOT NULL,
            priority INTEGER NOT NULL,
            locationName TEXT,
            latitude REAL,
            longitude REAL
          )
        ''');
      },

      // Migration-like action, since the location part was added later, seems good practice
      onUpgrade: (db, oldVersion, newVersion) async {
        if (oldVersion < 2) {
          await db.execute('ALTER TABLE tasks ADD COLUMN locationName TEXT');
          await db.execute('ALTER TABLE tasks ADD COLUMN latitude REAL');
          await db.execute('ALTER TABLE tasks ADD COLUMN longitude REAL');
        }
      },
    );
  }

  // Adding a new task
  static Future<int> insertTask(Task task) async {
    final db = await _getDatabase();
    return await db.insert('tasks', task.toMap());
  }

  // Getting all tasks to show on list of show OpenAI
  static Future<List<Task>> getTasks({String sortBy = 'dueDate'}) async {
    final db = await _getDatabase();
    final result = await db.query(
      'tasks',
      orderBy: sortBy,
    );
    return result.map((map) => Task.fromMap(map)).toList();
  }

  // Change an existing task
  static Future<int> updateTask(Task task) async {
    final db = await _getDatabase();
    return await db.update(
      'tasks',
      task.toMap(),
      where: 'id = ?',
      whereArgs: [task.id],
    );
  }

  // Delete a task after swiping
  static Future<int> deleteTask(int id) async {
    final db = await _getDatabase();
    return await db.delete(
      'tasks',
      where: 'id = ?',
      whereArgs: [id],
    );
  }
}