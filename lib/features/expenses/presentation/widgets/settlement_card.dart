import 'package:flutter/material.dart';
import 'package:flutter_bill_splitter/core/theme/app_colors.dart';
import 'package:flutter_bill_splitter/core/utils/string_utils.dart';
import 'package:flutter_bill_splitter/features/expenses/domain/models/settlement_transaction.dart';
import 'package:flutter_bill_splitter/shared/widgets/platform_adaptive.dart';

/// Platform-adaptive Card displaying an individual settlement transaction:
/// Debtor (Avatar, Name, Pay ₹Amount) -> Arrow -> Creditor (Avatar, Name).
class SettlementCard extends StatelessWidget {
  final SettlementTransaction transaction;

  const SettlementCard({
    super.key,
    required this.transaction,
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
    final fromInitial = StringUtils.getSingleInitial(transaction.from.name);
    final toInitial = StringUtils.getSingleInitial(transaction.to.name);
    final amountFormatted = _formatAmount(transaction.amount);

    return Semantics(
      label: '${transaction.from.name} should pay $amountFormatted to ${transaction.to.name}',
      child: PlatformCard(
        borderRadius: 18,
        elevation: 1.5,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            // Debtor Circular Avatar (Soft peach/pink)
            Container(
              width: 38,
              height: 38,
              decoration: const BoxDecoration(
                color: Color(0xFFFFECE0),
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Text(
                  fromInitial,
                  style: const TextStyle(
                    color: Color(0xFFDC2626),
                    fontWeight: FontWeight.w900,
                    fontSize: 16,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),

            // Debtor Name & "Pay ₹Amount"
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    transaction.from.name,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w800,
                      color: AppColors.textPrimary,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'Pay $amountFormatted',
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),

            // Arrow Center
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 10),
              child: Icon(
                Icons.arrow_forward_rounded,
                color: AppColors.textPrimary,
                size: 20,
              ),
            ),

            // Creditor Circular Avatar (Soft lime)
            Container(
              width: 38,
              height: 38,
              decoration: const BoxDecoration(
                color: Color(0xFFE8F8D8),
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Text(
                  toInitial,
                  style: const TextStyle(
                    color: Color(0xFF284821),
                    fontWeight: FontWeight.w900,
                    fontSize: 16,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),

            // Creditor Name
            Expanded(
              child: Text(
                transaction.to.name,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w800,
                  color: AppColors.textPrimary,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
