import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_bill_splitter/core/services/invite_service.dart';
import 'package:flutter_bill_splitter/core/services/storage_service.dart';
import 'package:flutter_bill_splitter/features/expenses/presentation/screens/split_detail_screen.dart';
import 'package:flutter_bill_splitter/features/friends/domain/models/friend.dart';
import 'package:flutter_bill_splitter/features/onboarding/presentation/screens/onboarding_screen.dart';
import 'package:flutter_bill_splitter/features/stories/data/repositories/story_repository.dart';
import 'package:flutter_bill_splitter/features/stories/domain/models/story.dart';
import 'package:flutter_bill_splitter/features/stories/presentation/widgets/join_story_dialog.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    await StorageService.instance.init();
    await StorageService.instance.clear();
    await StoryRepository.instance.init();
    await StoryRepository.instance.clearAll();
  });

  group('Story Invite and Join Flow Tests', () {
    test('InviteService generates shareable URL with story_id', () {
      const storyId = 'story_delhi_123';
      final url = InviteService.buildInviteUrl(storyId);
      expect(url, contains('story_id=story_delhi_123'));
    });

    test('StoryRepository.joinStoryWithCurrentUser adds new user to story members',
        () async {
      final story = Story.sampleDelhiTrip();
      await StoryRepository.instance.addStory(story);

      // Pre-set user name in storage
      await StorageService.instance
          .setString('user_profile_name', 'Priya Sharma');

      final initialMemberCount = story.members.length;

      final joinedStory = await StoryRepository.instance
          .joinStoryWithCurrentUser(story.storyId);

      expect(joinedStory, isNotNull);
      expect(joinedStory!.members.length, equals(initialMemberCount + 1));
      expect(
        joinedStory.members.any((m) => m.name == 'Priya Sharma'),
        isTrue,
      );
      expect(
        joinedStory.memberBalances.any((b) => b.name == 'Priya Sharma'),
        isTrue,
      );
    });

    testWidgets('SplitDetailScreen shows Invite button and opens share modal',
        (tester) async {
      final story = Story.sampleDelhiTrip();
      await StoryRepository.instance.addStory(story);

      await tester.pumpWidget(
        MaterialApp(
          home: SplitDetailScreen(
            groupName: story.title,
            members: story.members.map((m) => Friend(name: m.name, phone: '')).toList(),
            story: story,
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Switch to Members tab
      await tester.tap(find.text('Members'));
      await tester.pumpAndSettle();

      // Verify Invite button is present
      final inviteBtn = find.byKey(const ValueKey('members_tab_invite_btn'));
      expect(inviteBtn, findsOneWidget);

      // Tap Invite button to open share bottom sheet
      await tester.tap(inviteBtn);
      await tester.pumpAndSettle();

      // Verify bottom sheet content
      expect(find.textContaining('Invite to'), findsOneWidget);
      expect(find.text('Copy'), findsOneWidget);
      expect(find.textContaining('story_id='), findsOneWidget);
    });

    testWidgets(
        'OnboardingScreen displays invite banner when pending invite is present',
        (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: OnboardingScreen(
            inviteStoryId: 'story_sample_999',
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Verify special invite badge is displayed on the auth screen
      expect(find.text('Join Story Invite • Sign in to accept'), findsOneWidget);
      expect(find.text('Continue with Google'), findsOneWidget);
    });

    testWidgets(
        'JoinStoryDialog shows accept and decline popup when user is not a member',
        (tester) async {
      final story = Story.sampleDelhiTrip();

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: JoinStoryDialog(
              story: story,
              isAlreadyMember: false,
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Verify title & question
      expect(find.text('Join Story'), findsOneWidget);
      expect(find.text('Do you really want to join this story?'), findsOneWidget);
      expect(find.text(story.title), findsOneWidget);

      // Verify Accept and Decline buttons
      expect(find.text('Accept'), findsOneWidget);
      expect(find.text('Decline'), findsOneWidget);
    });

    testWidgets(
        'JoinStoryDialog shows already member message and View Story button when user is already a member',
        (tester) async {
      final story = Story.sampleDelhiTrip();

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: JoinStoryDialog(
              story: story,
              isAlreadyMember: true,
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Verify Already a Member title and copy
      expect(find.text('Already a Member'), findsOneWidget);
      expect(
        find.text('You are already a member of "${story.title}".'),
        findsOneWidget,
      );
      expect(find.text(story.title), findsOneWidget);

      // Verify View Story and Dismiss buttons
      expect(find.text('View Story'), findsOneWidget);
      expect(find.text('Dismiss'), findsOneWidget);
    });
  });
}
