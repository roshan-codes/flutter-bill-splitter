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

  Map<String, dynamic> toJson() => {
        'name': name,
        'phone': phone,
        if (avatarUrl != null) 'avatarUrl': avatarUrl,
      };

  factory Friend.fromJson(Map<String, dynamic> json) => Friend(
        name: json['name'] as String? ?? '',
        phone: json['phone'] as String? ?? '',
        avatarUrl: json['avatarUrl'] as String?,
      );

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
