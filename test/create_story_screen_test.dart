import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_bill_splitter/features/stories/presentation/screens/create_story_screen.dart';
import 'package:flutter_bill_splitter/shared/widgets/app_avatar.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('CreateStoryScreen Tests', () {
    testWidgets('renders Create Story form with creator and dynamic fields', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: CreateStoryScreen(),
        ),
      );
      await tester.pumpAndSettle();

      // Verify Header Title
      expect(find.text('Create Story'), findsWidgets);
      expect(find.byIcon(Icons.chevron_left_rounded), findsOneWidget);

      // Verify Form Field Labels
      expect(find.text('Cover Icon'), findsOneWidget);
      expect(find.text('Story name'), findsOneWidget);
      expect(find.text('Mumbai Trip'), findsOneWidget); // Hint
      expect(find.text('Description (optional)'), findsOneWidget);
      expect(find.text('Trip, stay, food, travel etc.'), findsOneWidget); // Hint
      expect(find.text('Start date'), findsNothing);
      expect(find.text('End date'), findsNothing);
      expect(find.text('Add members'), findsOneWidget);

      // Verify Add button is present
      expect(find.byIcon(Icons.add_rounded), findsOneWidget); // + button

      // Verify Bottom CTA Button
      expect(find.widgetWithText(ElevatedButton, 'Create Story'), findsOneWidget);
      expect(find.byIcon(Icons.arrow_forward_rounded), findsWidgets);
    });

    testWidgets('renders member avatar chips when initialMembers provided', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: CreateStoryScreen(
            initialMembers: ['Rashmi', 'Shubham', 'Roshan'],
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byType(AppAvatar), findsWidgets);
      expect(find.byIcon(Icons.add_rounded), findsOneWidget); // + button
    });

    testWidgets(
        'opens Add Members modal with Contacts, Manual, and Invite Link options',
        (tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      await tester.pumpWidget(
        const MaterialApp(
          home: CreateStoryScreen(),
        ),
      );
      await tester.pumpAndSettle();

      // Open Add Members bottom sheet by tapping '+'
      await tester.tap(find.byIcon(Icons.add_rounded));
      await tester.pumpAndSettle();

      // Verify modal options
      expect(find.text('Add from Contacts'), findsOneWidget);
      expect(find.text('Invite via Link'), findsOneWidget);
      expect(find.text('Add Manually'), findsOneWidget);
      expect(find.text('Copy'), findsOneWidget);
      expect(find.widgetWithText(ElevatedButton, 'Add'), findsOneWidget);

      // Add a member manually
      final manualInput = find.widgetWithText(TextField, 'Enter friend name...');
      expect(manualInput, findsOneWidget);
      await tester.enterText(manualInput, 'Pooja');
      await tester.tap(find.widgetWithText(ElevatedButton, 'Add'));
      await tester.pumpAndSettle();

      // Close modal
      await tester.tapAt(const Offset(20, 20));
      await tester.pumpAndSettle();

      // Verify member chip list contains 2 avatars (creator + Pooja)
      expect(find.byType(AppAvatar), findsNWidgets(2));
    });

    testWidgets('tapping Copy invite link in modal shows copy confirmation toast', (tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      await tester.pumpWidget(
        const MaterialApp(
          home: CreateStoryScreen(),
        ),
      );
      await tester.pumpAndSettle();

      // Open Add Members sheet
      await tester.tap(find.byIcon(Icons.add_rounded));
      await tester.pumpAndSettle();

      // Tap Copy button for invite link
      await tester.tap(find.text('Copy'));
      await tester.pumpAndSettle();

      // Verify SnackBar toast
      expect(find.textContaining('Invite link copied!'), findsOneWidget);
    });

    testWidgets('allows selecting cover emoji', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: CreateStoryScreen(),
        ),
      );
      await tester.pumpAndSettle();

      // Find '🍕' emoji in Cover Icon list and tap it
      final pizzaEmoji = find.text('🍕');
      expect(pizzaEmoji, findsOneWidget);
      await tester.tap(pizzaEmoji);
      await tester.pumpAndSettle();

      // Verify selected emoji is displayed in the story name input row
      expect(find.text('🍕'), findsWidgets);
    });
  });
}
