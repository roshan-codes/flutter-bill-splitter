import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_bill_splitter/core/constants/expense_categories.dart';
import 'package:flutter_bill_splitter/core/theme/app_colors.dart';
import 'package:flutter_bill_splitter/core/theme/app_radius.dart';
import 'package:flutter_bill_splitter/core/utils/currency_formatter.dart';
import 'package:flutter_bill_splitter/core/utils/user_identity_resolver.dart';
import 'package:flutter_bill_splitter/features/stories/domain/models/story.dart';

/// The Expenses tab widget for a story, rendering categorized expenses,
/// counts, and expense rows.
class StoryExpensesTab extends StatelessWidget {
  final Story story;
  final double totalExpenses;
  final Future<void> Function() onRefresh;
  final void Function(StoryExpense expense) onExpenseTap;
  final String? resolvedCurrentMemberId;

  const StoryExpensesTab({
    super.key,
    required this.story,
    required this.totalExpenses,
    required this.onRefresh,
    required this.onExpenseTap,
    this.resolvedCurrentMemberId,
  });

  bool _isCurrentUser(String name, [String? userId]) {
    return UserIdentityResolver.isCurrentUser(
      name: name,
      userId: userId,
      story: story,
      resolvedCurrentMemberId: resolvedCurrentMemberId,
    );
  }

  String _formatMemberDisplayName(String name, bool isMe) {
    return UserIdentityResolver.formatMemberDisplayName(name, isMe);
  }

  StoryMember _resolvePayerMember(String paidByIdentifier) {
    return story.members.firstWhere(
      (m) =>
          m.userId == paidByIdentifier ||
          m.name.toLowerCase() == paidByIdentifier.toLowerCase(),
      orElse: () => StoryMember(
        userId: paidByIdentifier,
        name: paidByIdentifier,
        joinedAt: '',
      ),
    );
  }

  String _formatExpenseDateTime(String dateStr) {
    try {
      final dt = DateTime.parse(dateStr).toLocal();
      const months = [
        'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
        'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
      ];
      final month = months[dt.month - 1];
      final hour = dt.hour == 0 ? 12 : (dt.hour > 12 ? dt.hour - 12 : dt.hour);
      final hourStr = hour.toString().padLeft(2, '0');
      final minuteStr = dt.minute.toString().padLeft(2, '0');
      final ampm = dt.hour >= 12 ? 'PM' : 'AM';
      return '$month ${dt.day}, $hourStr:$minuteStr $ampm';
    } catch (_) {
      return dateStr;
    }
  }

  Widget _buildExpenseItemRow(StoryExpense expense) {
    final payer = _resolvePayerMember(expense.paidBy);
    final isMe = _isCurrentUser(payer.name, payer.userId);
    final displayName = _formatMemberDisplayName(payer.name, isMe);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => onExpenseTap(expense),
        borderRadius: BorderRadius.circular(20),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Row(
            children: [
              // Category Icon Squircle
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: const Color(0xFFF3F4F6),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Center(
                  child: Icon(
                    ExpenseCategories.getCategoryIcon(expense.category),
                    size: 22,
                    color: const Color(0xFF1F2937),
                  ),
                ),
              ),
              const SizedBox(width: 14),

              // Title, Payer, and Timestamp
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      expense.title,
                      style: GoogleFonts.manrope(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 3),
                    Text(
                      'Paid by $displayName',
                      style: GoogleFonts.manrope(
                        fontSize: 12,
                        color: AppColors.textSecondary,
                        fontWeight: FontWeight.w500,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      _formatExpenseDateTime(expense.date),
                      style: GoogleFonts.manrope(
                        fontSize: 12,
                        color: AppColors.textSecondary,
                        fontWeight: FontWeight.w500,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),

              // Trailing Amount
              Text(
                '₹${CurrencyFormatter.format(expense.amount)}',
                style: GoogleFonts.manrope(
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  color: AppColors.textPrimary,
                  letterSpacing: -0.3,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: onRefresh,
      color: AppColors.primary,
      child: SingleChildScrollView(
        key: const ValueKey('expenses_tab'),
        physics: const AlwaysScrollableScrollPhysics(
            parent: BouncingScrollPhysics()),
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 90),
        child: SizedBox(
          width: double.infinity,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Sub-header: "₹1,000 total · 1 expense"
              Builder(
                builder: (context) {
                  final actualCount = story.expenses
                      .where((e) =>
                          e.category != 'reimbursement' &&
                          e.category != 'settlement' &&
                          e.category != 'advance')
                      .length;
                  final transferCount = story.expenses.length - actualCount;
                  final countText = transferCount > 0
                      ? '$actualCount expense${actualCount == 1 ? '' : 's'} · $transferCount transfer${transferCount == 1 ? '' : 's'}'
                      : '$actualCount expense${actualCount == 1 ? '' : 's'}';
                  return Text(
                    '₹${CurrencyFormatter.format(totalExpenses)} total · $countText',
                    style: GoogleFonts.manrope(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textSecondary,
                    ),
                  );
                },
              ),
              const SizedBox(height: 14),

              if (story.expenses.isEmpty)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 40),
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          width: 56,
                          height: 56,
                          decoration: BoxDecoration(
                            color: AppColors.surfaceSubtle,
                            borderRadius: BorderRadius.circular(AppRadius.card),
                          ),
                          child: const Icon(
                            Icons.receipt_long_outlined,
                            size: 28,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 14),
                        Text(
                          'No expenses added yet',
                          style: GoogleFonts.manrope(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          'Tap "+ Add expense" below to record who paid.',
                          style: GoogleFonts.manrope(
                            fontSize: 13,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                )
              else
                Builder(
                  builder: (context) {
                    final sortedExpenses =
                        List<StoryExpense>.from(story.expenses);
                    sortedExpenses.sort((a, b) {
                      final dateA = DateTime.tryParse(a.date);
                      final dateB = DateTime.tryParse(b.date);
                      if (dateA != null && dateB != null) {
                        final cmp = dateB.compareTo(dateA); // Latest first
                        if (cmp != 0) return cmp;
                      }
                      return b.expenseId.compareTo(a.expenseId);
                    });

                    // Expenses in single card with dividers like members list
                    return Container(
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: AppColors.border, width: 1.0),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.03),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          for (int i = 0; i < sortedExpenses.length; i++) ...[
                            _buildExpenseItemRow(sortedExpenses[i]),
                            if (i < sortedExpenses.length - 1)
                              const Divider(
                                color: AppColors.border,
                                height: 1,
                                thickness: 1,
                              ),
                          ],
                        ],
                      ),
                    );
                  },
                ),
            ],
          ),
        ),
      ),
    );
  }
}
