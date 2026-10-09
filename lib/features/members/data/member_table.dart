import 'package:sqflite/sqflite.dart';

class MemberTable {
  MemberTable._();

  static const name = 'members';

  static Future<void> create(Database db) async {
    await db.execute('''
      CREATE TABLE IF NOT EXISTS $name (
        id    INTEGER PRIMARY KEY AUTOINCREMENT,
        name  TEXT NOT NULL,
        email TEXT NOT NULL
      )
    ''');
  }
}
