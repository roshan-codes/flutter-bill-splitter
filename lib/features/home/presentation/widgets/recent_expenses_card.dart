import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_bill_splitter/core/theme/app_colors.dart';
import 'package:flutter_bill_splitter/core/theme/app_radius.dart';
import 'package:flutter_bill_splitter/core/utils/expense_icon_resolver.dart';
import 'package:flutter_bill_splitter/features/activity/data/repositories/activity_repository.dart';
import 'package:flutter_bill_splitter/features/activity/domain/models/split_activity.dart';
import 'package:flutter_bill_splitter/features/activity/presentation/widgets/activity_detail_sheet.dart';
import 'package:flutter_bill_splitter/features/home/domain/models/recent_expense.dart';
import 'package:flutter_bill_splitter/features/home/presentation/widgets/recent_expense_item.dart';
import 'package:flutter_bill_splitter/features/stories/data/repositories/story_repository.dart';
import 'package:flutter_bill_splitter/shared/widgets/platform_adaptive.dart';

/// Platform-adaptive Card container displaying "Recent Expenses".
/// Displays real activities from [ActivityRepository], custom expenses, or a clean empty state.
/// Adheres to design.md Section 5, 8 & 10.
class RecentExpensesCard extends StatelessWidget {
  final List<RecentExpense>? customExpenses;
  final void Function(RecentExpense expense)? onExpenseTap;
  final VoidCallback? onNavigateToActivity;

  const RecentExpensesCard({
    super.key,
    this.customExpenses,
    this.onExpenseTap,
    this.onNavigateToActivity,
  });

