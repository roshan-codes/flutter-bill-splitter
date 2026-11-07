import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_bill_splitter/core/services/storage_service.dart';
import 'package:flutter_bill_splitter/features/activity/data/repositories/activity_repository.dart';
import 'package:flutter_bill_splitter/features/activity/domain/models/split_activity.dart';
import 'package:flutter_bill_splitter/features/expenses/domain/models/settlement_transaction.dart';
import 'package:flutter_bill_splitter/features/friends/data/repositories/friends_repository.dart';
import 'package:flutter_bill_splitter/features/friends/domain/models/friend.dart';
import 'package:flutter_bill_splitter/features/friends/domain/models/group.dart';

void main() {
  group('Persistence & Serialization Tests', () {
    setUp(() async {
      SharedPreferences.setMockInitialValues({});
      await StorageService.instance.init();
    });

    test('Friend serialization and deserialization preserves properties', () {
      const friend = Friend(name: 'Vinit', phone: '+91 98765 11111', avatarUrl: 'https://example.com/a.png');
      final json = friend.toJson();
      final restored = Friend.fromJson(json);

      expect(restored.name, friend.name);
      expect(restored.phone, friend.phone);
      expect(restored.avatarUrl, friend.avatarUrl);
    });

    test('Group serialization and deserialization preserves members', () {
      const friend1 = Friend(name: 'Vinit', phone: '+91 98765 11111');
      const friend2 = Friend(name: 'Nishant', phone: '+91 98765 22222');
      const group = Group(name: 'Trip Gang', members: [friend1, friend2]);

      final json = group.toJson();
      final restored = Group.fromJson(json);

      expect(restored.name, 'Trip Gang');
      expect(restored.members.length, 2);
      expect(restored.members.first.name, 'Vinit');
      expect(restored.members.last.name, 'Nishant');
    });

    test('SettlementTransaction serialization and deserialization works', () {
      const from = Friend(name: 'Saurabh', phone: '+91 98765 33333');
      const to = Friend(name: 'Vinit', phone: '+91 98765 11111');
      const tx = SettlementTransaction(from: from, to: to, amount: 183.0);

      final json = tx.toJson();
      final restored = SettlementTransaction.fromJson(json);

      expect(restored.from.name, 'Saurabh');
      expect(restored.to.name, 'Vinit');
      expect(restored.amount, 183.0);
    });

    test('SplitActivity serialization and deserialization works', () {
      const friend1 = Friend(name: 'Vinit', phone: '+91 98765 11111');
      const friend2 = Friend(name: 'Nishant', phone: '+91 98765 22222');
      final activity = SplitActivity(
        id: 'split_101',
        groupName: 'Dinner at Sakali',
        totalAmount: 549.0,
        sharePerPerson: 183.0,
        members: const [friend1, friend2],
        memberExpenses: const {'Vinit': 500.0, 'Nishant': 49.0},
        settlements: const [
          SettlementTransaction(from: friend2, to: friend1, amount: 134.0),
        ],
        timestamp: DateTime(2026, 11, 7, 21, 0),
      );

      final json = activity.toJson();
      final restored = SplitActivity.fromJson(json);

      expect(restored.id, 'split_101');
      expect(restored.groupName, 'Dinner at Sakali');
      expect(restored.totalAmount, 549.0);
      expect(restored.sharePerPerson, 183.0);
      expect(restored.members.length, 2);
      expect(restored.memberExpenses['Vinit'], 500.0);
      expect(restored.settlements.length, 1);
      expect(restored.settlements.first.amount, 134.0);
    });

    test('ActivityRepository persists data across simulated app restart', () async {
      final repo1 = ActivityRepository(storageService: StorageService.instance);
      await repo1.init();
      expect(repo1.activities, isEmpty);

      const friend1 = Friend(name: 'Vinit', phone: '+91 98765 11111');
      final activity = SplitActivity(
        id: 'split_persisted_1',
        groupName: 'Goa Trip Fuel',
        totalAmount: 2800.0,
        sharePerPerson: 700.0,
        members: const [friend1],
        memberExpenses: const {'Vinit': 2800.0},
        settlements: const [],
        timestamp: DateTime.now(),
      );

      repo1.recordActivity(activity);
      expect(repo1.activities.length, 1);

      // Simulate App Restart by creating a fresh repository instance and calling init()
      final repo2 = ActivityRepository(storageService: StorageService.instance);
      await repo2.init();

      expect(repo2.activities.length, 1);
      expect(repo2.activities.first.id, 'split_persisted_1');
      expect(repo2.activities.first.groupName, 'Goa Trip Fuel');
      expect(repo2.activities.first.totalAmount, 2800.0);
    });

    test('FriendsRepository persists friends and groups across simulated restart', () async {
      final repo1 = FriendsRepository(storageService: StorageService.instance);
      await repo1.init();

      const friend = Friend(name: 'Rohan Sharma', phone: '+91 99999 88888');
      repo1.addFriend(friend);
      expect(repo1.friends.length, 1);

      const group = Group(name: 'Office Lunch', members: [friend]);
      repo1.addGroup(group);
      expect(repo1.groups.length, 1);

      // Simulate App Restart
      final repo2 = FriendsRepository(storageService: StorageService.instance);
      await repo2.init();

      expect(repo2.friends.length, 1);
      expect(repo2.friends.first.name, 'Rohan Sharma');
      expect(repo2.groups.length, 1);
      expect(repo2.groups.first.name, 'Office Lunch');
    });
  });
}

