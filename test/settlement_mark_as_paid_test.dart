import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_bill_splitter/features/expenses/presentation/screens/split_summary_screen.dart';
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
      'Settlement plan shows Mark as paid button and records reimbursement transaction',
      (tester) async {
    tester.view.physicalSize = const Size(800, 1000);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() => tester.view.resetPhysicalSize());

    const rahul = Friend(name: 'Rahul', phone: '+91 98765 11111');
    const roshan = Friend(name: 'Roshan', phone: '+91 98765 22222');
    const amit = Friend(name: 'Amit', phone: '+91 98765 33333');

    final story = Story.create(
      storyId: 'story_settle_test',
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
        StoryMember(
          userId: 'user_amit',
          name: 'Amit',
          joinedAt: DateTime.now().toIso8601String(),
        ),
      ],
      expenses: [
        StoryExpense(
          expenseId: 'exp_001',
          title: 'Villa Stay',
          category: 'stay',
          amount: 6000.0,
          paidBy: 'user_roshan',
          splitType: 'equal',
          participants: ['user_roshan', 'user_rahul', 'user_amit'],
          shares: const [
            ExpenseShare(userId: 'user_roshan', amount: 2000.0),
            ExpenseShare(userId: 'user_rahul', amount: 2000.0),
            ExpenseShare(userId: 'user_amit', amount: 2000.0),
          ],
          date: DateTime.now().toIso8601String(),
        ),
      ],
    );

    await StoryRepository.instance.addStory(story);

    await tester.pumpWidget(
      MaterialApp(
        home: SplitSummaryScreen(
          groupName: story.title,
          members: const [rahul, roshan, amit],
          memberExpenses: const {
            'Roshan': 6000.0,
            'Rahul': 0.0,
            'Amit': 0.0,
          },
          storyId: story.storyId,
          existingStory: story,
        ),
      ),
    );
    await tester.pumpAndSettle();

    // 1. Verify "Settlement plan" header and rows
    expect(find.text('Settlement plan'), findsOneWidget);
    expect(find.text('Mark as paid'), findsWidgets);

    // 2. Click "Mark as paid" on Rahul's settlement (Rahul pays ₹2,000 to Roshan)
    final markAsPaidButtons = find.widgetWithText(OutlinedButton, 'Mark as paid');
    expect(markAsPaidButtons, findsWidgets);

    await tester.tap(markAsPaidButtons.first);
    await tester.pumpAndSettle();

    // 3. Verify row now shows "Paid" badge with checkmark
    expect(find.byIcon(Icons.check_circle_rounded), findsOneWidget);

    // 4. Verify Story in repository contains reimbursement expense with exact title
    final updatedStory =
        StoryRepository.instance.getStoryById(story.storyId);
    expect(updatedStory, isNotNull);
    final reimbExpense = updatedStory!.expenses.firstWhere(
      (e) => e.category == 'reimbursement',
    );
    expect(reimbExpense.title, contains('Reimbursement transfer to Roshan by Rahul'));
    expect(reimbExpense.amount, 2000.0);
    expect(reimbExpense.paidBy, 'user_rahul');
  });

  testWidgets(
      'Reimbursement transaction displays in SplitDetailScreen Expenses tab and updates Overview tab',
      (tester) async {
    tester.view.physicalSize = const Size(800, 1000);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() => tester.view.resetPhysicalSize());

    final story = Story.create(
      storyId: 'story_reimb_tab_test',
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
          expenseId: 'exp_hotel',
          title: 'Hotel',
          category: 'stay',
          amount: 4000.0,
          paidBy: 'user_roshan',
          splitType: 'equal',
          participants: ['user_roshan', 'user_rahul'],
          shares: const [
            ExpenseShare(userId: 'user_roshan', amount: 2000.0),
            ExpenseShare(userId: 'user_rahul', amount: 2000.0),
          ],
          date: DateTime.now().toIso8601String(),
        ),
        StoryExpense(
          expenseId: 'exp_reimb_1',
          title: 'Reimbursement transfer to Roshan by Rahul',
          category: 'reimbursement',
          amount: 2000.0,
          paidBy: 'user_rahul',
          splitType: 'exact',
          participants: const ['user_roshan'],
          shares: const [
            ExpenseShare(userId: 'user_roshan', amount: 2000.0),
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

    // 1. Overview Tab: Total expenses should be 4000 (excluding 2000 reimbursement)
    expect(find.text('₹4,000'), findsWidgets);

    // 2. Overview Tab: Rahul is settled
    expect(find.text('Settled'), findsWidgets);

    // 3. Switch to Expenses Tab
    await tester.tap(find.text('Expenses'));
    await tester.pumpAndSettle();

    // 4. Verify Reimbursement transfer appears in the Expenses tab list
    expect(
        find.text('Reimbursement transfer to Roshan by Rahul'), findsOneWidget);
    expect(find.text('Paid by Rahul'), findsOneWidget);
  });

  testWidgets(
      'When settlement is NOT done, banner does NOT show All settled and displays actual owe/gets back',
      (tester) async {
    tester.view.physicalSize = const Size(800, 1000);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() => tester.view.resetPhysicalSize());

    final story = Story.create(
      storyId: 'story_unsettled_banner_test',
      title: 'Manali Trip',
      description: 'Trip with pending debt',
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
          expenseId: 'exp_manali_1',
          title: 'Resort Stay',
          category: 'stay',
          amount: 4000.0,
          paidBy: 'user_roshan',
          splitType: 'equal',
          participants: const ['user_roshan', 'user_rahul'],
          shares: const [
            ExpenseShare(userId: 'user_roshan', amount: 2000.0),
            ExpenseShare(userId: 'user_rahul', amount: 2000.0),
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

    // Since settlement is pending (Roshan gets back ₹2,000, Rahul owes ₹2,000):
    // 1. "All settled" must NOT be shown
    expect(find.text('All settled'), findsNothing);
    expect(find.text('You are all square'), findsNothing);

    // 2. Banner shows actual status: "You get back"
    expect(find.text('You get back'), findsOneWidget);
  });
}
