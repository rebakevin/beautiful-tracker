import 'package:flutter/foundation.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:sqflite_common_ffi_web/sqflite_ffi_web.dart';

import '../../features/tasks/data/task_table.dart';

/// Schema changes are numbered migrations in [_migrations]. A fresh install
/// runs all of them; an existing install runs only the ones newer than its
/// stored version. To change the schema, add a migration and bump [_version]
/// to match. Never edit a migration that has already been pushed.
class DatabaseHelper {
  DatabaseHelper._();

  static final DatabaseHelper instance = DatabaseHelper._();

  static const _databaseName = 'beautiful_tracker.db';
  static const _version = 6;

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
      onOpen: _onOpen,
    );
  }

  /// Safety net for databases created before the tasks table existed at the
  /// current version: a missing table is created instead of failing every query.
  Future<void> _onOpen(Database db) => TaskTable.create(db);

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
    4: TaskTable.create,
    5: (db) async {
      // SLA is derived now, so drop the column. Recreate the table rather than
      // ALTER TABLE ... DROP COLUMN, which needs SQLite 3.35+ (Android 13+).
      await db.execute('''
        CREATE TABLE tasks_new (
          id          INTEGER PRIMARY KEY AUTOINCREMENT,
          title       TEXT NOT NULL,
          description TEXT NOT NULL DEFAULT '',
          assignee    TEXT NOT NULL,
          due_date    TEXT NOT NULL,
          priority    TEXT NOT NULL,
          status      TEXT NOT NULL
        )
      ''');
      await db.execute('''
        INSERT INTO tasks_new (id, title, description, assignee, due_date, priority, status)
        SELECT id, title, description, assignee, due_date, priority, status
        FROM tasks
      ''');
      await db.execute('DROP TABLE tasks');
      await db.execute('ALTER TABLE tasks_new RENAME TO tasks');
    },
    6: (db) => db.execute('ALTER TABLE users ADD COLUMN avatar_path TEXT'),
  };

  Future<void> close() async {
    await _database?.close();
    _database = null;
  }
}
