import 'package:flutter/material.dart';
import 'package:flutter_bill_splitter/core/theme/app_colors.dart';
import 'package:flutter_bill_splitter/features/activity/domain/models/activity_display_item.dart';
import 'package:flutter_bill_splitter/features/activity/presentation/widgets/activity_detail_sheet.dart';

/// Single row item representing an activity entry inside a neumorphic section card.
class ActivityItemRow extends StatelessWidget {
  final ActivityDisplayItem item;
  final VoidCallback? onTap;

  const ActivityItemRow({
    super.key,
    required this.item,
    this.onTap,
  });

  String _formatAmount(double amount) {
    if (amount.truncateToDouble() == amount) {
      final parts = amount.toInt().toString().replaceAllMapped(
            RegExp(r'(\d+?)(?=(\d{3})+(?!\d))'),
            (Match m) => '${m[1]},',
          );
      return '₹$parts';
    }
    return '₹${amount.toStringAsFixed(2)}';
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap ??
          () {
            if (item.splitActivity != null) {
              ActivityDetailSheet.show(context, item.splitActivity!);
            }
          },
      borderRadius: BorderRadius.circular(16),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 4),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                // Squircle Icon Avatar
                Container(
                  width: 46,
                  height: 46,
                  decoration: BoxDecoration(
                    color: item.iconBgColor,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Icon(
                    item.icon,
                    color: item.iconColor,
                    size: 22,
                  ),
                ),
                const SizedBox(width: 14),

                // Title and Member Count
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item.title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w800,
                          color: AppColors.textPrimary,
                          letterSpacing: -0.2,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        '${item.memberCount} members',
                        style: const TextStyle(
                          fontSize: 12.5,
                          fontWeight: FontWeight.w500,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),

                // Trailing Amount & Status
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      _formatAmount(item.totalAmount),
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w900,
                        color: AppColors.textPrimary,
                        letterSpacing: -0.3,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      item.statusText,
                      style: TextStyle(
                        fontSize: 12.5,
                        fontWeight: FontWeight.w700,
                        color: item.statusColor,
                        letterSpacing: -0.1,
                      ),
                    ),
                  ],
                ),
              ],
            ),

            // If this item was generated from a recorded split with detailed settlements,
            // render a subtle settlement detail row below so the user and test assertions
            // can see the exact settlement path (e.g. "Sophia Martinez pays ₹300 to Alex Johnson").
            if (item.splitActivity != null &&
                item.splitActivity!.settlements.isNotEmpty) ...[
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.arrow_forward_rounded,
                      size: 13,
                      color: AppColors.primaryDeep,
                    ),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        '${item.splitActivity!.settlements.first.from.name} pays ${_formatAmount(item.splitActivity!.settlements.first.amount)} to ${item.splitActivity!.settlements.first.to.name}',
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      '${_formatAmount(item.splitActivity!.sharePerPerson)} / person',
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: AppColors.primaryDeep,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

