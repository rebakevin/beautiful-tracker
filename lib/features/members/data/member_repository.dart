import '../../../data/local/database_helper.dart';
import '../models/member.dart';
import 'member_table.dart';

class MemberRepository {
  MemberRepository({DatabaseHelper? helper})
    : _helper = helper ?? DatabaseHelper.instance;

  final DatabaseHelper _helper;

  Future<int> insert(Member member) async {
    final db = await _helper.database;
    return db.insert(MemberTable.name, member.toMap());
  }

  Future<List<Member>> getAll() async {
    final db = await _helper.database;
    final rows = await db.query(
      MemberTable.name,
      orderBy: 'name COLLATE NOCASE',
    );
    return rows.map(Member.fromMap).toList();
  }
}
