import 'package:sqflite/sqflite.dart';

/// SQL definition of the tasks table.
class TaskTable {
  TaskTable._();

  static const name = 'tasks';

  static Future<void> create(Database db) async {
    await db.execute('''
      CREATE TABLE $name (
        id          INTEGER PRIMARY KEY AUTOINCREMENT,
        title       TEXT NOT NULL,
        description TEXT NOT NULL DEFAULT '',
        assignee    TEXT NOT NULL,
        due_date    TEXT NOT NULL,
        priority    TEXT NOT NULL,
        status      TEXT NOT NULL,
        sla_status  TEXT NOT NULL
      )
    ''');
  }
}
