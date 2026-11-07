import 'package:flutter/material.dart';
import 'package:flutter_neumorphism_ui/flutter_neumorphism_ui.dart';
import 'package:flutter_bill_splitter/core/theme/app_colors.dart';
import 'package:flutter_bill_splitter/core/theme/neumorphic_styles.dart';

/// Inset Neumorphic segmented filter bar for Activity tab: All, Expenses, Settlements.
class ActivityFilterBar extends StatelessWidget {
  final int selectedIndex;
  final ValueChanged<int> onFilterChanged;

  const ActivityFilterBar({
    super.key,
    required this.selectedIndex,
    required this.onFilterChanged,
  });

  static const List<String> _filters = ['All', 'Expenses', 'Settlements'];

  @override
  Widget build(BuildContext context) {
    return FlutterNeumorphism(
      style: NeumorphicStyles.inset(borderRadius: 24, depth: 3),
      width: double.infinity,
      height: 48,
      padding: const EdgeInsets.all(4),
      child: Row(
        children: [
          for (int i = 0; i < _filters.length; i++)
            Expanded(
              child: _buildFilterPill(
                title: _filters[i],
                isSelected: selectedIndex == i,
                onTap: () => onFilterChanged(i),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildFilterPill({
    required String title,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    if (isSelected) {
      return FlutterNeumorphism(
        style: NeumorphicStyles.card(
          borderRadius: 20,
          depth: 3,
          color: AppColors.primary,
        ),
        padding: EdgeInsets.zero,
        child: Center(
          child: Text(
            title,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w800,
              color: AppColors.primaryDark,
            ),
          ),
        ),
      );
    }

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Center(
        child: Text(
          title,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: AppColors.textSecondary,
          ),
        ),
      ),
    );
  }
}
