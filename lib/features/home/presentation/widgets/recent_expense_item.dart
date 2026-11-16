import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_bill_splitter/core/theme/app_colors.dart';
import 'package:flutter_bill_splitter/core/theme/app_radius.dart';
import 'package:flutter_bill_splitter/core/utils/currency_formatter.dart';
import 'package:flutter_bill_splitter/features/home/domain/models/recent_expense.dart';

/// Single item row displaying a recent expense.
/// Adheres to design.md Section 3, 4 & 10.
class RecentExpenseItem extends StatelessWidget {
  final RecentExpense expense;
  final VoidCallback? onTap;

  const RecentExpenseItem({
    super.key,
    required this.expense,
    this.onTap,
  });

  String _formatAmount(double amount) =>
      CurrencyFormatter.format(amount, includeSymbol: true);

  String _formatSubtitle() {
    if (expense.payerName != null && expense.payerName!.isNotEmpty) {
      if (expense.timestamp != null) {
        final now = DateTime.now();
        final dt = expense.timestamp!;
        final diffDays = DateTime(now.year, now.month, now.day)
            .difference(DateTime(dt.year, dt.month, dt.day))
            .inDays;

        String dateStr;
        if (diffDays == 0) {
          dateStr = 'Today';
        } else if (diffDays == 1) {
          dateStr = 'Yesterday';
        } else {
          const months = [
            'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
            'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
          ];
          dateStr = '${dt.day} ${months[dt.month - 1]}';
        }
        return 'Paid by ${expense.payerName}  •  $dateStr';
      }
      return 'Paid by ${expense.payerName}  •  ${expense.memberCount} members';
    }

    return '${expense.category}  •  ${expense.memberCount} members';
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppRadius.input),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 4),
        child: Row(
          children: [
            // Colored Squircle Icon Container with Category Visual
            Container(
              width: 46,
              height: 46,
              decoration: BoxDecoration(
                color: expense.iconBgColor,
                borderRadius: BorderRadius.circular(AppRadius.iconContainer),
              ),
              child: Icon(
                expense.icon,
                color: expense.iconColor,
                size: 22,
              ),
            ),
            const SizedBox(width: 14),

            // Title & Contextual Subtitle (Paid by Who • Date / Category)
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    expense.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.manrope(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                      letterSpacing: -0.2,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    _formatSubtitle(),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.manrope(
                      fontSize: 12.5,
                      fontWeight: FontWeight.w400,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),

            // Amount
            Text(
              _formatAmount(expense.amount),
              style: GoogleFonts.manrope(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
                letterSpacing: -0.3,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
