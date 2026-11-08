import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bill_splitter/core/theme/app_colors.dart';
import 'package:flutter_bill_splitter/shared/widgets/platform_adaptive.dart';

/// Row of 3 Platform-adaptive Quick Action Cards: Add Expense, Scan Bill, and Settle Up.
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
            context: context,
            onTap: onAddExpense,
            iconWidget: Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Icon(
                Icons.add,
                color: Colors.black,
                size: 28,
              ),
            ),
            label: 'Add\nExpense',
          ),
        ),
        const SizedBox(width: 14),

        // Tile 2: Scan Bill
        Expanded(
          child: _buildActionTile(
            context: context,
            onTap: onScanBill,
            iconWidget: Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: const Color(0xFFE8EDF2),
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Icon(
                Icons.qr_code_scanner_rounded,
                color: Colors.black,
                size: 24,
              ),
            ),
            label: 'Scan Bill',
          ),
        ),
        const SizedBox(width: 14),

        // Tile 3: Settle Up
        Expanded(
          child: _buildActionTile(
            context: context,
            onTap: onSettleUp,
            iconWidget: Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: const Color(0xFFE8EDF2),
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Icon(
                Icons.credit_card_rounded,
                color: Colors.black,
                size: 24,
              ),
            ),
            label: 'Settle Up',
          ),
        ),
      ],
    );
  }

  Widget _buildActionTile({
    required BuildContext context,
    required VoidCallback onTap,
    required Widget iconWidget,
    required String label,
  }) {
    return Semantics(
      label: label.replaceAll('\n', ' '),
      button: true,
      child: PlatformCard(
        borderRadius: 20,
        elevation: 1,
        color: Colors.white,
        height: 128,
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 14),
        onTap: () {
          HapticFeedback.lightImpact();
          onTap();
        },
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            iconWidget,
            const SizedBox(height: 12),
            Text(
              label,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 13.5,
                fontWeight: FontWeight.w700,
                color: Color(0xFF1B241E),
                height: 1.15,
                letterSpacing: -0.2,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
