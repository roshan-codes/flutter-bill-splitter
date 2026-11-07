import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter_bill_splitter/core/services/storage_service.dart';
import 'package:flutter_bill_splitter/features/friends/domain/models/friend.dart';
import 'package:flutter_bill_splitter/features/friends/domain/models/group.dart';

/// Repository managing friends and groups with offline persistence.
class FriendsRepository extends ChangeNotifier {
  static final FriendsRepository instance = FriendsRepository();

  static const String _friendsStorageKey = 'saved_friends_key';
  static const String _groupsStorageKey = 'saved_groups_key';

  final StorageService _storageService;

  FriendsRepository({StorageService? storageService})
      : _storageService = storageService ?? StorageService.instance;

  final List<Friend> _friends = [];
  final List<Group> _groups = [];

  List<Friend> get friends => List.unmodifiable(_friends);
  List<Group> get groups => List.unmodifiable(_groups);

  /// Loads persisted friends and groups from offline storage.
  Future<void> init() async {
    try {
      final friendsJson =
          await _storageService.getStringList(_friendsStorageKey);
      if (friendsJson != null && friendsJson.isNotEmpty) {
        _friends.clear();
        for (final str in friendsJson) {
          try {
            final map = jsonDecode(str) as Map<String, dynamic>;
            _friends.add(Friend.fromJson(map));
          } catch (e) {
            debugPrint('Error parsing stored friend: $e');
          }
        }
      }

      final groupsJson = await _storageService.getStringList(_groupsStorageKey);
      if (groupsJson != null && groupsJson.isNotEmpty) {
        _groups.clear();
        for (final str in groupsJson) {
          try {
            final map = jsonDecode(str) as Map<String, dynamic>;
            _groups.add(Group.fromJson(map));
          } catch (e) {
            debugPrint('Error parsing stored group: $e');
          }
        }
      }

      notifyListeners();
    } catch (e) {
      debugPrint('FriendsRepository init error: $e');
    }
  }

  /// Adds a new friend and persists to offline storage.
  void addFriend(Friend friend) {
    _friends.add(friend);
    notifyListeners();
    _persistFriends();
  }

  /// Removes a friend at [index] and persists changes.
  void removeFriendAt(int index) {
    if (index >= 0 && index < _friends.length) {
      _friends.removeAt(index);
      notifyListeners();
      _persistFriends();
    }
  }

  /// Adds a new group and persists to offline storage.
  void addGroup(Group group) {
    _groups.add(group);
    notifyListeners();
    _persistGroups();
  }

  /// Removes a group at [index] and persists changes.
  void removeGroupAt(int index) {
    if (index >= 0 && index < _groups.length) {
      _groups.removeAt(index);
      notifyListeners();
      _persistGroups();
    }
  }

  /// Clears all friends and groups (useful for test resets).
  void clearAll() {
    _friends.clear();
    _groups.clear();
    notifyListeners();
    _persistFriends();
    _persistGroups();
  }

  Future<void> _persistFriends() async {
    try {
      final jsonStrings = _friends.map((f) => jsonEncode(f.toJson())).toList();
      await _storageService.setStringList(_friendsStorageKey, jsonStrings);
    } catch (e) {
      debugPrint('Error persisting friends: $e');
    }
  }

  Future<void> _persistGroups() async {
    try {
      final jsonStrings = _groups.map((g) => jsonEncode(g.toJson())).toList();
      await _storageService.setStringList(_groupsStorageKey, jsonStrings);
    } catch (e) {
      debugPrint('Error persisting groups: $e');
    }
  }
}
