import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_bill_splitter/core/theme/app_colors.dart';
import 'package:flutter_bill_splitter/core/theme/app_radius.dart';
import 'package:flutter_bill_splitter/shared/widgets/platform_adaptive.dart';

/// Row of 3 Platform-adaptive Quick Action Cards: Add Expense, Scan Bill, and Settle Up.
/// Adheres to design.md Section 4, 6 & 10.
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
        // Tile 1: Add Expense (Highlighted near-black action)
        Expanded(
          child: _buildActionTile(
            context: context,
            onTap: onAddExpense,
            iconWidget: Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.circular(AppRadius.iconContainer + 2),
              ),
              child: const Icon(
                Icons.add,
                color: Colors.white,
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
                color: AppColors.surfaceSubtle,
                borderRadius: BorderRadius.circular(AppRadius.iconContainer + 2),
              ),
              child: const Icon(
                Icons.qr_code_scanner_rounded,
                color: AppColors.textPrimary,
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
                color: AppColors.surfaceSubtle,
                borderRadius: BorderRadius.circular(AppRadius.iconContainer + 2),
              ),
              child: const Icon(
                Icons.credit_card_rounded,
                color: AppColors.textPrimary,
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
        borderRadius: AppRadius.card,
        elevation: 0,
        color: AppColors.surface,
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
              style: GoogleFonts.manrope(
                fontSize: 13.5,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
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
