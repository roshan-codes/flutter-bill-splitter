import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_bill_splitter/features/friends/presentation/screens/friends_tab.dart';
import 'package:flutter_bill_splitter/main.dart';

Future<void> _addFriendHelper(
    WidgetTester tester, String name, String phone) async {
  final addBtn = find.byTooltip('Add');
  await tester.tap(addBtn);
  await tester.pumpAndSettle();

  await tester.tap(find.text('Add New Friend'));
  await tester.pumpAndSettle();

  await tester.enterText(
      find.widgetWithText(TextFormField, 'Friend Name'), name);
  await tester.enterText(
      find.widgetWithText(TextFormField, 'Mobile Number'), phone);
  await tester.pumpAndSettle();

  await tester.tap(find.widgetWithText(ElevatedButton, 'Add'));
  await tester.pumpAndSettle();
}

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
    ActivityRepository.instance.clearActivities();
    FriendsRepository.instance.clearAll();
  });

  testWidgets(
      'Friends screen + button shows options: Add New Friend and Create New Group',
      (WidgetTester tester) async {
    await tester.pumpWidget(const MyApp(home: MainScreen()));

    // Switch to profile tab and tap Friends
    final profileTab = find.byIcon(Icons.person_outline_rounded);
    await tester.tap(profileTab);
    await tester.pumpAndSettle();

    await tester.tap(find.text('Friends'));
    await tester.pumpAndSettle();

    expect(find.text('Friends'), findsWidgets);
    expect(find.text('No friends yet'), findsOneWidget);

    // Tap + button in Friends header
    final addBtn = find.byTooltip('Add');
    expect(addBtn, findsOneWidget);
    await tester.tap(addBtn);
    await tester.pumpAndSettle();

    // Verify Choose an Option modal displays all three options without subtitles
    expect(find.text('Choose an Option'), findsOneWidget);
    expect(find.text('Add New Friend'), findsOneWidget);
    expect(find.text('Import from Contacts'), findsOneWidget);
    expect(find.text('Create New Group'), findsOneWidget);
    expect(
        find.text('Add an individual friend with name & phone'), findsNothing);
    expect(find.text('Select multiple friends to create a split group'),
        findsNothing);

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
      'Friends screen + button -> Import from Contacts opens bottom sheet and imports contact',
      (WidgetTester tester) async {
    await tester.pumpWidget(const MyApp(home: MainScreen()));

    // Switch to profile tab and tap Friends
    final profileTab = find.byIcon(Icons.person_outline_rounded);
    await tester.tap(profileTab);
    await tester.pumpAndSettle();

    await tester.tap(find.text('Friends'));
    await tester.pumpAndSettle();

    // Tap + button
    final addBtn = find.byTooltip('Add');
    await tester.tap(addBtn);
    await tester.pumpAndSettle();

    // Tap 'Import from Contacts'
    await tester.tap(find.text('Import from Contacts'));
    await tester.pumpAndSettle();

    // Verify Import Contacts bottom sheet is displayed
    expect(find.text('Search contacts...'), findsOneWidget);
    expect(find.text('Rahul Sharma'), findsOneWidget);

    // Tap contact to select
    await tester.tap(find.text('Rahul Sharma'));
    await tester.pumpAndSettle();

    // Verify button says 'Import 1 Contact'
    expect(find.widgetWithText(ElevatedButton, 'Import 1 Contact'),
        findsOneWidget);

    // Tap import button
    await tester.tap(find.widgetWithText(ElevatedButton, 'Import 1 Contact'));
    await tester.pumpAndSettle();

    // Verify contact imported into Friends screen
    expect(find.text('Rahul Sharma'), findsOneWidget);
  });

  testWidgets('Friends screen allows creating a new group after adding friends',
      (WidgetTester tester) async {
    await tester.pumpWidget(const MyApp(home: MainScreen()));

    // Switch to profile tab and tap Friends
    final profileTab = find.byIcon(Icons.person_outline_rounded);
    await tester.tap(profileTab);
    await tester.pumpAndSettle();

    await tester.tap(find.text('Friends'));
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

    // Verify group was created and shows in Groups list
    expect(find.text('Weekend Trek'), findsOneWidget);
    expect(find.text('2 members'), findsOneWidget);
  });

  testWidgets(
      'CreateStoryScreen sequence: story name, add members modal, and create story navigation',
      (WidgetTester tester) async {
    // Add friends directly to repository
    FriendsRepository.instance.addFriend(
        const Friend(name: 'Alex Johnson', phone: '+91 98765 43210'));
    FriendsRepository.instance.addFriend(
        const Friend(name: 'Sophia Martinez', phone: '+91 99887 76655'));

    await tester.pumpWidget(const MyApp(home: MainScreen()));

    // Tap Add Story hero action pill to open CreateStoryScreen
    final addStoryButton = find.byTooltip('Add Story');
    expect(addStoryButton, findsOneWidget);
    await tester.tap(addStoryButton);
    await tester.pumpAndSettle();

    // Verify screen title
    expect(find.text('Create Story'), findsWidgets);

    // Enter story name
    final nameInput = find.widgetWithText(TextField, 'Mumbai Trip');
    expect(nameInput, findsOneWidget);
    await tester.enterText(nameInput, 'Friday Dinner');
    await tester.pumpAndSettle();

    // Tap Add Member '+' icon to open member sheet
    final addMemberBtn = find.byIcon(Icons.add_rounded);
    expect(addMemberBtn, findsOneWidget);
    await tester.tap(addMemberBtn);
    await tester.pumpAndSettle();

    // Select Alex Johnson from existing friends filter chips
    final alexChip = find.text('Alex Johnson');
    expect(alexChip, findsOneWidget);
    await tester.tap(alexChip);
    await tester.pumpAndSettle();

    // Select Sophia Martinez
    final sophiaChip = find.text('Sophia Martinez');
    expect(sophiaChip, findsOneWidget);
    await tester.tap(sophiaChip);
    await tester.pumpAndSettle();

    // Close the member sheet by tapping outside or back
    await tester.tapAt(const Offset(20, 50));
    await tester.pumpAndSettle();

    // Tap Create Story button
    final createStoryBtn =
        find.widgetWithText(ElevatedButton, 'Create Story');
    expect(createStoryBtn, findsOneWidget);
    await tester.tap(createStoryBtn);
    await tester.pumpAndSettle();

    // Verify SplitDetailScreen is displayed with selected members
    expect(find.text('Split with Members'), findsOneWidget);
    expect(find.text('Friday Dinner'), findsOneWidget);
    expect(find.text('Alex Johnson'), findsOneWidget);
    expect(find.text('Sophia Martinez'), findsOneWidget);

    // Verify mobile numbers are removed from the member items
    expect(find.text('+91 98765 43210'), findsNothing);
    expect(find.text('+91 99887 76655'), findsNothing);

    // Verify Add expense button is shown for all members
    expect(find.text('Add expense'), findsWidgets);

    // Tap Add expense button for Alex Johnson
    await tester.tap(find.text('Add expense').first);
    await tester.pumpAndSettle();

    // Verify dialog opens
    expect(find.textContaining('Expense for'), findsOneWidget);
    await tester.enterText(
        find.widgetWithText(TextFormField, 'Enter amount e.g. 250'), '600');
    await tester.pumpAndSettle();

    // Save expense
    await tester.tap(find.widgetWithText(ElevatedButton, 'Save Expense'));
    await tester.pumpAndSettle();

    // Verify expense badge updated with ₹600
    expect(find.text('₹600'), findsWidgets);
    expect(find.text('Edit expense'), findsOneWidget);

    // Tap Confirm Split to navigate to SplitSummaryScreen
    final confirmSplitBtn =
        find.widgetWithText(ElevatedButton, 'Confirm Split');
    await tester.tap(confirmSplitBtn);
    await tester.pumpAndSettle();

    // Verify SplitSummaryScreen is displayed
    expect(find.text('Split Summary'), findsOneWidget);
    expect(find.text('Total Expense'), findsOneWidget);
    expect(find.text('₹600'), findsWidgets);
    expect(find.text('Each Pays'), findsOneWidget);
    expect(find.text('₹200'), findsWidgets);

    // Verify Who Pays Whom section clearly shows whom should pay whom
    expect(find.text('Who Pays Whom'), findsOneWidget);

    // Verify Member Breakdown section
    expect(find.text('Member Breakdown'), findsOneWidget);

    // Tap Save & Track Settlement button
    final saveBtn =
        find.widgetWithText(ElevatedButton, 'Save & Track Settlement');
    await tester.tap(saveBtn);
    await tester.pumpAndSettle();

    // Verify screen popped back to MainScreen and success SnackBar is shown
    expect(find.text('Split Summary'), findsNothing);
    expect(
        find.textContaining('Split settled successfully for "Friday Dinner"!'),
        findsOneWidget);

    // Switch to Activity Tab (index 2)
    final activityTab = find.byIcon(Icons.access_time_rounded);
    await tester.tap(activityTab);
    await tester.pumpAndSettle();

    // Verify Activity Tab displays the recorded split!
    expect(find.text('Activity'), findsWidgets);
    expect(find.text('Friday Dinner'), findsWidgets);
    expect(find.text('₹600'), findsWidgets);
    expect(find.text('₹200 / person'), findsWidgets);
    expect(find.text('3 members'), findsWidgets);

    // Tap on the activity card to open ActivityDetailSheet
    await tester.tap(find.text('Friday Dinner').first);
    await tester.pumpAndSettle();

    // Verify detail sheet shows recorded split details
    expect(find.text('Recorded Split Details'), findsOneWidget);
    expect(find.text('Who Pays Whom'), findsOneWidget);
  });

  testWidgets(
      'MainScreen has 3 tabs and Profile tab has Friends and Groups options',
      (WidgetTester tester) async {
    await tester.pumpWidget(const MyApp(home: MainScreen()));

    // Verify only 3 tabs in bottom nav: Home, Activity, Profile (Friends removed)
    expect(find.text('Home'), findsWidgets);
    expect(find.text('Activity'), findsWidgets);
    expect(find.text('Profile'), findsWidgets);
    expect(find.byIcon(Icons.people_outline_rounded), findsNothing);

    // Switch to Profile tab
    await tester.tap(find.byIcon(Icons.person_outline_rounded));
    await tester.pumpAndSettle();

    // Verify Friends and Groups options are in ProfileMenuCard
    expect(find.text('Friends'), findsOneWidget);
    expect(find.text('Groups'), findsOneWidget);

    // Tap Friends -> navigates to Friends screen with back button
    await tester.tap(find.text('Friends'));
    await tester.pumpAndSettle();
    expect(find.byType(FriendsTab), findsOneWidget);
    expect(find.text('No friends yet'), findsOneWidget);

    // Tap Back button -> returns to Profile tab
    final backBtn = find.byType(PlatformBackButton);
    expect(backBtn, findsOneWidget);
    await tester.tap(backBtn);
    await tester.pumpAndSettle();

    expect(find.text('Guest User'), findsOneWidget);

    // Tap Groups -> navigates to Groups list
    await tester.tap(find.text('Groups'));
    await tester.pumpAndSettle();
    expect(find.byType(FriendsTab), findsOneWidget);
    expect(find.text('No groups yet'), findsOneWidget);
  });
}
