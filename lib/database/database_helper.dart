import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

import '../storage/token_storage.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();

  static Database? _database;

  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;

    final dbName = await _resolveDbName();

    _database = await _initDB(dbName);
    return _database!;
  }

  Future<String> getDatabasePath() async {
    final dbDir = await getDatabasesPath();
    final dbName = await _resolveDbName();

    final fullPath = join(dbDir, dbName);

    print('DB PATH: $fullPath');

    return fullPath;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    print('DB PATH: $path');

    return await openDatabase(path, version: 1, onCreate: _createDB);
  }

  Future<String> _resolveDbName() async {
    final prefs = await SharedPreferences.getInstance();

    // se já existe → usa
    String? dbName = prefs.getString('db_name');
    if (dbName != null) return dbName;

    // pega token salvo
    final token = await TokenStorage.getAccessToken();

    if (token == null) {
      throw Exception('Token não encontrado para gerar nome do banco');
    }

    // extrai nome
    final name = _getNameFromToken(token);

    // sanitiza
    final safeName = _sanitize(name);

    dbName = 'caderneta_$safeName.db';

    // salva pra nunca mais mudar
    await prefs.setString('db_name', dbName);

    return dbName;
  }

  String _getNameFromToken(String token) {
    final parts = token.split('.');
    final payload = parts[1];

    final normalized = base64Url.normalize(payload);
    final decoded = utf8.decode(base64Url.decode(normalized));

    final Map<String, dynamic> data = json.decode(decoded);

    return data['nome'] ?? data['preferred_username'] ?? 'default';
  }


  String _sanitize(String name) {
    return name.toLowerCase().replaceAll(RegExp(r'[^\w]+'), '_');
  }

  Future _createDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE clients (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        phone TEXT NOT NULL,
        created_at TEXT NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE debts (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        client_id INTEGER NOT NULL,
        amount REAL NOT NULL,
        description TEXT,
        created_at TEXT NOT NULL,
        is_paid INTEGER DEFAULT 0
      )
    ''');

    await db.execute('''
      CREATE TABLE payments (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        client_id INTEGER NOT NULL,
        amount REAL NOT NULL,
        created_at TEXT NOT NULL
      )
    ''');
  }
}
