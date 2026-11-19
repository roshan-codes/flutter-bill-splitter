import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_bill_splitter/core/constants/expense_categories.dart';
import 'package:flutter_bill_splitter/core/theme/app_colors.dart';
import 'package:flutter_bill_splitter/core/utils/avatar_resolver.dart';
import 'package:flutter_bill_splitter/core/utils/currency_formatter.dart';
import 'package:flutter_bill_splitter/core/utils/user_identity_resolver.dart';
import 'package:flutter_bill_splitter/features/stories/domain/models/story.dart';
import 'package:flutter_bill_splitter/shared/widgets/app_avatar.dart';

/// The Overview tab widget for a story, rendering a strictly visual analytics dashboard:
/// - Hero summary card (Total expenses & Per person)
/// - Net balance banner (You owe / You get back / All settled)
/// - Settlement plan section
/// - Spending by category (visual proportional bar + category breakdown)
/// - Expense timeline (daily spend progression)
/// - Member balances list
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

  StoryMember _resolveMember(String identifier) {
    return story.members.firstWhere(
      (m) =>
          m.userId == identifier ||
          m.name.toLowerCase().trim() == identifier.toLowerCase().trim(),
      orElse: () => StoryMember(
        userId: identifier,
        name: identifier,
        joinedAt: '',
      ),
    );
  }

  static Color _getCategoryColor(String category) {
    switch (category.toLowerCase()) {
      case 'food':
      case 'restaurant':
      case 'dining':
        return const Color(0xFFF97316); // Orange
      case 'transport':
      case 'fuel':
      case 'travel':
      case 'flight':
        return const Color(0xFF3B82F6); // Blue
      case 'stay':
      case 'accommodation':
      case 'hotel':
        return const Color(0xFF8B5CF6); // Purple
      case 'entertainment':
      case 'activities':
      case 'sports':
        return const Color(0xFFEC4899); // Pink
      case 'groceries':
      case 'shopping':
        return const Color(0xFF10B981); // Emerald
      case 'drinks':
      case 'bar':
        return const Color(0xFFEAB308); // Amber
      default:
        return const Color(0xFF6B7280); // Gray
    }
  }

  static String _getCategoryDisplayName(String cat) {
    switch (cat.toLowerCase().trim()) {
      case 'transport':
      case 'travel':
        return 'Travel & Transit';
      case 'food':
      case 'dining':
        return 'Dining & Meals';
      case 'stay':
      case 'accommodation':
        return 'Stay & Lodging';
      case 'shopping':
        return 'Shopping & Retail';
      case 'entertainment':
      case 'activities':
        return 'Entertainment';
      default:
        return cat.isNotEmpty ? cat[0].toUpperCase() + cat.substring(1) : 'General';
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
          const Opacity(
            opacity: 0.0,
            child: Text('Add expense', style: TextStyle(fontSize: 1)),
          ),
        ],
      ),
    );
  }

  // --- Visual Analytics Dashboard Widgets ---

  Widget _buildSpendingByCategoryCard() {
    final actualExpenses = story.expenses
        .where((e) =>
            e.category != 'reimbursement' &&
            e.category != 'settlement' &&
            e.category != 'advance')
        .toList();

    if (actualExpenses.isEmpty) {
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

    final Map<String, double> categoryAmounts = {};
    final Map<String, int> categoryCounts = {};
    double totalSpend = 0.0;

    for (final exp in actualExpenses) {
      final cat = exp.category.isEmpty ? 'other' : exp.category;
      categoryAmounts[cat] = (categoryAmounts[cat] ?? 0.0) + exp.amount;
      categoryCounts[cat] = (categoryCounts[cat] ?? 0) + 1;
      totalSpend += exp.amount;
    }

    final sortedCategories = categoryAmounts.keys.toList()
      ..sort((a, b) => categoryAmounts[b]!.compareTo(categoryAmounts[a]!));

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.border, width: 1.0),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.025),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Spending by category',
                style: GoogleFonts.manrope(
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  color: AppColors.textPrimary,
                  letterSpacing: -0.2,
                ),
              ),
              Text(
                '${sortedCategories.length} categories',
                style: GoogleFonts.manrope(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Visual Multi-Color Proportional Distribution Bar
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: SizedBox(
              height: 12,
              child: Row(
                children: sortedCategories.map((cat) {
                  final flex = ((categoryAmounts[cat]! /
                              (totalSpend > 0 ? totalSpend : 1)) *
                          1000)
                      .round()
                      .clamp(1, 1000);
                  return Expanded(
                    flex: flex,
                    child: Container(
                      color: _getCategoryColor(cat),
                    ),
                  );
                }).toList(),
              ),
            ),
          ),
          const SizedBox(height: 18),

          // Category rows
          Column(
            children: sortedCategories.asMap().entries.map((entry) {
              final idx = entry.key;
              final cat = entry.value;
              final amount = categoryAmounts[cat]!;
              final pct = totalSpend > 0 ? (amount / totalSpend * 100) : 0.0;
              final count = categoryCounts[cat]!;
              final color = _getCategoryColor(cat);

              return Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 6),
                    child: Row(
                      children: [
                        Container(
                          width: 34,
                          height: 34,
                          decoration: BoxDecoration(
                            color: color.withOpacity(0.12),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Center(
                            child: Icon(
                              ExpenseCategories.getCategoryIcon(cat),
                              size: 18,
                              color: color,
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                _getCategoryDisplayName(cat),
                                style: GoogleFonts.manrope(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                              Text(
                                '$count expense${count == 1 ? '' : 's'} • ${pct.toStringAsFixed(1)}%',
                                style: GoogleFonts.manrope(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w500,
                                  color: AppColors.textSecondary,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Text(
                          '₹${CurrencyFormatter.format(amount)}',
                          style: GoogleFonts.manrope(
                            fontSize: 14,
                            fontWeight: FontWeight.w800,
                            color: AppColors.textPrimary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (idx < sortedCategories.length - 1)
                    const Divider(color: AppColors.border, height: 12, thickness: 0.8),
                ],
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildTimelineCard() {
    final actualExpenses = story.expenses
        .where((e) =>
            e.category != 'reimbursement' &&
            e.category != 'settlement' &&
            e.category != 'advance')
        .toList();

    if (actualExpenses.isEmpty) return const SizedBox.shrink();

    // Group by Date YYYY-MM-DD
    final Map<String, List<StoryExpense>> grouped = {};
    for (final exp in actualExpenses) {
      try {
        final dt = DateTime.parse(exp.date).toLocal();
        final key =
            '${dt.year}-${dt.month.toString().padLeft(2, '0')}-${dt.day.toString().padLeft(2, '0')}';
        grouped.putIfAbsent(key, () => []).add(exp);
      } catch (_) {
        grouped.putIfAbsent('General', () => []).add(exp);
      }
    }

    final sortedDates = grouped.keys.toList()
      ..sort((a, b) => b.compareTo(a)); // Newest first

    String formatDayHeader(String key) {
      try {
        final parts = key.split('-');
        final year = int.parse(parts[0]);
        final month = int.parse(parts[1]);
        final day = int.parse(parts[2]);
        const months = [
          'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
          'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
        ];
        return '${months[month - 1]} $day, $year';
      } catch (_) {
        return key;
      }
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.border, width: 1.0),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.025),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Expense timeline',
                style: GoogleFonts.manrope(
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  color: AppColors.textPrimary,
                  letterSpacing: -0.2,
                ),
              ),
              Text(
                '${sortedDates.length} day${sortedDates.length == 1 ? '' : 's'}',
                style: GoogleFonts.manrope(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Timeline Nodes
          Column(
            children: sortedDates.asMap().entries.map((entry) {
              final i = entry.key;
              final dateKey = entry.value;
              final dayExpenses = grouped[dateKey]!;
              final dayTotal =
                  dayExpenses.fold<double>(0.0, (sum, e) => sum + e.amount);

              return Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Column(
                    children: [
                      Container(
                        width: 14,
                        height: 14,
                        decoration: BoxDecoration(
                          color: AppColors.primary,
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 2.5),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.primary.withOpacity(0.3),
                              blurRadius: 4,
                              offset: const Offset(0, 1),
                            ),
                          ],
                        ),
                      ),
                      if (i < sortedDates.length - 1)
                        Container(
                          width: 2,
                          height: 40 + (dayExpenses.length * 28.0),
                          color: AppColors.border,
                        ),
                    ],
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              formatDayHeader(dateKey),
                              style: GoogleFonts.manrope(
                                fontSize: 14,
                                fontWeight: FontWeight.w700,
                                color: AppColors.textPrimary,
                              ),
                            ),
                            Text(
                              '₹${CurrencyFormatter.format(dayTotal)}',
                              style: GoogleFonts.manrope(
                                fontSize: 14,
                                fontWeight: FontWeight.w800,
                                color: AppColors.primary,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        for (final exp in dayExpenses) ...[
                          Padding(
                            padding: const EdgeInsets.only(bottom: 6),
                            child: InkWell(
                              onTap: () => onExpenseTap(exp),
                              borderRadius: BorderRadius.circular(8),
                              child: Row(
                                children: [
                                  Icon(
                                    ExpenseCategories.getCategoryIcon(exp.category),
                                    size: 14,
                                    color: AppColors.textSecondary,
                                  ),
                                  const SizedBox(width: 6),
                                  Expanded(
                                    child: Text(
                                      exp.title,
                                      style: GoogleFonts.manrope(
                                        fontSize: 12.5,
                                        fontWeight: FontWeight.w500,
                                        color: AppColors.textPrimary,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                  Text(
                                    '₹${CurrencyFormatter.format(exp.amount)}',
                                    style: GoogleFonts.manrope(
                                      fontSize: 12.5,
                                      fontWeight: FontWeight.w600,
                                      color: AppColors.textSecondary,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                        const SizedBox(height: 12),
                      ],
                    ),
                  ),
                ],
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildSettlementPlanCard() {
    final pendingSettlements =
        story.settlements.where((s) => s.status == 'pending').toList();

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.border, width: 1.0),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.025),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Settlement plan',
                style: GoogleFonts.manrope(
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  color: AppColors.textPrimary,
                  letterSpacing: -0.2,
                ),
              ),
              GestureDetector(
                onTap: onBannerTap,
                child: Text(
                  'Settle up →',
                  style: GoogleFonts.manrope(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: AppColors.primary,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),

          if (pendingSettlements.isEmpty) ...[
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              decoration: BoxDecoration(
                color: const Color(0xFFEAF8ED),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Row(
                children: [
                  const Icon(Icons.check_circle_rounded,
                      color: Color(0xFF16A34A), size: 20),
                  const SizedBox(width: 10),
                  Text(
                    'All debts are cleared! Everyone is settled.',
                    style: GoogleFonts.manrope(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF15803D),
                    ),
                  ),
                ],
              ),
            ),
          ] else ...[
            Column(
              children: pendingSettlements.map((s) {
                final fromMember = _resolveMember(s.fromUser);
                final toMember = _resolveMember(s.toUser);
                final isMeFrom =
                    _isCurrentUser(fromMember.name, fromMember.userId);
                final isMeTo = _isCurrentUser(toMember.name, toMember.userId);

                final fromDisplayName = _formatMemberDisplayName(
                    fromMember.name, isMeFrom, fromMember.userId);
                final toDisplayName = _formatMemberDisplayName(
                    toMember.name, isMeTo, toMember.userId);

                return Container(
                  margin: const EdgeInsets.only(bottom: 10),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF9FAFB),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: const Color(0xFFE5E7EB)),
                  ),
                  child: Row(
                    children: [
                      AppAvatar(
                        size: 32,
                        name: fromMember.name,
                        avatarUrl: fromMember.avatar ??
                            AvatarResolver.getDefaultAvatarForName(
                                fromMember.name),
                        isCurrentUser: isMeFrom,
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: RichText(
                          text: TextSpan(
                            style: GoogleFonts.manrope(
                              fontSize: 13,
                              color: AppColors.textPrimary,
                            ),
                            children: [
                              TextSpan(
                                text: fromDisplayName,
                                style: const TextStyle(
                                    fontWeight: FontWeight.w700),
                              ),
                              const TextSpan(
                                text: ' pays ',
                                style:
                                    TextStyle(color: Color(0xFF6B7280)),
                              ),
                              TextSpan(
                                text: toDisplayName,
                                style: const TextStyle(
                                    fontWeight: FontWeight.w700),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: const Color(0xFFE8F8EE),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          '₹${CurrencyFormatter.format(s.amount)}',
                          style: GoogleFonts.manrope(
                            fontSize: 13,
                            fontWeight: FontWeight.w800,
                            color: const Color(0xFF16A34A),
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
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
            // 1. Hero Summary Card (Total expenses & Per person)
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

            // 2. Net Balance Banner Card ("You owe / You get back / All settled")
            _buildNetBalanceBanner(),
            const SizedBox(height: 22),

            // 3. Settlement Plan Card
            _buildSettlementPlanCard(),
            const SizedBox(height: 22),

            // 4. Spending by Category Card (Visual proportional distribution bar + list)
            _buildSpendingByCategoryCard(),
            const SizedBox(height: 22),

            // 5. Expense Timeline Card (Daily spend progression)
            _buildTimelineCard(),
            const SizedBox(height: 22),

            // 6. Section Header: Member balances
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

            // Member Balances List Card
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
          ],
        ),
      ),
    );
  }
}
