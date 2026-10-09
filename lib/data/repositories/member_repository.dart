import '../../features/members/member.dart';
import '../local/database_helper.dart';

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

  /// Makes sure a member with [email] exists, adding one if not. Used so a
  /// signed-in account always appears in the team list.
  Future<void> ensureExists({
    required String name,
    required String email,
  }) async {
    final db = await DatabaseHelper.instance.database;
    final found = await db.query(
      'members',
      columns: ['id'],
      where: 'email = ? COLLATE NOCASE',
      whereArgs: [email],
      limit: 1,
    );
    if (found.isNotEmpty) return;
    await db.insert('members', {
      'name': name,
      'email': email,
      'initials': Member.initialsFromName(name),
    });
  }

  Future<void> syncProfile({
    required String oldEmail,
    required String name,
    required String email,
  }) async {
    final db = await DatabaseHelper.instance.database;
    await db.update(
      'members',
      {'name': name, 'email': email, 'initials': Member.initialsFromName(name)},
      where: 'email = ? COLLATE NOCASE',
      whereArgs: [oldEmail],
    );
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
