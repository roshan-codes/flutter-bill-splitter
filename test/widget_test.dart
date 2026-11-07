import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bill_splitter/main.dart';

void main() {
  testWidgets('Friends tab + button shows options: Add New Friend and Create New Group', (WidgetTester tester) async {
    await tester.pumpWidget(const MyApp());

    // Switch to friends tab
    final friendsTab = find.byIcon(Icons.people_outline_rounded);
    await tester.tap(friendsTab);
    await tester.pumpAndSettle();

    expect(find.text('Friends'), findsWidgets);

    // Tap + button in Friends header
    final addBtn = find.byTooltip('Add');
    expect(addBtn, findsOneWidget);
    await tester.tap(addBtn);
    await tester.pumpAndSettle();

    // Verify Choose an Option modal displays both options
    expect(find.text('Choose an Option'), findsOneWidget);
    expect(find.text('Add New Friend'), findsOneWidget);
    expect(find.text('Create New Group'), findsOneWidget);

    // Select 'Add New Friend'
    await tester.tap(find.text('Add New Friend'));
    await tester.pumpAndSettle();

    // Verify Add Friend dialog is shown
    expect(find.text('Add Friend'), findsOneWidget);
    expect(find.text('Friend Name'), findsOneWidget);
    expect(find.text('Mobile Number'), findsOneWidget);

    // Enter details & submit
    await tester.enterText(find.widgetWithText(TextFormField, 'Friend Name'), 'Pooja Hegde');
    await tester.enterText(find.widgetWithText(TextFormField, 'Mobile Number'), '+91 98765 00000');
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(ElevatedButton, 'Add'));
    await tester.pumpAndSettle();

    // Verify new friend added to the list
    expect(find.text('Pooja Hegde'), findsOneWidget);
  });

  testWidgets('Friends tab + button allows creating a new group with available friends', (WidgetTester tester) async {
    await tester.pumpWidget(const MyApp());

    // Switch to friends tab
    final friendsTab = find.byIcon(Icons.people_outline_rounded);
    await tester.tap(friendsTab);
    await tester.pumpAndSettle();

    // Tap + button in Friends header
    final addBtn = find.byTooltip('Add');
    await tester.tap(addBtn);
    await tester.pumpAndSettle();

    // Select 'Create New Group'
    await tester.tap(find.text('Create New Group'));
    await tester.pumpAndSettle();

    // Verify Create New Group bottom sheet is shown
    expect(find.text('Create New Group'), findsOneWidget);
    expect(find.text('Group Name'), findsOneWidget);
    expect(find.text('Select Members'), findsOneWidget);

    // Verify available friends are listed in modal
    expect(find.widgetWithText(InkWell, 'Alex Johnson'), findsOneWidget);
    expect(find.widgetWithText(InkWell, 'David Kalu'), findsOneWidget);

    // Enter group name
    await tester.enterText(find.widgetWithText(TextFormField, 'Group Name'), 'Weekend Trek');
    await tester.pumpAndSettle();

    // Select friends (Alex Johnson and David Kalu)
    await tester.tap(find.widgetWithText(InkWell, 'Alex Johnson'));
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(InkWell, 'David Kalu'));
    await tester.pumpAndSettle();

    expect(find.text('2 selected'), findsOneWidget);

    // Tap Create Group
    await tester.tap(find.widgetWithText(ElevatedButton, 'Create Group'));
    await tester.pumpAndSettle();

    // Verify group was created and shows in Groups tab
    expect(find.text('Weekend Trek'), findsOneWidget);
    expect(find.text('2 members'), findsOneWidget);
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

    // Verify Available Groups horizontal section is rendered
    expect(find.text('Available Groups'), findsOneWidget);
    expect(find.text('3 groups'), findsOneWidget);
    expect(find.text('Goa Trip'), findsWidgets);
    expect(find.text('Flatmates'), findsOneWidget);
    expect(find.text('Office Lunch'), findsOneWidget);

    // Tap 'Flatmates' group chip
    await tester.tap(find.text('Flatmates'));
    await tester.pumpAndSettle();

    // Verify group name text field is populated with 'Flatmates'
    final groupField = find.widgetWithText(TextFormField, 'Flatmates');
    expect(groupField, findsOneWidget);

    // Scroll into view & tap Confirm & Split button
    final confirmBtn = find.widgetWithText(ElevatedButton, 'Confirm & Split');
    await tester.ensureVisible(confirmBtn);
    await tester.pumpAndSettle();
    await tester.tap(confirmBtn);
    await tester.pumpAndSettle();

    // Verify screen popped back to MainScreen and SnackBar is shown
    expect(find.text('Add & Split Expense'), findsNothing);
    expect(find.textContaining('Group "Flatmates" created'), findsOneWidget);
  });
}
