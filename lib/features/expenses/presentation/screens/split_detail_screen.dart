import 'package:flutter/material.dart';
import 'package:flutter_neumorphism_ui/flutter_neumorphism_ui.dart';
import 'package:flutter_bill_splitter/core/theme/app_colors.dart';
import 'package:flutter_bill_splitter/core/theme/neumorphic_styles.dart';
import 'package:flutter_bill_splitter/core/utils/string_utils.dart';
import 'package:flutter_bill_splitter/features/activity/data/repositories/activity_repository.dart';
import 'package:flutter_bill_splitter/features/activity/domain/models/split_activity.dart';
import 'package:flutter_bill_splitter/features/expenses/domain/services/expense_calculator.dart';
import 'package:flutter_bill_splitter/features/expenses/presentation/screens/split_summary_screen.dart';
import 'package:flutter_bill_splitter/features/expenses/presentation/widgets/split_member_card.dart';
import 'package:flutter_bill_splitter/features/friends/domain/models/friend.dart';

/// Screen displaying the list of selected friends / members with options to add person expenses.
class SplitDetailScreen extends StatefulWidget {
  final String groupName;
  final List<Friend> members;

  const SplitDetailScreen({
    super.key,
    required this.groupName,
    required this.members,
  });

  @override
  State<SplitDetailScreen> createState() => _SplitDetailScreenState();
}

class _SplitDetailScreenState extends State<SplitDetailScreen> {
  final Map<String, double> _memberExpenses = {};

  double get _totalExpense =>
      _memberExpenses.values.fold(0.0, (sum, val) => sum + val);

