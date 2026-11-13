import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_bill_splitter/core/theme/app_colors.dart';
import 'package:flutter_bill_splitter/core/theme/app_radius.dart';
import 'package:flutter_bill_splitter/core/utils/string_utils.dart';
import 'package:flutter_bill_splitter/features/friends/domain/models/friend.dart';
import 'package:flutter_bill_splitter/shared/widgets/platform_adaptive.dart';

/// Table card widget showing the breakdown for each member: Member, Paid, Share, Net.
/// Adheres to design.md Section 2, 3, 5 & 11.
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
    return PlatformCard(
      borderRadius: AppRadius.card,
      elevation: 0,
      color: AppColors.surface,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Column(
        children: [
          // Table Column Headers: Member | Paid | Share | Net
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 4),
            child: Row(
              children: [
                Expanded(
                  flex: 3,
                  child: Text(
                    'Member',
                    style: GoogleFonts.manrope(
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
                    style: GoogleFonts.manrope(
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
                    style: GoogleFonts.manrope(
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
                    style: GoogleFonts.manrope(
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
                                  ? AppColors.successSoft
                                  : isNegative
                                      ? AppColors.dangerSoft
                                      : AppColors.surfaceSubtle,
                              shape: BoxShape.circle,
                            ),
                            child: Center(
                              child: Text(
                                initial,
                                style: GoogleFonts.manrope(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w700,
                                  color: isPositive
                                      ? AppColors.success
                                      : isNegative
                                          ? AppColors.danger
                                          : AppColors.textPrimary,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              member.name,
                              style: GoogleFonts.manrope(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
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
                        style: GoogleFonts.manrope(
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
                        style: GoogleFonts.manrope(
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
                                  ? AppColors.successSoft
                                  : isNegative
                                      ? AppColors.dangerSoft
                                      : AppColors.surfaceSubtle,
                              borderRadius: BorderRadius.circular(AppRadius.pill),
                            ),
                            child: Text(
                              netFormatted,
                              style: GoogleFonts.manrope(
                                fontSize: 12.5,
                                fontWeight: FontWeight.w700,
                                color: isPositive
                                    ? AppColors.success
                                    : isNegative
                                        ? AppColors.danger
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
