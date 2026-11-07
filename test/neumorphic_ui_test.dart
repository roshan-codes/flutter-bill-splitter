import 'package:flutter/material.dart';
import 'package:flutter_neumorphism_ui/flutter_neumorphism_ui.dart';
import 'package:neumorphic_glass_navbar/neumorphic_glass_navbar.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_bill_splitter/core/theme/app_colors.dart';
import 'package:flutter_bill_splitter/core/theme/neumorphic_styles.dart';
import 'package:flutter_bill_splitter/features/activity/presentation/screens/activity_tab.dart';
import 'package:flutter_bill_splitter/features/expenses/presentation/screens/add_expense_screen.dart';
import 'package:flutter_bill_splitter/features/expenses/presentation/widgets/search_name_group_bar.dart';
import 'package:flutter_bill_splitter/features/home/presentation/screens/home_tab.dart';
import 'package:flutter_bill_splitter/features/profile/presentation/screens/profile_tab.dart';
import 'package:flutter_bill_splitter/shared/widgets/empty_state_view.dart';

void main() {
  group('Neumorphic UI Tests', () {
    test('NeumorphicStyles generates correct card style', () {
      final style = NeumorphicStyles.card(borderRadius: 20, depth: 6);
      expect(style.borderRadius, 20.0);
      expect(style.depth, 6.0);
      expect(style.type, NeumorphismType.flat);
      expect(style.color, AppColors.surface);
      expect(style.lightShadow, AppColors.neumorphicLight);
      expect(style.darkShadow, AppColors.neumorphicDark);
    });

    test('NeumorphicStyles generates correct inset style', () {
      final style = NeumorphicStyles.inset(borderRadius: 16, depth: 4);
      expect(style.borderRadius, 16.0);
      expect(style.depth, 4.0);
      expect(style.type, NeumorphismType.pressed);
      expect(style.color, AppColors.neumorphicPressed);
    });

    testWidgets('EmptyStateView renders with circular FlutterNeumorphism icon container', (tester) async {
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
      expect(find.byType(FlutterNeumorphism), findsOneWidget);
    });

    testWidgets('SearchNameGroupBar renders with inset field and raised action button', (tester) async {
      final controller = TextEditingController();
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SearchNameGroupBar(
              controller: controller,
              onChanged: (_) {},
              onSearchPressed: () {},
            ),
          ),
        ),
      );

      expect(find.byType(FlutterNeumorphism), findsNWidgets(2));
      expect(find.byType(TextField), findsOneWidget);
    });

    testWidgets('NeumorphicGlassNavbar renders with glass settings and items', (tester) async {
      int tappedIndex = -1;
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            bottomNavigationBar: NeumorphicGlassNavbar(
              currentIndex: 0,
              onTap: (idx) => tappedIndex = idx,
              height: 68,
              settings: const NeumorphicGlassNavbarSettings(
                tintColor: AppColors.background,
                opacity: 0.65,
                borderRadius: 28.0,
              ),
              items: const [
                BottomNavigationBarItem(
                  icon: Icon(Icons.home_outlined),
                  label: 'Home',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.people_outline_rounded),
                  label: 'Friends',
                ),
              ],
            ),
          ),
        ),
      );

      expect(find.byType(NeumorphicGlassNavbar), findsOneWidget);
      expect(find.text('Home'), findsOneWidget);
      expect(find.text('Friends'), findsOneWidget);

      await tester.tap(find.text('Friends'));
      await tester.pumpAndSettle();
      expect(tappedIndex, 1);
    });

    testWidgets('HomeTab renders screenshot-matching neumorphic UI elements', (tester) async {
      bool addExpenseTapped = false;
      await tester.pumpWidget(
        MaterialApp(
          home: HomeTab(
            onAddExpense: () {
              addExpenseTapped = true;
            },
          ),
        ),
      );

      // Verify header greeting & user name
      expect(find.textContaining('Good'), findsOneWidget);
      expect(find.text('Roshan'), findsOneWidget);
      expect(find.text('👋'), findsOneWidget);
      expect(find.byIcon(Icons.bolt_rounded), findsOneWidget);
      expect(find.byIcon(Icons.notifications_none_rounded), findsOneWidget);

      // Verify 3 quick action tiles
      expect(find.textContaining('Add\nExpense'), findsOneWidget);
      expect(find.text('Scan Bill'), findsOneWidget);
      expect(find.text('Settle Up'), findsOneWidget);

      // Verify Your Balance card
      expect(find.text('Your Balance'), findsOneWidget);
      expect(find.text('You get'), findsOneWidget);
      expect(find.text('₹2,340'), findsOneWidget);
      expect(find.text('You owe'), findsOneWidget);
      expect(find.text('₹860'), findsOneWidget);

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

      // Verify tapping Add Expense tile triggers onAddExpense callback
      await tester.tap(find.textContaining('Add\nExpense'));
      await tester.pumpAndSettle();
      expect(addExpenseTapped, isTrue);
    });

    testWidgets('ProfileTab renders screenshot-matching neumorphic UI elements', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: ProfileTab(),
        ),
      );

      // Verify Header
      expect(find.text('Profile'), findsOneWidget);
      expect(find.byIcon(Icons.edit_outlined), findsOneWidget);

      // Verify Avatar & User Info
      expect(find.text('R'), findsOneWidget);
      expect(find.text('Roshan Badwaik'), findsOneWidget);
      expect(find.text('+91 9876543210'), findsOneWidget);

      // Verify Neumorphic Menu Items
      expect(find.text('Edit Profile'), findsOneWidget);
      expect(find.byIcon(Icons.person_outline_rounded), findsOneWidget);

      expect(find.text('Payment & Settlement'), findsOneWidget);
      expect(find.byIcon(Icons.account_balance_wallet_outlined), findsOneWidget);

      expect(find.text('App Settings'), findsOneWidget);
      expect(find.byIcon(Icons.settings_outlined), findsOneWidget);

      expect(find.text('Help & Support'), findsOneWidget);
      expect(find.byIcon(Icons.help_outline_rounded), findsOneWidget);

      expect(find.text('About BillSplit'), findsOneWidget);
      expect(find.byIcon(Icons.info_outline_rounded), findsOneWidget);

      // Verify Logout Button
      expect(find.text('Logout'), findsOneWidget);
      expect(find.byIcon(Icons.logout_rounded), findsOneWidget);

      // Tap Logout button and verify confirmation dialog opens
      await tester.tap(find.text('Logout'));
      await tester.pumpAndSettle();
      expect(find.text('Confirm Logout'), findsOneWidget);
      expect(find.text('Are you sure you want to log out of BillSplit?'), findsOneWidget);
    });

    testWidgets('ActivityTab renders screenshot-matching neumorphic UI elements and filters', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: ActivityTab(),
        ),
      );

      // Verify Header
      expect(find.text('Activity'), findsOneWidget);

      // Verify Segmented Filter Pills
      expect(find.text('All'), findsOneWidget);
      expect(find.text('Expenses'), findsOneWidget);
      expect(find.text('Settlements'), findsOneWidget);

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

      // Tap Settlements filter
      await tester.tap(find.text('Settlements'));
      await tester.pumpAndSettle();

      // In Settlements filter: Groceries & Movie Night visible, Dinner at Sakali and Goa Trip Fuel hidden
      expect(find.text('Groceries'), findsOneWidget);
      expect(find.text('Movie Night'), findsOneWidget);
      expect(find.text('Dinner at Sakali'), findsNothing);
      expect(find.text('Goa Trip Fuel'), findsNothing);

      // Tap Expenses filter
      await tester.tap(find.text('Expenses'));
      await tester.pumpAndSettle();

      // In Expenses filter: Dinner at Sakali & Goa Trip Fuel visible, Groceries & Movie Night hidden
      expect(find.text('Dinner at Sakali'), findsOneWidget);
      expect(find.text('Goa Trip Fuel'), findsOneWidget);
      expect(find.text('Groceries'), findsNothing);
      expect(find.text('Movie Night'), findsNothing);

      // Tap All filter
      await tester.tap(find.text('All'));
      await tester.pumpAndSettle();

      expect(find.text('Dinner at Sakali'), findsOneWidget);
      expect(find.text('Groceries'), findsOneWidget);
    });

    testWidgets('AddExpenseScreen renders screenshot-matching neumorphic UI elements', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: AddExpenseScreen(
            friends: [],
            groups: [],
          ),
        ),
      );

      // Verify Header
      expect(find.text('Add & Split Expense'), findsOneWidget);
      expect(find.byIcon(Icons.arrow_back_ios_new_rounded), findsOneWidget);

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
      expect(find.text('Akash'), findsOneWidget);
      expect(find.text('Pratik'), findsOneWidget);

      // Verify Continue button
      expect(find.widgetWithText(ElevatedButton, 'Continue'), findsOneWidget);
      expect(find.byIcon(Icons.arrow_forward_rounded), findsOneWidget);
    });
  });
}

