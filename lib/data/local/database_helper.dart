import 'package:flutter/foundation.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:sqflite_common_ffi_web/sqflite_ffi_web.dart';

/// Single entry point to the local SQLite database.
///
/// The database is opened lazily on first access and the same instance is
/// reused for the lifetime of the app. Tables are created in [_onCreate] and
/// schema changes go through [_onUpgrade] by bumping [_version].
class DatabaseHelper {
  DatabaseHelper._();

  static final DatabaseHelper instance = DatabaseHelper._();

  static const _databaseName = 'beautiful_tracker.db';
  static const _version = 1;

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

  Future<void> _onCreate(Database db, int version) async {
    // No tables yet.
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    // No migrations yet.
  }

  Future<void> close() async {
    await _database?.close();
    _database = null;
  }
}
