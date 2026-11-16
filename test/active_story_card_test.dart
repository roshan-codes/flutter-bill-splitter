import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_bill_splitter/features/home/presentation/widgets/active_story_card.dart';
import 'package:flutter_bill_splitter/features/stories/domain/models/story.dart';

void main() {
  group('ActiveStoryCard Widget Tests', () {
    testWidgets(
        'renders active story card matching design mockup with title, expenses, members, and status',
        (WidgetTester tester) async {
      final sampleStory = Story.sampleGoaTrip();
      bool tapped = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ActiveStoryCard(
              story: sampleStory,
              onTap: () => tapped = true,
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Verify Title & Dates
      expect(find.text('Goa Trip'), findsOneWidget);
      expect(find.text('Nov 12 – Nov 16'), findsOneWidget);

      // Verify Metrics
      expect(find.text('₹20,000'), findsOneWidget);
      expect(find.text('Total expenses'), findsOneWidget);
      expect(find.text('4'), findsOneWidget);
      expect(find.text('Members'), findsOneWidget);

      // Verify Status Pill removed per design update
      expect(find.text('Active'), findsNothing);

      // Verify Chevron icon
      expect(find.byIcon(Icons.chevron_right_rounded), findsOneWidget);

      // Verify Tap interaction
      await tester.tap(find.byType(ActiveStoryCard));
      expect(tapped, isTrue);
    });
  });
}
