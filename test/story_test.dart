import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_bill_splitter/core/services/storage_service.dart';
import 'package:flutter_bill_splitter/features/stories/data/repositories/story_repository.dart';
import 'package:flutter_bill_splitter/features/stories/domain/models/story.dart';

void main() {
  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    await StorageService.instance.init();
    await StoryRepository.instance.clearAll();
  });

  group('Story Domain Model & JSON Schema Tests', () {
    test('Story perfectly parses and serializes the Goa Trip JSON schema', () {
      final sampleJson = Story.sampleGoaTripJson();

      // Parse from JSON
      final story = Story.fromJson(sampleJson);

      expect(story.storyId, equals('story_001'));
      expect(story.title, equals('Goa Trip'));
      expect(story.description, equals('Goa vacation with friends'));
      expect(story.coverEmoji, equals('🌴'));
      expect(story.currency, equals('INR'));
      expect(story.status, equals('active'));
      expect(story.createdBy, equals('user_001'));
      expect(story.createdAt, equals('2026-11-12T09:00:00Z'));
      expect(story.startDate, equals('2026-11-12'));
      expect(story.endDate, equals('2026-11-16'));

      // Verify members (4 members)
      expect(story.members.length, equals(4));
      expect(story.members[0].userId, equals('user_001'));
      expect(story.members[0].name, equals('Roshan'));
      expect(story.members[0].role, equals('admin'));
      expect(story.members[1].name, equals('Rahul'));
      expect(story.members[2].name, equals('Amit'));
      expect(story.members[3].name, equals('Sanket'));

      // Verify summary
      expect(story.summary.totalExpenses, equals(20000.0));
      expect(story.summary.totalSettled, equals(0.0));
      expect(story.summary.pendingAmount, equals(5000.0));
      expect(story.summary.memberCount, equals(4));
      expect(story.summary.expenseCount, equals(5));

      // Verify expenses (5 expenses)
      expect(story.expenses.length, equals(5));
      expect(story.expenses[0].title, equals('Hotel Booking'));
      expect(story.expenses[0].amount, equals(8000.0));
      expect(story.expenses[0].shares.length, equals(4));
      expect(story.expenses[0].shares[0].amount, equals(2000.0));
      expect(story.expenses[1].title, equals('Dinner'));
      expect(story.expenses[2].title, equals('Petrol'));
      expect(story.expenses[3].title, equals('Water Sports'));
      expect(story.expenses[4].title, equals('Food & Snacks'));

      // Verify member_balances
      expect(story.memberBalances.length, equals(4));
      final roshanBal = story.memberBalances.firstWhere((b) => b.userId == 'user_001');
      expect(roshanBal.totalPaid, equals(10000.0));
      expect(roshanBal.totalShare, equals(5000.0));
      expect(roshanBal.netBalance, equals(5000.0));
      expect(roshanBal.status, equals('gets_back'));

      final rahulBal = story.memberBalances.firstWhere((b) => b.userId == 'user_002');
      expect(rahulBal.totalPaid, equals(2000.0));
      expect(rahulBal.totalShare, equals(5000.0));
      expect(rahulBal.netBalance, equals(-3000.0));
      expect(rahulBal.status, equals('owes'));

      final amitBal = story.memberBalances.firstWhere((b) => b.userId == 'user_003');
      expect(amitBal.netBalance, equals(-2000.0));
      expect(amitBal.status, equals('owes'));

      final sanketBal = story.memberBalances.firstWhere((b) => b.userId == 'user_004');
      expect(sanketBal.netBalance, equals(0.0));
      expect(sanketBal.status, equals('settled'));

      // Verify settlements
      expect(story.settlements.length, equals(2));
      expect(story.settlements[0].fromUser, equals('user_002'));
      expect(story.settlements[0].toUser, equals('user_001'));
      expect(story.settlements[0].amount, equals(3000.0));
      expect(story.settlements[0].status, equals('pending'));

      expect(story.settlements[1].fromUser, equals('user_003'));
      expect(story.settlements[1].toUser, equals('user_001'));
      expect(story.settlements[1].amount, equals(2000.0));
      expect(story.settlements[1].status, equals('pending'));

      // Serialize back to JSON and verify identical structure
      final serialized = story.toJson();
      expect(serialized['story_id'], equals(sampleJson['story_id']));
      expect(serialized['title'], equals(sampleJson['title']));
      expect(serialized['summary']['total_expenses'], equals(sampleJson['summary']['total_expenses']));
      expect(serialized['expenses'].length, equals(5));
      expect(serialized['member_balances'].length, equals(4));
      expect(serialized['settlements'].length, equals(2));

      // Test valid roundtrip JSON string
      final jsonString = jsonEncode(serialized);
      final decodedMap = jsonDecode(jsonString) as Map<String, dynamic>;
      final roundtripStory = Story.fromJson(decodedMap);
      expect(roundtripStory.title, equals('Goa Trip'));
      expect(roundtripStory.summary.totalExpenses, equals(20000.0));
    });

    test('Story.create auto-computes summary, balances, and settlements', () {
      final members = [
        const StoryMember(userId: 'u1', name: 'Alice', joinedAt: '2026-11-12T00:00:00Z'),
        const StoryMember(userId: 'u2', name: 'Bob', joinedAt: '2026-11-12T00:00:00Z'),
      ];

      final expenses = [
        const StoryExpense(
          expenseId: 'e1',
          title: 'Lunch',
          category: 'food',
          amount: 1000.0,
          paidBy: 'u1',
          participants: ['u1', 'u2'],
          shares: [
            ExpenseShare(userId: 'u1', amount: 500.0),
            ExpenseShare(userId: 'u2', amount: 500.0),
          ],
          date: '2026-11-12T12:00:00Z',
        ),
      ];

      final story = Story.create(
        storyId: 'story_new',
        title: 'Road Trip',
        description: 'Weekend drive',
        createdBy: 'u1',
        members: members,
        expenses: expenses,
      );

      expect(story.summary.totalExpenses, equals(1000.0));
      expect(story.summary.memberCount, equals(2));
      expect(story.summary.expenseCount, equals(1));

      final aliceBal = story.memberBalances.firstWhere((b) => b.userId == 'u1');
      expect(aliceBal.totalPaid, equals(1000.0));
      expect(aliceBal.totalShare, equals(500.0));
      expect(aliceBal.netBalance, equals(500.0));
      expect(aliceBal.status, equals('gets_back'));

      final bobBal = story.memberBalances.firstWhere((b) => b.userId == 'u2');
      expect(bobBal.totalPaid, equals(0.0));
      expect(bobBal.totalShare, equals(500.0));
      expect(bobBal.netBalance, equals(-500.0));
      expect(bobBal.status, equals('owes'));

      expect(story.settlements.length, equals(1));
      expect(story.settlements[0].fromUser, equals('u2'));
      expect(story.settlements[0].toUser, equals('u1'));
      expect(story.settlements[0].amount, equals(500.0));
      expect(story.settlements[0].status, equals('pending'));
      expect(story.summary.pendingAmount, equals(500.0));
    });

    test('StoryRepository persists stories and handles settlements', () async {
      final repo = StoryRepository.instance;
      await repo.init();

      // Initialized with sample Goa Trip
      expect(repo.stories.length, equals(1));
      expect(repo.stories[0].title, equals('Goa Trip'));

      // Settle set_001 (Rahul pays Roshan 3000)
      await repo.settlePayment('story_001', 'set_001');

      final updatedStory = repo.getStoryById('story_001')!;
      final s1 = updatedStory.settlements.firstWhere((s) => s.settlementId == 'set_001');
      expect(s1.status, equals('completed'));
      expect(updatedStory.summary.totalSettled, equals(3000.0));
      expect(updatedStory.summary.pendingAmount, equals(2000.0));

      // Reinitialize repo to verify offline persistence
      final repo2 = StoryRepository(storageService: StorageService.instance);
      await repo2.init();
      expect(repo2.stories.length, equals(1));
      expect(repo2.stories[0].summary.totalSettled, equals(3000.0));
    });
  });
}
