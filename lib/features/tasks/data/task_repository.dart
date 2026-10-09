import '../../../data/local/database_helper.dart';
import '../models/task.dart';
import 'task_table.dart';

class TaskRepository {
  TaskRepository({DatabaseHelper? helper})
    : _helper = helper ?? DatabaseHelper.instance;

  final DatabaseHelper _helper;

  Future<int> insert(Task task) async {
    final db = await _helper.database;
    return db.insert(TaskTable.name, task.toMap());
  }

  Future<List<Task>> getAll() async {
    final db = await _helper.database;
    final rows = await db.query(TaskTable.name, orderBy: 'due_date ASC');
    return rows.map(Task.fromMap).toList();
  }

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

  Future<int> delete(int id) async {
    final db = await _helper.database;
    return db.delete(TaskTable.name, where: 'id = ?', whereArgs: [id]);
  }
}
