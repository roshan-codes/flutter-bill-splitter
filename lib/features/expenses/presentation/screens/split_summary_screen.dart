import 'package:flutter/material.dart';
import 'package:flutter_neumorphism_ui/flutter_neumorphism_ui.dart';
import 'package:flutter_bill_splitter/core/theme/app_colors.dart';
import 'package:flutter_bill_splitter/core/theme/neumorphic_styles.dart';
import 'package:flutter_bill_splitter/core/utils/string_utils.dart';
import 'package:flutter_bill_splitter/features/expenses/domain/models/settlement_transaction.dart';
import 'package:flutter_bill_splitter/features/expenses/domain/services/expense_calculator.dart';
import 'package:flutter_bill_splitter/features/expenses/presentation/widgets/settlement_card.dart';
import 'package:flutter_bill_splitter/features/friends/domain/models/friend.dart';

/// Screen displayed after confirming split.
/// Clearly shows total split details, individual balances, and who pays whom with Neumorphic UI styling.
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
      return '₹${amount.toInt()}';
    }
    return '₹${amount.toStringAsFixed(2)}';
  }

  @override
  Widget build(BuildContext context) {
    final totalExpense = ExpenseCalculator.calculateTotal(memberExpenses);
    final sharePerPerson = ExpenseCalculator.calculateSharePerPerson(totalExpense, members.length);
    final List<SettlementTransaction> settlements = ExpenseCalculator.calculateSettlements(
      members: members,
      paidAmounts: memberExpenses,
    );

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        leading: Padding(
          padding: const EdgeInsets.only(left: 12),
          child: Center(
            child: InkWell(
              onTap: () => Navigator.pop(context),
              borderRadius: BorderRadius.circular(20),
              child: FlutterNeumorphism(
                style: NeumorphicStyles.circle(depth: 4),
                width: 38,
                height: 38,
                padding: EdgeInsets.zero,
                child: const Icon(
                  Icons.arrow_back_ios_new_rounded,
                  color: AppColors.textPrimary,
                  size: 16,
                ),
              ),
            ),
          ),
        ),
        title: const Text(
          'Split Summary',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w800,
            color: AppColors.textPrimary,
            letterSpacing: -0.3,
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Top Overview Banner
              _buildOverviewCard(totalExpense, sharePerPerson),
              const SizedBox(height: 24),

              // Who Pays Whom Section
              _buildWhoPaysWhomSection(settlements, totalExpense, sharePerPerson),
              const SizedBox(height: 24),

              // Member Balances Section
              _buildMemberBalancesSection(sharePerPerson),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
      bottomNavigationBar: Container(
        color: AppColors.background,
        padding: const EdgeInsets.fromLTRB(20, 10, 20, 24),
        child: SafeArea(
          top: false,
          child: SizedBox(
            width: double.infinity,
            child: FlutterNeumorphism(
              style: NeumorphicStyles.primaryButton(borderRadius: 18, depth: 6),
              padding: EdgeInsets.zero,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.transparent,
                  foregroundColor: AppColors.primaryDark,
                  shadowColor: Colors.transparent,
                  padding: const EdgeInsets.symmetric(vertical: 18),
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(18),
                  ),
                ),
                onPressed: () {
                  Navigator.of(context).popUntil((route) => route.isFirst);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        'Split settled successfully for "$groupName"!',
                      ),
                      backgroundColor: const Color(0xFF111713),
                      behavior: SnackBarBehavior.floating,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  );
                },
                child: const Text(
                  'Done',
                  style: TextStyle(
                    fontWeight: FontWeight.w800,
                    fontSize: 17,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildOverviewCard(double totalExpense, double sharePerPerson) {
    return FlutterNeumorphism(
      style: NeumorphicStyles.card(borderRadius: 26, depth: 6),
      width: double.infinity,
      padding: const EdgeInsets.all(22),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              FlutterNeumorphism(
                style: NeumorphicStyles.card(borderRadius: 10, depth: 3, color: AppColors.primaryLight),
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                child: Text(
                  groupName,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                    color: AppColors.primaryDeep,
                  ),
                ),
              ),
              const Spacer(),
              Text(
                '${members.length} members',
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Total Expense',
                    style: TextStyle(
                      fontSize: 13,
                      color: AppColors.textSecondary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _formatAmount(totalExpense),
                    style: const TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.w900,
                      color: AppColors.textPrimary,
                      letterSpacing: -0.5,
                    ),
                  ),
                ],
              ),
              Container(
                height: 44,
                width: 1,
                color: AppColors.border,
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  const Text(
                    'Each Person Pays',
                    style: TextStyle(
                      fontSize: 13,
                      color: AppColors.textSecondary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _formatAmount(sharePerPerson),
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w900,
                      color: AppColors.primaryDeep,
                      letterSpacing: -0.5,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildWhoPaysWhomSection(
    List<SettlementTransaction> settlements,
    double totalExpense,
    double sharePerPerson,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            FlutterNeumorphism(
              style: NeumorphicStyles.circle(depth: 3, color: AppColors.primaryLight),
              width: 32,
              height: 32,
              padding: EdgeInsets.zero,
              child: const Icon(
                Icons.swap_horiz_rounded,
                size: 18,
                color: AppColors.primaryDeep,
              ),
            ),
            const SizedBox(width: 10),
            const Text(
              'Who Pays Whom',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: AppColors.textPrimary,
                letterSpacing: -0.3,
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        const Text(
          'Exact transactions to settle all debts in minimum steps',
          style: TextStyle(
            fontSize: 12,
            color: AppColors.textSecondary,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 14),

        if (settlements.isEmpty)
          FlutterNeumorphism(
            style: NeumorphicStyles.card(
              borderRadius: 20,
              depth: 4,
              color: const Color(0xFFF0FDF4),
            ),
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                const Icon(
                  Icons.check_circle_rounded,
                  color: Color(0xFF16A34A),
                  size: 28,
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'All settled up!',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w800,
                          color: Color(0xFF166534),
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        totalExpense == 0
                            ? 'No expenses were added for any member.'
                            : 'Everyone paid their exact equal share (${_formatAmount(sharePerPerson)}). No payments needed!',
                        style: const TextStyle(
                          fontSize: 12,
                          color: Color(0xFF15803D),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          )
        else
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: settlements.length,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              return SettlementCard(transaction: settlements[index]);
            },
          ),
      ],
    );
  }

  Widget _buildMemberBalancesSection(double sharePerPerson) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Member Breakdown',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w800,
            color: AppColors.textPrimary,
            letterSpacing: -0.3,
          ),
        ),
        const SizedBox(height: 4),
        const Text(
          'Amount paid and net balance for each person',
          style: TextStyle(
            fontSize: 12,
            color: AppColors.textSecondary,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 14),
        FlutterNeumorphism(
          style: NeumorphicStyles.card(borderRadius: 22, depth: 5),
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: members.length,
            separatorBuilder: (_, __) => const Divider(height: 1, color: AppColors.border),
            itemBuilder: (context, index) {
              final member = members[index];
              final paid = memberExpenses[member.name] ?? 0.0;
              final net = paid - sharePerPerson;
              final isPositive = net > 0.01;
              final isNegative = net < -0.01;
              final initial = StringUtils.getSingleInitial(member.name);

              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                child: Row(
                  children: [
                    FlutterNeumorphism(
                      style: NeumorphicStyles.card(
                        borderRadius: 14,
                        depth: 3,
                        color: AppColors.primaryLight,
                      ),
                      width: 40,
                      height: 40,
                      padding: EdgeInsets.zero,
                      child: Text(
                        initial,
                        style: const TextStyle(
                          color: Color(0xFF284821),
                          fontWeight: FontWeight.w900,
                          fontSize: 16,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            member.name,
                            style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w800,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'Paid ${_formatAmount(paid)}',
                            style: const TextStyle(
                              fontSize: 12,
                              color: AppColors.textSecondary,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                    FlutterNeumorphism(
                      style: NeumorphicStyles.inset(
                        borderRadius: 10,
                        depth: 2,
                        color: isPositive
                            ? const Color(0xFFE8F8D8)
                            : isNegative
                                ? const Color(0xFFFFEAEA)
                                : Colors.grey.shade100,
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                      child: Text(
                        isPositive
                            ? 'Gets ${_formatAmount(net)}'
                            : isNegative
                                ? 'Owes ${_formatAmount(-net)}'
                                : 'Settled',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w800,
                          color: isPositive
                              ? const Color(0xFF284821)
                              : isNegative
                                  ? const Color(0xFFC92A2A)
                                  : Colors.grey.shade700,
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
