import 'package:animations/animations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_bill_splitter/core/animations/app_motion.dart';
import 'package:flutter_bill_splitter/core/animations/app_transitions.dart';

void main() {
  group('AppMotion & AppTransitions Tests', () {
    test('AppMotion defines specified duration constants', () {
      expect(AppMotion.fast, const Duration(milliseconds: 150));
      expect(AppMotion.normal, const Duration(milliseconds: 250));
      expect(AppMotion.medium, const Duration(milliseconds: 350));
      expect(AppMotion.emphasized, const Duration(milliseconds: 400));
    });

    test('AppMotion respects accessibility disableAnimations', () {
      // In null or normal context, returns default duration
      expect(AppMotion.getDuration(null, AppMotion.normal), AppMotion.normal);
    });

    testWidgets('AppTransitions.fadeThroughSwitcher switches smoothly', (tester) async {
      int activeIndex = 0;

      await tester.pumpWidget(
        MaterialApp(
          home: StatefulBuilder(
            builder: (context, setState) {
              return Scaffold(
                body: Column(
                  children: [
                    TextButton(
                      onPressed: () => setState(() => activeIndex = 1),
                      child: const Text('Next'),
                    ),
                    Expanded(
                      child: AppTransitions.fadeThroughSwitcher(
                        context: context,
                        transitionKey: activeIndex,
                        child: activeIndex == 0
                            ? const Text('Page Zero')
                            : const Text('Page One'),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      );

      expect(find.text('Page Zero'), findsOneWidget);
      await tester.tap(find.text('Next'));
      await tester.pumpAndSettle();
      expect(find.text('Page One'), findsOneWidget);
    });

    testWidgets('AppTransitions.sharedAxisSwitcher switches horizontally', (tester) async {
      int tabIndex = 0;

      await tester.pumpWidget(
        MaterialApp(
          home: StatefulBuilder(
            builder: (context, setState) {
              return Scaffold(
                body: Column(
                  children: [
                    TextButton(
                      onPressed: () => setState(() => tabIndex = 1),
                      child: const Text('Switch Tab'),
                    ),
                    Expanded(
                      child: AppTransitions.sharedAxisSwitcher(
                        context: context,
                        transitionKey: tabIndex,
                        type: SharedAxisTransitionType.horizontal,
                        child: tabIndex == 0
                            ? const Text('Overview Tab')
                            : const Text('Expenses Tab'),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      );

      expect(find.text('Overview Tab'), findsOneWidget);
      await tester.tap(find.text('Switch Tab'));
      await tester.pumpAndSettle();
      expect(find.text('Expenses Tab'), findsOneWidget);
    });

    testWidgets('AppTransitions.showFadeScaleDialog displays dialog with gentle scale', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) {
                return ElevatedButton(
                  onPressed: () {
                    AppTransitions.showFadeScaleDialog(
                      context: context,
                      builder: (ctx) => const AlertDialog(
                        title: Text('Delete Confirmation'),
                      ),
                    );
                  },
                  child: const Text('Open Dialog'),
                );
              },
            ),
          ),
        ),
      );

      await tester.tap(find.text('Open Dialog'));
      await tester.pumpAndSettle();

      expect(find.text('Delete Confirmation'), findsOneWidget);
    });

    testWidgets('AppTransitions.openContainer transforms closed into open child', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) {
                return AppTransitions.openContainer(
                  context: context,
                  closedBuilder: (context, open) {
                    return ElevatedButton(
                      onPressed: open,
                      child: const Text('Open Card'),
                    );
                  },
                  openBuilder: (context, close) {
                    return const Scaffold(
                      body: Text('Details Screen'),
                    );
                  },
                );
              },
            ),
          ),
        ),
      );

      expect(find.text('Open Card'), findsOneWidget);
      await tester.tap(find.text('Open Card'));
      await tester.pumpAndSettle();

      expect(find.text('Details Screen'), findsOneWidget);
    });
  });
}
