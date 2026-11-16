import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_bill_splitter/features/activity/presentation/screens/activity_tab.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('ActivityTab Mockup UI Tests', () {
    testWidgets('renders Activity tab matching design mockup with Today & Yesterday sections',
        (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: ActivityTab(
            showMockupFeed: true,
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Verify Header & Filter button
      expect(find.text('Activity'), findsOneWidget);
      expect(find.byIcon(Icons.filter_alt_outlined), findsOneWidget);

      // Verify Filter Chips
      expect(find.text('All'), findsOneWidget);
      expect(find.text('Expenses'), findsOneWidget);
      expect(find.text('Settlements'), findsOneWidget);
      expect(find.text('Members'), findsNothing);

      // Verify Section Headers
      expect(find.text('Today'), findsOneWidget);
      expect(find.text('Yesterday'), findsOneWidget);

      // Verify Today Items
      expect(find.text('Shubham settled'), findsOneWidget);
      expect(find.text('₹3,000 with you'), findsOneWidget);
      expect(find.text('+₹3,000'), findsOneWidget);

      expect(find.text('You added Dinner'), findsOneWidget);
      expect(find.text('₹2,400'), findsOneWidget);
      expect(find.text('-₹2,400'), findsOneWidget);

      expect(find.text('Rashmi added Hotel Stay'), findsOneWidget);
      expect(find.text('₹6,000'), findsNWidgets(2)); // subtitle amount + trailing amount

      // Verify Yesterday Items
      expect(find.text('Roshan added Fuel'), findsOneWidget);
      expect(find.text('₹2,100'), findsNWidgets(2)); // subtitle amount + trailing amount

      expect(find.text('Priya joined Delhi'), findsOneWidget);
      expect(find.text('10:15 AM'), findsOneWidget);

      // Verify Filter interaction: tap Settlements
      await tester.tap(find.text('Settlements'));
      await tester.pumpAndSettle();

      // Only settlement item should be visible
      expect(find.text('Shubham settled'), findsOneWidget);
      expect(find.text('You added Dinner'), findsNothing);
      expect(find.text('Roshan added Fuel'), findsNothing);

      // Tap Expenses
      await tester.tap(find.text('Expenses'));
      await tester.pumpAndSettle();

      expect(find.text('You added Dinner'), findsOneWidget);
      expect(find.text('Rashmi added Hotel Stay'), findsOneWidget);
      expect(find.text('Roshan added Fuel'), findsOneWidget);
      expect(find.text('Shubham settled'), findsNothing);

      // Tap All to restore full list
      await tester.tap(find.text('All'));
      await tester.pumpAndSettle();

      expect(find.text('You added Dinner'), findsOneWidget);
      expect(find.text('Shubham settled'), findsOneWidget);
    });
  });
}
