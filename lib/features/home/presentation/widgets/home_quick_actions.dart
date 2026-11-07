import 'package:flutter/material.dart';
import 'package:flutter_neumorphism_ui/flutter_neumorphism_ui.dart';
import 'package:flutter_bill_splitter/core/theme/app_colors.dart';
import 'package:flutter_bill_splitter/core/theme/neumorphic_styles.dart';

/// Row of 3 Neumorphic Quick Action Cards: Add Expense, Scan Bill, and Settle Up.
class HomeQuickActions extends StatelessWidget {
  final VoidCallback onAddExpense;
  final VoidCallback onScanBill;
  final VoidCallback onSettleUp;

  const HomeQuickActions({
    super.key,
    required this.onAddExpense,
    required this.onScanBill,
    required this.onSettleUp,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        // Tile 1: Add Expense (Highlighted)
        Expanded(
          child: _buildActionTile(
            onTap: onAddExpense,
            iconWidget: FlutterNeumorphism(
              style: NeumorphicStyles.card(
                borderRadius: 16,
                depth: 4,
                color: AppColors.primary,
              ),
              width: 52,
              height: 52,
              padding: EdgeInsets.zero,
              child: const Icon(
                Icons.add,
                color: AppColors.primaryDark,
                size: 26,
              ),
            ),
            label: 'Add\nExpense',
          ),
        ),
        const SizedBox(width: 14),

        // Tile 2: Scan Bill
        Expanded(
          child: _buildActionTile(
            onTap: onScanBill,
            iconWidget: FlutterNeumorphism(
              style: NeumorphicStyles.inset(
                borderRadius: 16,
                depth: 2,
                color: AppColors.surface,
              ),
              width: 52,
              height: 52,
              padding: EdgeInsets.zero,
              child: const Icon(
                Icons.qr_code_scanner_rounded,
                color: AppColors.textPrimary,
                size: 26,
              ),
            ),
            label: 'Scan Bill',
          ),
        ),
        const SizedBox(width: 14),

        // Tile 3: Settle Up
        Expanded(
          child: _buildActionTile(
            onTap: onSettleUp,
            iconWidget: FlutterNeumorphism(
              style: NeumorphicStyles.inset(
                borderRadius: 16,
                depth: 2,
                color: AppColors.surface,
              ),
              width: 52,
              height: 52,
              padding: EdgeInsets.zero,
              child: const Icon(
                Icons.account_balance_wallet_outlined,
                color: AppColors.textPrimary,
                size: 26,
              ),
            ),
            label: 'Settle Up',
          ),
        ),
      ],
    );
  }

  Widget _buildActionTile({
    required VoidCallback onTap,
    required Widget iconWidget,
    required String label,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(22),
      child: FlutterNeumorphism(
        style: NeumorphicStyles.card(borderRadius: 22, depth: 5),
        height: 124,
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 14),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            iconWidget,
            const SizedBox(height: 10),
            Text(
              label,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
                height: 1.15,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

