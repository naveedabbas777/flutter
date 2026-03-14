import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

import 'task_model.dart';
import 'task_store.dart';

TaskStore createStore() => _SqfliteTaskStore();

class _SqfliteTaskStore implements TaskStore {
  Database? _database;

  @override
  Future<void> init() async {
    final String dbPath = await getDatabasesPath();
    final String path = join(dbPath, 'tasks.db');
    _database = await openDatabase(
      path,
      version: 1,
      onCreate: (Database db, int version) async {
        await db.execute(
          'CREATE TABLE tasks(id INTEGER PRIMARY KEY AUTOINCREMENT, name TEXT, description TEXT)',
        );
      },
    );
  }

  @override
  Future<List<TaskItem>> getTasks() async {
    final Database db = _database!;
    final List<Map<String, dynamic>> rows = await db.query(
      'tasks',
      orderBy: 'id DESC',
    );
    return rows.map(TaskItem.fromJson).toList(growable: false);
  }

  @override
  Future<void> addTask(String name, String description) async {
    final Database db = _database!;
    await db.insert('tasks', {
      'name': name,
      'description': description,
    }, conflictAlgorithm: ConflictAlgorithm.replace);
  }

  @override
  Future<void> updateTask(int id, String name, String description) async {
    final Database db = _database!;
    await db.update(
      'tasks',
      {'name': name, 'description': description},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  @override
  Future<void> deleteTask(int id) async {
    final Database db = _database!;
    await db.delete('tasks', where: 'id = ?', whereArgs: [id]);
  }

  @override
  Future<void> addNotes(int taskId, String notes) async {
    final Database db = _database!;
    await db.update(
      'tasks',
      {'description': notes},
      where: 'id = ?',
      whereArgs: [taskId],
    );
  }

  @override
  Future<void> dispose() async {
    await _database?.close();
    _database = null;
  }
}
