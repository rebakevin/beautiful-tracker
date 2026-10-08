/// A local account. Stored in the `users` table.
class AppUser {
  const AppUser({
    this.id,
    required this.name,
    required this.email,
    required this.passwordHash,
    required this.passwordSalt,
    required this.createdAt,
  });

  final int? id;
  final String name;
  final String email;
  final String passwordHash;
  final String passwordSalt;
  final DateTime createdAt;

  /// Up to two initials for the avatar, e.g. "Kevin Rebakure" → "KR".
  String get initials {
    final parts = name.trim().split(RegExp(r'\s+')).where((p) => p.isNotEmpty);
    final letters = parts.take(2).map((p) => p[0].toUpperCase()).join();
    return letters.isEmpty ? '?' : letters;
  }

  String get firstName => name.trim().split(RegExp(r'\s+')).first;

  AppUser copyWith({
    int? id,
    String? name,
    String? email,
    String? passwordHash,
    String? passwordSalt,
  }) {
    return AppUser(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      passwordHash: passwordHash ?? this.passwordHash,
      passwordSalt: passwordSalt ?? this.passwordSalt,
      createdAt: createdAt,
    );
  }

  Map<String, Object?> toMap() => {
    if (id != null) 'id': id,
    'name': name,
    'email': email,
    'password_hash': passwordHash,
    'password_salt': passwordSalt,
    'created_at': createdAt.toIso8601String(),
  };

  factory AppUser.fromMap(Map<String, Object?> map) => AppUser(
    id: map['id'] as int,
    name: map['name'] as String,
    email: map['email'] as String,
    passwordHash: map['password_hash'] as String,
    passwordSalt: map['password_salt'] as String,
    createdAt: DateTime.parse(map['created_at'] as String),
  );
}
