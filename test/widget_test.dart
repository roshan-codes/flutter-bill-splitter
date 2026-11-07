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

  testWidgets('AddExpenseScreen shows selected contacts row with x badge in container and friends list below', (WidgetTester tester) async {
    await tester.pumpWidget(const MyApp());

    // Tap center + action button in bottom bar
    final centerAddBtn = find.byIcon(Icons.add).first;
    await tester.tap(centerAddBtn);
    await tester.pumpAndSettle();

    // Verify full screen AddExpenseScreen is pushed
    expect(find.text('Add & Split Expense'), findsOneWidget);
    expect(find.text('Group Name'), findsOneWidget);

    // Verify Total Amount and Total Persons and Split Per Person are removed
    expect(find.text('Total Amount'), findsNothing);
    expect(find.text('Total Persons'), findsNothing);
    expect(find.text('Split Per Person'), findsNothing);

    // Verify friends list items appear below
    expect(find.text('Friends'), findsWidgets);
    expect(find.text('Alex Johnson'), findsOneWidget);
    expect(find.text('David Kalu'), findsOneWidget);

    // Verify close 'x' badges exist on selected contacts in the top container
    final removeAlexBtn = find.byKey(const ValueKey('remove_selected_Alex Johnson'));
    expect(removeAlexBtn, findsOneWidget);

    // Tap 'x' to remove Alex Johnson from the selected contacts container
    await tester.tap(removeAlexBtn);
    await tester.pumpAndSettle();
    expect(find.byKey(const ValueKey('remove_selected_Alex Johnson')), findsNothing);

    // Enter Group Name
    await tester.enterText(find.widgetWithText(TextFormField, 'e.g. Goa Trip, Dinner, Flat Rent'), 'Goa Trip');
    await tester.pumpAndSettle();

    // Scroll into view & tap Confirm & Split button
    final confirmBtn = find.widgetWithText(ElevatedButton, 'Confirm & Split');
    await tester.ensureVisible(confirmBtn);
    await tester.pumpAndSettle();
    await tester.tap(confirmBtn);
    await tester.pumpAndSettle();

    // Verify screen popped back to MainScreen and SnackBar is shown
    expect(find.text('Add & Split Expense'), findsNothing);
    expect(find.textContaining('Group "Goa Trip" created'), findsOneWidget);
  });
}
