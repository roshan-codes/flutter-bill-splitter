import 'package:flutter/material.dart';
import 'package:flutter_bill_splitter/core/theme/app_colors.dart';
import 'package:flutter_bill_splitter/core/utils/string_utils.dart';
import 'package:flutter_bill_splitter/features/friends/domain/models/friend.dart';

/// Card displaying an individual selected member with their expense in SplitDetailScreen.
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

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: hasExpense ? AppColors.primary.withOpacity(0.5) : AppColors.border,
          width: hasExpense ? 1.5 : 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        children: [
          // Light lime-green squircle avatar (matching user screenshot)
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: const Color(0xFFE8F8D8),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: const Color(0xFFD6F0BE),
                width: 1,
              ),
            ),
            child: friend.avatarUrl != null && friend.avatarUrl!.isNotEmpty
                ? ClipRRect(
                    borderRadius: BorderRadius.circular(15),
                    child: Image.network(
                      friend.avatarUrl!,
                      width: 48,
                      height: 48,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => _buildInitial(singleInitial),
                    ),
                  )
                : _buildInitial(singleInitial),
          ),
          const SizedBox(width: 14),

          // Name and "Add expense" action row (no mobile number)
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
                  ),
                ),
                const SizedBox(height: 8),

                // Add / Edit expense button row (styled matching user screenshot)
                InkWell(
                  onTap: onAddExpense,
                  borderRadius: BorderRadius.circular(10),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 32,
                        height: 32,
                        decoration: BoxDecoration(
                          color: AppColors.amber,
                          borderRadius: BorderRadius.circular(10),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.amber.withOpacity(0.35),
                              blurRadius: 6,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Icon(
                          hasExpense ? Icons.edit_rounded : Icons.add,
                          color: AppColors.primaryDark,
                          size: 18,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Text(
                        hasExpense ? 'Edit expense' : 'Add expense',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: hasExpense ? AppColors.primaryDeep : AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Expense amount badge
          if (hasExpense)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.18),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: AppColors.primary,
                  width: 1.5,
                ),
              ),
              child: Text(
                '₹${expenseAmount!.toStringAsFixed(expenseAmount!.truncateToDouble() == expenseAmount! ? 0 : 2)}',
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w800,
                  color: AppColors.primaryDeep,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildInitial(String initial) {
    return Center(
      child: Text(
        initial,
        style: const TextStyle(
          color: Color(0xFF284821),
          fontWeight: FontWeight.w900,
          fontSize: 20,
        ),
      ),
    );
  }
}
