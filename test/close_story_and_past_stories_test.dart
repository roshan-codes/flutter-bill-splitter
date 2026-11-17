import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_bill_splitter/core/services/storage_service.dart';
import 'package:flutter_bill_splitter/features/expenses/presentation/screens/split_detail_screen.dart';
import 'package:flutter_bill_splitter/features/friends/domain/models/friend.dart';
import 'package:flutter_bill_splitter/features/home/presentation/screens/home_tab.dart';
import 'package:flutter_bill_splitter/features/stories/data/repositories/story_repository.dart';
import 'package:flutter_bill_splitter/features/stories/domain/models/story.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    await StorageService.instance.init();
    await StoryRepository.instance.clearAll();
  });

  group('Close Story & Past Stories Tests', () {
    testWidgets('SplitDetailScreen: 3-dots popup has Close Story button and updates status to inactive', (tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      final story = Story.sampleGoaTrip().copyWith(storyId: 'story_active_1', status: 'active');
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

      // Check header initially displays 'Active'
      expect(find.text('Active'), findsOneWidget);

      // Open 3-dots popup menu
      final moreButton = find.byKey(const ValueKey('story_detail_more_button'));
      expect(moreButton, findsOneWidget);
      await tester.tap(moreButton);
      await tester.pumpAndSettle();

      // Check 'Close Story' tile is present instead of 'Finalize & Settle Split'
      expect(find.text('Finalize & Settle Split'), findsNothing);
      final closeTile = find.byKey(const ValueKey('close_story_tile'));
      expect(closeTile, findsOneWidget);
      expect(find.text('Close Story'), findsOneWidget);

      // Tap 'Close Story'
      await tester.tap(closeTile);
      await tester.pumpAndSettle();

      // Verify header status is now 'Inactive'
      expect(find.text('Inactive'), findsOneWidget);

      // Open 3-dots popup menu again
      await tester.tap(moreButton);
      await tester.pumpAndSettle();

      // Verify tile now says 'Reopen Story'
      expect(find.text('Reopen Story'), findsOneWidget);
      await tester.tap(find.text('Reopen Story'));
      await tester.pumpAndSettle();

      // Verify header status toggles back to 'Active'
      expect(find.text('Active'), findsOneWidget);
    });

    testWidgets('HomeTab: single inactive story renders "Past Story" header', (tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      final activeStory = Story.sampleGoaTrip().copyWith(storyId: 'active_1', title: 'Manali Trip', status: 'active');
      final inactiveStory = Story.sampleGoaTrip().copyWith(storyId: 'past_1', title: 'Old Goa Trip', status: 'inactive');

      await StoryRepository.instance.addStory(activeStory);
      await StoryRepository.instance.addStory(inactiveStory);

      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: HomeTab(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Active stories section header
      expect(find.text('Active Stories'), findsOneWidget);
      expect(find.text('Manali Trip'), findsOneWidget);

      // Single inactive story header: 'Past Story' (singular)
      expect(find.text('Past Story'), findsOneWidget);
      expect(find.text('Past Stories'), findsNothing);
      expect(find.text('Old Goa Trip'), findsOneWidget);
    });

    testWidgets('HomeTab: multiple inactive stories render "Past Stories" header with horizontal scroll', (tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      final activeStory = Story.sampleGoaTrip().copyWith(storyId: 'active_1', title: 'Manali Trip', status: 'active');
      final pastStory1 = Story.sampleGoaTrip().copyWith(storyId: 'past_1', title: 'Goa 2024', status: 'inactive');
      final pastStory2 = Story.sampleGoaTrip().copyWith(storyId: 'past_2', title: 'Kerala 2023', status: 'inactive');

      await StoryRepository.instance.addStory(activeStory);
      await StoryRepository.instance.addStory(pastStory1);
      await StoryRepository.instance.addStory(pastStory2);

      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: HomeTab(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Header: 'Past Stories' (plural)
      expect(find.text('Past Stories'), findsOneWidget);
      expect(find.text('Past Story'), findsNothing);

      // Check horizontal ListView exists
      final horizontalListViewFinder = find.byWidgetPredicate((widget) {
        return widget is ListView && widget.scrollDirection == Axis.horizontal;
      });
      expect(horizontalListViewFinder, findsOneWidget);

      // Verify stories inside
      expect(find.text('Goa 2024'), findsOneWidget);
      expect(find.text('Kerala 2023'), findsOneWidget);
    });
  });
}
