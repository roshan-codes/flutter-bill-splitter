import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_bill_splitter/core/theme/app_colors.dart';
import 'package:flutter_bill_splitter/core/theme/app_radius.dart';
import 'package:flutter_bill_splitter/shared/widgets/platform_adaptive.dart';

/// Segmented filter bar for Activity tab: All, Expenses, Settlements.
/// Follows design.md Section 4 & 6.
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
    return PlatformInsetContainer(
      borderRadius: AppRadius.pill,
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
      return Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(AppRadius.pill),
          color: AppColors.primary,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 4,
              offset: const Offset(0, 1),
            ),
          ],
        ),
        child: Center(
          child: Text(
            title,
            style: GoogleFonts.manrope(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
          ),
        ),
      );
    }

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppRadius.pill),
      child: Center(
        child: Text(
          title,
          style: GoogleFonts.manrope(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: AppColors.textSecondary,
          ),
        ),
      ),
    );
  }
}
