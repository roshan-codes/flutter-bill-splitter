import 'package:flutter/material.dart';
import 'package:flutter_neumorphism_ui/flutter_neumorphism_ui.dart';
import 'package:flutter_bill_splitter/core/theme/app_colors.dart';
import 'package:flutter_bill_splitter/core/theme/neumorphic_styles.dart';
import 'package:flutter_bill_splitter/core/utils/string_utils.dart';
import 'package:flutter_bill_splitter/features/friends/domain/models/friend.dart';

/// Neumorphic Card displaying an individual selected member with their expense in SplitDetailScreen.
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

    return FlutterNeumorphism(
      style: NeumorphicStyles.card(borderRadius: 22, depth: 5),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(
        children: [
          // Light lime-green neumorphic squircle avatar
          FlutterNeumorphism(
            style: NeumorphicStyles.card(
              borderRadius: 16,
              depth: 3,
              color: AppColors.primaryLight,
            ),
            width: 48,
            height: 48,
            padding: EdgeInsets.zero,
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

                // Add / Edit expense button row
                InkWell(
                  onTap: onAddExpense,
                  borderRadius: BorderRadius.circular(10),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      FlutterNeumorphism(
                        style: NeumorphismStyle(
                          color: AppColors.amber,
                          borderRadius: 10,
                          depth: 4,
                          lightShadow: Colors.white.withOpacity(0.6),
                          darkShadow: const Color(0xFFC78F1A),
                        ),
                        width: 32,
                        height: 32,
                        padding: EdgeInsets.zero,
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
                          fontWeight: FontWeight.w700,
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
            FlutterNeumorphism(
              style: NeumorphicStyles.inset(
                borderRadius: 14,
                depth: 3,
                color: AppColors.primaryLight,
              ),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
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
