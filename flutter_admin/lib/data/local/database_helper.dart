import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'dart:async';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('finance_app.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(
      path, 
      version: 1,
      onCreate: _createDB,
    );
  }

  Future<void> _createDB(Database db, int version) async {
    // Create tables for different entities
    await db.execute('''
      CREATE TABLE financial_reports (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        title TEXT,
        amount REAL,
        date TEXT,
        category TEXT,
        type TEXT
      )
    ''');

    await db.execute('''
      CREATE TABLE transactions (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        amount REAL,
        date TEXT,
        description TEXT,
        category TEXT
      )
    ''');
  }

  // Generic insert method
  Future<int> insert(String table, Map<String, dynamic> data) async {
    final db = await database;
    return await db.insert(table, data);
  }

  // Generic query method
  Future<List<Map<String, dynamic>>> query(String table, {
    String? where, 
    List<dynamic>? whereArgs,
    String? orderBy
  }) async {
    final db = await database;
    return await db.query(
      table, 
      where: where, 
      whereArgs: whereArgs,
      orderBy: orderBy
    );
  }

  // Generic update method
  Future<int> update(String table, Map<String, dynamic> data, {
    required String where, 
    required List<dynamic> whereArgs
  }) async {
    final db = await database;
    return await db.update(
      table, 
      data, 
      where: where, 
      whereArgs: whereArgs
    );
  }

  // Generic delete method
  Future<int> delete(String table, {
    required String where, 
    required List<dynamic> whereArgs
  }) async {
    final db = await database;
    return await db.delete(
      table, 
      where: where, 
      whereArgs: whereArgs
    );
  }

  // Close database
  Future<void> close() async {
    final db = await database;
    await db.close();
  }
}