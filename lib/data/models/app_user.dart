class AppUser {
  const AppUser({
    this.id,
    required this.name,
    required this.email,
    required this.passwordHash,
    required this.passwordSalt,
    required this.createdAt,
    this.avatarPath,
  });

  final int? id;
  final String name;
  final String email;
  final String passwordHash;
  final String passwordSalt;
  final DateTime createdAt;

  /// Photo stored on this device, or null to show initials.
  final String? avatarPath;

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
    String? avatarPath,
    bool clearAvatar = false,
  }) {
    return AppUser(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      passwordHash: passwordHash ?? this.passwordHash,
      passwordSalt: passwordSalt ?? this.passwordSalt,
      createdAt: createdAt,
      avatarPath: clearAvatar ? null : (avatarPath ?? this.avatarPath),
    );
  }

  Map<String, Object?> toMap() => {
    if (id != null) 'id': id,
    'name': name,
    'email': email,
    'password_hash': passwordHash,
    'password_salt': passwordSalt,
    'created_at': createdAt.toIso8601String(),
    'avatar_path': avatarPath,
  };

  factory AppUser.fromMap(Map<String, Object?> map) => AppUser(
    id: map['id'] as int,
    name: map['name'] as String,
    email: map['email'] as String,
    passwordHash: map['password_hash'] as String,
    passwordSalt: map['password_salt'] as String,
    createdAt: DateTime.parse(map['created_at'] as String),
    avatarPath: map['avatar_path'] as String?,
  );
}
