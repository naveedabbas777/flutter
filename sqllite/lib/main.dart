import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  Database? _database;
  List<Map<String, dynamic>> users = [];

  @override
  void initState() {
    super.initState();
    _initDatabase();
  }

  Future<void> _initDatabase() async {
    String path = join(await getDatabasesPath(), 'users.db');
    _database = await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) {
        db.execute('''
          CREATE TABLE users (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            name TEXT,
            age INTEGER
          )
        ''');
      },
    );
    _loadUsers();
  }

  Future<void> _addUser() async {
    await _database?.insert('users', {'name': 'John Doe', 'age': 25});
    _loadUsers();
  }

  Future<void> _updateUser(int id) async {
    await _database?.update(
      'users',
      {'name': 'Updated Name', 'age': 30},
      where: 'id = ?',
      whereArgs: [id],
    );
    _loadUsers();
  }

  Future<void> _deleteUser(int id) async {
    await _database?.delete('users', where: 'id = ?', whereArgs: [id]);
    _loadUsers();
  }

  Future<void> _loadUsers() async {
    List<Map<String, dynamic>> data = await _database?.query('users') ?? [];
    setState(() {
      users = data;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(title: Text("SQLite CRUD Example")),
        body: Column(
          children: [
            ElevatedButton(onPressed: _addUser, child: Text("Add User")),
            Expanded(
              child: ListView.builder(
                itemCount: users.length,
                itemBuilder: (context, index) {
                  return ListTile(
                    title: Text(users[index]['name']),
                    subtitle: Text("Age: ${users[index]['age']}"),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: Icon(Icons.edit),
                          onPressed: () => _updateUser(users[index]['id']),
                        ),
                        IconButton(
                          icon: Icon(Icons.delete),
                          onPressed: () => _deleteUser(users[index]['id']),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
