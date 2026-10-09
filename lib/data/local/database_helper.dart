import '../../features/members/data/member_table.dart';
import '../../features/tasks/data/task_table.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

/// Single entry point to the local SQLite database.
///
/// The database is opened lazily on first access and the same instance is
/// reused for the lifetime of the app. Tables are created in [_onCreate] and
/// schema changes go through [_onUpgrade] by bumping [_version].
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
  Future<void> _onOpen(Database db) async {
    await TaskTable.create(db);
    await MemberTable.create(db);
  }

  Future<void> _onConfigure(Database db) async {
    // SQLite has foreign keys off by default; tasks will reference members.
    await db.execute('PRAGMA foreign_keys = ON');
  }

  Future<void> _onCreate(Database db, int version) async {
    await TaskTable.create(db);
    await MemberTable.create(db);
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      await TaskTable.create(db);
    }
    if (oldVersion < 3) {
      await MemberTable.create(db);
    }
  }

  Future<void> close() async {
    await _database?.close();
    _database = null;
  }
}
