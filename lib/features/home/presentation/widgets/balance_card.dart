import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bill_splitter/features/activity/data/repositories/activity_repository.dart';
import 'package:flutter_bill_splitter/shared/widgets/platform_adaptive.dart';

/// Platform-adaptive Card displaying user's total net balance: "You get" vs "You owe".
/// Dynamically computes from [ActivityRepository] unless explicit amounts are provided.
class BalanceCard extends StatelessWidget {
  final double? youGetAmount;
  final double? youOweAmount;
  final VoidCallback? onTap;

  const BalanceCard({
    super.key,
    this.youGetAmount,
    this.youOweAmount,
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
    final isIOS = isIOSPlatform(context);

    return AnimatedBuilder(
      animation: ActivityRepository.instance,
      builder: (context, _) {
        double computedGet = 0.0;
        double computedOwe = 0.0;

        for (final act in ActivityRepository.instance.activities) {
          for (final st in act.settlements) {
            final toName = st.to.name.toLowerCase();
            final fromName = st.from.name.toLowerCase();
            if (toName == 'you' || toName == 'roshan') {
              computedGet += st.amount;
            } else if (fromName == 'you' || fromName == 'roshan') {
              computedOwe += st.amount;
            }
          }
        }

        final displayGet = youGetAmount ?? computedGet;
        final displayOwe = youOweAmount ?? computedOwe;

        return PlatformCard(
          borderRadius: 22,
          elevation: 1,
          color: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 20),
          onTap: () {
            HapticFeedback.lightImpact();
            onTap?.call();
          },
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
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF1B241E),
                      letterSpacing: -0.3,
                    ),
                  ),
                  Icon(
                    isIOS ? CupertinoIcons.chevron_right : Icons.chevron_right_rounded,
                    color: const Color(0xFF94A3B8),
                    size: 20,
                  ),
                ],
              ),
              const SizedBox(height: 18),

              // Values Row: You get vs You owe
              Row(
                children: [
                  // You get column
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'You get',
                          style: TextStyle(
                            fontSize: 13.5,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF16A34A),
                            letterSpacing: -0.1,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          _formatAmount(displayGet),
                          style: const TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.w900,
                            color: Color(0xFF16A34A),
                            letterSpacing: -0.5,
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Divider
                  Container(
                    height: 44,
                    width: 1,
                    color: const Color(0xFFE5E7EB),
                  ),
                  const SizedBox(width: 24),

                  // You owe column
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'You owe',
                          style: TextStyle(
                            fontSize: 13.5,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFFDC2626),
                            letterSpacing: -0.1,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          _formatAmount(displayOwe),
                          style: const TextStyle(
                            fontSize: 28,
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
        );
      },
    );
  }
}
