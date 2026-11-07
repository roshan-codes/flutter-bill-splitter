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
}
