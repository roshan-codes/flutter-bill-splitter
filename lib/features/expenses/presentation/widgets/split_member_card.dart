import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_bill_splitter/core/theme/app_colors.dart';
import 'package:flutter_bill_splitter/core/theme/app_radius.dart';
import 'package:flutter_bill_splitter/core/utils/string_utils.dart';
import 'package:flutter_bill_splitter/features/friends/domain/models/friend.dart';
import 'package:flutter_bill_splitter/shared/widgets/platform_adaptive.dart';

/// Platform-adaptive Card displaying an individual selected member with their expense in SplitDetailScreen.
/// Adheres to design.md Section 3, 5, 8 & 10.
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
      borderRadius: AppRadius.card,
      elevation: 0,
      color: AppColors.surface,
      onTap: onAddExpense,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          // Circular neutral avatar
          Container(
            width: 44,
            height: 44,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.surfaceSubtle,
            ),
            child: Center(
              child: Text(
                singleInitial,
                style: GoogleFonts.manrope(
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.w700,
                  fontSize: 16,
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
                  style: GoogleFonts.manrope(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
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
                        color: AppColors.primary,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Icon(
                        hasExpense ? Icons.edit_rounded : Icons.add,
                        color: Colors.white,
                        size: 14,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      hasExpense ? 'Edit expense' : 'Add expense',
                      style: GoogleFonts.manrope(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: hasExpense ? AppColors.textPrimary : AppColors.textSecondary,
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
                borderRadius: BorderRadius.circular(AppRadius.pill),
                color: AppColors.surfaceSubtle,
                border: Border.all(color: AppColors.border, width: 1.0),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              child: Text(
                '₹${expenseAmount!.toStringAsFixed(expenseAmount!.truncateToDouble() == expenseAmount! ? 0 : 2)}',
                style: GoogleFonts.manrope(
                  fontSize: 15,
                  fontWeight: FontWeight.w800,
                  color: AppColors.textPrimary,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
