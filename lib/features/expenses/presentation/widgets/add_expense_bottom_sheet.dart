import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_bill_splitter/core/constants/expense_categories.dart';
import 'package:flutter_bill_splitter/core/services/storage_service.dart';
import 'package:flutter_bill_splitter/core/theme/app_colors.dart';
import 'package:flutter_bill_splitter/core/theme/app_radius.dart';
import 'package:flutter_bill_splitter/core/utils/currency_formatter.dart';
import 'package:flutter_bill_splitter/core/utils/user_identity_resolver.dart';
import 'package:flutter_bill_splitter/features/stories/data/repositories/story_repository.dart';
import 'package:flutter_bill_splitter/features/stories/domain/models/story.dart';

class ExpenseQuickTag {
  final String label;
  final IconData icon;
  final String category;
  final bool isFrequent;

  const ExpenseQuickTag({
    required this.label,
    required this.icon,
    required this.category,
    this.isFrequent = false,
  });
}

/// Bottom sheet widget allowing users to add an expense or record an advance payment.
class AddExpenseBottomSheet extends StatefulWidget {
  final Story story;
  final String splitMethod;
  final String? resolvedCurrentMemberId;
  final Future<void> Function(
    StoryExpense expense,
    String payerName,
    Story updatedStory,
  ) onExpenseSaved;
  final Future<void> Function(
    StoryExpense advanceExpense,
    Story updatedStory,
  ) onAdvancePaymentRecorded;

  const AddExpenseBottomSheet({
    super.key,
    required this.story,
    required this.splitMethod,
    this.resolvedCurrentMemberId,
    required this.onExpenseSaved,
    required this.onAdvancePaymentRecorded,
  });

  static Future<void> show(
    BuildContext context, {
    required Story story,
    required String splitMethod,
    String? resolvedCurrentMemberId,
    required Future<void> Function(
      StoryExpense expense,
      String payerName,
      Story updatedStory,
    ) onExpenseSaved,
    required Future<void> Function(
      StoryExpense advanceExpense,
      Story updatedStory,
    ) onAdvancePaymentRecorded,
  }) {
    HapticFeedback.lightImpact();
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => AddExpenseBottomSheet(
        story: story,
        splitMethod: splitMethod,
        resolvedCurrentMemberId: resolvedCurrentMemberId,
        onExpenseSaved: onExpenseSaved,
        onAdvancePaymentRecorded: onAdvancePaymentRecorded,
      ),
    );
  }

  @override
  State<AddExpenseBottomSheet> createState() => _AddExpenseBottomSheetState();
}

