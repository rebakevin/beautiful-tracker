import '../../../data/local/database_helper.dart';
import '../models/task.dart';
import 'task_table.dart';

/// All database access for tasks (the CRUD from issue #3).

class TaskRepository {
  TaskRepository({DatabaseHelper? helper})
      : _helper = helper ?? DatabaseHelper.instance;

  final DatabaseHelper _helper;

  /// Create: saves a new task and returns the id SQLite gave it.
  Future<int> insert(Task task) async {
    final db = await _helper.database;
    return db.insert(TaskTable.name, task.toMap());
  }

  /// Read: all tasks, earliest deadline first.
  Future<List<Task>> getAll() async {
    final db = await _helper.database;
    final rows = await db.query(TaskTable.name, orderBy: 'due_date ASC');
    return rows.map(Task.fromMap).toList();
  }

  /// Read: one task by id, or null if it doesn't exist.
  Future<Task?> getById(int id) async {
    final db = await _helper.database;
    final rows = await db.query(
      TaskTable.name,
      where: 'id = ?',
      whereArgs: [id],
      limit: 1,
    );
    return rows.isEmpty ? null : Task.fromMap(rows.first);
  }

  /// Update: overwrites the stored task that has the same id.
  Future<int> update(Task task) async {
    assert(task.id != null, 'Cannot update a task that has no id');
    final db = await _helper.database;
    return db.update(
      TaskTable.name,
      task.toMap(),
      where: 'id = ?',
      whereArgs: [task.id],
    );
  }

  /// Delete: removes the task with this id.
  Future<int> delete(int id) async {
    final db = await _helper.database;
    return db.delete(TaskTable.name, where: 'id = ?', whereArgs: [id]);
  }
}