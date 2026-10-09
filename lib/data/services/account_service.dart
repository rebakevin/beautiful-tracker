import '../../core/utils/password_hasher.dart';
import '../models/app_user.dart';
import '../repositories/member_repository.dart';
import '../repositories/user_repository.dart';

enum AccountField { email, password, currentPassword }

class AccountException implements Exception {
  const AccountException(this.field, this.message);

  final AccountField field;
  final String message;

  @override
  String toString() => message;
}

/// Inputs are expected to have passed form validation already; this class
/// only enforces rules that need the database.
class AccountService {
  AccountService({UserRepository? users, MemberRepository? members})
    : _users = users ?? UserRepository(),
      _members = members ?? const MemberRepository();

  final UserRepository _users;
  final MemberRepository _members;

  /// Demo sign-in, as described on the sign-in screen: any valid email and a
  /// 6+ character password works. If the email already has an account the
  /// password must match; otherwise an account is created for it.
  Future<AppUser> signIn({
    required String email,
    required String password,
  }) async {
    final existing = await _users.findByEmail(email);
    if (existing == null) {
      return _create(nameFromEmail(email), email, password);
    }
    final ok = PasswordHasher.verify(
      password,
      salt: existing.passwordSalt,
      hash: existing.passwordHash,
    );
    if (!ok) {
      throw const AccountException(AccountField.password, 'Incorrect password');
    }
    // Accounts made before members existed have no member row yet.
    await _members.ensureExists(name: existing.name, email: existing.email);
    return existing;
  }

  Future<AppUser> signUp({
    required String name,
    required String email,
    required String password,
  }) async {
    if (await _users.emailTaken(email)) {
      throw const AccountException(
        AccountField.email,
        'An account with this email already exists',
      );
    }
    return _create(name.trim(), email, password);
  }

  Future<AppUser> updateProfile(
    AppUser user, {
    required String name,
    required String email,
    required String? avatarPath,
  }) async {
    if (await _users.emailTaken(email, exceptId: user.id)) {
      throw const AccountException(
        AccountField.email,
        'An account with this email already exists',
      );
    }
    final updated = user.copyWith(
      name: name.trim(),
      email: email.trim(),
      avatarPath: avatarPath,
      clearAvatar: avatarPath == null,
    );
    await _users.update(updated);
    await _members.syncProfile(
      oldEmail: user.email,
      name: updated.name,
      email: updated.email,
    );
    return updated;
  }

  Future<AppUser> changePassword(
    AppUser user, {
    required String currentPassword,
    required String newPassword,
  }) async {
    final ok = PasswordHasher.verify(
      currentPassword,
      salt: user.passwordSalt,
      hash: user.passwordHash,
    );
    if (!ok) {
      throw const AccountException(
        AccountField.currentPassword,
        'Incorrect password',
      );
    }
    if (newPassword == currentPassword) {
      throw const AccountException(
        AccountField.password,
        'New password must be different from the current one',
      );
    }
    final salt = PasswordHasher.newSalt();
    final updated = user.copyWith(
      passwordSalt: salt,
      passwordHash: PasswordHasher.hash(newPassword, salt),
    );
    await _users.update(updated);
    return updated;
  }

  Future<AppUser?> findById(int id) => _users.findById(id);

  Future<AppUser> _create(String name, String email, String password) async {
    final salt = PasswordHasher.newSalt();
    final user = await _users.insert(
      AppUser(
        name: name,
        email: email.trim(),
        passwordHash: PasswordHasher.hash(password, salt),
        passwordSalt: salt,
        createdAt: DateTime.now(),
      ),
    );
    await _members.ensureExists(name: user.name, email: user.email);
    return user;
  }

  static String nameFromEmail(String email) {
    final local = email.trim().split('@').first;
    final words = local
        .split(RegExp(r'[._\-+0-9]+'))
        .where((w) => w.isNotEmpty)
        .map((w) => w[0].toUpperCase() + w.substring(1).toLowerCase());
    final name = words.join(' ');
    return name.isEmpty ? 'Team Member' : name;
  }
}
