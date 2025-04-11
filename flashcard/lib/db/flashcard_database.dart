import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import '../models/flashcard.dart';

class FlashcardDatabase {
  static final FlashcardDatabase instance = FlashcardDatabase._init();

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
    final db = await instance.database;
    final id = await db.insert('flashcards', flashcard.toMap());
    return flashcard.copyWith(id: id);
  }

  Future<List<Flashcard>> readAll() async {
    final db = await instance.database;
    final result = await db.query('flashcards');
    return result.map((json) => Flashcard.fromMap(json)).toList();
  }

  Future<int> delete(int id) async {
    final db = await instance.database;
    return await db.delete('flashcards', where: 'id = ?', whereArgs: [id]);
  }

  Future close() async {
    final db = await instance.database;
    db.close();
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
