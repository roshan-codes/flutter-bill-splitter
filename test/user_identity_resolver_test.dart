import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_bill_splitter/core/utils/user_identity_resolver.dart';
import 'package:flutter_bill_splitter/features/stories/domain/models/story.dart';

void main() {
  group('UserIdentityResolver display name formatting', () {
    const story = Story(
      storyId: 'story_test_1',
      title: 'Goa Trip',
      description: 'Trip to Goa',
      coverEmoji: '🌴',
      members: [
        StoryMember(userId: 'creator_1', name: 'You', role: 'creator', joinedAt: ''),
        StoryMember(userId: 'gunjan_1', name: 'Gunjan', role: 'member', joinedAt: ''),
      ],
      expenses: [],
      settlements: [],
      memberBalances: [],
      summary: StorySummary(
        totalExpenses: 0,
        totalSettled: 0,
        pendingAmount: 0,
        memberCount: 2,
        expenseCount: 0,
      ),
      createdAt: '',
      createdBy: 'creator_1',
    );

    test('Current user (Gunjan) sees herself as "Gunjan (You)"', () {
      final isMe = UserIdentityResolver.isCurrentUser(
        name: 'Gunjan',
        userId: 'gunjan_1',
        story: story,
        resolvedCurrentMemberId: 'gunjan_1',
      );
      expect(isMe, isTrue);

      final displayName = UserIdentityResolver.formatMemberDisplayName(
        'Gunjan',
        isMe,
        memberUserId: 'gunjan_1',
        story: story,
      );
      expect(displayName, equals('Gunjan (You)'));
    });

    test('Current user (Gunjan) NEVER sees creator with name "You" as "You"', () {
      final isMe = UserIdentityResolver.isCurrentUser(
        name: 'You',
        userId: 'creator_1',
        story: story,
        resolvedCurrentMemberId: 'gunjan_1',
      );
      expect(isMe, isFalse);

      final displayName = UserIdentityResolver.formatMemberDisplayName(
        'You',
        isMe,
        memberUserId: 'creator_1',
        story: story,
      );
      expect(displayName, isNot(equals('You')));
      expect(displayName, equals('Host'));
    });

    test('Anonymous guest user is NEVER resolved as story creator or member', () {
      const guestStory = Story(
        storyId: 'story_party',
        title: 'Party',
        description: 'Party trip',
        coverEmoji: '🌴',
        members: [
          StoryMember(userId: 'gunjan_id', name: 'Gunjan Barai', role: 'creator', joinedAt: ''),
          StoryMember(userId: 'roshan_id', name: 'Roshan', role: 'member', joinedAt: ''),
        ],
        expenses: [],
        settlements: [],
        memberBalances: [],
        summary: StorySummary(
          totalExpenses: 0,
          totalSettled: 0,
          pendingAmount: 0,
          memberCount: 2,
          expenseCount: 0,
        ),
        createdAt: '',
        createdBy: 'gunjan_id',
      );

      final resolvedId = UserIdentityResolver.resolveCurrentMemberId(guestStory);
      expect(resolvedId, isNull);

      final isGunjanMe = UserIdentityResolver.isCurrentUser(
        name: 'Gunjan Barai',
        userId: 'gunjan_id',
        story: guestStory,
      );
      expect(isGunjanMe, isFalse);

      final isRoshanMe = UserIdentityResolver.isCurrentUser(
        name: 'Roshan',
        userId: 'roshan_id',
        story: guestStory,
      );
      expect(isRoshanMe, isFalse);

      final gunjanDisplay = UserIdentityResolver.formatMemberDisplayName(
        'Gunjan Barai',
        isGunjanMe,
        memberUserId: 'gunjan_id',
        story: guestStory,
      );
      expect(gunjanDisplay, equals('Gunjan Barai'));

      final roshanDisplay = UserIdentityResolver.formatMemberDisplayName(
        'Roshan',
        isRoshanMe,
        memberUserId: 'roshan_id',
        story: guestStory,
      );
      expect(roshanDisplay, equals('Roshan'));
    });
  });
}
