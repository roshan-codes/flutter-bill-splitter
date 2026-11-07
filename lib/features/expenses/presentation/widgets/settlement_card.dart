import 'package:flutter/material.dart';
import 'package:flutter_neumorphism_ui/flutter_neumorphism_ui.dart';
import 'package:flutter_bill_splitter/core/theme/app_colors.dart';
import 'package:flutter_bill_splitter/core/theme/neumorphic_styles.dart';
import 'package:flutter_bill_splitter/core/utils/string_utils.dart';
import 'package:flutter_bill_splitter/features/expenses/domain/models/settlement_transaction.dart';

/// Neumorphic Card showing clearly who should pay whom and the exact amount.
class SettlementCard extends StatelessWidget {
  final SettlementTransaction transaction;

  const SettlementCard({
    super.key,
    required this.transaction,
  });

  @override
  Widget build(BuildContext context) {
    final fromInitial = StringUtils.getSingleInitial(transaction.from.name);
    final toInitial = StringUtils.getSingleInitial(transaction.to.name);
    final amountFormatted = '₹${transaction.amount.toStringAsFixed(transaction.amount.truncateToDouble() == transaction.amount ? 0 : 2)}';

    return FlutterNeumorphism(
      style: NeumorphicStyles.card(borderRadius: 22, depth: 5),
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // Visual payer -> arrow with amount -> receiver flow
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Payer
              Expanded(
                child: Row(
                  children: [
                    FlutterNeumorphism(
                      style: NeumorphicStyles.card(
                        borderRadius: 14,
                        depth: 3,
                        color: const Color(0xFFFFECEC),
                      ),
                      width: 44,
                      height: 44,
                      padding: EdgeInsets.zero,
                      child: Text(
                        fromInitial,
                        style: const TextStyle(
                          color: Color(0xFFC92A2A),
                          fontWeight: FontWeight.w900,
                          fontSize: 18,
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            transaction.from.name,
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w800,
                              color: AppColors.textPrimary,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const Text(
                            'Payer',
                            style: TextStyle(
                              fontSize: 11,
                              color: Color(0xFFC92A2A),
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              // Arrow with amount pill
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: Column(
                  children: [
                    FlutterNeumorphism(
                      style: NeumorphicStyles.primaryButton(borderRadius: 12, depth: 4),
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                      child: Text(
                        amountFormatted,
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w900,
                          color: AppColors.primaryDark,
                        ),
                      ),
                    ),
                    const SizedBox(height: 3),
                    const Icon(
                      Icons.arrow_forward_rounded,
                      size: 20,
                      color: AppColors.primaryDeep,
                    ),
                  ],
                ),
              ),

              // Receiver
              Expanded(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            transaction.to.name,
                            textAlign: TextAlign.end,
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w800,
                              color: AppColors.textPrimary,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const Text(
                            'Receiver',
                            textAlign: TextAlign.end,
                            style: TextStyle(
                              fontSize: 11,
                              color: Color(0xFF284821),
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 10),
                    FlutterNeumorphism(
                      style: NeumorphicStyles.card(
                        borderRadius: 14,
                        depth: 3,
                        color: AppColors.primaryLight,
                      ),
                      width: 44,
                      height: 44,
                      padding: EdgeInsets.zero,
                      child: Text(
                        toInitial,
                        style: const TextStyle(
                          color: Color(0xFF284821),
                          fontWeight: FontWeight.w900,
                          fontSize: 18,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),
          const Divider(height: 1, color: AppColors.border),
          const SizedBox(height: 10),

          // Explicit statement: "[From] should pay [Amount] to [To]"
          Row(
            children: [
              const Icon(
                Icons.info_outline_rounded,
                size: 16,
                color: AppColors.textSecondary,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text.rich(
                  TextSpan(
                    style: const TextStyle(
                      fontSize: 13,
                      color: AppColors.textPrimary,
                    ),
                    children: [
                      TextSpan(
                        text: transaction.from.name,
                        style: const TextStyle(fontWeight: FontWeight.w800),
                      ),
                      const TextSpan(text: ' should pay '),
                      TextSpan(
                        text: amountFormatted,
                        style: const TextStyle(
                          fontWeight: FontWeight.w800,
                          color: AppColors.primaryDeep,
                        ),
                      ),
                      const TextSpan(text: ' to '),
                      TextSpan(
                        text: transaction.to.name,
                        style: const TextStyle(fontWeight: FontWeight.w800),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
