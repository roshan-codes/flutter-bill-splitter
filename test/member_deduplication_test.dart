import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_bill_splitter/core/services/storage_service.dart';
import 'package:flutter_bill_splitter/features/friends/domain/models/group.dart';
import 'package:flutter_bill_splitter/features/friends/domain/models/friend.dart';
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

  group('Member Deduplication Tests', () {
    test('Story.deduplicateMembers removes duplicate members by userId', () {
      final members = [
        const StoryMember(
          userId: 'user_roshan',
          name: 'Roshan',
          role: 'creator',
          joinedAt: '2026-11-15',
        ),
        const StoryMember(
          userId: 'user_vinit',
          name: 'Vinit',
          role: 'member',
          joinedAt: '2026-11-15',
        ),
        const StoryMember(
          userId: 'user_roshan',
          name: 'Roshan Badwaik',
          role: 'member',
          joinedAt: '2026-11-15',
        ),
      ];

      final unique = Story.deduplicateMembers(members);
      expect(unique.length, equals(2));
      expect(unique.map((m) => m.userId).toSet().length, equals(2));
    });

    test('Story.deduplicateMembers merges first-name and full-name duplicates', () {
      final members = [
        const StoryMember(
          userId: 'user_vinit',
          name: 'Vinit',
          role: 'member',
          joinedAt: '2026-11-15',
        ),
        const StoryMember(
          userId: 'user_vinit_sharma',
          name: 'Vinit Sharma',
          role: 'member',
          joinedAt: '2026-11-15',
        ),
      ];

      final unique = Story.deduplicateMembers(members);
      expect(unique.length, equals(1));
      expect(unique.first.name, equals('Vinit Sharma'));
    });

    test('Story.deduplicateMembers removes "You" when creator is present', () {
      final members = [
        const StoryMember(
          userId: 'user_creator',
          name: 'Roshan Badwaik',
          role: 'creator',
          joinedAt: '2026-11-15',
        ),
        const StoryMember(
          userId: 'user_you',
          name: 'You',
          role: 'member',
          joinedAt: '2026-11-15',
        ),
        const StoryMember(
          userId: 'user_vinit',
          name: 'Vinit',
          role: 'member',
          joinedAt: '2026-11-15',
        ),
      ];

      final unique = Story.deduplicateMembers(members);
      expect(unique.length, equals(2));
      expect(unique.any((m) => m.name == 'You'), isFalse);
      expect(unique.first.name, equals('Roshan Badwaik'));
    });

    test('joinStoryWithCurrentUser claims existing manual member instead of duplicating',
        () async {
      // 1. Story created with manually added "Nishant"
      const story = Story(
        storyId: 'story_dedup_001',
        title: 'Goa Trip',
        description: 'Weekend with friends',
        createdBy: 'user_creator',
        createdAt: '2026-11-15',
        members: [
          StoryMember(
            userId: 'user_creator',
            name: 'Roshan Badwaik',
            role: 'creator',
            joinedAt: '2026-11-15',
          ),
          StoryMember(
            userId: 'user_nishant',
            name: 'Nishant',
            role: 'member',
            joinedAt: '2026-11-15',
          ),
        ],
        summary: StorySummary(
          totalExpenses: 0,
          totalSettled: 0,
          pendingAmount: 0,
          memberCount: 2,
          expenseCount: 0,
        ),
        expenses: [],
        memberBalances: [
          StoryMemberBalance(
            userId: 'user_creator',
            name: 'Roshan Badwaik',
            totalPaid: 0,
            totalShare: 0,
            netBalance: 0,
            status: 'settled',
          ),
          StoryMemberBalance(
            userId: 'user_nishant',
            name: 'Nishant',
            totalPaid: 0,
            totalShare: 0,
            netBalance: 0,
            status: 'settled',
          ),
        ],
        settlements: [],
      );

      await StoryRepository.instance.addStory(story);

      // 2. User logs in as "Nishant" and joins via invite link
      await StorageService.instance.setString('user_profile_name', 'Nishant');

      final updatedStory = await StoryRepository.instance
          .joinStoryWithCurrentUser(story.storyId);

      expect(updatedStory, isNotNull);
      // Member count MUST still be 2, NOT 3!
      expect(updatedStory!.members.length, equals(2));
      expect(
        updatedStory.members.where((m) => m.name.toLowerCase().contains('nishant')).length,
        equals(1),
      );
      expect(updatedStory.memberBalances.length, equals(2));
    });

    test('Story.deduplicateBalances merges manual user balance and authenticated balance', () {
      final balances = [
        const StoryMemberBalance(
          userId: 'user_rahul',
          name: 'Rahul',
          totalPaid: 500,
          totalShare: 250,
          netBalance: 250,
          status: 'owed',
        ),
        const StoryMemberBalance(
          userId: 'auth_uuid_999',
          name: 'Rahul Sharma',
          totalPaid: 0,
          totalShare: 0,
          netBalance: 0,
          status: 'settled',
        ),
      ];

      final unique = Story.deduplicateBalances(balances);
      expect(unique.length, equals(1));
      expect(unique.first.userId, equals('auth_uuid_999'));
      expect(unique.first.name, equals('Rahul Sharma'));
      expect(unique.first.totalPaid, equals(500));
    });

    test('joinStoryWithCurrentUser called multiple times is idempotent and never duplicates',
        () async {
      const story = Story(
        storyId: 'story_dedup_002',
        title: 'Manali Trip',
        description: 'Road trip',
        createdBy: 'user_creator',
        createdAt: '2026-11-15',
        members: [
          StoryMember(
            userId: 'user_creator',
            name: 'Creator',
            role: 'creator',
            joinedAt: '2026-11-15',
          ),
        ],
        summary: StorySummary(
          totalExpenses: 0,
          totalSettled: 0,
          pendingAmount: 0,
          memberCount: 1,
          expenseCount: 0,
        ),
        expenses: [],
        memberBalances: [
          StoryMemberBalance(
            userId: 'user_creator',
            name: 'Creator',
            totalPaid: 0,
            totalShare: 0,
            netBalance: 0,
            status: 'settled',
          ),
        ],
        settlements: [],
      );

      await StoryRepository.instance.addStory(story);
      await StorageService.instance.setString('user_profile_name', 'Aman');

      // Join first time
      final afterFirstJoin = await StoryRepository.instance
          .joinStoryWithCurrentUser(story.storyId);
      expect(afterFirstJoin!.members.length, equals(2));
      expect(afterFirstJoin.memberBalances.length, equals(2));

      // Join second time (e.g. reload or re-click link)
      final afterSecondJoin = await StoryRepository.instance
          .joinStoryWithCurrentUser(story.storyId);
      expect(afterSecondJoin!.members.length, equals(2));
      expect(afterSecondJoin.memberBalances.length, equals(2));
      expect(
        afterSecondJoin.members.where((m) => m.name == 'Aman').length,
        equals(1),
      );
    });

    test('Group.deduplicateFriends prevents duplicate friends in group', () {
      final friends = [
        const Friend(name: 'Vinit', phone: '+91 98765 11111'),
        const Friend(name: 'vinit', phone: '+91 98765 22222'),
        const Friend(name: 'Nishant', phone: '+91 98765 33333'),
      ];

      final group = Group(name: 'Test Group', members: Group.deduplicateFriends(friends));
      expect(group.members.length, equals(2));
    });
  });
}
