import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bill_splitter/main.dart';

void main() {
  testWidgets('Renders bottom navigation bar and switches tabs', (WidgetTester tester) async {
    await tester.pumpWidget(const MyApp());

    // Initially on Home tab
    expect(find.text('Home'), findsWidgets);

    // Tap on friends tab
    final friendsTab = find.byIcon(Icons.people_outline_rounded);
    expect(friendsTab, findsOneWidget);
    await tester.tap(friendsTab);
    await tester.pumpAndSettle();

    // Now on Friends tab
    expect(find.text('Friends'), findsOneWidget);

    // Verify + button exists in Friends header row
    final addFriendBtn = find.byTooltip('Add Friend');
    expect(addFriendBtn, findsOneWidget);

    // Tap + button to open Add Friend dialog
    await tester.tap(addFriendBtn);
    await tester.pumpAndSettle();

    expect(find.text('Add Friend'), findsOneWidget);
    expect(find.text('Friend Name'), findsOneWidget);
    expect(find.text('Mobile Number'), findsOneWidget);

    // Enter name & phone
    await tester.enterText(find.widgetWithText(TextFormField, 'Friend Name'), 'Pooja Hegde');
    await tester.enterText(find.widgetWithText(TextFormField, 'Mobile Number'), '+91 98765 00000');
    await tester.pumpAndSettle();

    // Tap Add button
    await tester.tap(find.widgetWithText(ElevatedButton, 'Add'));
    await tester.pumpAndSettle();

    // Verify newly added friend appears in the list
    expect(find.text('Pooja Hegde'), findsOneWidget);
    expect(find.text('+91 98765 00000'), findsOneWidget);
  });

  testWidgets('Add Expense bottom sheet calculates split between persons', (WidgetTester tester) async {
    await tester.pumpWidget(const MyApp());

    // Tap center + action button in bottom bar
    final centerAddBtn = find.byIcon(Icons.add).first;
    await tester.tap(centerAddBtn);
    await tester.pumpAndSettle();

    // Verify modal is open
    expect(find.text('Add & Split Expense'), findsOneWidget);
    expect(find.text('Group Name'), findsOneWidget);
    expect(find.text('Total Amount'), findsOneWidget);
    expect(find.text('Total Person'), findsOneWidget);

    // Enter Group Name: 'Goa Trip', Amount: '3000', Persons: '3'
    await tester.enterText(find.widgetWithText(TextFormField, 'Group Name'), 'Goa Trip');
    await tester.enterText(find.widgetWithText(TextFormField, 'Total Amount'), '3000');
    await tester.enterText(find.widgetWithText(TextFormField, 'Total Person'), '3');
    await tester.pumpAndSettle();

    // Calculated split: 3000 / 3 = ₹1000.00
    expect(find.text('₹1000.00'), findsOneWidget);
    expect(find.text('Group: Goa Trip'), findsOneWidget);

    // Tap Confirm & Split
    await tester.tap(find.widgetWithText(ElevatedButton, 'Confirm & Split'));
    await tester.pumpAndSettle();

    // Verify modal dismissed and SnackBar shown
    expect(find.text('Add & Split Expense'), findsNothing);
    expect(find.textContaining('Expense for "Goa Trip" split: ₹1000.00'), findsOneWidget);
  });
}
