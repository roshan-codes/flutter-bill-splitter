import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_bill_splitter/core/theme/app_colors.dart';
import 'package:flutter_bill_splitter/core/theme/app_radius.dart';
import 'package:flutter_bill_splitter/features/activity/data/repositories/activity_repository.dart';
import 'package:flutter_bill_splitter/features/activity/domain/models/split_activity.dart';
import 'package:flutter_bill_splitter/features/expenses/domain/services/expense_calculator.dart';
import 'package:flutter_bill_splitter/features/expenses/presentation/widgets/member_breakdown_table.dart';
import 'package:flutter_bill_splitter/features/expenses/presentation/widgets/settlement_card.dart';
import 'package:flutter_bill_splitter/features/friends/domain/models/friend.dart';
import 'package:flutter_bill_splitter/features/stories/data/repositories/story_repository.dart';
import 'package:flutter_bill_splitter/features/stories/domain/models/story.dart';
import 'package:flutter_bill_splitter/shared/widgets/platform_adaptive.dart';

/// Screen displaying the final settlement summary: total expenses, who owes whom, and full member breakdown table.
/// Adheres to design.md Section 2, 3, 5, 6 & 10.3/10.7.
class SplitSummaryScreen extends StatelessWidget {
  final String groupName;
  final List<Friend> members;
  final Map<String, double> memberExpenses;