  /// Sample expenses available for tests or preview.
  static const List<RecentExpense> sampleExpenses = [
    RecentExpense(
      id: 'sample_1',
      title: 'Dinner at Sakali',
      category: 'Sakali',
      memberCount: 3,
      amount: 549.0,
      icon: Icons.restaurant_rounded,
      iconBgColor: Color(0xFFFFF3E0),
      iconColor: Color(0xFFE65100),
    ),
    RecentExpense(
      id: 'sample_2',
      title: 'Goa Trip Fuel',
      category: 'Trip',
      memberCount: 4,
      amount: 2800.0,
      icon: Icons.local_gas_station_rounded,
      iconBgColor: Color(0xFFFFF8E1),
      iconColor: Color(0xFFF57F17),
    ),
    RecentExpense(
      id: 'sample_3',
      title: 'Groceries',
      category: 'Home',
      memberCount: 2,
      amount: 620.0,
      icon: Icons.shopping_bag_outlined,
      iconBgColor: Color(0xFFE0F2F1),
      iconColor: Color(0xFF00695C),
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Section Header Row: Title + "View all →"
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Recent Expenses',
              style: GoogleFonts.manrope(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
                letterSpacing: -0.4,
              ),
            ),
            if (onNavigateToActivity != null)
              InkWell(
                onTap: () {
                  HapticFeedback.lightImpact();
                  onNavigateToActivity!();
                },
                borderRadius: BorderRadius.circular(8),
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'View all',
                        style: GoogleFonts.manrope(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(width: 3),
                      const Icon(
                        Icons.arrow_forward_rounded,
                        size: 14,
                        color: AppColors.textPrimary,
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
        const SizedBox(height: 14),

        // Platform Adaptive Container
        AnimatedBuilder(
          animation: Listenable.merge([
            ActivityRepository.instance,
            StoryRepository.instance,
          ]),
          builder: (context, _) {
            final activeStoryTitles = StoryRepository.instance.stories
                .map((s) => s.title.trim().toLowerCase())
                .toSet();
            final activities = ActivityRepository.instance.activities
                .where((a) =>
                    activeStoryTitles.isEmpty ||
                    activeStoryTitles
                        .contains(a.groupName.trim().toLowerCase()))
                .toList();
            final dynamicExpenses = activities.map((a) {
              // 1. Resolve Expense Title vs Story Name
              String displayTitle =
                  (a.expenseTitle != null && a.expenseTitle!.isNotEmpty)
                      ? a.expenseTitle!
                      : '';
              String storyName = a.groupName;

              if (displayTitle.isEmpty) {
                for (final story in StoryRepository.instance.stories) {
                  final matchById = story.expenses
                      .where((e) => e.expenseId == a.id)
                      .firstOrNull;
                  if (matchById != null &&
                      matchById.title.isNotEmpty &&
                      !matchById.title.startsWith('Expense by ')) {
                    displayTitle = matchById.title;
                    storyName = story.title;
                    break;
                  }
                  if (story.title.trim().toLowerCase() ==
                      a.groupName.trim().toLowerCase()) {
                    final matchByAmount = story.expenses
                        .where((e) =>
                            (e.amount - a.totalAmount).abs() < 0.01 &&
                            !e.title.startsWith('Expense by '))
                        .firstOrNull;
                    if (matchByAmount != null &&
                        matchByAmount.title.isNotEmpty) {
                      displayTitle = matchByAmount.title;
                      storyName = story.title;
                      break;
                    }
                  }
                }
              }

              if (displayTitle.isEmpty) {
                displayTitle = storyName;
              }

              final icon = ExpenseIconResolver.resolveIcon(displayTitle);
              final iconBg = ExpenseIconResolver.resolveBgColor(icon);
              final iconColor = ExpenseIconResolver.resolveIconColor(icon);

              // Find primary payer
              String? payer;
              if (a.memberExpenses.isNotEmpty) {
                final sorted = a.memberExpenses.entries.toList()
                  ..sort((x, y) => y.value.compareTo(x.value));
                if (sorted.isNotEmpty && sorted.first.value > 0) {
                  payer = sorted.first.key;
                }
              }

              return RecentExpense(
                id: a.id,
                title: displayTitle,
                category: storyName,
                memberCount: a.members.length,
                amount: a.totalAmount,
                icon: icon,
                iconBgColor: iconBg,
                iconColor: iconColor,
                payerName: payer,
                timestamp: a.timestamp,
              );
            }).toList();

            final displayExpenses = customExpenses ?? dynamicExpenses;

            if (displayExpenses.isEmpty) {
              return PlatformCard(
                borderRadius: AppRadius.cardLarge,
                elevation: 0,
                color: AppColors.surface,
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 34),
                child: Center(
                  child: Column(
                    children: [
                      Container(
                        width: 52,
                        height: 52,
                        decoration: BoxDecoration(
                          color: AppColors.successSoft,
                          borderRadius: BorderRadius.circular(
                              AppRadius.iconContainer + 2),
                        ),
                        child: const Icon(
                          Icons.receipt_long_rounded,
                          color: AppColors.success,
                          size: 26,
                        ),
                      ),
                      const SizedBox(height: 14),
                      Text(
                        'No Recent Expenses',
                        style: GoogleFonts.manrope(
                          fontSize: 16.5,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Splits you create will appear here.',
                        style: GoogleFonts.manrope(
                          fontSize: 13,
                          fontWeight: FontWeight.w400,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }

            return PlatformCard(
              borderRadius: AppRadius.cardLarge,
              elevation: 0,
              color: AppColors.surface,
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
              child: Column(
                children: [
                  for (int i = 0; i < displayExpenses.length; i++) ...[
                    RecentExpenseItem(
                      expense: displayExpenses[i],
                      onTap: () {
                        HapticFeedback.lightImpact();
                        if (onExpenseTap != null) {
                          onExpenseTap!(displayExpenses[i]);
                        } else {
                          final activity =
                              ActivityRepository.instance.activities.firstWhere(
                            (a) => a.id == displayExpenses[i].id,
                            orElse: () => SplitActivity(
                              id: displayExpenses[i].id,
                              groupName: displayExpenses[i].title,
                              totalAmount: displayExpenses[i].amount,
                              sharePerPerson: displayExpenses[i].amount /
                                  displayExpenses[i].memberCount,
                              members: const [],
                              memberExpenses: const {},
                              settlements: const [],
                              timestamp: displayExpenses[i].timestamp ??
                                  DateTime.now(),
                            ),
                          );
                          ActivityDetailSheet.show(context, activity);
                        }
                      },
                    ),
                    if (i < displayExpenses.length - 1)
                      const Divider(
                        color: AppColors.border,
                        height: 12,
                        thickness: 1.0,
                      ),
                  ],
                ],
              ),
            );
          },
        ),
      ],
    );
  }
}
