import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_bill_splitter/features/expenses/presentation/screens/add_expense_screen.dart';
import 'package:flutter_bill_splitter/features/expenses/presentation/screens/split_detail_screen.dart';
import 'package:flutter_bill_splitter/features/expenses/presentation/screens/split_summary_screen.dart';
import 'package:flutter_bill_splitter/features/expenses/presentation/widgets/friend_selection_tile.dart';
import 'package:flutter_bill_splitter/features/friends/domain/models/friend.dart';
import 'package:flutter_bill_splitter/features/onboarding/presentation/screens/onboarding_screen.dart';

void main() {
  group('Apple HIG Compliance Tests', () {
    testWidgets('Back button in AddExpenseScreen has at least 44x44pt hit target and semantic label',
        (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: AddExpenseScreen(friends: [], groups: []),
        ),
      );

      final backButtonFinder = find.byTooltip('Back');
      expect(backButtonFinder, findsOneWidget);

      final renderBox = tester.renderObject<RenderBox>(backButtonFinder);
      expect(renderBox.size.width, greaterThanOrEqualTo(44.0));
      expect(renderBox.size.height, greaterThanOrEqualTo(44.0));
    });

    testWidgets('Back button in SplitDetailScreen has at least 44x44pt hit target and semantic label',
        (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: SplitDetailScreen(
            groupName: 'Dinner',
            members: [Friend(name: 'Vinit', phone: '+91 98765 11111')],
          ),
        ),
      );

      final backButtonFinder = find.byTooltip('Back');
      expect(backButtonFinder, findsOneWidget);

      final renderBox = tester.renderObject<RenderBox>(backButtonFinder);
      expect(renderBox.size.width, greaterThanOrEqualTo(44.0));
      expect(renderBox.size.height, greaterThanOrEqualTo(44.0));
    });

    testWidgets('Back button in SplitSummaryScreen has at least 44x44pt hit target and semantic label',
        (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: SplitSummaryScreen(
            groupName: 'Dinner',
            members: [Friend(name: 'Vinit', phone: '+91 98765 11111')],
            memberExpenses: {'Vinit': 500.0},
          ),
        ),
      );

      final backButtonFinder = find.byTooltip('Back');
      expect(backButtonFinder, findsOneWidget);

      final renderBox = tester.renderObject<RenderBox>(backButtonFinder);
      expect(renderBox.size.width, greaterThanOrEqualTo(44.0));
      expect(renderBox.size.height, greaterThanOrEqualTo(44.0));
    });

    testWidgets('FriendSelectionTile declares checkbox semantics and is interactive',
        (tester) async {
      bool toggled = false;
      const friend = Friend(name: 'Saurabh', phone: '+91 98765 33333');

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: FriendSelectionTile(
              friend: friend,
              isSelected: true,
              onToggle: () => toggled = true,
            ),
          ),
        ),
      );

      // Verify semantics
      expect(
        tester.getSemantics(find.byType(FriendSelectionTile)),
        matchesSemantics(
          label: 'Saurabh',
          isChecked: true,
          isButton: true,
          hasCheckedState: true,
          hasTapAction: true,
          hasEnabledState: true,
          isEnabled: true,
        ),
      );

      await tester.tap(find.byType(FriendSelectionTile));
      await tester.pumpAndSettle();
      expect(toggled, isTrue);
    });

    testWidgets('OnboardingScreen supports horizontal swiping across PageView',
        (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: OnboardingScreen(),
        ),
      );

      // Initially on page 1
      expect(find.textContaining('Split Expenses'), findsOneWidget);

      // Swipe left to page 2
      await tester.drag(find.byType(PageView), const Offset(-400, 0));
      await tester.pumpAndSettle();

      // Verify page 2 headline
      expect(find.textContaining('Real-Time Balance'), findsOneWidget);

      // Swipe left to page 3
      await tester.drag(find.byType(PageView), const Offset(-400, 0));
      await tester.pumpAndSettle();

      // Verify page 3 headline
      expect(find.textContaining('Settle Up with'), findsOneWidget);
    });
  });
}
