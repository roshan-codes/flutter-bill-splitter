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

    test('Current user (Gunjan) sees herself as "You"', () {
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
      expect(displayName, equals('You'));
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
  });
}
