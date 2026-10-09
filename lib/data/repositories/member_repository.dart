import '../../features/members/member.dart';
import '../local/database_helper.dart';

/// Translates between [Member] objects and the `members` table.
///
/// This is the only place SQL for members lives, keeping the UI free of
/// storage details.
class MemberRepository {
  const MemberRepository();

  Future<int> insert(Member member) async {
    final db = await DatabaseHelper.instance.database;
    return db.insert('members', {
      'name': member.name,
      'email': member.email,
      'initials': member.initials,
    });
  }

  Future<int> update(Member member) async {
    final db = await DatabaseHelper.instance.database;
    return db.update(
      'members',
      {'name': member.name, 'email': member.email, 'initials': member.initials},
      where: 'id = ?',
      whereArgs: [member.id],
    );
  }

  Future<int> delete(int id) async {
    final db = await DatabaseHelper.instance.database;
    return db.delete('members', where: 'id = ?', whereArgs: [id]);
  }

  Future<List<Member>> fetchAll() async {
    final db = await DatabaseHelper.instance.database;
    final rows = await db.query('members', orderBy: 'name ASC');
    return rows.map(_fromRow).toList();
  }

  Member _fromRow(Map<String, Object?> row) {
    return Member(
      id: row['id'] as int,
      name: row['name'] as String,
      email: row['email'] as String,
      initials: row['initials'] as String,
      taskCount: 0,
      statuses: const [],
    );
  }
}
