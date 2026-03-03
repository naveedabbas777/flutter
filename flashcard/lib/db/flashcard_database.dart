import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:path/path.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite/sqflite.dart';
import '../models/flashcard.dart';

class FlashcardDatabase {
  static final FlashcardDatabase instance = FlashcardDatabase._init();
  static const _webFlashcardsKey = 'flashcards_v1';
  static const _webNextIdKey = 'flashcards_next_id_v1';

  static Database? _database;

  FlashcardDatabase._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('flashcards.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(path, version: 1, onCreate: _createDB);
  }

  Future _createDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE flashcards (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        question TEXT NOT NULL,
        answer TEXT NOT NULL
      )
    ''');
  }

  Future<Flashcard> create(Flashcard flashcard) async {
    if (kIsWeb) {
      final prefs = await SharedPreferences.getInstance();
      final cards = await _readAllFromPrefs(prefs);
      final nextId = prefs.getInt(_webNextIdKey) ?? 1;

      final saved = flashcard.copyWith(id: nextId);
      cards.add(saved);

      await _writeAllToPrefs(prefs, cards);
      await prefs.setInt(_webNextIdKey, nextId + 1);
      return saved;
    }

    final db = await instance.database;
    final id = await db.insert('flashcards', flashcard.toMap());
    return flashcard.copyWith(id: id);
  }

  Future<List<Flashcard>> readAll() async {
    if (kIsWeb) {
      final prefs = await SharedPreferences.getInstance();
      return _readAllFromPrefs(prefs);
    }

    final db = await instance.database;
    final result = await db.query('flashcards');
    return result.map((json) => Flashcard.fromMap(json)).toList();
  }

  Future<int> delete(int id) async {
    if (kIsWeb) {
      final prefs = await SharedPreferences.getInstance();
      final cards = await _readAllFromPrefs(prefs);
      final updated = cards.where((card) => card.id != id).toList();

      await _writeAllToPrefs(prefs, updated);
      return cards.length - updated.length;
    }

    final db = await instance.database;
    return await db.delete('flashcards', where: 'id = ?', whereArgs: [id]);
  }

  Future close() async {
    if (kIsWeb) return;

    final db = await instance.database;
    db.close();
  }

  Future<List<Flashcard>> _readAllFromPrefs(SharedPreferences prefs) async {
    final raw = prefs.getStringList(_webFlashcardsKey) ?? [];
    return raw
        .map(
          (item) => Flashcard.fromMap(jsonDecode(item) as Map<String, dynamic>),
        )
        .toList();
  }

  Future<void> _writeAllToPrefs(
    SharedPreferences prefs,
    List<Flashcard> cards,
  ) async {
    final encoded = cards.map((card) => jsonEncode(card.toMap())).toList();
    await prefs.setStringList(_webFlashcardsKey, encoded);
  }
}

extension on Flashcard {
  Flashcard copyWith({int? id, String? question, String? answer}) {
    return Flashcard(
      id: id ?? this.id,
      question: question ?? this.question,
      answer: answer ?? this.answer,
    );
  }
}
