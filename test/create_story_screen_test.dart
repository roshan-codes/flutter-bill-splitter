import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_bill_splitter/features/stories/presentation/screens/create_story_screen.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('CreateStoryScreen Tests', () {
    testWidgets('renders Create Story form matching mockup', (tester) async {
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
      expect(find.text('Story name'), findsOneWidget);
      expect(find.text('Mumbai Trip'), findsOneWidget); // Hint
      expect(find.text('Description (optional)'), findsOneWidget);
      expect(find.text('Trip, stay, food, travel etc.'), findsOneWidget); // Hint
      expect(find.text('Start date'), findsOneWidget);
      expect(find.text('End date'), findsOneWidget);
      expect(find.text('Add members'), findsOneWidget);

      // Verify Default Member Avatar Chips
      expect(find.text('R'), findsOneWidget); // Rashmi
      expect(find.text('S'), findsOneWidget); // Shubham
      expect(find.byIcon(Icons.add_rounded), findsOneWidget); // + button

      // Verify Bottom CTA Button
      expect(find.widgetWithText(ElevatedButton, 'Create Story'), findsOneWidget);
      expect(find.byIcon(Icons.arrow_forward_rounded), findsWidgets);
    });
  });
}