  const SplitSummaryScreen({
    super.key,
    required this.groupName,
    required this.members,
    required this.memberExpenses,
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
    final title = groupName.isNotEmpty ? groupName : 'Shared Expense';
    final totalExpense = ExpenseCalculator.calculateTotal(memberExpenses);
    final sharePerPerson = ExpenseCalculator.calculateSharePerPerson(totalExpense, members.length);
    final settlements = ExpenseCalculator.calculateSettlements(
      members: members,
      paidAmounts: memberExpenses,
    );
    final isIOS = isIOSPlatform(context);

    return Scaffold(
      backgroundColor: isIOS ? AppColors.iosBackground : AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        leadingWidth: 64,
        leading: Padding(
          padding: const EdgeInsets.only(left: 16),
          child: Center(
            child: PlatformBackButton(
              onPressed: () {
                HapticFeedback.lightImpact();
                Navigator.pop(context);
              },
            ),
          ),
        ),
        title: Text(
          'Split Summary',
          style: GoogleFonts.manrope(
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
            letterSpacing: -0.3,
          ),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          physics: isIOS ? const BouncingScrollPhysics() : const ClampingScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1. Top Card: Title & Member Count
              PlatformCard(
                borderRadius: AppRadius.card,
                elevation: 0,
                color: AppColors.surface,
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
                child: Row(
                  children: [
                    Container(
                      width: 46,
                      height: 46,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(AppRadius.iconContainer),
                        color: AppColors.surfaceSubtle,
                      ),
                      child: const Icon(
                        Icons.restaurant_rounded,
                        color: AppColors.textPrimary,
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            title,
                            style: GoogleFonts.manrope(
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                              color: AppColors.textPrimary,
                              letterSpacing: -0.2,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 3),
                          Text(
                            '${members.length} members',
                            style: GoogleFonts.manrope(
                              fontSize: 13,
                              color: AppColors.textSecondary,
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // 2. Overview Card: Total Expense vs Each Pays
              PlatformCard(
                borderRadius: AppRadius.card,
                elevation: 0,
                color: AppColors.surface,
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
                child: Row(
                  children: [
                    // Total Expense
                    Expanded(
                      child: Row(
                        children: [
                          Container(
                            width: 38,
                            height: 38,
                            decoration: BoxDecoration(
                              color: AppColors.surfaceSubtle,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Icon(
                              Icons.receipt_long_rounded,
                              color: AppColors.textPrimary,
                              size: 20,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Total Expense',
                                  style: GoogleFonts.manrope(
                                    fontSize: 12,
                                    color: AppColors.textSecondary,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  _formatAmount(totalExpense),
                                  style: GoogleFonts.manrope(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w800,
                                    color: AppColors.textPrimary,
                                    letterSpacing: -0.3,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Divider
                    Container(
                      height: 40,
                      width: 1,
                      color: AppColors.border,
                    ),
                    const SizedBox(width: 16),

                    // Each Pays
                    Expanded(
                      child: Row(
                        children: [
                          Container(
                            width: 38,
                            height: 38,
                            decoration: BoxDecoration(
                              color: AppColors.surfaceSubtle,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Icon(
                              Icons.pie_chart_outline_rounded,
                              color: AppColors.textPrimary,
                              size: 20,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Each Pays',
                                  style: GoogleFonts.manrope(
                                    fontSize: 12,
                                    color: AppColors.textSecondary,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  _formatAmount(sharePerPerson),
                                  style: GoogleFonts.manrope(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w800,
                                    color: AppColors.textPrimary,
                                    letterSpacing: -0.3,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 22),

              // 3. Section: Settlement Plan
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(
                          color: AppColors.surfaceSubtle,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Icon(
                          Icons.swap_horiz_rounded,
                          color: AppColors.textPrimary,
                          size: 20,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        'Who Pays Whom',
                        style: GoogleFonts.manrope(
                          fontSize: 17,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary,
                          letterSpacing: -0.3,
                        ),
                      ),
                    ],
                  ),
                  Text(
                    '${settlements.length} payment${settlements.length == 1 ? '' : 's'}',
                    style: GoogleFonts.manrope(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),

              if (settlements.isEmpty)
                PlatformCard(
                  borderRadius: AppRadius.card,
                  color: AppColors.successSoft,
                  border: Border.all(color: AppColors.success.withOpacity(0.2), width: 1.0),
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.check_circle_rounded,
                        color: AppColors.success,
                        size: 26,
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Text(
                          'All settled up! Everyone paid their exact equal share. No payments needed!',
                          style: GoogleFonts.manrope(
                            fontSize: 13,
                            color: AppColors.success,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ],
                  ),
                )
              else
                for (final st in settlements) ...[
                  Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: SettlementCard(transaction: st),
                  ),
                ],
              const SizedBox(height: 16),

              // 4. Section: Member Breakdown
              Row(
                children: [
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: AppColors.surfaceSubtle,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(
                      Icons.bar_chart_rounded,
                      color: AppColors.textPrimary,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    'Member Breakdown',
                    style: GoogleFonts.manrope(
                      fontSize: 17,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                      letterSpacing: -0.3,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),

              // Breakdown Table
              MemberBreakdownTable(
                members: members,
                memberExpenses: memberExpenses,
                sharePerPerson: sharePerPerson,
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),

      // 5. Fixed Bottom Button: "Save & Track Settlement"
      bottomNavigationBar: Container(
        color: isIOS ? AppColors.iosBackground : AppColors.background,
        padding: const EdgeInsets.fromLTRB(20, 10, 20, 24),
        child: SafeArea(
          top: false,
          child: SizedBox(
            width: double.infinity,
            height: 56,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppRadius.button),
                ),
              ),
              onPressed: () {
                HapticFeedback.mediumImpact();
                final activity = SplitActivity(
                  id: DateTime.now().millisecondsSinceEpoch.toString(),
                  groupName: title,
                  totalAmount: totalExpense,
                  sharePerPerson: sharePerPerson,
                  members: List.unmodifiable(members),
                  memberExpenses: Map.unmodifiable(memberExpenses),
                  settlements: settlements,
                  timestamp: DateTime.now(),
                );
                ActivityRepository.instance.recordActivity(activity);

                // Build and persist Story adhering to standard Story JSON schema
                final storyMembers = members.map((m) {
                  final safeId = 'user_${m.name.toLowerCase().replaceAll(RegExp(r'\s+'), '_')}';
                  return StoryMember(
                    userId: safeId,
                    name: m.name,
                    role: m == members.first ? 'admin' : 'member',
                    joinedAt: DateTime.now().toIso8601String(),
                  );
                }).toList();

                final memberIdByName = {
                  for (var sm in storyMembers) sm.name: sm.userId,
                };

                final storyShares = members.map((m) {
                  return ExpenseShare(
                    userId: memberIdByName[m.name] ?? 'user_${m.name}',
                    amount: sharePerPerson,
                  );
                }).toList();

                final List<StoryExpense> storyExpenses = [];
                int expCount = 1;
                memberExpenses.forEach((payerName, paidAmount) {
                  if (paidAmount > 0) {
                    storyExpenses.add(
                      StoryExpense(
                        expenseId: 'exp_${expCount.toString().padLeft(3, '0')}',
                        title: title,
                        category: 'general',
                        amount: paidAmount,
                        paidBy: memberIdByName[payerName] ?? 'user_$payerName',
                        splitType: 'equal',
                        participants: storyMembers.map((m) => m.userId).toList(),
                        shares: storyShares,
                        date: DateTime.now().toIso8601String(),
                      ),
                    );
                    expCount++;
                  }
                });

                final story = Story.create(
                  storyId: 'story_${DateTime.now().millisecondsSinceEpoch}',
                  title: title,
                  description: 'Shared expense story for $title',
                  coverEmoji: '🌴',
                  currency: 'INR',
                  status: 'active',
                  createdBy: storyMembers.isNotEmpty ? storyMembers.first.userId : 'user_001',
                  createdAt: DateTime.now().toIso8601String(),
                  members: storyMembers,
                  expenses: storyExpenses,
                );
                StoryRepository.instance.addStory(story);

                Navigator.of(context).popUntil((route) => route.isFirst);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      'Split settled successfully for "$title"!',
                      style: GoogleFonts.manrope(fontWeight: FontWeight.w600),
                    ),
                    backgroundColor: AppColors.primary,
                    behavior: SnackBarBehavior.floating,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppRadius.buttonSecondary),
                    ),
                  ),
                );
              },
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.check_circle_outline_rounded,
                    color: Colors.white,
                    size: 22,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Save & Track Settlement',
                    style: GoogleFonts.manrope(
                      fontWeight: FontWeight.w700,
                      fontSize: 16.5,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
