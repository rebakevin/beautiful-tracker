class Member {
  const Member({this.id, required this.name, required this.email});

  final int? id; // null until the database assigns one
  final String name;
  final String email;

  Map<String, Object?> toMap() => {
    if (id != null) 'id': id,
    'name': name,
    'email': email,
  };

  factory Member.fromMap(Map<String, Object?> map) => Member(
    id: map['id'] as int?,
    name: map['name'] as String,
    email: map['email'] as String,
  );
}
