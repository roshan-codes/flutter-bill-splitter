import 'package:flutter/material.dart';
import 'package:flutter_bill_splitter/core/theme/app_colors.dart';
import 'package:flutter_bill_splitter/features/activity/domain/models/activity_display_item.dart';
import 'package:flutter_bill_splitter/features/activity/presentation/widgets/activity_item_row.dart';
import 'package:flutter_bill_splitter/shared/widgets/platform_adaptive.dart';

/// Platform-adaptive Card container rendering a section of activities (e.g., "This Week", "Last Week").
class ActivitySectionCard extends StatelessWidget {
  final String title;
  final List<ActivityDisplayItem> items;
  final void Function(ActivityDisplayItem item)? onItemTap;

  const ActivitySectionCard({
    super.key,
    required this.title,
    required this.items,
    this.onItemTap,
  });

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.w800,
            color: AppColors.textPrimary,
            letterSpacing: -0.3,
          ),
        ),
        const SizedBox(height: 12),
        PlatformCard(
          borderRadius: 20,
          elevation: 1.5,
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
          child: Column(
            children: [
              for (int i = 0; i < items.length; i++) ...[
                ActivityItemRow(
                  item: items[i],
                  onTap: onItemTap != null ? () => onItemTap!(items[i]) : null,
                ),
                if (i < items.length - 1)
                  const Divider(
                    color: AppColors.border,
                    height: 12,
                    thickness: 0.8,
                  ),
              ],
            ],
          ),
        ),
      ],
    );
  }
}