class _AddExpenseBottomSheetState extends State<AddExpenseBottomSheet> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _titleController;
  late final TextEditingController _amountController;

  late String _selectedPayerId;
  String? _selectedRecipientId;
  bool _isAdvanceMode = false;
  bool _isSubmitting = false;
  String? _selectedTagLabel;
  String? _selectedCategory;
  late List<ExpenseQuickTag> _quickTags;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController();
    _amountController = TextEditingController();

    final myMember = widget.story.members
        .where((m) => _isCurrentUser(m.name, m.userId))
        .firstOrNull;
    _selectedPayerId = myMember?.userId ??
        (widget.story.members.isNotEmpty
            ? widget.story.members.first.userId
            : 'user_001');

    _selectedRecipientId = widget.story.members
        .where((m) => m.userId != _selectedPayerId)
        .map((m) => m.userId)
        .firstOrNull;

    _quickTags = _getFrequentAndQuickTags();
  }

  @override
  void dispose() {
    _titleController.dispose();
    _amountController.dispose();
    super.dispose();
  }

  bool _isCurrentUser(String name, [String? userId]) {
    return UserIdentityResolver.isCurrentUser(
      name: name,
      userId: userId,
      story: widget.story,
      resolvedCurrentMemberId: widget.resolvedCurrentMemberId,
    );
  }

  String _formatMemberDisplayName(String name, bool isMe) {
    return UserIdentityResolver.formatMemberDisplayName(name, isMe);
  }

  List<ExpenseQuickTag> _getFrequentAndQuickTags() {
    const baseTags = <ExpenseQuickTag>[
      ExpenseQuickTag(
          label: 'Food', icon: Icons.restaurant_rounded, category: 'food'),
      ExpenseQuickTag(
          label: 'Travel',
          icon: Icons.directions_car_rounded,
          category: 'transport'),
      ExpenseQuickTag(
          label: 'Stay', icon: Icons.hotel_rounded, category: 'stay'),
      ExpenseQuickTag(
          label: 'Fuel',
          icon: Icons.local_gas_station_rounded,
          category: 'transport'),
      ExpenseQuickTag(
          label: 'Drinks', icon: Icons.local_bar_rounded, category: 'food'),
      ExpenseQuickTag(
          label: 'Activities',
          icon: Icons.confirmation_number_rounded,
          category: 'activities'),
      ExpenseQuickTag(
          label: 'Groceries',
          icon: Icons.shopping_cart_rounded,
          category: 'food'),
      ExpenseQuickTag(
          label: 'Shopping',
          icon: Icons.shopping_bag_rounded,
          category: 'shopping'),
      ExpenseQuickTag(
          label: 'Flight',
          icon: Icons.flight_takeoff_rounded,
          category: 'transport'),
      ExpenseQuickTag(
          label: 'Cafe', icon: Icons.local_cafe_rounded, category: 'food'),
    ];

    final frequencyMap = <String, int>{};

    try {
      final raw =
          StorageService.instance.getStringSync('frequent_expense_tags');
      if (raw != null && raw.isNotEmpty) {
        final decoded = jsonDecode(raw) as Map<String, dynamic>;
        decoded.forEach((k, v) {
          if (v is num) frequencyMap[k.toLowerCase().trim()] = v.toInt();
        });
      }
    } catch (_) {}

    for (final s in StoryRepository.instance.stories) {
      for (final exp in s.expenses) {
        if (exp.category == 'reimbursement' ||
            exp.category == 'settlement' ||
            exp.category == 'advance') continue;
        final key = exp.title.trim().toLowerCase();
        if (key.isNotEmpty) {
          frequencyMap[key] = (frequencyMap[key] ?? 0) + 1;
        }
      }
    }

    final frequentCustomTags = <ExpenseQuickTag>[];
    final baseLabelsLower = baseTags.map((t) => t.label.toLowerCase()).toSet();

    final sortedKeys = frequencyMap.keys.toList()
      ..sort((a, b) => (frequencyMap[b] ?? 0).compareTo(frequencyMap[a] ?? 0));

    for (final key in sortedKeys) {
      if ((frequencyMap[key] ?? 0) >= 1 && !baseLabelsLower.contains(key)) {
        final displayLabel = key.split(' ').map((word) {
          if (word.isEmpty) return word;
          return word[0].toUpperCase() + word.substring(1);
        }).join(' ');

        final inferredCat = ExpenseCategories.inferCategoryFromTitle(displayLabel);
        final icon = ExpenseCategories.getCategoryIcon(inferredCat);
        frequentCustomTags.add(
          ExpenseQuickTag(
            label: displayLabel,
            icon: icon,
            category: inferredCat,
            isFrequent: true,
          ),
        );
        if (frequentCustomTags.length >= 4) break;
      }
    }

    final enrichedBaseTags = baseTags.map((t) {
      final count = frequencyMap[t.label.toLowerCase()] ?? 0;
      return ExpenseQuickTag(
        label: t.label,
        icon: t.icon,
        category: t.category,
        isFrequent: count > 0,
      );
    }).toList();

    final result = <ExpenseQuickTag>[...frequentCustomTags];
    for (final t in enrichedBaseTags) {
      if (t.isFrequent) result.add(t);
    }
    for (final t in enrichedBaseTags) {
      if (!t.isFrequent) result.add(t);
    }
    return result;
  }

  Future<void> _recordTagUsage(String title) async {
    try {
      final key = title.trim().toLowerCase();
      if (key.isEmpty) return;
      final raw =
          StorageService.instance.getStringSync('frequent_expense_tags');
      final map = <String, int>{};
      if (raw != null && raw.isNotEmpty) {
        final decoded = jsonDecode(raw) as Map<String, dynamic>;
        decoded.forEach((k, v) {
          if (v is num) map[k] = v.toInt();
        });
      }
      map[key] = (map[key] ?? 0) + 1;
      await StorageService.instance
          .setString('frequent_expense_tags', jsonEncode(map));
    } catch (_) {}
  }

  Future<void> _handleSubmit() async {
    if (_isSubmitting) return;
    setState(() => _isSubmitting = true);

    if (!(_formKey.currentState?.validate() ?? false)) {
      setState(() => _isSubmitting = false);
      return;
    }

    final amt = double.parse(_amountController.text.trim());

    if (_isAdvanceMode) {
      final sender = widget.story.members.firstWhere(
        (m) => m.userId == _selectedPayerId,
        orElse: () => widget.story.members.first,
      );
      final recipient = widget.story.members.firstWhere(
        (m) =>
            m.userId ==
            (_selectedRecipientId ??
                widget.story.members
                    .where((m) => m.userId != _selectedPayerId)
                    .map((m) => m.userId)
                    .firstOrNull ??
                ''),
        orElse: () => widget.story.members.last,
      );

      if (sender.userId == recipient.userId) {
        setState(() => _isSubmitting = false);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Sender and recipient cannot be the same member'),
            behavior: SnackBarBehavior.floating,
          ),
        );
        return;
      }

      final rawTitle = _titleController.text.trim();
      final note = rawTitle.isNotEmpty ? ' ($rawTitle)' : '';
      final advanceTitle =
          'Advance to ${recipient.name} by ${sender.name}$note';

      final newExpense = StoryExpense(
        expenseId: 'exp_adv_${DateTime.now().millisecondsSinceEpoch}',
        title: advanceTitle,
        category: 'advance',
        amount: amt,
        paidBy: sender.userId,
        splitType: 'exact',
        participants: [recipient.userId],
        shares: [
          ExpenseShare(
            userId: recipient.userId,
            amount: amt,
          ),
        ],
        date: DateTime.now().toIso8601String(),
        note: rawTitle.isNotEmpty ? rawTitle : null,
      );

      final updatedStory = widget.story.addExpense(newExpense);

      if (mounted) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
                'Advance payment of ₹${CurrencyFormatter.format(amt)} recorded'),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }

      await widget.onAdvancePaymentRecorded(newExpense, updatedStory);
      return;
    }

    // Normal Expense mode
    final payer = widget.story.members.firstWhere(
      (m) => m.userId == _selectedPayerId,
      orElse: () => widget.story.members.first,
    );

    final expenseTitle = _titleController.text.trim();
    final finalCategory = _selectedCategory ??
        ExpenseCategories.inferCategoryFromTitle(expenseTitle);

    final newExpense = StoryExpense(
      expenseId: 'exp_${DateTime.now().millisecondsSinceEpoch}',
      title: expenseTitle,
      category: finalCategory,
      amount: amt,
      paidBy: payer.userId,
      splitType: 'equal',
      participants: widget.story.members.map((m) => m.userId).toList(),
      shares: widget.story.members
          .map((m) => ExpenseShare(
                userId: m.userId,
                amount: amt /
                    (widget.story.members.isNotEmpty
                        ? widget.story.members.length
                        : 1),
              ))
          .toList(),
      date: DateTime.now().toIso8601String(),
    );

    final recalculatedStory = Story.create(
      storyId: widget.story.storyId,
      title: widget.story.title,
      description: widget.story.description,
      coverEmoji: widget.story.coverEmoji,
      currency: widget.story.currency,
      status: widget.story.status,
      splitMethod: widget.splitMethod,
      createdBy: widget.story.createdBy,
      createdAt: widget.story.createdAt,
      startDate: widget.story.startDate,
      endDate: widget.story.endDate,
      members: widget.story.members,
      expenses: [...widget.story.expenses, newExpense],
      existingSettlements: widget.story.settlements
          .where((s) => s.status == 'completed')
          .toList(),
    );

    if (mounted) {
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Expense "$expenseTitle" added'),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }

    unawaited(_recordTagUsage(expenseTitle));
    await widget.onExpenseSaved(newExpense, payer.name, recalculatedStory);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.88,
      ),
      padding: EdgeInsets.fromLTRB(
          20, 20, 20, MediaQuery.of(context).viewInsets.bottom + 24),
      decoration: const BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppColors.border,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                _isAdvanceMode
                    ? 'Record Advance Payment'
                    : 'Add New Expense',
                style: GoogleFonts.manrope(
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 14),

              // Segmented Mode Switcher: Expense vs Advance / Transfer
              Container(
                height: 42,
                decoration: BoxDecoration(
                  color: const Color(0xFFF3F4F6),
                  borderRadius: BorderRadius.circular(12),
                ),
                padding: const EdgeInsets.all(3),
                child: Row(
                  children: [
                    Expanded(
                      child: GestureDetector(
                        key: const ValueKey('expense_mode_tab'),
                        onTap: () {
                          HapticFeedback.selectionClick();
                          setState(() => _isAdvanceMode = false);
                        },
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 150),
                          decoration: BoxDecoration(
                            color: !_isAdvanceMode
                                ? Colors.white
                                : Colors.transparent,
                            borderRadius: BorderRadius.circular(9),
                            boxShadow: !_isAdvanceMode
                                ? [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.06),
                                      blurRadius: 4,
                                      offset: const Offset(0, 1),
                                    ),
                                  ]
                                : null,
                          ),
                          child: Center(
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.receipt_long_rounded,
                                  size: 15,
                                  color: !_isAdvanceMode
                                      ? AppColors.textPrimary
                                      : AppColors.textSecondary,
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  'Expense',
                                  style: GoogleFonts.manrope(
                                    fontSize: 13,
                                    fontWeight: !_isAdvanceMode
                                        ? FontWeight.w700
                                        : FontWeight.w600,
                                    color: !_isAdvanceMode
                                        ? AppColors.textPrimary
                                        : AppColors.textSecondary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                    Expanded(
                      child: GestureDetector(
                        key: const ValueKey('advance_mode_tab'),
                        onTap: () {
                          HapticFeedback.selectionClick();
                          setState(() {
                            _isAdvanceMode = true;
                            if (_selectedRecipientId == null ||
                                _selectedRecipientId == _selectedPayerId) {
                              _selectedRecipientId = widget.story.members
                                  .where((m) => m.userId != _selectedPayerId)
                                  .map((m) => m.userId)
                                  .firstOrNull;
                            }
                          });
                        },
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 150),
                          decoration: BoxDecoration(
                            color: _isAdvanceMode
                                ? Colors.white
                                : Colors.transparent,
                            borderRadius: BorderRadius.circular(9),
                            boxShadow: _isAdvanceMode
                                ? [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.06),
                                      blurRadius: 4,
                                      offset: const Offset(0, 1),
                                    ),
                                  ]
                                : null,
                          ),
                          child: Center(
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.currency_exchange_rounded,
                                  size: 15,
                                  color: _isAdvanceMode
                                      ? AppColors.textPrimary
                                      : AppColors.textSecondary,
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  'Advance / Transfer',
                                  style: GoogleFonts.manrope(
                                    fontSize: 13,
                                    fontWeight: _isAdvanceMode
                                        ? FontWeight.w700
                                        : FontWeight.w600,
                                    color: _isAdvanceMode
                                        ? AppColors.textPrimary
                                        : AppColors.textSecondary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              Text(
                _isAdvanceMode
                    ? 'Note / Purpose (Optional)'
                    : 'Expense Title',
                style: GoogleFonts.manrope(
                  fontSize: 14.5,
                  fontWeight: FontWeight.w800,
                  color: const Color(0xFF111111),
                ),
              ),
              const SizedBox(height: 8),
              Container(
                height: 56,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(
                      color: const Color(0xFFEAEAEF), width: 1.2),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.025),
                      blurRadius: 10,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Center(
                  child: TextFormField(
                    controller: _titleController,
                    style: GoogleFonts.manrope(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF111111),
                    ),
                    decoration: InputDecoration(
                      isDense: true,
                      border: InputBorder.none,
                      enabledBorder: InputBorder.none,
                      focusedBorder: InputBorder.none,
                      errorBorder: InputBorder.none,
                      disabledBorder: InputBorder.none,
                      filled: false,
                      contentPadding:
                          const EdgeInsets.symmetric(vertical: 16),
                      hintText: _isAdvanceMode
                          ? 'Note / Purpose (Optional)'
                          : 'Expense Title',
                      hintStyle: GoogleFonts.manrope(
                        fontSize: 15,
                        fontWeight: FontWeight.w500,
                        color: const Color(0xFF9CA3AF),
                      ),
                    ),
                    validator: _isAdvanceMode
                        ? null
                        : (v) => (v == null || v.trim().isEmpty)
                            ? 'Enter a title'
                            : null,
                  ),
                ),
              ),
              if (!_isAdvanceMode) ...[
                const SizedBox(height: 10),
                // Quick Tags horizontal list with travel and frequently used tags
                SizedBox(
                  height: 38,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    physics: const BouncingScrollPhysics(),
                    itemCount: _quickTags.length,
                    separatorBuilder: (_, __) => const SizedBox(width: 8),
                    itemBuilder: (context, index) {
                      final tag = _quickTags[index];
                      final isSelected = _selectedTagLabel == tag.label;
                      return Material(
                        color: Colors.transparent,
                        child: InkWell(
                          onTap: () {
                            HapticFeedback.selectionClick();
                            setState(() {
                              if (isSelected) {
                                _selectedTagLabel = null;
                                _selectedCategory = null;
                              } else {
                                _selectedTagLabel = tag.label;
                                _selectedCategory = tag.category;
                                final currentTitle =
                                    _titleController.text.trim();
                                if (currentTitle.isEmpty ||
                                    _quickTags.any((t) =>
                                        t.label.toLowerCase() ==
                                        currentTitle.toLowerCase())) {
                                  _titleController.text = tag.label;
                                  _titleController.selection =
                                      TextSelection.fromPosition(
                                    TextPosition(offset: tag.label.length),
                                  );
                                }
                              }
                            });
                          },
                          borderRadius: BorderRadius.circular(20),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 150),
                            padding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 8),
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? AppColors.primary
                                  : (tag.isFrequent
                                      ? const Color(0xFFF3F4F6)
                                      : AppColors.surfaceSubtle),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: isSelected
                                    ? AppColors.primary
                                    : (tag.isFrequent
                                        ? const Color(0xFFD1D5DB)
                                        : AppColors.border),
                                width: 1.0,
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                if (tag.isFrequent && !isSelected) ...[
                                  const Icon(
                                    Icons.auto_awesome_rounded,
                                    size: 13,
                                    color: Color(0xFFEAB308),
                                  ),
                                  const SizedBox(width: 4),
                                ],
                                Icon(
                                  tag.icon,
                                  size: 14,
                                  color: isSelected
                                      ? Colors.white
                                      : AppColors.textPrimary,
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  tag.label,
                                  style: GoogleFonts.manrope(
                                    fontSize: 12,
                                    fontWeight: isSelected
                                        ? FontWeight.w700
                                        : FontWeight.w600,
                                    color: isSelected
                                        ? Colors.white
                                        : AppColors.textPrimary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
              const SizedBox(height: 16),
              Text(
                'Amount (₹)',
                style: GoogleFonts.manrope(
                  fontSize: 14.5,
                  fontWeight: FontWeight.w800,
                  color: const Color(0xFF111111),
                ),
              ),
              const SizedBox(height: 8),
              Container(
                height: 56,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(
                      color: const Color(0xFFEAEAEF), width: 1.2),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.025),
                      blurRadius: 10,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Center(
                  child: TextFormField(
                    controller: _amountController,
                    keyboardType: const TextInputType.numberWithOptions(
                        decimal: true),
                    style: GoogleFonts.manrope(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF111111),
                    ),
                    decoration: InputDecoration(
                      isDense: true,
                      border: InputBorder.none,
                      enabledBorder: InputBorder.none,
                      focusedBorder: InputBorder.none,
                      errorBorder: InputBorder.none,
                      disabledBorder: InputBorder.none,
                      filled: false,
                      contentPadding:
                          const EdgeInsets.symmetric(vertical: 16),
                      hintText: 'Amount (₹)',
                      hintStyle: GoogleFonts.manrope(
                        fontSize: 15,
                        fontWeight: FontWeight.w500,
                        color: const Color(0xFF9CA3AF),
                      ),
                    ),
                    validator: (v) {
                      if (v == null || v.trim().isEmpty) {
                        return 'Enter amount';
                      }
                      final val = double.tryParse(v.trim());
                      if (val == null || val <= 0) {
                        return 'Enter valid amount > 0';
                      }
                      return null;
                    },
                  ),
                ),
              ),
              const SizedBox(height: 16),
              if (!_isAdvanceMode) ...[
                Text(
                  'Paid By',
                  style: GoogleFonts.manrope(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 8),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: widget.story.members.map((m) {
                      final isSelected = m.userId == _selectedPayerId;
                      return GestureDetector(
                        onTap: () =>
                            setState(() => _selectedPayerId = m.userId),
                        child: Container(
                          margin: const EdgeInsets.only(right: 8),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 14, vertical: 8),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? AppColors.primary
                                : AppColors.surfaceSubtle,
                            borderRadius:
                                BorderRadius.circular(AppRadius.pill),
                            border: Border.all(
                              color: isSelected
                                  ? AppColors.primary
                                  : AppColors.border,
                            ),
                          ),
                          child: Text(
                            _formatMemberDisplayName(
                                m.name, _isCurrentUser(m.name, m.userId)),
                            style: GoogleFonts.manrope(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: isSelected
                                  ? Colors.white
                                  : AppColors.textPrimary,
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ] else ...[
                Text(
                  'From (Who Paid in Advance)',
                  style: GoogleFonts.manrope(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 8),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: widget.story.members.map((m) {
                      final isSelected = m.userId == _selectedPayerId;
                      return GestureDetector(
                        onTap: () => setState(() {
                          _selectedPayerId = m.userId;
                          if (_selectedRecipientId == _selectedPayerId) {
                            _selectedRecipientId = widget.story.members
                                .where((other) => other.userId != m.userId)
                                .map((other) => other.userId)
                                .firstOrNull;
                          }
                        }),
                        child: Container(
                          margin: const EdgeInsets.only(right: 8),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 14, vertical: 8),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? AppColors.primary
                                : AppColors.surfaceSubtle,
                            borderRadius:
                                BorderRadius.circular(AppRadius.pill),
                            border: Border.all(
                              color: isSelected
                                  ? AppColors.primary
                                  : AppColors.border,
                            ),
                          ),
                          child: Text(
                            _formatMemberDisplayName(
                                m.name, _isCurrentUser(m.name, m.userId)),
                            style: GoogleFonts.manrope(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: isSelected
                                  ? Colors.white
                                  : AppColors.textPrimary,
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),
                const SizedBox(height: 14),
                Text(
                  'To (Who Received Advance)',
                  style: GoogleFonts.manrope(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 8),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: widget.story.members.map((m) {
                      final isSelected = m.userId == _selectedRecipientId;
                      final isSender = m.userId == _selectedPayerId;
                      return GestureDetector(
                        onTap: isSender
                            ? null
                            : () => setState(
                                () => _selectedRecipientId = m.userId),
                        child: Container(
                          margin: const EdgeInsets.only(right: 8),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 14, vertical: 8),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? const Color(0xFF16A34A)
                                : (isSender
                                    ? const Color(0xFFF3F4F6)
                                    : AppColors.surfaceSubtle),
                            borderRadius:
                                BorderRadius.circular(AppRadius.pill),
                            border: Border.all(
                              color: isSelected
                                  ? const Color(0xFF16A34A)
                                  : (isSender
                                      ? const Color(0xFFE5E7EB)
                                      : AppColors.border),
                            ),
                          ),
                          child: Text(
                            _formatMemberDisplayName(
                                m.name, _isCurrentUser(m.name, m.userId)),
                            style: GoogleFonts.manrope(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: isSelected
                                  ? Colors.white
                                  : (isSender
                                      ? const Color(0xFF9CA3AF)
                                      : AppColors.textPrimary),
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ],
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _isSubmitting
                        ? const Color(0xFF666666)
                        : AppColors.primary,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppRadius.button),
                    ),
                  ),
                  onPressed: _isSubmitting ? null : _handleSubmit,
                  child: _isSubmitting
                      ? const SizedBox(
                          width: 22,
                          height: 22,
                          child: CircularProgressIndicator(
                            strokeWidth: 2.2,
                            color: Colors.white,
                          ),
                        )
                      : Text(
                          _isAdvanceMode
                              ? 'Record Advance Payment'
                              : 'Save Expense',
                          style: GoogleFonts.manrope(
                              fontWeight: FontWeight.w700, fontSize: 16),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
