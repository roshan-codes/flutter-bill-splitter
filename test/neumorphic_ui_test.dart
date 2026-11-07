import 'package:flutter/material.dart';
import 'package:flutter_neumorphism_ui/flutter_neumorphism_ui.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_bill_splitter/core/theme/app_colors.dart';
import 'package:flutter_bill_splitter/core/theme/neumorphic_styles.dart';
import 'package:flutter_bill_splitter/features/expenses/presentation/widgets/search_name_group_bar.dart';
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
  });
}