  void _showAddExpenseDialog(Friend friend) {
    final currentAmount = _memberExpenses[friend.name];
    final controller = TextEditingController(
      text: currentAmount != null ? currentAmount.toStringAsFixed(0) : '',
    );
    final formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.background,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(26),
        ),
        title: Row(
          children: [
            FlutterNeumorphism(
              style: NeumorphicStyles.circle(depth: 3, color: AppColors.primaryLight),
              width: 38,
              height: 38,
              padding: EdgeInsets.zero,
              child: Text(
                StringUtils.getSingleInitial(friend.name),
                style: const TextStyle(
                  color: Color(0xFF284821),
                  fontWeight: FontWeight.w900,
                  fontSize: 16,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                'Expense for ${friend.name}',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: AppColors.textPrimary,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
        content: Form(
          key: formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              FlutterNeumorphism(
                style: NeumorphicStyles.inset(borderRadius: 16, depth: 4),
                padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                child: TextFormField(
                  controller: controller,
                  autofocus: true,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  decoration: const InputDecoration(
                    labelText: 'Amount (₹)',
                    hintText: 'Enter amount e.g. 250',
                    prefixIcon: Icon(Icons.currency_rupee_rounded, color: AppColors.primaryDeep),
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  ),
                  validator: (val) {
                    if (val == null || val.trim().isEmpty) {
                      return 'Please enter an amount';
                    }
                    final parsed = double.tryParse(val.trim());
                    if (parsed == null || parsed <= 0) {
                      return 'Please enter a valid amount';
                    }
                    return null;
                  },
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Cancel',
              style: TextStyle(color: Colors.grey.shade600, fontWeight: FontWeight.w700),
            ),
          ),
          FlutterNeumorphism(
            style: NeumorphicStyles.primaryButton(borderRadius: 14, depth: 5),
            padding: EdgeInsets.zero,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.transparent,
                foregroundColor: AppColors.primaryDark,
                shadowColor: Colors.transparent,
                elevation: 0,
                padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              onPressed: () {
                if (formKey.currentState?.validate() ?? false) {
                  final amount = double.parse(controller.text.trim());
                  setState(() {
                    _memberExpenses[friend.name] = amount;
                  });
                  Navigator.pop(context);
                }
              },
              child: const Text('Save Expense', style: TextStyle(fontWeight: FontWeight.w800)),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        leading: Padding(
          padding: const EdgeInsets.only(left: 12),
          child: Center(
            child: InkWell(
              onTap: () => Navigator.of(context).pop(),
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
          'Split with Members',
          style: TextStyle(
            color: AppColors.textPrimary,
            fontSize: 20,
            fontWeight: FontWeight.w800,
            letterSpacing: -0.3,
          ),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Group Summary Header Card
              FlutterNeumorphism(
                style: NeumorphicStyles.card(borderRadius: 24, depth: 6),
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        FlutterNeumorphism(
                          style: NeumorphicStyles.card(
                            borderRadius: 14,
                            depth: 4,
                            color: AppColors.primaryLight,
                          ),
                          width: 46,
                          height: 46,
                          padding: EdgeInsets.zero,
                          child: const Icon(
                            Icons.groups_rounded,
                            color: AppColors.primaryDeep,
                            size: 24,
                          ),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                widget.groupName,
                                style: const TextStyle(
                                  fontSize: 19,
                                  fontWeight: FontWeight.w800,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                _totalExpense > 0
                                    ? 'Total expense: ₹${_totalExpense.toStringAsFixed(_totalExpense.truncateToDouble() == _totalExpense ? 0 : 2)}'
                                    : '${widget.members.length} members included in split',
                                style: TextStyle(
                                  fontSize: 13,
                                  color: _totalExpense > 0 ? AppColors.primaryDeep : AppColors.textSecondary,
                                  fontWeight: _totalExpense > 0 ? FontWeight.w700 : FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    const Divider(height: 1, color: AppColors.border),
                    const SizedBox(height: 14),

                    // Avatars preview row with neumorphic squircle avatars
                    SizedBox(
                      height: 42,
                      child: ListView.separated(
                        scrollDirection: Axis.horizontal,
                        itemCount: widget.members.length,
                        separatorBuilder: (_, __) => const SizedBox(width: 10),
                        itemBuilder: (context, idx) {
                          final m = widget.members[idx];
                          final initial = StringUtils.getSingleInitial(m.name);
                          return FlutterNeumorphism(
                            style: NeumorphicStyles.card(
                              borderRadius: 14,
                              depth: 3,
                              color: AppColors.primaryLight,
                            ),
                            width: 42,
                            height: 42,
                            padding: EdgeInsets.zero,
                            child: Text(
                              initial,
                              style: const TextStyle(
                                color: Color(0xFF284821),
                                fontWeight: FontWeight.w900,
                                fontSize: 17,
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Section Title
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Selected Members',
                    style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w800,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  Text(
                    '${widget.members.length} total',
                    style: const TextStyle(
                      fontSize: 13,
                      color: AppColors.textSecondary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),

              // List of Selected Members with Add Expense Option
              ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: widget.members.length,
                separatorBuilder: (_, __) => const SizedBox(height: 12),
                itemBuilder: (context, index) {
                  final member = widget.members[index];
                  return SplitMemberCard(
                    friend: member,
                    index: index,
                    expenseAmount: _memberExpenses[member.name],
                    onAddExpense: () => _showAddExpenseDialog(member),
                  );
                },
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
      // Fixed bottom button
      bottomNavigationBar: Container(
        color: AppColors.background,
        padding: const EdgeInsets.fromLTRB(24, 10, 24, 20),
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
                  final total = ExpenseCalculator.calculateTotal(_memberExpenses);
                  final share = ExpenseCalculator.calculateSharePerPerson(total, widget.members.length);
                  final settlements = ExpenseCalculator.calculateSettlements(
                    members: widget.members,
                    paidAmounts: _memberExpenses,
                  );

                  final activity = SplitActivity(
                    id: DateTime.now().millisecondsSinceEpoch.toString(),
                    groupName: widget.groupName,
                    totalAmount: total,
                    sharePerPerson: share,
                    members: List.unmodifiable(widget.members),
                    memberExpenses: Map.unmodifiable(_memberExpenses),
                    settlements: settlements,
                    timestamp: DateTime.now(),
                  );
                  ActivityRepository.instance.recordActivity(activity);

                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => SplitSummaryScreen(
                        groupName: widget.groupName,
                        members: widget.members,
                        memberExpenses: _memberExpenses,
                      ),
                    ),
                  );
                },
                child: const Text(
                  'Confirm Split',
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
}
