import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_bill_splitter/core/services/storage_service.dart';
import 'package:flutter_bill_splitter/features/activity/data/repositories/activity_repository.dart';
import 'package:flutter_bill_splitter/features/activity/domain/models/split_activity.dart';
import 'package:flutter_bill_splitter/features/friends/domain/models/friend.dart';
import 'package:flutter_bill_splitter/features/expenses/presentation/screens/split_detail_screen.dart';
import 'package:flutter_bill_splitter/features/stories/data/repositories/story_repository.dart';
import 'package:flutter_bill_splitter/features/stories/domain/models/story.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    await StorageService.instance.init();
    await StorageService.instance.clear();
    await ActivityRepository.instance.init();
    ActivityRepository.instance.clearActivities();
    await StoryRepository.instance.init();
    await StoryRepository.instance.clearAll();
  });

  group('Story Deletion in SplitDetailScreen', () {
    test('Deleting a story also deletes associated activities in ActivityRepository',
        () async {
      final story = Story.sampleGoaTrip();
      await StoryRepository.instance.addStory(story);

      final activity = SplitActivity(
        id: 'act_${story.storyId}',
        groupName: story.title,
        totalAmount: 1000,
        sharePerPerson: 500,
        members: const [],
        memberExpenses: const {},
        settlements: const [],
        timestamp: DateTime.now(),
      );
      ActivityRepository.instance.recordActivity(activity);
      expect(ActivityRepository.instance.activities.length, 1);

      await StoryRepository.instance.deleteStory(story.storyId);

      expect(StoryRepository.instance.stories.isEmpty, isTrue);
      expect(ActivityRepository.instance.activities.isEmpty, isTrue);
    });

    testWidgets('3-dot menu shows Delete Story option and confirms deletion',
        (tester) async {
      final story = Story.sampleGoaTrip();

      await StoryRepository.instance.addStory(story);
      expect(StoryRepository.instance.stories.length, 1);

      await tester.pumpWidget(
        MaterialApp(
          home: SplitDetailScreen(
            groupName: story.title,
            members: const [
              Friend(name: 'Roshan', phone: '+91 98765 00000'),
              Friend(name: 'Rahul', phone: '+91 98765 11111'),
              Friend(name: 'Priya', phone: '+91 98765 22222'),
            ],
            story: story,
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Tap 3-dot more button
      final moreButton = find.byKey(const ValueKey('story_detail_more_button'));
      expect(moreButton, findsOneWidget);
      await tester.tap(moreButton);
      await tester.pumpAndSettle();

      // Verify bottom sheet shows Delete Story option
      final deleteOption = find.byKey(const ValueKey('delete_story_tile'));
      expect(deleteOption, findsOneWidget);
      expect(find.text('Delete Story'), findsOneWidget);

      // Tap Delete Story to trigger confirmation dialog
      await tester.tap(deleteOption);
      await tester.pumpAndSettle();

      // Verify dialog is shown
      expect(find.text('Delete Story?'), findsOneWidget);
      expect(
        find.textContaining('Are you sure you want to delete "Goa Trip"?'),
        findsOneWidget,
      );

      // Tap Delete in confirmation dialog
      final confirmDeleteBtn = find.widgetWithText(ElevatedButton, 'Delete');
      expect(confirmDeleteBtn, findsOneWidget);
      await tester.tap(confirmDeleteBtn);
      await tester.pumpAndSettle();

      // Verify story was removed from StoryRepository
      expect(StoryRepository.instance.stories.any((s) => s.storyId == story.storyId), isFalse);
    });
  });
}
