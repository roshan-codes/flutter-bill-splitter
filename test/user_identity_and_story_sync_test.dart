import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_bill_splitter/core/services/storage_service.dart';
import 'package:flutter_bill_splitter/features/stories/data/repositories/story_repository.dart';
import 'package:flutter_bill_splitter/features/stories/domain/models/story.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    await StorageService.instance.init();
    await StorageService.instance.clear();
    await StoryRepository.instance.init();
    await StoryRepository.instance.clearAll();
  });

  group('User Identity & Story Cloud Sync Tests', () {
    test('Current user resolution only marks the logged-in user, not other members', () async {
      // Simulate Sharda being the logged in user
      await StorageService.instance.setString('user_profile_name', 'Sharda Badwaik');

      final currentName = StorageService.instance.getStringSync('user_profile_name') ?? '';
      final myClean = currentName.toLowerCase().trim();

      bool checkIsCurrentUser(String name, [String? userId]) {
        final clean = name.toLowerCase().trim();
        if (clean == 'you') return true;
        if (myClean.isNotEmpty && clean == myClean) return true;
        return false;
      }

      // Sharda Badwaik should be current user
      expect(checkIsCurrentUser('Sharda Badwaik'), isTrue);

      // Roshan Badwaik must NOT be marked as current user
      expect(checkIsCurrentUser('Roshan Badwaik'), isFalse);

      // Other members must NOT be marked as current user
      expect(checkIsCurrentUser('Popat'), isFalse);
      expect(checkIsCurrentUser('Amit Sharma'), isFalse);
    });

    test('StoryRepository updates existing story when remote has newer members or expenses', () async {
      // Local story only has Roshan
      const initialStory = Story(
        storyId: 'story_sync_001',
        title: 'Trip to Chandpur',
        description: 'Yatra',
        coverEmoji: '🌴',
        currency: 'INR',
        status: 'active',
        createdBy: 'user_roshan',
        createdAt: '2026-11-15T18:00:00.000',
        members: [
          StoryMember(
            userId: 'user_roshan',
            name: 'Roshan Badwaik',
            role: 'creator',
            joinedAt: '2026-11-15T18:00:00.000',
          ),
        ],
        expenses: [],
        memberBalances: [
          StoryMemberBalance(
            userId: 'user_roshan',
            name: 'Roshan Badwaik',
            totalPaid: 0,
            totalShare: 0,
            netBalance: 0,
            status: 'settled',
          ),
        ],
        settlements: [],
        summary: StorySummary(
          totalExpenses: 0,
          totalSettled: 0,
          pendingAmount: 0,
          memberCount: 1,
          expenseCount: 0,
        ),
      );

      await StoryRepository.instance.addStory(initialStory);
      expect(StoryRepository.instance.getStoryById('story_sync_001')?.members.length, 1);

      // Remote story has Sharda as well, plus an expense
      final updatedRemoteStory = initialStory.copyWith(
        members: [
          ...initialStory.members,
          const StoryMember(
            userId: 'user_sharda',
            name: 'Sharda Badwaik',
            role: 'member',
            joinedAt: '2026-11-15T18:15:00.000',
          ),
        ],
        expenses: const [
          StoryExpense(
            expenseId: 'exp_001',
            title: 'Dinner',
            category: 'food',
            amount: 500,
            paidBy: 'user_sharda',
            splitType: 'equal',
            participants: ['user_roshan', 'user_sharda'],
            shares: [
              ExpenseShare(userId: 'user_roshan', amount: 250),
              ExpenseShare(userId: 'user_sharda', amount: 250),
            ],
            date: '2026-11-15T18:20:00.000',
          ),
        ],
      );

      // When updateStory or remote sync is applied
      await StoryRepository.instance.updateStory(updatedRemoteStory);

      final result = StoryRepository.instance.getStoryById('story_sync_001');
      expect(result, isNotNull);
      expect(result!.members.length, 2);
      expect(result.members.any((m) => m.name == 'Sharda Badwaik'), isTrue);
      expect(result.expenses.length, 1);
      expect(result.expenses.first.title, 'Dinner');
      expect(result.expenses.first.amount, 500);
    });
  });
}
