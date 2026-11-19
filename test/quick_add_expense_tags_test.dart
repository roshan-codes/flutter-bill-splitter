import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_bill_splitter/features/expenses/presentation/screens/split_detail_screen.dart';
import 'package:flutter_bill_splitter/features/friends/domain/models/friend.dart';
import 'package:flutter_bill_splitter/features/stories/data/repositories/story_repository.dart';
import 'package:flutter_bill_splitter/features/stories/domain/models/story.dart';
import 'package:flutter_bill_splitter/core/services/storage_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    await StorageService.instance.init();
  });

  testWidgets(
      'Add New Expense sheet displays quick travel tags and tapping a tag autofills title',
      (tester) async {
    tester.view.physicalSize = const Size(800, 1000);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() => tester.view.resetPhysicalSize());

    final story = Story.create(
      storyId: 'story_quick_tags_test',
      title: 'Goa Vacation',
      description: 'Trip with quick tags',
      createdBy: 'user_roshan',
      members: [
        StoryMember(
          userId: 'user_roshan',
          name: 'Roshan',
          joinedAt: DateTime.now().toIso8601String(),
        ),
        StoryMember(
          userId: 'user_kumar',
          name: 'Kumar',
          joinedAt: DateTime.now().toIso8601String(),
        ),
      ],
      expenses: const [],
    );

    await StoryRepository.instance.addStory(story);

    await tester.pumpWidget(
      MaterialApp(
        home: SplitDetailScreen(
          groupName: story.title,
          story: story,
          members: const [
            Friend(name: 'Roshan', phone: ''),
            Friend(name: 'Kumar', phone: ''),
          ],
        ),
      ),
    );
    await tester.pumpAndSettle();

    // 1. Open the "Add Expense" sheet
    final addExpenseButton = find.text('Add Expense');
    expect(addExpenseButton, findsWidgets);
    await tester.tap(addExpenseButton.first);
    await tester.pumpAndSettle();

    // 2. Verify sheet title and quick tags are visible
    expect(find.text('Add New Expense'), findsOneWidget);
    expect(find.text('Food'), findsOneWidget);
    expect(find.text('Travel'), findsOneWidget);
    expect(find.text('Stay'), findsOneWidget);
    expect(find.text('Fuel'), findsOneWidget);

    // 3. Tap on "Food" quick tag
    await tester.tap(find.text('Food'));
    await tester.pumpAndSettle();

    // 4. Verify Expense Title is autofilled with "Food"
    final titleField = find.widgetWithText(TextFormField, 'Food');
    expect(titleField, findsOneWidget);

    // 5. Enter amount and save
    final amountField = find.widgetWithText(TextFormField, 'Amount (₹)');
    await tester.enterText(amountField, '850');
    await tester.pumpAndSettle();

    await tester.tap(find.text('Save Expense'));
    await tester.pumpAndSettle();

    // 6. Verify expense was added with food category
    final updatedStory =
        StoryRepository.instance.getStoryById(story.storyId);
    expect(updatedStory, isNotNull);
    expect(updatedStory!.expenses.length, 1);
    expect(updatedStory.expenses.first.title, 'Food');
    expect(updatedStory.expenses.first.category, 'food');
    expect(updatedStory.expenses.first.amount, 850.0);
  });

  testWidgets(
      'Frequently used tags by user are prioritized and marked with frequent badge',
      (tester) async {
    tester.view.physicalSize = const Size(800, 1000);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() => tester.view.resetPhysicalSize());

    // Story has repeated "Boat Ride" and "Scuba Diving" expenses
    final story = Story.create(
      storyId: 'story_frequent_tags_test',
      title: 'Goa Adventure',
      description: 'Trip with frequent tags',
      createdBy: 'user_roshan',
      members: [
        StoryMember(
          userId: 'user_roshan',
          name: 'Roshan',
          joinedAt: DateTime.now().toIso8601String(),
        ),
      ],
      expenses: [
        StoryExpense(
          expenseId: 'exp_1',
          title: 'Boat Ride',
          category: 'activities',
          amount: 1500.0,
          paidBy: 'user_roshan',
          splitType: 'equal',
          participants: const ['user_roshan'],
          shares: const [ExpenseShare(userId: 'user_roshan', amount: 1500.0)],
          date: DateTime.now().toIso8601String(),
        ),
        StoryExpense(
          expenseId: 'exp_2',
          title: 'Boat Ride',
          category: 'activities',
          amount: 2000.0,
          paidBy: 'user_roshan',
          splitType: 'equal',
          participants: const ['user_roshan'],
          shares: const [ExpenseShare(userId: 'user_roshan', amount: 2000.0)],
          date: DateTime.now().toIso8601String(),
        ),
      ],
    );

    await StoryRepository.instance.addStory(story);

    await tester.pumpWidget(
      MaterialApp(
        home: SplitDetailScreen(
          groupName: story.title,
          story: story,
          members: const [
            Friend(name: 'Roshan', phone: ''),
          ],
        ),
      ),
    );
    await tester.pumpAndSettle();

    // Open Add Expense sheet
    final addExpenseButton = find.text('Add Expense');
    expect(addExpenseButton, findsWidgets);
    await tester.tap(addExpenseButton.first);
    await tester.pumpAndSettle();

    // Verify "Boat Ride" appears as a quick tag with frequent star icon in bottom sheet
    final tagFinder = find.descendant(
      of: find.byType(BottomSheet),
      matching: find.text('Boat Ride'),
    );
    expect(tagFinder, findsOneWidget);
    expect(find.byIcon(Icons.auto_awesome_rounded), findsWidgets);

    // Tap "Boat Ride" tag
    await tester.tap(tagFinder);
    await tester.pumpAndSettle();

    // Title should now be Boat Ride
    expect(find.widgetWithText(TextFormField, 'Boat Ride'), findsOneWidget);
  });
}
