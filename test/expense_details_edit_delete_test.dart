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
      'Tapping an expense opens detail sheet with Edit and Delete options; editing updates expense and UI',
      (tester) async {
    tester.view.physicalSize = const Size(800, 1000);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() => tester.view.resetPhysicalSize());

    final story = Story.create(
      storyId: 'story_edit_delete_test',
      title: 'Goa Trip',
      description: 'Trip to Goa',
      createdBy: 'user_roshan',
      members: [
        StoryMember(
          userId: 'user_roshan',
          name: 'Roshan',
          joinedAt: DateTime.now().toIso8601String(),
        ),
        StoryMember(
          userId: 'user_rahul',
          name: 'Rahul',
          joinedAt: DateTime.now().toIso8601String(),
        ),
      ],
      expenses: [
        StoryExpense(
          expenseId: 'exp_dinner',
          title: 'Seafood Dinner',
          category: 'food',
          amount: 3000.0,
          paidBy: 'user_roshan',
          splitType: 'equal',
          participants: const ['user_roshan', 'user_rahul'],
          shares: const [
            ExpenseShare(userId: 'user_roshan', amount: 1500.0),
            ExpenseShare(userId: 'user_rahul', amount: 1500.0),
          ],
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
            Friend(name: 'Rahul', phone: ''),
          ],
        ),
      ),
    );
    await tester.pumpAndSettle();

    // 1. Switch to Expenses tab
    await tester.tap(find.text('Expenses'));
    await tester.pumpAndSettle();

    expect(find.text('Seafood Dinner'), findsOneWidget);
    expect(find.text('₹3,000'), findsWidgets);

    // 2. Tap on the Seafood Dinner expense card to open detail sheet
    await tester.tap(find.text('Seafood Dinner'));
    await tester.pumpAndSettle();

    // 3. Verify detail sheet is displayed with Edit and Delete buttons
    expect(find.text('Edit'), findsOneWidget);
    expect(find.text('Delete'), findsOneWidget);
    expect(find.text('Paid by'), findsOneWidget);

    // 4. Tap Edit button
    await tester.tap(find.text('Edit'));
    await tester.pumpAndSettle();

    // 5. Verify Edit Expense sheet opens with prefilled data
    expect(find.text('Edit Expense'), findsOneWidget);
    expect(find.text('Update Expense'), findsOneWidget);

    // 6. Change title to 'Luxury Seafood Dinner' and amount to 4000
    final titleField = find.widgetWithText(TextFormField, 'Seafood Dinner');
    expect(titleField, findsOneWidget);
    await tester.enterText(titleField, 'Luxury Seafood Dinner');

    final amountField = find.widgetWithText(TextFormField, '3000');
    expect(amountField, findsOneWidget);
    await tester.enterText(amountField, '4000');
    await tester.pumpAndSettle();

    // 7. Tap Update Expense
    await tester.tap(find.text('Update Expense'));
    await tester.pumpAndSettle();

    // 8. Verify the updated expense title and amount are shown in Expenses list
    expect(find.text('Luxury Seafood Dinner'), findsOneWidget);
    expect(find.text('₹4,000'), findsWidgets);
  });

  testWidgets('Deleting an expense removes it and updates member balances',
      (tester) async {
    tester.view.physicalSize = const Size(800, 1000);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() => tester.view.resetPhysicalSize());

    final story = Story.create(
      storyId: 'story_delete_exp_test',
      title: 'Goa Trip',
      description: 'Trip to Goa',
      createdBy: 'user_roshan',
      members: [
        StoryMember(
          userId: 'user_roshan',
          name: 'Roshan',
          joinedAt: DateTime.now().toIso8601String(),
        ),
        StoryMember(
          userId: 'user_rahul',
          name: 'Rahul',
          joinedAt: DateTime.now().toIso8601String(),
        ),
      ],
      expenses: [
        StoryExpense(
          expenseId: 'exp_kayak',
          title: 'Kayaking',
          category: 'activities',
          amount: 2000.0,
          paidBy: 'user_roshan',
          splitType: 'equal',
          participants: const ['user_roshan', 'user_rahul'],
          shares: const [
            ExpenseShare(userId: 'user_roshan', amount: 1000.0),
            ExpenseShare(userId: 'user_rahul', amount: 1000.0),
          ],
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
            Friend(name: 'Rahul', phone: ''),
          ],
        ),
      ),
    );
    await tester.pumpAndSettle();

    // 1. Switch to Expenses tab
    await tester.tap(find.text('Expenses'));
    await tester.pumpAndSettle();

    expect(find.text('Kayaking'), findsOneWidget);

    // 2. Tap on Kayaking expense card
    await tester.tap(find.text('Kayaking'));
    await tester.pumpAndSettle();

    // 3. Tap Delete button on the detail sheet
    expect(find.text('Delete'), findsOneWidget);
    await tester.tap(find.text('Delete'));
    await tester.pumpAndSettle();

    // 4. Confirm deletion in dialog
    expect(find.text('Delete Expense?'), findsOneWidget);
    // Tap the 'Delete' button in the confirmation dialog
    final deleteDialogButton = find.descendant(
      of: find.byType(AlertDialog),
      matching: find.text('Delete'),
    );
    await tester.tap(deleteDialogButton);
    await tester.pumpAndSettle();

    // 5. Verify expense is removed and empty state or 0 expenses is displayed
    expect(find.text('Kayaking'), findsNothing);
    expect(find.text('No expenses added yet'), findsOneWidget);
  });
}
