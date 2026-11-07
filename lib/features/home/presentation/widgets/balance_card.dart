import 'package:flutter/material.dart';
import 'package:flutter_neumorphism_ui/flutter_neumorphism_ui.dart';
import 'package:flutter_bill_splitter/core/theme/app_colors.dart';
import 'package:flutter_bill_splitter/core/theme/neumorphic_styles.dart';

/// Neumorphic Card displaying user's total net balance: "You get" vs "You owe".
class BalanceCard extends StatelessWidget {
  final double youGetAmount;
  final double youOweAmount;
  final VoidCallback? onTap;

  const BalanceCard({
    super.key,
    this.youGetAmount = 2340.0,
    this.youOweAmount = 860.0,
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
      onTap: onTap,
      borderRadius: BorderRadius.circular(24),
      child: FlutterNeumorphism(
        style: NeumorphicStyles.card(borderRadius: 24, depth: 6),
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Row: Title & Chevron
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Your Balance',
                  style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w800,
                    color: AppColors.textPrimary,
                    letterSpacing: -0.2,
                  ),
                ),
                Icon(
                  Icons.chevron_right_rounded,
                  color: Colors.grey.shade400,
                  size: 22,
                ),
              ],
            ),
            const SizedBox(height: 18),

            // Amounts Row: You get vs You owe
            Row(
              children: [
                // You get
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'You get',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF16A34A),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _formatAmount(youGetAmount),
                        style: const TextStyle(
                          fontSize: 26,
                          fontWeight: FontWeight.w900,
                          color: Color(0xFF16A34A),
                          letterSpacing: -0.5,
                        ),
                      ),
                    ],
                  ),
                ),

                // Subtle vertical separator
                Container(
                  width: 1,
                  height: 44,
                  color: AppColors.border,
                ),
                const SizedBox(width: 24),

                // You owe
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'You owe',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFFDC2626),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _formatAmount(youOweAmount),
                        style: const TextStyle(
                          fontSize: 26,
                          fontWeight: FontWeight.w900,
                          color: Color(0xFFDC2626),
                          letterSpacing: -0.5,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
