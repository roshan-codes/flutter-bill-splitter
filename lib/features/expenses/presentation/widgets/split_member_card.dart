import 'package:flutter/material.dart';
import 'package:flutter_bill_splitter/core/theme/app_colors.dart';
import 'package:flutter_bill_splitter/core/utils/string_utils.dart';
import 'package:flutter_bill_splitter/features/friends/domain/models/friend.dart';
import 'package:flutter_bill_splitter/shared/widgets/platform_adaptive.dart';

/// Platform-adaptive Card displaying an individual selected member with their expense in SplitDetailScreen.
class SplitMemberCard extends StatelessWidget {
  final Friend friend;
  final int index;
  final double? expenseAmount;
  final VoidCallback onAddExpense;

  const SplitMemberCard({
    super.key,
    required this.friend,
    required this.index,
    this.expenseAmount,
    required this.onAddExpense,
  });

  @override
  Widget build(BuildContext context) {
    final singleInitial = StringUtils.getSingleInitial(friend.name);
    final hasExpense = expenseAmount != null && expenseAmount! > 0;

    return PlatformCard(
      borderRadius: 18,
      elevation: 1.5,
      onTap: onAddExpense,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          // Lime-green rounded avatar
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(14),
              color: const Color(0xFFE8F8D8),
            ),
            child: Center(
              child: Text(
                singleInitial,
                style: const TextStyle(
                  color: Color(0xFF284821),
                  fontWeight: FontWeight.w900,
                  fontSize: 18,
                ),
              ),
            ),
          ),
          const SizedBox(width: 14),

          // Friend Name and "+ Add expense" row
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  friend.name,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    color: AppColors.textPrimary,
                    letterSpacing: -0.2,
                  ),
                ),
                const SizedBox(height: 6),

                // "+ Add expense" / "Edit expense" row
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 24,
                      height: 24,
                      decoration: BoxDecoration(
                        color: const Color(0xFF86E829),
                        borderRadius: BorderRadius.circular(8),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF86E829).withOpacity(0.4),
                            blurRadius: 6,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Icon(
                        hasExpense ? Icons.edit_rounded : Icons.add,
                        color: const Color(0xFF10210A),
                        size: 14,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      hasExpense ? 'Edit expense' : 'Add expense',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: hasExpense ? AppColors.primaryDeep : AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Expense amount badge when present
          if (hasExpense)
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                color: AppColors.primaryLight,
              ),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              child: Text(
                '₹${expenseAmount!.toStringAsFixed(expenseAmount!.truncateToDouble() == expenseAmount! ? 0 : 2)}',
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w900,
                  color: AppColors.primaryDeep,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
