import 'package:flutter/foundation.dart';
import 'package:path/path.dart' as p;
import 'package:sqflite/sqflite.dart';
import 'package:sqflite_common_ffi_web/sqflite_ffi_web.dart';

class DatabaseHelper {
  DatabaseHelper._internal();

  static final DatabaseHelper instance = DatabaseHelper._internal();
  static Database? _database;

  Future<Database> get database async {
    if (_database != null) {
      return _database!;
    }
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final dbFactory = kIsWeb ? databaseFactoryFfiWeb : databaseFactory;
    final path = kIsWeb
        ? 'committee_management.db'
        : p.join(await getDatabasesPath(), 'committee_management.db');

    return dbFactory.openDatabase(
      path,
      options: OpenDatabaseOptions(
        version: 1,
        onConfigure: (db) async {
          await db.execute('PRAGMA foreign_keys = ON');
        },
        onCreate: _onCreate,
      ),
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE clients (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        phone TEXT,
        company TEXT,
        created_at TEXT NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE committees (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        client_id INTEGER NOT NULL,
        name TEXT NOT NULL,
        description TEXT,
        status TEXT NOT NULL,
        start_date TEXT,
        end_date TEXT,
        created_at TEXT NOT NULL,
        FOREIGN KEY (client_id) REFERENCES clients(id) ON DELETE CASCADE
      )
    ''');

    await db.execute('''
      CREATE TABLE committee_members (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        committee_id INTEGER NOT NULL,
        name TEXT NOT NULL,
        role TEXT,
        phone TEXT,
        email TEXT,
        joined_at TEXT,
        FOREIGN KEY (committee_id) REFERENCES committees(id) ON DELETE CASCADE
      )
    ''');
  }

  Future<List<Map<String, Object?>>> getClients() async {
    final db = await database;
    return db.query('clients', orderBy: 'id DESC');
  }

  Future<int> insertClient({
    required String name,
    required String phone,
    required String company,
  }) async {
    final db = await database;
    return db.insert('clients', {
      'name': name,
      'phone': phone,
      'company': company,
      'created_at': DateTime.now().toIso8601String(),
    });
  }

  Future<int> updateClient({
    required int id,
    required String name,
    required String phone,
    required String company,
  }) async {
    final db = await database;
    return db.update(
      'clients',
      {
        'name': name,
        'phone': phone,
        'company': company,
      },
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<int> deleteClient(int id) async {
    final db = await database;
    return db.delete('clients', where: 'id = ?', whereArgs: [id]);
  }

  Future<List<Map<String, Object?>>> getCommitteesByClient(int clientId) async {
    final db = await database;
    return db.query(
      'committees',
      where: 'client_id = ?',
      whereArgs: [clientId],
      orderBy: 'id DESC',
    );
  }

  Future<int> insertCommittee({
    required int clientId,
    required String name,
    required String description,
    required String status,
    String? startDate,
    String? endDate,
  }) async {
    final db = await database;
    return db.insert('committees', {
      'client_id': clientId,
      'name': name,
      'description': description,
      'status': status,
      'start_date': startDate,
      'end_date': endDate,
      'created_at': DateTime.now().toIso8601String(),
    });
  }

  Future<int> updateCommittee({
    required int id,
    required String name,
    required String description,
    required String status,
    String? startDate,
    String? endDate,
  }) async {
    final db = await database;
    return db.update(
      'committees',
      {
        'name': name,
        'description': description,
        'status': status,
        'start_date': startDate,
        'end_date': endDate,
      },
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<int> deleteCommittee(int id) async {
    final db = await database;
    return db.delete('committees', where: 'id = ?', whereArgs: [id]);
  }

  Future<List<Map<String, Object?>>> getMembersByCommittee(
    int committeeId,
  ) async {
    final db = await database;
    return db.query(
      'committee_members',
      where: 'committee_id = ?',
      whereArgs: [committeeId],
      orderBy: 'id DESC',
    );
  }

  Future<int> insertMember({
    required int committeeId,
    required String name,
    required String role,
    required String phone,
    required String email,
    String? joinedAt,
  }) async {
    final db = await database;
    return db.insert('committee_members', {
      'committee_id': committeeId,
      'name': name,
      'role': role,
      'phone': phone,
      'email': email,
      'joined_at': joinedAt,
    });
  }

  Future<int> updateMember({
    required int id,
    required String name,
    required String role,
    required String phone,
    required String email,
    String? joinedAt,
  }) async {
    final db = await database;
    return db.update(
      'committee_members',
      {
        'name': name,
        'role': role,
        'phone': phone,
        'email': email,
        'joined_at': joinedAt,
      },
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<int> deleteMember(int id) async {
    final db = await database;
    return db.delete('committee_members', where: 'id = ?', whereArgs: [id]);
  }
}
