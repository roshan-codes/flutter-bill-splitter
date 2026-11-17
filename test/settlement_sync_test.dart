import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_bill_splitter/core/services/storage_service.dart';
import 'package:flutter_bill_splitter/features/expenses/presentation/screens/split_summary_screen.dart';
import 'package:flutter_bill_splitter/features/friends/domain/models/friend.dart';
import 'package:flutter_bill_splitter/features/stories/data/repositories/story_repository.dart';
import 'package:flutter_bill_splitter/features/stories/domain/models/story.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    await StorageService.instance.init();
  });

  testWidgets(
      'SplitSummaryScreen settlement plan and member breakdown are mathematically synced',
      (tester) async {
    tester.view.physicalSize = const Size(800, 1000);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() => tester.view.resetPhysicalSize());

    const you = Friend(name: 'You', phone: '+91 98765 11111');
    const kumar = Friend(name: 'Kumar', phone: '+91 98765 22222');
    const golya = Friend(name: 'Golya', phone: '+91 98765 33333');

    // Simulate story with unequal expenses matching user scenario (Total: ₹15,800)
    final story = Story.create(
      storyId: 'story_party_sync_test',
      title: 'Party',
      description: 'Party trip',
      createdBy: 'user_you',
      members: [
        StoryMember(
          userId: 'user_you',
          name: 'You',
          role: 'admin',
          joinedAt: DateTime.now().toIso8601String(),
        ),
        StoryMember(
          userId: 'user_kumar',
          name: 'Kumar',
          role: 'member',
          joinedAt: DateTime.now().toIso8601String(),
        ),
        StoryMember(
          userId: 'user_golya',
          name: 'Golya',
          role: 'member',
          joinedAt: DateTime.now().toIso8601String(),
        ),
      ],
      expenses: [
        StoryExpense(
          expenseId: 'exp_001',
          title: 'Stay',
          category: 'stay',
          amount: 8367.0,
          paidBy: 'user_you',
          splitType: 'equal',
          participants: ['user_you', 'user_kumar', 'user_golya'],
          shares: const [
            ExpenseShare(userId: 'user_you', amount: 2789.0),
            ExpenseShare(userId: 'user_kumar', amount: 2789.0),
            ExpenseShare(userId: 'user_golya', amount: 2789.0),
          ],
          date: DateTime.now().toIso8601String(),
        ),
        StoryExpense(
          expenseId: 'exp_002',
          title: 'Food',
          category: 'food',
          amount: 5733.0,
          paidBy: 'user_kumar',
          splitType: 'equal',
          participants: ['user_you', 'user_kumar', 'user_golya'],
          shares: const [
            ExpenseShare(userId: 'user_you', amount: 1911.0),
            ExpenseShare(userId: 'user_kumar', amount: 1911.0),
            ExpenseShare(userId: 'user_golya', amount: 1911.0),
          ],
          date: DateTime.now().toIso8601String(),
        ),
        StoryExpense(
          expenseId: 'exp_003',
          title: 'Snacks',
          category: 'food',
          amount: 1700.0,
          paidBy: 'user_golya',
          splitType: 'equal',
          participants: ['user_you', 'user_kumar', 'user_golya'],
          shares: const [
            ExpenseShare(userId: 'user_you', amount: 566.67),
            ExpenseShare(userId: 'user_kumar', amount: 566.67),
            ExpenseShare(userId: 'user_golya', amount: 566.67),
          ],
          date: DateTime.now().toIso8601String(),
        ),
      ],
    );

    await StoryRepository.instance.addStory(story);

    await tester.pumpWidget(
      MaterialApp(
        home: SplitSummaryScreen(
          groupName: 'Party',
          members: const [you, kumar, golya],
          memberExpenses: const {
            'You': 8367.0,
            'Kumar': 5733.0,
            'Golya': 1700.0,
          },
          storyId: story.storyId,
          existingStory: story,
        ),
      ),
    );
    await tester.pumpAndSettle();

    // 1. Total expense and title
    expect(find.text('Party'), findsOneWidget);
    expect(find.text('₹15,800'), findsOneWidget);

    // 2. Member breakdown verification
    // You: Gets ₹3,100
    expect(find.text('Gets ₹3,100'), findsOneWidget);
    // Kumar: Gets ₹467 (or ₹466 based on rounding)
    expect(find.byWidgetPredicate((w) =>
        w is Text &&
        (w.data == 'Gets ₹467' || w.data == 'Gets ₹466')), findsOneWidget);
    // Golya: Owes ₹3,567
    expect(find.text('Owes ₹3,567'), findsOneWidget);

    // 3. Settlement plan verification:
    // Should have 2 payments (Golya to You, Golya to Kumar)
    expect(find.text('2 payments'), findsOneWidget);
    // Golya pays You (3,100)
    expect(find.text('Golya'), findsWidgets);
    expect(find.text('Pays ₹3,100'), findsOneWidget);
    // Golya pays Kumar (467 or 466)
    expect(find.byWidgetPredicate((w) =>
        w is Text &&
        (w.data == 'Pays ₹467' || w.data == 'Pays ₹466')), findsOneWidget);
  });
}
