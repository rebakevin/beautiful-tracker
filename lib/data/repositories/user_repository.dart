import 'package:sqflite/sqflite.dart';

import '../local/database_helper.dart';
import '../models/app_user.dart';

/// CRUD for the `users` table. Email comparisons are case-insensitive because
/// the column is declared `COLLATE NOCASE`.
class UserRepository {
  UserRepository({DatabaseHelper? db}) : _db = db ?? DatabaseHelper.instance;

  final DatabaseHelper _db;

  static const _table = 'users';

  Future<AppUser> insert(AppUser user) async {
    final db = await _db.database;
    final id = await db.insert(
      _table,
      user.toMap(),
      conflictAlgorithm: ConflictAlgorithm.abort,
    );
    return user.copyWith(id: id);
  }

  Future<AppUser?> findById(int id) => _findOne(where: 'id = ?', args: [id]);

  Future<AppUser?> findByEmail(String email) =>
      _findOne(where: 'email = ?', args: [email.trim()]);

  Future<bool> emailTaken(String email, {int? exceptId}) async {
    final user = await findByEmail(email);
    return user != null && user.id != exceptId;
  }

  Future<void> update(AppUser user) async {
    final db = await _db.database;
    await db.update(
      _table,
      user.toMap(),
      where: 'id = ?',
      whereArgs: [user.id],
    );
  }

  Future<AppUser?> _findOne({
    required String where,
    required List<Object?> args,
  }) async {
    final db = await _db.database;
    final rows = await db.query(
      _table,
      where: where,
      whereArgs: args,
      limit: 1,
    );
    return rows.isEmpty ? null : AppUser.fromMap(rows.first);
  }
}
