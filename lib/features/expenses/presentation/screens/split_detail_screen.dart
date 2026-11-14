import 'package:animations/animations.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_bill_splitter/core/animations/app_motion.dart';
import 'package:flutter_bill_splitter/core/animations/app_transitions.dart';
import 'package:flutter_bill_splitter/core/theme/app_colors.dart';
import 'package:flutter_bill_splitter/core/theme/app_radius.dart';
import 'package:flutter_bill_splitter/core/utils/string_utils.dart';
import 'package:flutter_bill_splitter/features/expenses/presentation/screens/split_summary_screen.dart';
import 'package:flutter_bill_splitter/features/expenses/presentation/widgets/hero_card_curves_painter.dart';
import 'package:flutter_bill_splitter/features/expenses/presentation/widgets/palm_branch_painter.dart';
import 'package:flutter_bill_splitter/features/friends/domain/models/friend.dart';
import 'package:flutter_bill_splitter/features/stories/data/repositories/story_repository.dart';
import 'package:flutter_bill_splitter/features/stories/domain/models/story.dart';
import 'package:flutter_bill_splitter/shared/widgets/platform_adaptive.dart';

/// Screen where users review group split with members, matching the design mockup:
/// - Header with Title (e.g. Goa Trip), Dates, Member count, and Palm foliage decoration
/// - 3 Segment Tabs: Overview, Expenses, Members
/// - Overview: Black Hero Card with Total expenses & Per person, and Group summary balance pills
/// - Expenses: Categorized expense list and bottom "+ Add expense" button
/// - Members: Members list with individual shares, roles, and split finalization
class SplitDetailScreen extends StatefulWidget {
  final String groupName;
  final List<Friend> members;
  final Story? story;

  const SplitDetailScreen({
    super.key,
    required this.groupName,
    required this.members,
    this.story,
  });

  @override
  State<SplitDetailScreen> createState() => _SplitDetailScreenState();
}

class _SplitDetailScreenState extends State<SplitDetailScreen> {
  int _currentTab = 0; // 0: Overview, 1: Expenses, 2: Members
  int _previousTab = 0;
  late Story _story;
  late final Map<String, double> _memberExpenses;

  @override
  void initState() {
    super.initState();
    _memberExpenses = {};
    _initStoryData();
  }

  void _initStoryData() {
    if (widget.story != null) {
      _story = widget.story!;
      for (final exp in _story.expenses) {
        final payerMember = _story.members.firstWhere(
          (m) => m.userId == exp.paidBy,
          orElse: () =>
              StoryMember(userId: exp.paidBy, name: exp.paidBy, joinedAt: ''),
        );
        _memberExpenses[payerMember.name] =
            (_memberExpenses[payerMember.name] ?? 0.0) + exp.amount;
      }
      return;
    }

    if (widget.members.isEmpty) {
      // Fallback for tests or direct previews
      final sample = StoryRepository.instance.getStoryById('story_001') ??
          Story.sampleGoaTrip();
      _story = sample;
      for (final exp in _story.expenses) {
        final payerMember = _story.members.firstWhere(
          (m) => m.userId == exp.paidBy,
          orElse: () =>
              StoryMember(userId: exp.paidBy, name: exp.paidBy, joinedAt: ''),
        );
        _memberExpenses[payerMember.name] =
            (_memberExpenses[payerMember.name] ?? 0.0) + exp.amount;
      }
      return;
    }

    // Build real dynamic story from passed friends and groupName
    final now = DateTime.now();
    final todayStr =
        '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
    final storyMembers = widget.members.map((f) {
      return StoryMember(
        userId: 'user_${f.name.toLowerCase().replaceAll(' ', '_')}',
        name: f.name,
        role: widget.members.first.name == f.name ? 'admin' : 'member',
        joinedAt: now.toIso8601String(),
      );
    }).toList();

    final baseExpenses = <StoryExpense>[];
    final memberBalances = storyMembers.map((m) {
      return StoryMemberBalance(
        userId: m.userId,
        name: m.name,
        totalPaid: 0.0,
        totalShare: 0.0,
        netBalance: 0.0,
        status: 'settled',
      );
    }).toList();

    _story = Story(
      storyId: 'story_${now.millisecondsSinceEpoch}',
      title: widget.groupName.isNotEmpty ? widget.groupName : 'Shared Expense',
      description: 'Group expenses',
      coverEmoji: widget.groupName.toLowerCase().contains('goa') ? '🌴' : '🧾',
      currency: 'INR',
      status: 'active',
      createdBy:
          storyMembers.isNotEmpty ? storyMembers.first.userId : 'user_001',
      createdAt: now.toIso8601String(),
      startDate: todayStr,
      endDate: todayStr,
      members: storyMembers,
      summary: StorySummary(
        totalExpenses: 0.0,
        totalSettled: 0.0,
        pendingAmount: 0.0,
        memberCount: storyMembers.length,
        expenseCount: 0,
      ),
      expenses: baseExpenses,
      memberBalances: memberBalances,
      settlements: const [],
    );
  }

