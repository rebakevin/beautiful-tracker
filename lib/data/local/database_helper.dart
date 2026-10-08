import 'package:flutter/foundation.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:sqflite_common_ffi_web/sqflite_ffi_web.dart';

/// Single entry point to the local SQLite database.
///
/// The database is opened lazily on first access and the same instance is
/// reused for the lifetime of the app.
///
/// Schema changes are numbered migrations in [_migrations]. A fresh install
/// runs all of them; an existing install runs only the ones newer than its
/// stored version. To change the schema, add a migration and bump [_version]
/// to match. Never edit a migration that has already been pushed.
class DatabaseHelper {
  DatabaseHelper._();

  static final DatabaseHelper instance = DatabaseHelper._();

  static const _databaseName = 'beautiful_tracker.db';
  static const _version = 3;

  Database? _database;

  Future<Database> get database async {
    return _database ??= await _open();
  }

  Future<Database> _open() async {
    // sqflite has no browser implementation; on web it runs on a WebAssembly
    // build of SQLite stored in IndexedDB (web/sqlite3.wasm, web/sqflite_sw.js).
    if (kIsWeb) databaseFactory = databaseFactoryFfiWeb;

    final path = join(await getDatabasesPath(), _databaseName);
    return openDatabase(
      path,
      version: _version,
      onConfigure: _onConfigure,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
  }

  Future<void> _onConfigure(Database db) async {
    // SQLite has foreign keys off by default; tasks will reference members.
    await db.execute('PRAGMA foreign_keys = ON');
  }

  Future<void> _onCreate(Database db, int version) =>
      _migrate(db, from: 1, to: version);

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) =>
      _migrate(db, from: oldVersion + 1, to: newVersion);

  Future<void> _migrate(
    Database db, {
    required int from,
    required int to,
  }) async {
    for (var v = from; v <= to; v++) {
      await _migrations[v]?.call(db);
    }
  }

  /// Schema version -> change. Version 1 was the empty initial database.
  static final Map<int, Future<void> Function(Database)> _migrations = {
    2: (db) => db.execute('''
      CREATE TABLE IF NOT EXISTS members (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        email TEXT NOT NULL,
        initials TEXT NOT NULL
      )
    '''),
    3: (db) => db.execute('''
      CREATE TABLE IF NOT EXISTS users (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        email TEXT NOT NULL UNIQUE COLLATE NOCASE,
        password_hash TEXT NOT NULL,
        password_salt TEXT NOT NULL,
        created_at TEXT NOT NULL
      )
    '''),
  };

  Future<void> close() async {
    await _database?.close();
    _database = null;
  }
}
