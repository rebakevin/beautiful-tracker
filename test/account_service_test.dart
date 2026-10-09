import 'package:beautiful_tracker/data/models/app_user.dart';
import 'package:beautiful_tracker/data/repositories/member_repository.dart';
import 'package:beautiful_tracker/data/repositories/user_repository.dart';
import 'package:beautiful_tracker/data/services/account_service.dart';
import 'package:flutter_test/flutter_test.dart';

class FakeUserRepository implements UserRepository {
  final _users = <int, AppUser>{};
  var _nextId = 1;

  @override
  Future<AppUser> insert(AppUser user) async {
    final saved = user.copyWith(id: _nextId++);
    _users[saved.id!] = saved;
    return saved;
  }

  @override
  Future<AppUser?> findById(int id) async => _users[id];

  @override
  Future<AppUser?> findByEmail(String email) async => _users.values
      .where((u) => u.email.toLowerCase() == email.trim().toLowerCase())
      .firstOrNull;

  @override
  Future<bool> emailTaken(String email, {int? exceptId}) async {
    final user = await findByEmail(email);
    return user != null && user.id != exceptId;
  }

  @override
  Future<void> update(AppUser user) async => _users[user.id!] = user;
}

class FakeMemberRepository implements MemberRepository {
  final emails = <String>[];

  @override
  Future<void> ensureExists({
    required String name,
    required String email,
  }) async {
    if (!emails.contains(email)) emails.add(email);
  }

  @override
  Future<void> syncProfile({
    required String oldEmail,
    required String name,
    required String email,
  }) async {}

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

Matcher throwsAccountError(AccountField field, String message) => throwsA(
  isA<AccountException>()
      .having((e) => e.field, 'field', field)
      .having((e) => e.message, 'message', message),
);

void main() {
  late AccountService accounts;

  setUp(
    () => accounts = AccountService(
      users: FakeUserRepository(),
      members: FakeMemberRepository(),
    ),
  );

  group('signUp', () {
    test('creates an account and never stores the plain password', () async {
      final user = await accounts.signUp(
        name: '  Alice Uwase ',
        email: 'alice@team.dev',
        password: 'secret1',
      );
      expect(user.id, isNotNull);
      expect(user.name, 'Alice Uwase');
      expect(user.passwordHash, isNot(contains('secret1')));
    });

    test('rejects an email that is already registered', () async {
      await accounts.signUp(name: 'A', email: 'a@team.dev', password: '123456');
      expect(
        accounts.signUp(name: 'B', email: 'A@Team.dev', password: '123456'),
        throwsAccountError(
          AccountField.email,
          'An account with this email already exists',
        ),
      );
    });
  });

  group('signIn', () {
    test('creates an account for a new email (demo mode)', () async {
      final user = await accounts.signIn(
        email: 'kevin.rebakure@team.dev',
        password: '123456',
      );
      expect(user.name, 'Kevin Rebakure');
    });

    test('returns the existing account when the password matches', () async {
      final created = await accounts.signUp(
        name: 'Eric',
        email: 'eric@team.dev',
        password: 'pass123',
      );
      final user = await accounts.signIn(
        email: 'eric@team.dev',
        password: 'pass123',
      );
      expect(user.id, created.id);
    });

    test('rejects a wrong password for an existing account', () async {
      await accounts.signUp(
        name: 'E',
        email: 'e@team.dev',
        password: 'pass123',
      );
      expect(
        accounts.signIn(email: 'e@team.dev', password: 'wrong12'),
        throwsAccountError(AccountField.password, 'Incorrect password'),
      );
    });
  });

  group('profile', () {
    test('updateProfile rejects an email used by another account', () async {
      await accounts.signUp(name: 'A', email: 'a@team.dev', password: '123456');
      final b = await accounts.signUp(
        name: 'B',
        email: 'b@team.dev',
        password: '123456',
      );
      expect(
        accounts.updateProfile(
          b,
          name: 'B',
          email: 'a@team.dev',
          avatarPath: null,
        ),
        throwsAccountError(
          AccountField.email,
          'An account with this email already exists',
        ),
      );
    });

    test('changePassword checks the current password', () async {
      final user = await accounts.signUp(
        name: 'D',
        email: 'd@team.dev',
        password: 'old123',
      );
      expect(
        accounts.changePassword(
          user,
          currentPassword: 'nope12',
          newPassword: 'new123',
        ),
        throwsAccountError(AccountField.currentPassword, 'Incorrect password'),
      );

      await accounts.changePassword(
        user,
        currentPassword: 'old123',
        newPassword: 'new123',
      );
      final signedIn = await accounts.signIn(
        email: 'd@team.dev',
        password: 'new123',
      );
      expect(signedIn.id, user.id);
    });
  });

  test('nameFromEmail turns the local part into a name', () {
    expect(
      AccountService.nameFromEmail('diane_ingabire@x.io'),
      'Diane Ingabire',
    );
    expect(AccountService.nameFromEmail('bob@x.io'), 'Bob');
    expect(AccountService.nameFromEmail('123@x.io'), 'Team Member');
  });
}
