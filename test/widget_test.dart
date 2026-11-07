import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bill_splitter/main.dart';

Future<void> _addFriendHelper(WidgetTester tester, String name, String phone) async {
  final addBtn = find.byTooltip('Add');
  await tester.tap(addBtn);
  await tester.pumpAndSettle();

  await tester.tap(find.text('Add New Friend'));
  await tester.pumpAndSettle();

  await tester.enterText(find.widgetWithText(TextFormField, 'Friend Name'), name);
  await tester.enterText(find.widgetWithText(TextFormField, 'Mobile Number'), phone);
  await tester.pumpAndSettle();

  await tester.tap(find.widgetWithText(ElevatedButton, 'Add'));
  await tester.pumpAndSettle();
}

void main() {
  setUp(() {
    ActivityRepository.instance.clearActivities();
  });

  testWidgets(
      'Friends tab + button shows options: Add New Friend and Create New Group',
      (WidgetTester tester) async {
    await tester.pumpWidget(const MyApp());

    // Switch to friends tab
    final friendsTab = find.byIcon(Icons.people_outline_rounded);
    await tester.tap(friendsTab);
    await tester.pumpAndSettle();

    expect(find.text('Friends'), findsWidgets);
    expect(find.text('No friends yet'), findsOneWidget);

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
    await tester.enterText(
        find.widgetWithText(TextFormField, 'Friend Name'), 'Pooja Hegde');
    await tester.enterText(
        find.widgetWithText(TextFormField, 'Mobile Number'), '+91 98765 00000');
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(ElevatedButton, 'Add'));
    await tester.pumpAndSettle();

    // Verify new friend added to the list
    expect(find.text('Pooja Hegde'), findsOneWidget);
  });

  testWidgets(
      'Friends tab allows creating a new group after adding friends',
      (WidgetTester tester) async {
    await tester.pumpWidget(const MyApp());

    // Switch to friends tab
    final friendsTab = find.byIcon(Icons.people_outline_rounded);
    await tester.tap(friendsTab);
    await tester.pumpAndSettle();

    // Add 2 friends first
    await _addFriendHelper(tester, 'Alex Johnson', '+91 98765 43210');
    await _addFriendHelper(tester, 'David Kalu', '+91 91234 56789');

    // Tap + button in Friends header to create group
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

    // Verify added friends are listed in modal
    expect(find.widgetWithText(InkWell, 'Alex Johnson'), findsOneWidget);
    expect(find.widgetWithText(InkWell, 'David Kalu'), findsOneWidget);

    // Enter group name
    await tester.enterText(
        find.widgetWithText(TextFormField, 'Group Name'), 'Weekend Trek');
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

  testWidgets(
      'AddExpenseScreen sequence: group name, selected person container, group list, search bar, friend list, and fixed continue button',
      (WidgetTester tester) async {
    await tester.pumpWidget(const MyApp());

    // Switch to friends tab and add a friend first so available friends exists
    final friendsTab = find.byIcon(Icons.people_outline_rounded);
    await tester.tap(friendsTab);
    await tester.pumpAndSettle();
    await _addFriendHelper(tester, 'Alex Johnson', '+91 98765 43210');
    await _addFriendHelper(tester, 'Sophia Martinez', '+91 99887 76655');

    // Switch to Home tab and tap Add Expense quick action tile to open AddExpenseScreen
    final homeTab = find.byIcon(Icons.home_outlined);
    await tester.tap(homeTab);
    await tester.pumpAndSettle();

    final addExpenseTile = find.textContaining('Add\nExpense');
    await tester.tap(addExpenseTile);
    await tester.pumpAndSettle();

    // Verify screen title
    expect(find.text('Add & Split Expense'), findsOneWidget);

    // Verify 1: Group Name
    expect(find.text('Group Name'), findsOneWidget);
    expect(find.widgetWithText(TextFormField, 'e.g. Goa Trip, Dinner, Flat Rent'), findsOneWidget);

    // Verify 2: Selected person container (initially empty with no dummy data)
    expect(find.text('Selected Members'), findsOneWidget);
    expect(find.text('Select friends below to add them here'), findsOneWidget);

    // Verify 3: Group list ("Select group")
    expect(find.text('Select group'), findsOneWidget);

    // Verify 4: Search name, group search bar before friends list
    expect(find.text('Search name, group'), findsOneWidget);

    // Verify 5: Friends list showing available friends
    expect(find.text('Friends'), findsWidgets);
    expect(find.text('Alex Johnson'), findsOneWidget);
    expect(find.text('Sophia Martinez'), findsOneWidget);

    // Verify 6: Fixed Continue Button (pinned, not inside scroll body)
    final continueBtn = find.widgetWithText(ElevatedButton, 'Continue');
    expect(continueBtn, findsOneWidget);

    // Test Search filter: search for 'Sophia'
    await tester.enterText(find.widgetWithText(TextField, 'Search name, group'), 'Sophia');
    await tester.pumpAndSettle();
    expect(find.text('Sophia Martinez'), findsOneWidget);
    expect(find.text('Alex Johnson'), findsNothing);

    // Clear search
    await tester.enterText(find.widgetWithText(TextField, 'Search name, group'), '');
    await tester.pumpAndSettle();
    expect(find.text('Alex Johnson'), findsOneWidget);

    // Select friend Alex Johnson from the list
    final alexItem = find.text('Alex Johnson');
    await tester.ensureVisible(alexItem);
    await tester.pumpAndSettle();
    await tester.tap(alexItem);
    await tester.pumpAndSettle();

    // Select friend Sophia Martinez as well
    final sophiaItem = find.text('Sophia Martinez');
    await tester.ensureVisible(sophiaItem);
    await tester.pumpAndSettle();
    await tester.tap(sophiaItem);
    await tester.pumpAndSettle();

    // Verify both are in the selected container with 'x' badge
    expect(find.byKey(const ValueKey('remove_selected_Alex Johnson')), findsOneWidget);
    expect(find.byKey(const ValueKey('remove_selected_Sophia Martinez')), findsOneWidget);

    // Enter group name
    await tester.enterText(
        find.widgetWithText(TextFormField, 'e.g. Goa Trip, Dinner, Flat Rent'), 'Friday Dinner');
    await tester.pumpAndSettle();

    // Tap fixed Continue button
    await tester.tap(continueBtn);
    await tester.pumpAndSettle();

    // Verify SplitDetailScreen is displayed with selected members
    expect(find.text('Split with Members'), findsOneWidget);
    expect(find.text('Friday Dinner'), findsOneWidget);
    expect(find.text('Alex Johnson'), findsOneWidget);
    expect(find.text('Sophia Martinez'), findsOneWidget);

    // Verify mobile numbers are removed from the member items
    expect(find.text('+91 98765 43210'), findsNothing);
    expect(find.text('+91 99887 76655'), findsNothing);

    // Verify Add expense button is shown for the members
    expect(find.text('Add expense'), findsNWidgets(2));

    // Tap Add expense button for Alex Johnson
    await tester.tap(find.text('Add expense').first);
    await tester.pumpAndSettle();

    // Verify dialog opens
    expect(find.textContaining('Expense for Alex Johnson'), findsOneWidget);
    await tester.enterText(find.widgetWithText(TextFormField, 'Enter amount e.g. 250'), '600');
    await tester.pumpAndSettle();

    // Save expense
    await tester.tap(find.widgetWithText(ElevatedButton, 'Save Expense'));
    await tester.pumpAndSettle();

    // Verify expense badge updated with ₹600
    expect(find.text('₹600'), findsOneWidget);
    expect(find.text('Edit expense'), findsOneWidget);

    // Tap Confirm Split to navigate to SplitSummaryScreen
    final confirmSplitBtn = find.widgetWithText(ElevatedButton, 'Confirm Split');
    await tester.tap(confirmSplitBtn);
    await tester.pumpAndSettle();

    // Verify SplitSummaryScreen is displayed
    expect(find.text('Split Summary'), findsOneWidget);
    expect(find.text('Total Expense'), findsOneWidget);
    expect(find.text('₹600'), findsOneWidget);
    expect(find.text('Each Person Pays'), findsOneWidget);
    expect(find.text('₹300'), findsWidgets);

    // Verify Who Pays Whom section clearly shows whom should pay whom
    expect(find.text('Who Pays Whom'), findsOneWidget);
    expect(find.textContaining('Sophia Martinez should pay ₹300 to Alex Johnson'), findsOneWidget);

    // Verify Member Breakdown section
    expect(find.text('Member Breakdown'), findsOneWidget);
    expect(find.text('Gets ₹300'), findsOneWidget);
    expect(find.text('Owes ₹300'), findsOneWidget);

    // Tap Done button
    final doneBtn = find.widgetWithText(ElevatedButton, 'Done');
    await tester.tap(doneBtn);
    await tester.pumpAndSettle();

    // Verify screen popped back to MainScreen and success SnackBar is shown
    expect(find.text('Split Summary'), findsNothing);
    expect(find.textContaining('Split settled successfully for "Friday Dinner"!'), findsOneWidget);

    // Switch to Activity Tab (index 2)
    final activityTab = find.byIcon(Icons.access_time_rounded);
    await tester.tap(activityTab);
    await tester.pumpAndSettle();

    // Verify Activity Tab displays the recorded split!
    expect(find.text('Activity'), findsWidgets);
    expect(find.text('Friday Dinner'), findsOneWidget);
    expect(find.text('₹600'), findsOneWidget);
    expect(find.text('₹300 / person'), findsOneWidget);
    expect(find.text('2 members'), findsOneWidget);
    expect(find.text('Sophia Martinez pays ₹300 to Alex Johnson'), findsOneWidget);

    // Tap on the activity card to open ActivityDetailSheet
    await tester.tap(find.text('Friday Dinner'));
    await tester.pumpAndSettle();

    // Verify detail sheet shows recorded split details
    expect(find.text('Recorded Split Details'), findsOneWidget);
    expect(find.text('Who Pays Whom'), findsOneWidget);
  });
}
