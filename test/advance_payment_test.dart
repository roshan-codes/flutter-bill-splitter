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

  group('Advance Payment Feature Tests', () {
    testWidgets('Add New Expense sheet allows switching to Advance/Transfer and recording an advance', (tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      final story = Story.create(
        storyId: 'story_advance_test',
        title: 'Manali Roadtrip',
        description: 'Test advance payments',
        createdBy: 'user_roshan',
        members: const [
          StoryMember(userId: 'user_roshan', name: 'Roshan', joinedAt: ''),
          StoryMember(userId: 'user_kumar', name: 'Kumar', joinedAt: ''),
          StoryMember(userId: 'user_golya', name: 'Golya', joinedAt: ''),
        ],
        expenses: const [],
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

      // Tap 'Add Expense' floating button
      final addExpenseBtn = find.text('Add Expense');
      expect(addExpenseBtn, findsOneWidget);
      await tester.tap(addExpenseBtn);
      await tester.pumpAndSettle();

      // Check mode switcher tabs exist
      expect(find.byKey(const ValueKey('expense_mode_tab')), findsOneWidget);
      final advanceTab = find.byKey(const ValueKey('advance_mode_tab'));
      expect(advanceTab, findsOneWidget);

      // Switch to Advance / Transfer mode
      await tester.tap(advanceTab);
      await tester.pumpAndSettle();

      // Verify advance mode labels
      expect(find.text('Record Advance Payment'), findsWidgets);
      expect(find.text('From (Who Paid in Advance)'), findsOneWidget);
      expect(find.text('To (Who Received Advance)'), findsOneWidget);

      // Enter amount ₹3,000
      final amountField = find.widgetWithText(TextFormField, 'Amount (₹)');
      expect(amountField, findsOneWidget);
      await tester.enterText(amountField, '3000');
      await tester.pumpAndSettle();

      // Tap 'Record Advance Payment' button
      final submitBtn = find.widgetWithText(ElevatedButton, 'Record Advance Payment');
      expect(submitBtn, findsOneWidget);
      await tester.tap(submitBtn);
      await tester.pumpAndSettle();

      // Verify total trip expenses remains ₹0 (advance is not a trip expense)
      expect(find.text('₹0'), findsWidgets);

      // Verify the advance transfer is recorded in the story expenses
      final updatedStory = StoryRepository.instance.getStoryById('story_advance_test');
      expect(updatedStory, isNotNull);
      final advanceExpense = updatedStory!.expenses.firstWhere((e) => e.category == 'advance');
      expect(advanceExpense.amount, 3000.0);
      expect(advanceExpense.paidBy, 'user_roshan');
      expect(advanceExpense.participants, contains('user_kumar'));
    });
  });
}
