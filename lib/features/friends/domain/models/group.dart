import 'friend.dart';

/// Domain model representing a Group of friends.
class Group {
  final String name;
  final List<Friend> members;

  const Group({
    required this.name,
    required this.members,
  });

  Group copyWith({
    String? name,
    List<Friend>? members,
  }) {
    return Group(
      name: name ?? this.name,
      members: members ?? this.members,
    );
  }

  Map<String, dynamic> toJson() => {
        'name': name,
        'members': members.map((m) => m.toJson()).toList(),
      };

  factory Group.fromJson(Map<String, dynamic> json) => Group(
        name: json['name'] as String? ?? '',
        members: deduplicateFriends((json['members'] as List<dynamic>? ?? [])
            .map((m) => Friend.fromJson(Map<String, dynamic>.from(m as Map)))
            .toList()),
      );

  static List<Friend> deduplicateFriends(List<Friend> list) {
    final List<Friend> result = [];
    final Set<String> seen = {};
    for (final f in list) {
      final key = f.name.toLowerCase().trim();
      if (key.isNotEmpty && seen.add(key)) {
        result.add(f);
      }
    }
    return result;
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Group &&
          runtimeType == other.runtimeType &&
          name == other.name &&
          members.length == other.members.length;

  @override
  int get hashCode => name.hashCode ^ members.length.hashCode;
}
