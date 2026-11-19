import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_bill_splitter/core/constants/expense_categories.dart';
import 'package:flutter_bill_splitter/core/services/storage_service.dart';
import 'package:flutter_bill_splitter/core/theme/app_colors.dart';
import 'package:flutter_bill_splitter/core/theme/app_radius.dart';
import 'package:flutter_bill_splitter/core/utils/user_identity_resolver.dart';
import 'package:flutter_bill_splitter/features/expenses/presentation/widgets/add_expense_bottom_sheet.dart';
import 'package:flutter_bill_splitter/features/stories/data/repositories/story_repository.dart';
import 'package:flutter_bill_splitter/features/stories/domain/models/story.dart';

/// Modal bottom sheet allowing users to edit an existing expense title,
/// amount, category, or payer.
class EditExpenseBottomSheet extends StatefulWidget {
  final Story story;
  final StoryExpense expense;
  final String? resolvedCurrentMemberId;
  final Future<void> Function(
    StoryExpense oldExpense,
    StoryExpense updatedExpense,
  ) onExpenseUpdated;

  const EditExpenseBottomSheet({
    super.key,
    required this.story,
    required this.expense,
    this.resolvedCurrentMemberId,
    required this.onExpenseUpdated,
  });

  static Future<void> show(
    BuildContext context, {
    required Story story,
    required StoryExpense expense,
    String? resolvedCurrentMemberId,
    required Future<void> Function(
      StoryExpense oldExpense,
      StoryExpense updatedExpense,
    ) onExpenseUpdated,
  }) {
    HapticFeedback.lightImpact();
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => EditExpenseBottomSheet(
        story: story,
        expense: expense,
        resolvedCurrentMemberId: resolvedCurrentMemberId,
        onExpenseUpdated: onExpenseUpdated,
      ),
    );
  }

  @override
  State<EditExpenseBottomSheet> createState() => _EditExpenseBottomSheetState();
}

class _EditExpenseBottomSheetState extends State<EditExpenseBottomSheet> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _titleController;
  late final TextEditingController _amountController;
  late String _selectedPayerId;
  String? _selectedCategory;
  String? _selectedTagLabel;
  late List<ExpenseQuickTag> _quickTags;
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.expense.title);
    _amountController = TextEditingController(
      text: widget.expense.amount.truncateToDouble() == widget.expense.amount
          ? widget.expense.amount.toInt().toString()
          : widget.expense.amount.toString(),
    );
    _selectedPayerId = widget.expense.paidBy;
    _selectedCategory = widget.expense.category;

    _quickTags = _getFrequentAndQuickTags();
    _selectedTagLabel = _quickTags
        .where((t) =>
            t.label.toLowerCase() == widget.expense.title.toLowerCase().trim() ||
            t.category == widget.expense.category)
        .firstOrNull
        ?.label;
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

  Future<void> _handleUpdate() async {
    if (_isSubmitting) return;
    setState(() => _isSubmitting = true);

    if (!(_formKey.currentState?.validate() ?? false)) {
      setState(() => _isSubmitting = false);
      return;
    }

    final amt = double.parse(_amountController.text.trim());
    final newTitle = _titleController.text.trim();
    final payer = widget.story.members.firstWhere(
      (m) => m.userId == _selectedPayerId,
      orElse: () => widget.story.members.first,
    );

    final finalCategory = _selectedCategory ??
        ExpenseCategories.inferCategoryFromTitle(newTitle);

    final count =
        widget.story.members.isNotEmpty ? widget.story.members.length : 1;

    final updatedExpense = StoryExpense(
      expenseId: widget.expense.expenseId,
      title: newTitle,
      category: finalCategory,
      amount: amt,
      paidBy: payer.userId,
      splitType: widget.expense.splitType,
      participants: widget.expense.participants,
      date: widget.expense.date,
      shares: widget.expense.splitType == 'equal'
          ? widget.story.members
              .map((m) => ExpenseShare(
                  userId: m.userId, amount: amt / count))
              .toList()
          : widget.expense.shares
              .map((s) => ExpenseShare(userId: s.userId, amount: amt))
              .toList(),
    );

    if (mounted) {
      Navigator.of(context).pop();
    }

    await _recordTagUsage(newTitle);
    await widget.onExpenseUpdated(widget.expense, updatedExpense);
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
              // Drag Handle
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
                'Edit Expense',
                style: GoogleFonts.manrope(
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 16),

              // Title Field
              Text(
                'Expense Title',
                style: GoogleFonts.manrope(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 6),
              TextFormField(
                controller: _titleController,
                decoration: InputDecoration(
                  filled: true,
                  fillColor: AppColors.surfaceSubtle,
                  hintText: 'e.g. Lunch, Groceries',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(AppRadius.input),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                ),
                validator: (v) =>
                    (v == null || v.trim().isEmpty) ? 'Enter a title' : null,
              ),
              const SizedBox(height: 10),

              // Quick tags
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
              const SizedBox(height: 16),

              // Amount Field
              Text(
                'Amount (₹)',
                style: GoogleFonts.manrope(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 6),
              TextFormField(
                controller: _amountController,
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
                decoration: InputDecoration(
                  filled: true,
                  fillColor: AppColors.surfaceSubtle,
                  hintText: '0.00',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(AppRadius.input),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                ),
                validator: (v) {
                  if (v == null || v.trim().isEmpty) return 'Enter amount';
                  final val = double.tryParse(v.trim());
                  if (val == null || val <= 0) {
                    return 'Enter valid amount > 0';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Paid By
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
                          borderRadius: BorderRadius.circular(AppRadius.pill),
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
              const SizedBox(height: 24),

              // Update Button
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppRadius.button),
                    ),
                  ),
                  onPressed: _isSubmitting ? null : _handleUpdate,
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
                          'Update Expense',
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
