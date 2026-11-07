/// Domain model representing a Friend.
class Friend {
  final String name;
  final String phone;
  final String? avatarUrl;

  const Friend({
    required this.name,
    required this.phone,
    this.avatarUrl,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Friend &&
          runtimeType == other.runtimeType &&
          name == other.name &&
          phone == other.phone;

  @override
  int get hashCode => name.hashCode ^ phone.hashCode;
}

