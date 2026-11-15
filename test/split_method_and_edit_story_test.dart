import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_bill_splitter/core/services/storage_service.dart';
import 'package:flutter_bill_splitter/features/expenses/presentation/screens/split_detail_screen.dart';
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

  Widget buildTestableWidget(Story story) {
    return MaterialApp(
      home: SplitDetailScreen(
        groupName: story.title,
        members: story.members
            .map((m) => Friend(name: m.name, phone: '+91 98765 00000'))
            .toList(),
        story: story,
      ),
    );
  }

  group('Split Method & Edit Story in SplitDetailScreen', () {
    testWidgets('Tapping Edit Story opens sheet and successfully saves updated story',
        (tester) async {
      tester.view.physicalSize = const Size(800, 1200);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      final story = Story.sampleGoaTrip();
      await StoryRepository.instance.addStory(story);

      await tester.pumpWidget(buildTestableWidget(story));
      await tester.pumpAndSettle();

      // Switch to Members tab (Tab index 2)
      await tester.tap(find.text('Members'));
      await tester.pumpAndSettle();

      // Find Edit Story option tile
      final editStoryTile = find.byKey(const ValueKey('edit_story_tile'));
      expect(editStoryTile, findsOneWidget);

      await tester.tap(editStoryTile);
      await tester.pumpAndSettle();

      // Edit Story Sheet is open
      expect(find.text('Edit Story'), findsOneWidget);
      expect(find.text('Cover Icon'), findsOneWidget);
      expect(find.text('Story Name'), findsOneWidget);
      expect(find.text('Save Changes'), findsOneWidget);

      // Change title to "Goa Beach Bash"
      final titleField = find.widgetWithText(TextField, story.title);
      expect(titleField, findsOneWidget);
      await tester.enterText(titleField, 'Goa Beach Bash');
      await tester.pumpAndSettle();

      // Tap Save Changes
      await tester.tap(find.text('Save Changes'));
      await tester.pumpAndSettle();

      // Story name is updated in repository and UI
      final updatedStory =
          StoryRepository.instance.getStoryById(story.storyId);
      expect(updatedStory?.title, 'Goa Beach Bash');
      expect(find.text('Goa Beach Bash'), findsWidgets);
    });

    testWidgets('Tapping Split Method opens sheet and changes split method',
        (tester) async {
      tester.view.physicalSize = const Size(800, 1200);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      final story = Story.sampleGoaTrip();
      await StoryRepository.instance.addStory(story);

      await tester.pumpWidget(buildTestableWidget(story));
      await tester.pumpAndSettle();

      // Switch to Members tab
      await tester.tap(find.text('Members'));
      await tester.pumpAndSettle();

      // Find Split Method option tile
      final splitMethodTile = find.byKey(const ValueKey('split_method_tile'));
      expect(splitMethodTile, findsOneWidget);
      expect(find.text('Equal split'), findsOneWidget);

      await tester.tap(splitMethodTile);
      await tester.pumpAndSettle();

      // Split Method sheet is open
      expect(find.text('Split Method'), findsOneWidget);
      expect(find.text('Equal Split (=)'), findsOneWidget);
      expect(find.text('Exact Amounts (₹)'), findsOneWidget);
      expect(find.text('By Percentages (%)'), findsOneWidget);
      expect(find.text('By Shares (1:2:1)'), findsOneWidget);
      expect(find.text('Adjustment Split'), findsOneWidget);

      // Select Adjustment Split
      await tester.tap(find.text('Adjustment Split'));
      await tester.pumpAndSettle();

      // Subtitle updates to 'Adjustment split'
      expect(find.text('Adjustment split'), findsOneWidget);
    });

    testWidgets('Configuring percentage split updates percentages and balances',
        (tester) async {
      tester.view.physicalSize = const Size(800, 1200);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      final story = Story.sampleGoaTrip();
      await StoryRepository.instance.addStory(story);

      await tester.pumpWidget(buildTestableWidget(story));
      await tester.pumpAndSettle();

      // Switch to Members tab
      await tester.tap(find.text('Members'));
      await tester.pumpAndSettle();

      // Tap Split Method
      await tester.tap(find.byKey(const ValueKey('split_method_tile')));
      await tester.pumpAndSettle();

      // Tap By Percentages
      await tester.tap(find.text('By Percentages (%)'));
      await tester.pumpAndSettle();

      expect(find.text('Split by Percentages'), findsOneWidget);
      expect(find.text('Apply Percentages'), findsOneWidget);

      await tester.tap(find.text('Apply Percentages'));
      await tester.pumpAndSettle();

      expect(find.text('By percentage'), findsOneWidget);
    });

    testWidgets('Add New Expense sheet does not show Category picker',
        (tester) async {
      tester.view.physicalSize = const Size(800, 1200);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      final story = Story.sampleGoaTrip();
      await StoryRepository.instance.addStory(story);

      await tester.pumpWidget(buildTestableWidget(story));
      await tester.pumpAndSettle();

      // Tap bottom "Add Expense" button
      final addExpenseBtn = find.widgetWithText(ElevatedButton, 'Add Expense');
      expect(addExpenseBtn, findsOneWidget);
      await tester.tap(addExpenseBtn);
      await tester.pumpAndSettle();

      // Verify Add New Expense sheet is displayed
      expect(find.text('Add New Expense'), findsOneWidget);
      expect(find.text('Expense Title'), findsOneWidget);
      expect(find.text('Amount (₹)'), findsOneWidget);
      expect(find.text('Paid By'), findsOneWidget);

      // Verify Category selector is removed
      expect(find.text('Category'), findsNothing);
      expect(find.text('Food & Drinks'), findsNothing);
      expect(find.text('Transport'), findsNothing);
    });
  });
}
