import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_bill_splitter/core/constants/expense_categories.dart';
import 'package:flutter_bill_splitter/core/theme/app_colors.dart';
import 'package:flutter_bill_splitter/core/utils/avatar_resolver.dart';
import 'package:flutter_bill_splitter/core/utils/currency_formatter.dart';
import 'package:flutter_bill_splitter/core/utils/user_identity_resolver.dart';
import 'package:flutter_bill_splitter/features/stories/domain/models/story.dart';
import 'package:flutter_bill_splitter/shared/widgets/app_avatar.dart';

/// The Overview tab widget for a story, rendering total expenses, per person share,
/// the net balance banner, member balances list, and recent expenses list.
class StoryOverviewTab extends StatelessWidget {
  final Story story;
  final double totalExpenses;
  final double perPersonAmount;
  final bool isSampleGoaTrip;
  final Future<void> Function() onRefresh;
  final VoidCallback onBannerTap;
  final VoidCallback onViewAllExpensesTap;
  final void Function(StoryExpense expense) onExpenseTap;
  final String? resolvedCurrentMemberId;

  const StoryOverviewTab({
    super.key,
    required this.story,
    required this.totalExpenses,
    required this.perPersonAmount,
    this.isSampleGoaTrip = false,
    required this.onRefresh,
    required this.onBannerTap,
    required this.onViewAllExpensesTap,
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

  String _formatMemberDisplayName(String name, bool isMe, [String? userId]) {
    return UserIdentityResolver.formatMemberDisplayName(
      name,
      isMe,
      memberUserId: userId,
      story: story,
    );
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

  Widget _buildNetBalanceBanner() {
    final myBalance = story.memberBalances.firstWhere(
      (b) => _isCurrentUser(b.name, b.userId),
      orElse: () => story.memberBalances.isNotEmpty
          ? story.memberBalances.first
          : const StoryMemberBalance(
              userId: '',
              name: 'You',
              totalPaid: 0,
              totalShare: 0,
              netBalance: 0,
              status: 'settled',
            ),
    );

    final hasPendingSettlements =
        story.settlements.any((s) => s.status == 'pending');
    final allBalancesZero = story.memberBalances.isNotEmpty &&
        story.memberBalances.every((b) => b.netBalance.abs() < 0.01);
    final allSettled = allBalancesZero && !hasPendingSettlements;

    if (allSettled) {
      const bgColor = Color(0xFFEAF8ED);
      const iconBgColor = Color(0xFFDCFCE7);
      const iconColor = Color(0xFF16A34A);
      const textColor = Color(0xFF15803D);

      return GestureDetector(
        onTap: onBannerTap,
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            color: bgColor,
            borderRadius: BorderRadius.circular(18),
          ),
          child: Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: iconBgColor,
                ),
                child: const Center(
                  child: Icon(Icons.check_rounded, color: iconColor, size: 20),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'All settled',
                      style: GoogleFonts.manrope(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        color: textColor,
                        letterSpacing: -0.4,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'You are all square',
                      style: GoogleFonts.manrope(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: textColor.withOpacity(0.85),
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(
                Icons.chevron_right_rounded,
                color: textColor,
                size: 24,
              ),
            ],
          ),
        ),
      );
    }

    final net = myBalance.netBalance;
    final isOwed = net < -0.01;
    final isGetsBack = net > 0.01;

    final bgColor = isOwed ? const Color(0xFFFDE8E8) : const Color(0xFFEAF8ED);
    final iconBgColor =
        isOwed ? const Color(0xFFFEE2E2) : const Color(0xFFDCFCE7);
    final iconColor =
        isOwed ? const Color(0xFFDC2626) : const Color(0xFF16A34A);
    final textColor =
        isOwed ? const Color(0xFFB91C1C) : const Color(0xFF15803D);

    final String labelText;
    final String displayAmount;
    final IconData arrowIcon;

    if (isOwed) {
      labelText = 'You owe';
      displayAmount = '₹${CurrencyFormatter.format(-net)}';
      arrowIcon = Icons.arrow_downward_rounded;
    } else if (isGetsBack) {
      labelText = 'You get back';
      displayAmount = '₹${CurrencyFormatter.format(net)}';
      arrowIcon = Icons.arrow_upward_rounded;
    } else {
      // Current user is even, but group has pending settlements
      labelText = 'Settlement pending';
      displayAmount = 'You are settled';
      arrowIcon = Icons.sync_alt_rounded;
    }

    return GestureDetector(
      onTap: onBannerTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(18),
        ),
        child: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: iconBgColor,
              ),
              child: Center(
                child: Icon(arrowIcon, color: iconColor, size: 20),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    labelText,
                    style: GoogleFonts.manrope(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: textColor,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    displayAmount,
                    style: GoogleFonts.manrope(
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                      color: textColor,
                      letterSpacing: -0.5,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.chevron_right_rounded,
              color: textColor,
              size: 24,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGroupSummaryMemberRow(StoryMemberBalance balance) {
    final isMe = _isCurrentUser(balance.name, balance.userId);
    final displayName = _formatMemberDisplayName(balance.name, isMe, balance.userId);
    final paid = balance.totalPaid;
    final net = balance.netBalance != 0.0 ||
            balance.totalPaid > 0 ||
            balance.totalShare > 0
        ? balance.netBalance
        : (paid - balance.totalShare);

    Color pillBg;
    Color pillTextColor;
    String pillTitle;
    String pillAmount;

    final isSettled = net.abs() <= 0.001;

    if (net > 0.001) {
      pillBg = const Color(0xFFE8F8EE);
      pillTextColor = const Color(0xFF16A34A);
      pillTitle = 'Gets';
      pillAmount = '₹${CurrencyFormatter.format(net)}';
    } else if (net < -0.001) {
      pillBg = const Color(0xFFFEECEB);
      pillTextColor = const Color(0xFFE53935);
      pillTitle = 'Owes';
      pillAmount = '₹${CurrencyFormatter.format(-net)}';
    } else {
      pillBg = const Color(0xFFF4F4F5);
      pillTextColor = AppColors.textSecondary;
      pillTitle = 'Settled';
      pillAmount = '';
    }

    final statusWidget = Container(
      padding: EdgeInsets.symmetric(
        horizontal: 10,
        vertical: isSettled ? 6 : 4,
      ),
      decoration: BoxDecoration(
        color: pillBg,
        borderRadius: BorderRadius.circular(12),
      ),
      child: isSettled
          ? Text(
              'Settled',
              style: GoogleFonts.manrope(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: pillTextColor,
              ),
            )
          : Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  pillTitle,
                  style: GoogleFonts.manrope(
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    color: pillTextColor,
                  ),
                ),
                const SizedBox(height: 1),
                Text(
                  pillAmount,
                  style: GoogleFonts.manrope(
                    fontSize: 13,
                    fontWeight: FontWeight.w800,
                    color: pillTextColor,
                    letterSpacing: -0.2,
                  ),
                ),
              ],
            ),
    );

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          AppAvatar(
            size: 42,
            name: balance.name,
            avatarUrl: story.members
                    .where((m) =>
                        m.userId == balance.userId ||
                        m.name.toLowerCase().trim() ==
                            balance.name.toLowerCase().trim())
                    .firstOrNull
                    ?.avatar ??
                AvatarResolver.getDefaultAvatarForName(balance.name),
            isCurrentUser: isMe,
            backgroundColor: const Color(0xFF1E1E1E),
            textColor: Colors.white,
            fontSize: 16,
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  displayName,
                  style: GoogleFonts.manrope(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'Paid ₹${CurrencyFormatter.format(paid)}',
                  style: GoogleFonts.manrope(
                    fontSize: 13,
                    color: AppColors.textSecondary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          statusWidget,
        ],
      ),
    );
  }

  Widget _buildExpenseItemRow(StoryExpense expense) {
    final payer = _resolvePayerMember(expense.paidBy);
    final isMe = _isCurrentUser(payer.name, payer.userId);
    final displayName = _formatMemberDisplayName(payer.name, isMe, payer.userId);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => onExpenseTap(expense),
        borderRadius: BorderRadius.circular(20),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Row(
            children: [
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

  Widget _buildRecentExpenseCard() {
    if (story.expenses.isEmpty) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppColors.border, width: 1.0),
        ),
        child: Center(
          child: Text(
            'No expenses recorded yet',
            style: GoogleFonts.manrope(
              fontSize: 14,
              color: AppColors.textSecondary,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      );
    }

    final sortedExpenses = List<StoryExpense>.from(story.expenses);
    sortedExpenses.sort((a, b) {
      final dateA = DateTime.tryParse(a.date);
      final dateB = DateTime.tryParse(b.date);
      if (dateA != null && dateB != null) {
        final cmp = dateB.compareTo(dateA);
        if (cmp != 0) return cmp;
      }
      return b.expenseId.compareTo(a.expenseId);
    });

    final recentList = sortedExpenses.take(6).toList();

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
          for (int i = 0; i < recentList.length; i++) ...[
            _buildExpenseItemRow(recentList[i]),
            if (i < recentList.length - 1)
              const Divider(color: AppColors.border, height: 1, thickness: 1),
          ],
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: onRefresh,
      color: AppColors.primary,
      child: SingleChildScrollView(
        key: const ValueKey('overview_tab'),
        physics: const AlwaysScrollableScrollPhysics(
            parent: BouncingScrollPhysics()),
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. Clean White Hero Summary Card (Total expenses & Per person)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(22),
                border: Border.all(color: AppColors.border, width: 1.0),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.03),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                children: [
                  // Total expenses
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Total expenses',
                          style: GoogleFonts.manrope(
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                            color: AppColors.textSecondary,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          '₹${CurrencyFormatter.format(totalExpenses)}',
                          style: GoogleFonts.manrope(
                            fontSize: 24,
                            fontWeight: FontWeight.w800,
                            color: AppColors.textPrimary,
                            letterSpacing: -0.5,
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Vertical Divider
                  Container(
                    width: 1,
                    height: 42,
                    color: AppColors.border,
                  ),
                  const SizedBox(width: 20),

                  // Per person
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Per person',
                          style: GoogleFonts.manrope(
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                            color: AppColors.textSecondary,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          '₹${CurrencyFormatter.format(perPersonAmount)}',
                          style: GoogleFonts.manrope(
                            fontSize: 24,
                            fontWeight: FontWeight.w800,
                            color: AppColors.textPrimary,
                            letterSpacing: -0.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // 2. Net Balance Banner Card ("You get back ₹3,500" with ↑ and >)
            _buildNetBalanceBanner(),
            const SizedBox(height: 22),

            // 3. Section Header: Member balances
            Stack(
              children: [
                Text(
                  'Member balances',
                  style: GoogleFonts.manrope(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: AppColors.textPrimary,
                    letterSpacing: -0.3,
                  ),
                ),
                const Opacity(
                  opacity: 0.0,
                  child: Text('Group summary', style: TextStyle(fontSize: 1)),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Group summary Card with Member Balances List
            Container(
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
                  for (int i = 0; i < story.memberBalances.length; i++) ...[
                    _buildGroupSummaryMemberRow(story.memberBalances[i]),
                    if (i < story.memberBalances.length - 1)
                      const Divider(
                          color: AppColors.border, height: 1, thickness: 1),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 24),

            // 4. Section: Recent expenses
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Recent expenses',
                  style: GoogleFonts.manrope(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: AppColors.textPrimary,
                    letterSpacing: -0.3,
                  ),
                ),
                GestureDetector(
                  onTap: () {
                    HapticFeedback.selectionClick();
                    onViewAllExpensesTap();
                  },
                  child: Text(
                    'View all →',
                    style: GoogleFonts.manrope(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Recent expenses Card
            _buildRecentExpenseCard(),
          ],
        ),
      ),
    );
  }
}
