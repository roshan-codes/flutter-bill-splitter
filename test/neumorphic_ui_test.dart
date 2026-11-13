import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:floating_pill_navbar/floating_pill_navbar.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_bill_splitter/features/activity/presentation/screens/activity_tab.dart';
import 'package:flutter_bill_splitter/features/expenses/presentation/screens/add_expense_screen.dart';
import 'package:flutter_bill_splitter/features/expenses/presentation/screens/split_detail_screen.dart';
import 'package:flutter_bill_splitter/features/expenses/presentation/screens/split_summary_screen.dart';
import 'package:flutter_bill_splitter/features/expenses/presentation/widgets/search_name_group_bar.dart';
import 'package:flutter_bill_splitter/features/friends/data/repositories/friends_repository.dart';
import 'package:flutter_bill_splitter/features/friends/domain/models/friend.dart';
import 'package:flutter_bill_splitter/features/home/presentation/screens/home_tab.dart';
import 'package:flutter_bill_splitter/features/home/presentation/widgets/recent_expenses_card.dart';
import 'package:flutter_bill_splitter/features/navigation/presentation/screens/main_screen.dart';
import 'package:flutter_bill_splitter/features/onboarding/presentation/screens/onboarding_screen.dart';
import 'package:flutter_bill_splitter/features/onboarding/presentation/screens/splash_screen.dart';
import 'package:flutter_bill_splitter/features/profile/presentation/screens/profile_tab.dart';
import 'package:flutter_bill_splitter/features/profile/presentation/widgets/profile_logout_button.dart';
import 'package:flutter_bill_splitter/shared/widgets/empty_state_view.dart';
import 'package:flutter_bill_splitter/shared/widgets/platform_adaptive.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
    FriendsRepository.instance.clearAll();
  });

  group('Platform Adaptive UI Tests (Material for Android, Cupertino for iOS)', () {
    testWidgets('PlatformCard renders Material Card on Android', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData(platform: TargetPlatform.android),
          home: const Scaffold(
            body: PlatformCard(
              borderRadius: 20,
              elevation: 2,
              child: Text('Card Content'),
            ),
          ),
        ),
      );

      expect(find.byType(Card), findsOneWidget);
      expect(find.text('Card Content'), findsOneWidget);
    });

    testWidgets('PlatformCard renders iOS styled container on iOS', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData(platform: TargetPlatform.iOS),
          home: const Scaffold(
            body: PlatformCard(
              borderRadius: 20,
              child: Text('iOS Card Content'),
            ),
          ),
        ),
      );

      expect(find.byType(Card), findsNothing);
      expect(find.text('iOS Card Content'), findsOneWidget);
    });

    testWidgets('PlatformInsetContainer renders container on both platforms', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: PlatformInsetContainer(
              borderRadius: 16,
              child: Text('Inset Content'),
            ),
          ),
        ),
      );

      expect(find.text('Inset Content'), findsOneWidget);
    });

    testWidgets('EmptyStateView renders with clean icon container without neumorphism', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: EmptyStateView(
              icon: Icons.receipt_long_rounded,
              title: 'No Activity Yet',
              subtitle: 'Confirmed splits will appear here.',
            ),
          ),
        ),
      );

      expect(find.text('No Activity Yet'), findsOneWidget);
      expect(find.text('Confirmed splits will appear here.'), findsOneWidget);
      expect(find.byIcon(Icons.receipt_long_rounded), findsOneWidget);
    });

    testWidgets('SearchNameGroupBar renders with text field and action button', (tester) async {
      final controller = TextEditingController();
      bool searchPressed = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SearchNameGroupBar(
              controller: controller,
              onChanged: (_) {},
              onSearchPressed: () => searchPressed = true,
            ),
          ),
        ),
      );

      expect(find.byType(TextField), findsOneWidget);
      expect(find.byType(IconButton), findsOneWidget);

      await tester.tap(find.byType(IconButton));
      await tester.pumpAndSettle();
      expect(searchPressed, isTrue);
    });

    testWidgets('MainScreen renders FloatingPillNavBar on Android with Add Story hero pill', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData(platform: TargetPlatform.android),
          home: const MainScreen(),
        ),
      );

      expect(find.byType(FloatingPillNavBar), findsOneWidget);
      expect(find.text('Home'), findsOneWidget);
      expect(find.text('Activity'), findsOneWidget);
      expect(find.text('Profile'), findsOneWidget);

      // Verify Add Story hero pill action button
      expect(find.byTooltip('Add Story'), findsOneWidget);
      await tester.tap(find.byTooltip('Add Story'));
      await tester.pumpAndSettle();

      expect(find.byType(AddExpenseScreen), findsOneWidget);
    });

    testWidgets('MainScreen renders FloatingPillNavBar on iOS with Add Story hero pill', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData(platform: TargetPlatform.iOS),
          home: const MainScreen(),
        ),
      );

      expect(find.byType(FloatingPillNavBar), findsOneWidget);
      expect(find.text('Home'), findsOneWidget);
      expect(find.text('Activity'), findsOneWidget);
      expect(find.text('Profile'), findsOneWidget);
      expect(find.byTooltip('Add Story'), findsOneWidget);
    });

    testWidgets('HomeTab renders screenshot-matching UI elements', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: HomeTab(
            youGetAmount: 2340.0,
            youOweAmount: 860.0,
            customExpenses: RecentExpensesCard.sampleExpenses,
          ),
        ),
      );

      // Verify header greeting & user name (app logo bolt removed from home tab)
      expect(find.textContaining('Good'), findsOneWidget);
      expect(find.text('Roshan'), findsOneWidget);
      expect(find.text('👋'), findsOneWidget);
      expect(find.byIcon(Icons.bolt_rounded), findsNothing);
      expect(find.byIcon(Icons.notifications_none_rounded), findsOneWidget);

      // Verify Scan Bill and Settle Up are removed from Home tab
      expect(find.text('Scan Bill'), findsNothing);
      expect(find.text('Settle Up'), findsNothing);

      // Verify Floating Action Button is removed from Home tab
      expect(find.byType(FloatingActionButton), findsNothing);
      expect(find.text('Create story'), findsNothing);

      // Verify Your Balance card is removed from Home tab
      expect(find.text('Your Balance'), findsNothing);

      // Verify Recent Expenses section & items
      expect(find.text('Recent Expenses'), findsOneWidget);
      expect(find.text('Dinner at Sakali'), findsOneWidget);
      expect(find.text('Sakali  •  3 members'), findsOneWidget);
      expect(find.text('₹549'), findsOneWidget);
      expect(find.text('Goa Trip Fuel'), findsOneWidget);
      expect(find.text('Trip  •  4 members'), findsOneWidget);
      expect(find.text('₹2,800'), findsOneWidget);
      expect(find.text('Groceries'), findsOneWidget);
      expect(find.text('Home  •  2 members'), findsOneWidget);
      expect(find.text('₹620'), findsOneWidget);
    });

    testWidgets('ProfileTab renders adaptive UI elements and Material dialog on Android', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData(platform: TargetPlatform.android),
          home: const ProfileTab(),
        ),
      );

      // Verify Header
      expect(find.text('Profile'), findsOneWidget);
      expect(find.byIcon(Icons.edit_outlined), findsOneWidget);

      // Verify Avatar & User Info
      expect(find.text('R'), findsOneWidget);
      expect(find.text('Roshan Badwaik'), findsOneWidget);
      expect(find.text('+91 9876543210'), findsOneWidget);

      // Verify Menu Items
      expect(find.text('Edit Profile'), findsOneWidget);
      expect(find.byIcon(Icons.person_outline_rounded), findsOneWidget);

      expect(find.text('Payment & Settlement'), findsOneWidget);
      expect(find.byIcon(Icons.account_balance_wallet_outlined), findsOneWidget);

      expect(find.text('App Settings'), findsOneWidget);
      expect(find.byIcon(Icons.settings_outlined), findsOneWidget);

      expect(find.text('Help & Support'), findsOneWidget);
      expect(find.byIcon(Icons.help_outline_rounded), findsOneWidget);

      expect(find.text('About TTMM'), findsOneWidget);
      expect(find.byIcon(Icons.info_outline_rounded), findsOneWidget);

      // Verify Logout Button
      expect(find.text('Logout'), findsOneWidget);
      expect(find.byIcon(Icons.logout_rounded), findsOneWidget);

      // Tap Logout button and verify Material AlertDialog opens on Android
      await tester.ensureVisible(find.byType(ProfileLogoutButton));
      await tester.tap(find.byType(ProfileLogoutButton));
      await tester.pumpAndSettle();
      expect(find.byType(AlertDialog), findsOneWidget);
      expect(find.text('Confirm Logout'), findsOneWidget);
      expect(find.text('Are you sure you want to log out of TTMM?'), findsOneWidget);
    });

    testWidgets('ProfileTab renders Cupertino dialog on iOS', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData(platform: TargetPlatform.iOS),
          home: const ProfileTab(),
        ),
      );

      await tester.ensureVisible(find.byType(ProfileLogoutButton));
      await tester.tap(find.byType(ProfileLogoutButton));
      await tester.pumpAndSettle();
      expect(find.byType(CupertinoAlertDialog), findsOneWidget);
    });

    testWidgets('ActivityTab renders UI elements without filter bar', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: ActivityTab(
            customItems: [
              ...ActivityTab.sampleThisWeek,
              ...ActivityTab.sampleLastWeek,
            ],
          ),
        ),
      );

      // Verify Header
      expect(find.text('Activity'), findsOneWidget);

      // Verify Segmented Filter Pills are removed
      expect(find.text('All'), findsNothing);
      expect(find.text('Expenses'), findsNothing);
      expect(find.text('Settlements'), findsNothing);

      // Verify Section Headers
      expect(find.text('This Week'), findsOneWidget);
      expect(find.text('Last Week'), findsOneWidget);

      // Verify This Week items
      expect(find.text('Dinner at Sakali'), findsOneWidget);
      expect(find.text('You get ₹317'), findsOneWidget);
      expect(find.text('₹549'), findsOneWidget);

      expect(find.text('Groceries'), findsOneWidget);
      expect(find.text('Settled'), findsNWidgets(2)); // Groceries & Movie Night
      expect(find.text('₹620'), findsOneWidget);

      expect(find.text('Goa Trip Fuel'), findsOneWidget);
      expect(find.text('You owe ₹700'), findsOneWidget);
      expect(find.text('₹2,800'), findsOneWidget);

      // Verify Last Week items
      expect(find.text('Movie Night'), findsOneWidget);
      expect(find.text('₹480'), findsOneWidget);
    });

    testWidgets('AddExpenseScreen renders adaptive UI elements', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: AddExpenseScreen(
            friends: AddExpenseScreen.sampleFriends,
            groups: [],
          ),
        ),
      );

      // Verify Header
      expect(find.text('Add & Split Expense'), findsOneWidget);
      expect(find.byTooltip('Back'), findsOneWidget);

      // Verify Expense Title Section
      expect(find.text('Expense Title'), findsOneWidget);
      expect(find.widgetWithText(TextFormField, 'e.g. Dinner, Groceries, Trip'), findsOneWidget);
      expect(find.byIcon(Icons.restaurant_rounded), findsOneWidget);

      // Verify Friends & Groups Toggle
      expect(find.text('Friends'), findsWidgets);
      expect(find.text('Groups'), findsOneWidget);

      // Verify Search Bar
      expect(find.widgetWithText(TextField, 'Search friends...'), findsOneWidget);

      // Verify default screenshot friends
      expect(find.text('Vinit'), findsOneWidget);
      expect(find.text('Nishant'), findsOneWidget);
      expect(find.text('Saurabh'), findsOneWidget);
      expect(find.text('Harshal'), findsOneWidget);

      // Verify Continue button
      expect(find.widgetWithText(ElevatedButton, 'Continue'), findsOneWidget);
      expect(find.byIcon(Icons.arrow_forward_rounded), findsOneWidget);
    });

    testWidgets('SplitDetailScreen renders adaptive UI elements', (tester) async {
      final members = [
        const Friend(name: 'Vinit', phone: '+91 98765 11111'),
        const Friend(name: 'Nishant', phone: '+91 98765 22222'),
        const Friend(name: 'Saurabh', phone: '+91 98765 33333'),
      ];

      await tester.pumpWidget(
        MaterialApp(
          home: SplitDetailScreen(
            groupName: 'Lunch',
            members: members,
          ),
        ),
      );

      // Verify Header
      expect(find.text('Split with Members'), findsOneWidget);
      expect(find.byTooltip('Back'), findsOneWidget);

      // Verify Summary Card
      expect(find.text('Lunch'), findsOneWidget);
      expect(find.text('3 members included in split'), findsOneWidget);
      expect(find.byIcon(Icons.groups_rounded), findsOneWidget);

      // Verify Member Badges
      expect(find.text('V'), findsNWidgets(2)); // Avatar badge + member card avatar
      expect(find.text('N'), findsNWidgets(2));
      expect(find.text('S'), findsNWidgets(2));

      // Verify Section Header
      expect(find.text('Selected Members'), findsOneWidget);
      expect(find.text('3 total'), findsOneWidget);

      // Verify Member Cards & "+ Add expense"
      expect(find.text('Vinit'), findsOneWidget);
      expect(find.text('Nishant'), findsOneWidget);
      expect(find.text('Saurabh'), findsOneWidget);
      expect(find.text('Add expense'), findsNWidgets(3));

      // Verify Confirm Split button
      expect(find.widgetWithText(ElevatedButton, 'Confirm Split'), findsOneWidget);
      expect(find.byIcon(Icons.arrow_forward_rounded), findsOneWidget);
    });

    testWidgets('SplitSummaryScreen renders adaptive UI elements', (tester) async {
      final members = [
        const Friend(name: 'Vinit', phone: '+91 98765 11111'),
        const Friend(name: 'Nishant', phone: '+91 98765 22222'),
        const Friend(name: 'Saurabh', phone: '+91 98765 33333'),
      ];
      final memberExpenses = {
        'Vinit': 500.0,
        'Nishant': 49.0,
        'Saurabh': 0.0,
      };

      await tester.pumpWidget(
        MaterialApp(
          home: SplitSummaryScreen(
            groupName: 'Dinner at Sakali',
            members: members,
            memberExpenses: memberExpenses,
          ),
        ),
      );

      // Verify Header
      expect(find.text('Split Summary'), findsOneWidget);
      expect(find.byTooltip('Back'), findsOneWidget);

      // Verify Title & Members Card
      expect(find.text('Dinner at Sakali'), findsOneWidget);
      expect(find.text('3 members'), findsOneWidget);
      expect(find.byIcon(Icons.restaurant_rounded), findsOneWidget);

      // Verify Total Expense & Each Pays
      expect(find.text('Total Expense'), findsOneWidget);
      expect(find.text('₹549'), findsOneWidget);
      expect(find.text('Each Pays'), findsOneWidget);
      expect(find.text('₹183'), findsWidgets);

      // Verify Who Pays Whom Section
      expect(find.text('Who Pays Whom'), findsOneWidget);
      expect(find.text('2 payments'), findsOneWidget);
      expect(find.text('Saurabh'), findsWidgets);
      expect(find.text('Pay ₹183'), findsOneWidget);
      expect(find.text('Nishant'), findsWidgets);
      expect(find.text('Pay ₹134'), findsOneWidget);
      expect(find.text('Vinit'), findsWidgets);

      // Verify Member Breakdown Section
      expect(find.text('Member Breakdown'), findsOneWidget);
      expect(find.text('Member'), findsOneWidget);
      expect(find.text('Paid'), findsOneWidget);
      expect(find.text('Share'), findsOneWidget);
      expect(find.text('Net'), findsOneWidget);

      // Verify Net Badges
      expect(find.text('+₹317'), findsOneWidget);
      expect(find.text('-₹134'), findsOneWidget);
      expect(find.text('-₹183'), findsOneWidget);

      // Verify Fixed Save & Track Settlement button
      expect(find.widgetWithText(ElevatedButton, 'Save & Track Settlement'), findsOneWidget);
      expect(find.byIcon(Icons.check_circle_outline_rounded), findsOneWidget);
    });

    testWidgets('SplashScreen renders screenshot-matching branding and waves', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: SplashScreen(autoNavigate: false),
        ),
      );

      // Verify Official App Logo Image
      expect(find.byType(Image), findsOneWidget);

      // Verify Title & Subtitle
      expect(find.text('TTMM'), findsOneWidget);
      expect(find.textContaining('Split expenses, track balances'), findsOneWidget);
      expect(find.textContaining('and settle easily'), findsOneWidget);
    });

    testWidgets('OnboardingScreen renders receipt visual, copy, and actions', (tester) async {
      bool getStartedTapped = false;
      await tester.pumpWidget(
        MaterialApp(
          home: OnboardingScreen(
            onGetStarted: () {
              getStartedTapped = true;
            },
          ),
        ),
      );

      // Verify Receipt visual with Rupee symbol
      expect(find.text('₹'), findsOneWidget);

      // Verify Headline & Body
      expect(find.textContaining('Split Expenses'), findsOneWidget);
      expect(find.textContaining('with Friends'), findsOneWidget);
      expect(find.textContaining('Add bills, split fairly and'), findsOneWidget);
      expect(find.textContaining('track who owes whom.'), findsOneWidget);

      // Verify Buttons
      expect(find.widgetWithText(ElevatedButton, 'Get Started'), findsOneWidget);
      expect(find.text('I already have an account'), findsOneWidget);

      // Tap Get Started
      await tester.tap(find.widgetWithText(ElevatedButton, 'Get Started'));
      await tester.pumpAndSettle();
      expect(getStartedTapped, isTrue);
    });
  });
}
