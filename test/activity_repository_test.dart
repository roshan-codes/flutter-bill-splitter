import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_bill_splitter/features/activity/data/repositories/activity_repository.dart';
import 'package:flutter_bill_splitter/features/activity/domain/models/split_activity.dart';
import 'package:flutter_bill_splitter/features/expenses/domain/models/settlement_transaction.dart';
import 'package:flutter_bill_splitter/features/friends/domain/models/friend.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('ActivityRepository Tests', () {
    late ActivityRepository repository;

    setUp(() {
      SharedPreferences.setMockInitialValues({});
      repository = ActivityRepository();
    });

    test('initial activities list is empty', () {
      expect(repository.activities, isEmpty);
    });

    test('recordActivity inserts new activity at the front and notifies listeners', () {
      int notifyCount = 0;
      repository.addListener(() {
        notifyCount++;
      });

      const friend1 = Friend(name: 'Alice', phone: '+91 90000 00001');
      const friend2 = Friend(name: 'Bob', phone: '+91 90000 00002');

      final activity1 = SplitActivity(
        id: '1',
        groupName: 'Brunch',
        totalAmount: 400.0,
        sharePerPerson: 200.0,
        members: [friend1, friend2],
        memberExpenses: {'Alice': 400.0, 'Bob': 0.0},
        settlements: const [
          SettlementTransaction(from: friend2, to: friend1, amount: 200.0),
        ],
        timestamp: DateTime(2026, 11, 7, 10, 0),
      );

      repository.recordActivity(activity1);

      expect(repository.activities.length, 1);
      expect(repository.activities.first.groupName, 'Brunch');
      expect(notifyCount, 1);

      final activity2 = SplitActivity(
        id: '2',
        groupName: 'Dinner',
        totalAmount: 1000.0,
        sharePerPerson: 500.0,
        members: [friend1, friend2],
        memberExpenses: {'Alice': 500.0, 'Bob': 500.0},
        settlements: const [],
        timestamp: DateTime(2026, 11, 7, 20, 0),
      );

      repository.recordActivity(activity2);

      expect(repository.activities.length, 2);
      expect(repository.activities.first.groupName, 'Dinner'); // Newest first
      expect(notifyCount, 2);
    });

    test('clearActivities empties the repository and notifies listeners', () {
      int notifyCount = 0;
      repository.addListener(() {
        notifyCount++;
      });

      const friend1 = Friend(name: 'Alice', phone: '+91 90000 00001');
      final activity = SplitActivity(
        id: '1',
        groupName: 'Snacks',
        totalAmount: 100.0,
        sharePerPerson: 100.0,
        members: [friend1],
        memberExpenses: {'Alice': 100.0},
        settlements: const [],
        timestamp: DateTime.now(),
      );

      repository.recordActivity(activity);
      expect(repository.activities.length, 1);

      repository.clearActivities();
      expect(repository.activities, isEmpty);
      expect(notifyCount, 2);
    });
  });
}

