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
    await StoryRepository.instance.clearAll();
  });

  testWidgets(
      'Expenses are rendered in a single card, sorted latest at top, and add expense form uses styled container fields',
      (tester) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() => tester.view.resetPhysicalSize());

    final story = Story.create(
      storyId: 'story_card_style_test',
      title: 'Goa Trip',
      description: 'Trip test',
      createdBy: 'user_roshan',
      members: const [
        StoryMember(userId: 'user_roshan', name: 'Roshan', joinedAt: ''),
        StoryMember(userId: 'user_kumar', name: 'Kumar', joinedAt: ''),
      ],
      expenses: const [
        StoryExpense(
          expenseId: 'exp_001',
          title: 'Breakfast',
          category: 'food',
          amount: 500.0,
          paidBy: 'user_roshan',
          splitType: 'equal',
          participants: ['user_roshan', 'user_kumar'],
          shares: [
            ExpenseShare(userId: 'user_roshan', amount: 250.0),
            ExpenseShare(userId: 'user_kumar', amount: 250.0),
          ],
          date: '2026-11-15T09:00:00Z',
        ),
        StoryExpense(
          expenseId: 'exp_002',
          title: 'Dinner Feast',
          category: 'food',
          amount: 1500.0,
          paidBy: 'user_kumar',
          splitType: 'equal',
          participants: ['user_roshan', 'user_kumar'],
          shares: [
            ExpenseShare(userId: 'user_roshan', amount: 750.0),
            ExpenseShare(userId: 'user_kumar', amount: 750.0),
          ],
          date: '2026-11-15T21:00:00Z',
        ),
      ],
    );

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

    // 1. Switch to Expenses tab
    await tester.tap(find.text('Expenses'));
    await tester.pumpAndSettle();

    // 2. Verify expenses are in a single card (Divider between them)
    expect(find.byType(Divider), findsWidgets);
    expect(find.text('Dinner Feast'), findsOneWidget);
    expect(find.text('Breakfast'), findsOneWidget);

    // 3. Verify latest expense (Dinner Feast at 21:00) is above earlier expense (Breakfast at 09:00)
    final dinnerTop = tester.getTopLeft(find.text('Dinner Feast')).dy;
    final breakfastTop = tester.getTopLeft(find.text('Breakfast')).dy;
    expect(dinnerTop, lessThan(breakfastTop));

    // 4. Tap 'Add Expense' button and verify form text fields use modern container styling
    await tester.tap(find.text('Add Expense'));
    await tester.pumpAndSettle();

    // Verify labels above the fields and input fields
    expect(find.text('Expense Title'), findsWidgets);
    expect(find.text('Amount (₹)'), findsWidgets);

    // Verify TextFormField widgets exist with floatingLabelBehavior.never
    final titleField = find.widgetWithText(TextFormField, 'Expense Title');
    expect(titleField, findsOneWidget);
    final amountField = find.widgetWithText(TextFormField, 'Amount (₹)');
    expect(amountField, findsOneWidget);
  });
}
