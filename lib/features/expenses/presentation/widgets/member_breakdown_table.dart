import 'package:flutter/material.dart';
import 'package:flutter_neumorphism_ui/flutter_neumorphism_ui.dart';
import 'package:flutter_bill_splitter/core/theme/app_colors.dart';
import 'package:flutter_bill_splitter/core/theme/neumorphic_styles.dart';
import 'package:flutter_bill_splitter/core/utils/string_utils.dart';
import 'package:flutter_bill_splitter/features/friends/domain/models/friend.dart';

/// Table card widget showing the breakdown for each member: Member, Paid, Share, Net.
class MemberBreakdownTable extends StatelessWidget {
  final List<Friend> members;
  final Map<String, double> memberExpenses;
  final double sharePerPerson;

  const MemberBreakdownTable({
    super.key,
    required this.members,
    required this.memberExpenses,
    required this.sharePerPerson,
  });

  String _formatAmount(double amount) {
    if (amount.truncateToDouble() == amount) {
      final parts = amount.toInt().toString().replaceAllMapped(
            RegExp(r'(\d+?)(?=(\d{3})+(?!\d))'),
            (Match m) => '${m[1]},',
          );
      return '₹$parts';
    }
    return '₹${amount.toStringAsFixed(0)}';
  }

  @override
  Widget build(BuildContext context) {
    return FlutterNeumorphism(
      style: NeumorphicStyles.card(borderRadius: 22, depth: 5),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Column(
        children: [
          // Table Column Headers: Member | Paid | Share | Net
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 6, horizontal: 4),
            child: Row(
              children: [
                Expanded(
                  flex: 3,
                  child: Text(
                    'Member',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ),
                Expanded(
                  flex: 2,
                  child: Text(
                    'Paid',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ),
                Expanded(
                  flex: 2,
                  child: Text(
                    'Share',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ),
                Expanded(
                  flex: 2,
                  child: Text(
                    'Net',
                    textAlign: TextAlign.right,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 12, color: AppColors.border),

          // Member Rows
          for (int i = 0; i < members.length; i++) ...[
            () {
              final member = members[i];
              final paid = memberExpenses[member.name] ?? 0.0;
              final net = paid - sharePerPerson;
              final isPositive = net > 0.01;
              final isNegative = net < -0.01;
              final initial = StringUtils.getSingleInitial(member.name);

              final netFormatted = isPositive
                  ? '+${_formatAmount(net)}'
                  : isNegative
                      ? '-${_formatAmount(-net)}'
                      : '₹0';

              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Row(
                  children: [
                    // Member Avatar & Name
                    Expanded(
                      flex: 3,
                      child: Row(
                        children: [
                          Container(
                            width: 28,
                            height: 28,
                            decoration: BoxDecoration(
                              color: isPositive
                                  ? const Color(0xFFE8F8D8)
                                  : const Color(0xFFFFECE0),
                              shape: BoxShape.circle,
                            ),
                            child: Center(
                              child: Text(
                                initial,
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w900,
                                  color: isPositive
                                      ? const Color(0xFF284821)
                                      : const Color(0xFFDC2626),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              member.name,
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w700,
                                color: AppColors.textPrimary,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Paid
                    Expanded(
                      flex: 2,
                      child: Text(
                        _formatAmount(paid),
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 13.5,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ),

                    // Share
                    Expanded(
                      flex: 2,
                      child: Text(
                        _formatAmount(sharePerPerson),
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 13.5,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ),

                    // Net Badge
                    Expanded(
                      flex: 2,
                      child: Align(
                        alignment: Alignment.centerRight,
                        child: Semantics(
                          label: isPositive
                              ? 'Gets ${_formatAmount(net)}'
                              : isNegative
                                  ? 'Owes ${_formatAmount(-net)}'
                                  : 'Settled',
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: isPositive
                                  ? const Color(0xFFE8F8D8)
                                  : isNegative
                                      ? const Color(0xFFFFECE0)
                                      : const Color(0xFFE8EEF2),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Text(
                              netFormatted,
                              style: TextStyle(
                                fontSize: 12.5,
                                fontWeight: FontWeight.w800,
                                color: isPositive
                                    ? const Color(0xFF16A34A)
                                    : isNegative
                                        ? const Color(0xFFDC2626)
                                        : AppColors.textSecondary,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }(),
            if (i < members.length - 1)
              const Divider(height: 8, color: AppColors.border),
          ],
        ],
      ),
    );
  }
}