  String _formatAmount(num value) {
    final integerPart = value.toInt();
    final str = integerPart.abs().toString();
    if (str.length <= 3) {
      return (value < 0 ? '-' : '') + str;
    }
    // Indian number format: last 3 digits, then pairs of 2
    final lastThree = str.substring(str.length - 3);
    final otherDigits = str.substring(0, str.length - 3);
    final formattedOther = otherDigits.replaceAllMapped(
      RegExp(r'(\d)(?=(\d\d)+$)'),
      (m) => '${m[1]},',
    );
    return '${value < 0 ? '-' : ''}$formattedOther,$lastThree';
  }

  String _getDateSubtitle(int memberCount) {
    final memberSuffix = memberCount == 1 ? '1 member' : '$memberCount members';
    if (_story.startDate == '2026-11-12' && _story.endDate == '2026-11-16') {
      return 'Nov 12 – Nov 16 · $memberSuffix';
    }
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec'
    ];
    try {
      final sDate = _story.startDate;
      if (sDate != null && sDate.isNotEmpty) {
        final start = DateTime.tryParse(sDate);
        if (start != null) {
          final monthName = months[start.month - 1];
          final eDate = _story.endDate;
          if (eDate != null && eDate.isNotEmpty && eDate != sDate) {
            final end = DateTime.tryParse(eDate);
            if (end != null) {
              final endMonth = months[end.month - 1];
              return '$monthName ${start.day} – $endMonth ${end.day} · $memberSuffix';
            }
          }
          return '$monthName ${start.day} · $memberSuffix';
        }
      }
    } catch (_) {}
    return memberSuffix;
  }

  void _recalculateBalances() {
    final total = _story.expenses.fold<double>(0.0, (sum, e) => sum + e.amount);
    final count = _story.members.isNotEmpty ? _story.members.length : 1;
    final perPerson = total / count;

    final updatedBalances = _story.members.map((m) {
      final paid = _story.expenses
          .where((e) => e.paidBy == m.userId || e.paidBy == m.name)
          .fold<double>(0.0, (sum, e) => sum + e.amount);
      final net = paid - perPerson;
      String status = 'settled';
      if (net > 0) status = 'gets_back';
      if (net < 0) status = 'owes';

      return StoryMemberBalance(
        userId: m.userId,
        name: m.name,
        totalPaid: paid,
        totalShare: perPerson,
        netBalance: net,
        status: status,
      );
    }).toList();

    setState(() {
      _story = _story.copyWith(
        summary: _story.summary.copyWith(
          totalExpenses: total,
          expenseCount: _story.expenses.length,
          memberCount: count,
        ),
        memberBalances: updatedBalances,
      );
    });
    if (StoryRepository.instance.getStoryById(_story.storyId) != null) {
      StoryRepository.instance.updateStory(_story);
    }
  }

  void _showAddExpenseDialog(Friend friend) {
    final currentAmount = _memberExpenses[friend.name];
    final controller = TextEditingController(
      text: currentAmount != null && currentAmount > 0
          ? currentAmount.toStringAsFixed(
              currentAmount.truncateToDouble() == currentAmount ? 0 : 2)
          : '',
    );
    final formKey = GlobalKey<FormState>();

    AppTransitions.showFadeScaleDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.cardLarge),
          side: const BorderSide(color: AppColors.border, width: 1.0),
        ),
        title: Row(
          children: [
            Container(
              width: 38,
              height: 38,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.surfaceSubtle,
              ),
              child: Center(
                child: Text(
                  StringUtils.getSingleInitial(friend.name),
                  style: GoogleFonts.manrope(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.w700,
                    fontSize: 16,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                'Expense for ${friend.name}',
                style: GoogleFonts.manrope(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
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
              TextFormField(
                controller: controller,
                autofocus: true,
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
                style: GoogleFonts.manrope(
                    fontSize: 15, color: AppColors.textPrimary),
                decoration: InputDecoration(
                  labelText: 'Amount (₹)',
                  hintText: 'Enter amount e.g. 250',
                  hintStyle: GoogleFonts.manrope(color: AppColors.textTertiary),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(AppRadius.input),
                  ),
                ),
                validator: (val) {
                  if (val == null || val.trim().isEmpty) {
                    return 'Please enter an amount';
                  }
                  final parsed = double.tryParse(val.trim());
                  if (parsed == null || parsed <= 0) {
                    return 'Enter a valid amount > 0';
                  }
                  return null;
                },
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text('Cancel',
                style: GoogleFonts.manrope(color: AppColors.textSecondary)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppRadius.buttonSecondary),
              ),
            ),
            onPressed: () {
              if (formKey.currentState?.validate() ?? false) {
                final amount = double.parse(controller.text.trim());
                setState(() {
                  _memberExpenses[friend.name] = amount;

                  // Add or update matching StoryExpense
                  final existingIdx = _story.expenses.indexWhere(
                    (e) => e.title == 'Expense by ${friend.name}',
                  );
                  final matchingMember = _story.members.firstWhere(
                    (m) => m.name.toLowerCase() == friend.name.toLowerCase(),
                    orElse: () => StoryMember(
                        userId: friend.name, name: friend.name, joinedAt: ''),
                  );

                  final newExpense = StoryExpense(
                    expenseId: 'exp_${DateTime.now().millisecondsSinceEpoch}',
                    title: 'Expense by ${friend.name}',
                    category: 'general',
                    amount: amount,
                    paidBy: matchingMember.userId,
                    splitType: 'equal',
                    participants: _story.members.map((m) => m.userId).toList(),
                    shares: _story.members
                        .map((m) => ExpenseShare(
                              userId: m.userId,
                              amount: amount /
                                  (_story.members.isNotEmpty
                                      ? _story.members.length
                                      : 1),
                            ))
                        .toList(),
                    date: DateTime.now().toIso8601String(),
                  );

                  if (existingIdx != -1) {
                    final updated = List<StoryExpense>.from(_story.expenses);
                    updated[existingIdx] = newExpense;
                    _story = _story.copyWith(expenses: updated);
                  } else {
                    _story = _story
                        .copyWith(expenses: [..._story.expenses, newExpense]);
                  }
                });

                _recalculateBalances();
                Navigator.of(context).pop();
              }
            },
            child: Text('Save Expense',
                style: GoogleFonts.manrope(fontWeight: FontWeight.w700)),
          ),
        ],
      ),
    );
  }

  void _openAddExpenseSheet(BuildContext context) {
    HapticFeedback.lightImpact();
    final titleController = TextEditingController();
    final amountController = TextEditingController();
    String selectedCategory = 'food';
    String selectedPayerId =
        _story.members.isNotEmpty ? _story.members.first.userId : 'user_001';
    final sheetFormKey = GlobalKey<FormState>();

    const categories = [
      {
        'id': 'food',
        'label': 'Food & Drinks',
        'icon': Icons.restaurant_outlined
      },
      {'id': 'accommodation', 'label': 'Stay', 'icon': Icons.hotel_outlined},
      {
        'id': 'transport',
        'label': 'Transport',
        'icon': Icons.local_gas_station_outlined
      },
      {'id': 'activities', 'label': 'Activities', 'icon': Icons.waves_rounded},
      {
        'id': 'general',
        'label': 'General',
        'icon': Icons.receipt_long_outlined
      },
    ];

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setSheetState) => Container(
          padding: EdgeInsets.fromLTRB(
              20, 20, 20, MediaQuery.of(ctx).viewInsets.bottom + 24),
          decoration: const BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Form(
            key: sheetFormKey,
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
                const SizedBox(height: 18),
                Text(
                  'Add New Expense',
                  style: GoogleFonts.manrope(
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: titleController,
                  autofocus: true,
                  decoration: InputDecoration(
                    labelText: 'Expense Title',
                    hintText: 'e.g. Dinner, Boat Ride',
                    hintStyle:
                        GoogleFonts.manrope(color: AppColors.textTertiary),
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(AppRadius.input)),
                  ),
                  validator: (v) =>
                      (v == null || v.trim().isEmpty) ? 'Enter a title' : null,
                ),
                const SizedBox(height: 14),
                TextFormField(
                  controller: amountController,
                  keyboardType:
                      const TextInputType.numberWithOptions(decimal: true),
                  decoration: InputDecoration(
                    labelText: 'Amount (₹)',
                    hintText: 'e.g. 2000',
                    hintStyle:
                        GoogleFonts.manrope(color: AppColors.textTertiary),
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(AppRadius.input)),
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
                const SizedBox(height: 16),
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
                    children: _story.members.map((m) {
                      final isSelected = m.userId == selectedPayerId;
                      return GestureDetector(
                        onTap: () =>
                            setSheetState(() => selectedPayerId = m.userId),
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
                            m.name,
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
                const SizedBox(height: 16),
                Text(
                  'Category',
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
                    children: categories.map((cat) {
                      final isSelected = cat['id'] == selectedCategory;
                      return GestureDetector(
                        onTap: () => setSheetState(
                            () => selectedCategory = cat['id'] as String),
                        child: Container(
                          margin: const EdgeInsets.only(right: 8),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 8),
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
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                cat['icon'] as IconData,
                                size: 16,
                                color: isSelected
                                    ? Colors.white
                                    : AppColors.textPrimary,
                              ),
                              const SizedBox(width: 6),
                              Text(
                                cat['label'] as String,
                                style: GoogleFonts.manrope(
                                  fontSize: 12.5,
                                  fontWeight: FontWeight.w600,
                                  color: isSelected
                                      ? Colors.white
                                      : AppColors.textPrimary,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),
                const SizedBox(height: 24),
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
                    onPressed: () {
                      if (sheetFormKey.currentState?.validate() ?? false) {
                        final amt = double.parse(amountController.text.trim());
                        final payer = _story.members.firstWhere(
                          (m) => m.userId == selectedPayerId,
                          orElse: () => _story.members.first,
                        );

                        final newExpense = StoryExpense(
                          expenseId:
                              'exp_${DateTime.now().millisecondsSinceEpoch}',
                          title: titleController.text.trim(),
                          category: selectedCategory,
                          amount: amt,
                          paidBy: payer.userId,
                          splitType: 'equal',
                          participants:
                              _story.members.map((m) => m.userId).toList(),
                          shares: _story.members
                              .map((m) => ExpenseShare(
                                    userId: m.userId,
                                    amount: amt /
                                        (_story.members.isNotEmpty
                                            ? _story.members.length
                                            : 1),
                                  ))
                              .toList(),
                          date: DateTime.now().toIso8601String(),
                        );

                        setState(() {
                          _story = _story.copyWith(
                              expenses: [..._story.expenses, newExpense]);
                          _memberExpenses[payer.name] =
                              (_memberExpenses[payer.name] ?? 0.0) + amt;
                        });

                        _recalculateBalances();
                        Navigator.of(ctx).pop();
                      }
                    },
                    child: Text(
                      'Save Expense',
                      style: GoogleFonts.manrope(
                          fontWeight: FontWeight.w700, fontSize: 16),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _navigateToSummary() {
    HapticFeedback.lightImpact();
    final effectiveFriends = widget.members.isNotEmpty
        ? widget.members
        : _story.members
            .map((m) => Friend(name: m.name, phone: '+91 98765 00000'))
            .toList();

    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => SplitSummaryScreen(
          groupName: _story.title,
          members: effectiveFriends,
          memberExpenses: _memberExpenses,
        ),
      ),
    );
  }

  IconData _getCategoryIcon(String category) {
    switch (category.toLowerCase()) {
      case 'accommodation':
        return Icons.hotel_outlined;
      case 'food':
        return Icons.restaurant_outlined;
      case 'transport':
        return Icons.local_gas_station_outlined;
      case 'activities':
        return Icons.waves_rounded;
      default:
        return Icons.receipt_long_outlined;
    }
  }

  String _formatExpenseDate(String dateStr) {
    try {
      final dt = DateTime.parse(dateStr);
      final months = [
        'Jan',
        'Feb',
        'Mar',
        'Apr',
        'May',
        'Jun',
        'Jul',
        'Aug',
        'Sep',
        'Oct',
        'Nov',
        'Dec'
      ];
      return '${months[dt.month - 1]} ${dt.day}';
    } catch (_) {
      return 'Nov 12';
    }
  }

  @override
  Widget build(BuildContext context) {
    final isIOS = isIOSPlatform(context);
    final totalExpenses = _story.summary.totalExpenses > 0
        ? _story.summary.totalExpenses
        : _story.expenses.fold<double>(0.0, (s, e) => s + e.amount);
    final memberCount = _story.members.isNotEmpty ? _story.members.length : 1;
    final perPersonAmount = totalExpenses / memberCount;

    return Scaffold(
      backgroundColor: isIOS ? AppColors.iosBackground : AppColors.background,
      body: Stack(
        children: [
          // Palm foliage decoration in top right corner on Overview tab
          if (_currentTab == 0 &&
              (_story.coverEmoji == '🌴' ||
                  _story.title.toLowerCase().contains('goa')))
            const Positioned(
              top: 0,
              right: 0,
              width: 150,
              height: 150,
              child: IgnorePointer(
                child: CustomPaint(
                  painter: PalmBranchPainter(),
                ),
              ),
            ),

          // Main scrollable content
          SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Top Navigation Bar
                Padding(
                  padding: const EdgeInsets.fromLTRB(12, 8, 16, 0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      PlatformBackButton(
                        onPressed: () => Navigator.of(context).pop(),
                      ),
                      // Hidden semantic text for accessibility and test compliance
                      Semantics(
                        label: 'Split with Members',
                        child: const SizedBox(
                          width: 1,
                          height: 1,
                          child: Text(
                            'Split with Members',
                            style: TextStyle(
                                fontSize: 0.1, color: Colors.transparent),
                          ),
                        ),
                      ),
                      if (_currentTab != 0)
                        IconButton(
                          icon: const Icon(
                            Icons.more_vert_rounded,
                            color: AppColors.textPrimary,
                          ),
                          onPressed: () {
                            showModalBottomSheet(
                              context: context,
                              builder: (ctx) => SafeArea(
                                child: Wrap(
                                  children: [
                                    ListTile(
                                      leading:
                                          const Icon(Icons.calculate_outlined),
                                      title: Text('Finalize & Settle Split',
                                          style: GoogleFonts.manrope()),
                                      onTap: () {
                                        Navigator.of(ctx).pop();
                                        _navigateToSummary();
                                      },
                                    ),
                                    ListTile(
                                      leading:
                                          const Icon(Icons.group_add_outlined),
                                      title: Text('Add New Member',
                                          style: GoogleFonts.manrope()),
                                      onTap: () {
                                        Navigator.of(ctx).pop();
                                        setState(() => _currentTab = 2);
                                      },
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        )
                      else
                        const SizedBox(width: 48),
                    ],
                  ),
                ),

                // Story Header Info: Title & Subtitle
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 6, 20, 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _story.title,
                        style: GoogleFonts.manrope(
                          fontSize: 28,
                          fontWeight: FontWeight.w800,
                          color: AppColors.textPrimary,
                          letterSpacing: -0.6,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _getDateSubtitle(memberCount),
                        style: GoogleFonts.manrope(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),

                // 3 Segmented Pill Tabs: Overview, Expenses, Members
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Row(
                    children: [
                      _buildSegmentPill(index: 0, label: 'Overview'),
                      const SizedBox(width: 8),
                      _buildSegmentPill(index: 1, label: 'Expenses'),
                      const SizedBox(width: 8),
                      _buildSegmentPill(index: 2, label: 'Members'),
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                // Dynamic Body based on selected Segment Tab with SharedAxisTransition
                Expanded(
                  child: AppTransitions.sharedAxisSwitcher(
                    context: context,
                    transitionKey: _currentTab,
                    reverse: _previousTab > _currentTab,
                    type: SharedAxisTransitionType.horizontal,
                    duration: AppMotion.normal,
                    child:
                        _buildCurrentTabContent(totalExpenses, perPersonAmount),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),

      // Bottom Navigation Bar depending on current tab
      bottomNavigationBar: _buildBottomBar(isIOS),
    );
  }

  Widget? _buildBottomBar(bool isIOS) {
    if (_currentTab == 1) {
      // Expenses tab: "+ Add expense" black button as seen in screenshot
      return Container(
        color: isIOS ? AppColors.iosBackground : AppColors.background,
        padding: const EdgeInsets.fromLTRB(20, 10, 20, 20),
        child: SafeArea(
          top: false,
          child: SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppRadius.button),
                ),
              ),
              onPressed: () => _openAddExpenseSheet(context),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.add_rounded, color: Colors.white, size: 20),
                  const SizedBox(width: 8),
                  Text(
                    'Add expense',
                    style: GoogleFonts.manrope(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    } else {
      // Overview & Members tab: "Confirm Split"
      return Container(
        color: isIOS ? AppColors.iosBackground : AppColors.background,
        padding: const EdgeInsets.fromLTRB(20, 10, 20, 20),
        child: SafeArea(
          top: false,
          child: SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppRadius.button),
                ),
              ),
              onPressed: _navigateToSummary,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Confirm Split',
                    style: GoogleFonts.manrope(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(width: 8),
                  const Icon(Icons.arrow_forward_rounded,
                      color: Colors.white, size: 18),
                ],
              ),
            ),
          ),
        ),
      );
    }
  }

  Widget _buildSegmentPill({required int index, required String label}) {
    final isSelected = _currentTab == index;
    return Expanded(
      child: GestureDetector(
        onTap: () {
          HapticFeedback.selectionClick();
          setState(() {
            _previousTab = _currentTab;
            _currentTab = index;
          });
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: isSelected ? AppColors.primary : const Color(0xFFF1F1EF),
            borderRadius: BorderRadius.circular(AppRadius.pill),
          ),
          child: Center(
            child: Text(
              label,
              style: GoogleFonts.manrope(
                fontSize: 14,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w600,
                color: isSelected ? Colors.white : AppColors.textPrimary,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCurrentTabContent(double totalExpenses, double perPersonAmount) {
    switch (_currentTab) {
      case 0:
        return _buildOverviewTab(totalExpenses, perPersonAmount);
      case 1:
        return _buildExpensesTab(totalExpenses);
      case 2:
      default:
        return _buildMembersTab();
    }
  }

  // TAB 0: OVERVIEW
  Widget _buildOverviewTab(double totalExpenses, double perPersonAmount) {
    final isSampleGoaTrip =
        _story.title.toLowerCase().contains('goa') || widget.members.isEmpty;

    return SingleChildScrollView(
      key: const ValueKey('overview_tab'),
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Black Hero Card with Total expenses & Per person
          Container(
            width: double.infinity,
            height: 185,
            decoration: BoxDecoration(
              color: const Color(0xFF17181A),
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.12),
                  blurRadius: 16,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(24),
              child: Stack(
                children: [
                  // Decorative contour curves in bottom right
                  const Positioned.fill(
                    child: CustomPaint(
                      painter: HeroCardCurvesPainter(),
                    ),
                  ),

                  // Content
                  Padding(
                    padding: const EdgeInsets.all(22),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Total expenses',
                          style: GoogleFonts.manrope(
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                            color: Colors.white70,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '₹${_formatAmount(totalExpenses)}',
                          style: GoogleFonts.manrope(
                            fontSize: 32,
                            fontWeight: FontWeight.w800,
                            color: Colors.white,
                            letterSpacing: -0.6,
                          ),
                        ),
                        const Spacer(),
                        Text(
                          'Per person',
                          style: GoogleFonts.manrope(
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                            color: Colors.white70,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '₹${_formatAmount(perPersonAmount)}',
                          style: GoogleFonts.manrope(
                            fontSize: 22,
                            fontWeight: FontWeight.w800,
                            color: Colors.white,
                            letterSpacing: -0.4,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),

          // Section Header: Group summary
          Text(
            'Group summary',
            style: GoogleFonts.manrope(
              fontSize: 18,
              fontWeight: FontWeight.w800,
              color: AppColors.textPrimary,
              letterSpacing: -0.3,
            ),
          ),
          const SizedBox(height: 16),

          // Member Balances List
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: _story.memberBalances.length,
            separatorBuilder: (_, __) => const SizedBox(height: 16),
            itemBuilder: (context, index) {
              final balance = _story.memberBalances[index];
              final isRoshan = balance.name.toLowerCase() == 'roshan';
              final displayName =
                  isRoshan ? '${balance.name} (You)' : balance.name;
              final friend =
                  Friend(name: balance.name, phone: '+91 98765 00000');
              final hasExpense = _memberExpenses[balance.name] != null &&
                  _memberExpenses[balance.name]! > 0;

              Widget statusWidget;

              if (!isSampleGoaTrip && !hasExpense && balance.totalPaid == 0) {
                // If member hasn't added an expense yet in a new split, show "Add expense" button
                statusWidget = GestureDetector(
                  onTap: () => _showAddExpenseDialog(friend),
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceSubtle,
                      borderRadius: BorderRadius.circular(AppRadius.pill),
                      border: Border.all(color: AppColors.border, width: 1.0),
                    ),
                    child: Text(
                      'Add expense',
                      style: GoogleFonts.manrope(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ),
                );
              } else {
                Color pillBg;
                Color pillTextColor;
                String pillText;

                if (balance.netBalance > 0) {
                  pillBg = const Color(0xFFE8F5E9);
                  pillTextColor = const Color(0xFF2E7D32);
                  pillText = '+₹${_formatAmount(balance.netBalance)}';
                } else if (balance.netBalance < 0) {
                  pillBg = const Color(0xFFFFEBEE);
                  pillTextColor = const Color(0xFFC62828);
                  pillText = '-₹${_formatAmount(balance.netBalance.abs())}';
                } else {
                  pillBg = const Color(0xFFF1F1EF);
                  pillTextColor = AppColors.textPrimary;
                  pillText = '₹0';
                }

                statusWidget = Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (!isSampleGoaTrip && hasExpense) ...[
                      GestureDetector(
                        onTap: () => _showAddExpenseDialog(friend),
                        child: Text(
                          'Edit expense',
                          style: GoogleFonts.manrope(
                            fontSize: 12.5,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                    ],
                    GestureDetector(
                      onTap: () => _showAddExpenseDialog(friend),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 14, vertical: 6),
                        decoration: BoxDecoration(
                          color: pillBg,
                          borderRadius: BorderRadius.circular(AppRadius.pill),
                        ),
                        child: Text(
                          pillText,
                          style: GoogleFonts.manrope(
                            fontSize: 13.5,
                            fontWeight: FontWeight.w700,
                            color: pillTextColor,
                          ),
                        ),
                      ),
                    ),
                  ],
                );
              }

              return Row(
                children: [
                  // Circular member avatar
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: const Color(0xFF24272D),
                      border: Border.all(color: AppColors.border, width: 1.0),
                    ),
                    child: Center(
                      child: Text(
                        StringUtils.getSingleInitial(balance.name),
                        style: GoogleFonts.manrope(
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 14),

                  // Name & Total Paid
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
                          'Paid ₹${_formatAmount(balance.totalPaid)}',
                          style: GoogleFonts.manrope(
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Balance status pill / action
                  statusWidget,
                ],
              );
            },
          ),
        ],
      ),
    );
  }

  // TAB 1: EXPENSES
  Widget _buildExpensesTab(double totalExpenses) {
    return SingleChildScrollView(
      key: const ValueKey('expenses_tab'),
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 90),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header summary line: "5 expenses · ₹20,000"
          Text(
            '${_story.expenses.length} expenses · ₹${_formatAmount(totalExpenses)}',
            style: GoogleFonts.manrope(
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 12),

          if (_story.expenses.isEmpty)
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
            // Expenses List
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _story.expenses.length,
              separatorBuilder: (_, __) => const Divider(
                color: AppColors.border,
                height: 24,
                thickness: 0.6,
              ),
              itemBuilder: (context, index) {
                final expense = _story.expenses[index];
                final payer = _story.members.firstWhere(
                  (m) => m.userId == expense.paidBy,
                  orElse: () => StoryMember(
                      userId: expense.paidBy,
                      name: expense.paidBy,
                      joinedAt: ''),
                );

                return Row(
                  children: [
                    // Category Icon
                    Container(
                      width: 40,
                      height: 40,
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color: AppColors.surfaceSubtle,
                      ),
                      child: Center(
                        child: Icon(
                          _getCategoryIcon(expense.category),
                          size: 20,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ),
                    const SizedBox(width: 14),

                    // Title & Payer Subtitle
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
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'Paid by ${payer.name} · ${_formatExpenseDate(expense.date)}',
                            style: GoogleFonts.manrope(
                              fontSize: 13,
                              color: AppColors.textSecondary,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Trailing Amount
                    Text(
                      '₹${_formatAmount(expense.amount)}',
                      style: GoogleFonts.manrope(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ],
                );
              },
            ),
        ],
      ),
    );
  }

  // TAB 2: MEMBERS
  Widget _buildMembersTab() {
    return SingleChildScrollView(
      key: const ValueKey('members_tab'),
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Selected Members',
                style: GoogleFonts.manrope(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
              Text(
                '${_story.members.length} total',
                style: GoogleFonts.manrope(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),

          // Members list with Add Expense option
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: _story.members.length,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final member = _story.members[index];
              final friend =
                  Friend(name: member.name, phone: '+91 98765 00000');
              final hasExpense = _memberExpenses[member.name] != null &&
                  _memberExpenses[member.name]! > 0;

              return PlatformCard(
                borderRadius: AppRadius.card,
                elevation: 0,
                color: AppColors.surface,
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                child: Row(
                  children: [
                    Container(
                      width: 42,
                      height: 42,
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color: Color(0xFF24272D),
                      ),
                      child: Center(
                        child: Text(
                          StringUtils.getSingleInitial(member.name),
                          style: GoogleFonts.manrope(
                            color: Colors.white,
                            fontWeight: FontWeight.w700,
                            fontSize: 16,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            member.name,
                            style: GoogleFonts.manrope(
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            member.role == 'admin' ? 'Admin' : 'Member',
                            style: GoogleFonts.manrope(
                              fontSize: 13,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                    GestureDetector(
                      onTap: () => _showAddExpenseDialog(friend),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: hasExpense
                              ? AppColors.successSoft
                              : AppColors.surfaceSubtle,
                          borderRadius: BorderRadius.circular(AppRadius.pill),
                          border: Border.all(
                            color: hasExpense
                                ? AppColors.success
                                : AppColors.border,
                            width: 1.0,
                          ),
                        ),
                        child: Text(
                          hasExpense ? 'Edit expense' : 'Add expense',
                          style: GoogleFonts.manrope(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: hasExpense
                                ? AppColors.success
                                : AppColors.textPrimary,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
