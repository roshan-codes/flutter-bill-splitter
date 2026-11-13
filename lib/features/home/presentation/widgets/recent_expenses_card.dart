import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_bill_splitter/core/theme/app_colors.dart';
import 'package:flutter_bill_splitter/core/theme/app_radius.dart';
import 'package:flutter_bill_splitter/features/activity/data/repositories/activity_repository.dart';
import 'package:flutter_bill_splitter/features/activity/domain/models/split_activity.dart';
import 'package:flutter_bill_splitter/features/activity/presentation/widgets/activity_detail_sheet.dart';
import 'package:flutter_bill_splitter/features/home/domain/models/recent_expense.dart';
import 'package:flutter_bill_splitter/features/home/presentation/widgets/recent_expense_item.dart';
import 'package:flutter_bill_splitter/shared/widgets/platform_adaptive.dart';

/// Platform-adaptive Card container displaying "Recent Expenses".
/// Displays real activities from [ActivityRepository], custom expenses, or a clean empty state.
/// Adheres to design.md Section 5, 8 & 10.
class RecentExpensesCard extends StatelessWidget {
  final List<RecentExpense>? customExpenses;
  final void Function(RecentExpense expense)? onExpenseTap;

  const RecentExpensesCard({
    super.key,
    this.customExpenses,
    this.onExpenseTap,
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
      iconBgColor: AppColors.surfaceSubtle,
      iconColor: AppColors.textPrimary,
    ),
    RecentExpense(
      id: 'sample_2',
      title: 'Goa Trip Fuel',
      category: 'Trip',
      memberCount: 4,
      amount: 2800.0,
      icon: Icons.local_gas_station_rounded,
      iconBgColor: AppColors.warningSoft,
      iconColor: AppColors.warning,
    ),
    RecentExpense(
      id: 'sample_3',
      title: 'Groceries',
      category: 'Home',
      memberCount: 2,
      amount: 620.0,
      icon: Icons.shopping_bag_outlined,
      iconBgColor: AppColors.surfaceSubtle,
      iconColor: AppColors.textPrimary,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Section Header
        Text(
          'Recent Expenses',
          style: GoogleFonts.manrope(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
            letterSpacing: -0.3,
          ),
        ),
        const SizedBox(height: 14),

        // Platform Adaptive Container
        AnimatedBuilder(
          animation: ActivityRepository.instance,
          builder: (context, _) {
            final activities = ActivityRepository.instance.activities;
            final dynamicExpenses = activities.map((a) {
              return RecentExpense(
                id: a.id,
                title: a.groupName,
                category: 'Split',
                memberCount: a.members.length,
                amount: a.totalAmount,
                icon: Icons.receipt_long_rounded,
                iconBgColor: AppColors.successSoft,
                iconColor: AppColors.success,
              );
            }).toList();

            final displayExpenses = customExpenses ?? dynamicExpenses;

            if (displayExpenses.isEmpty) {
              return PlatformCard(
                borderRadius: AppRadius.cardLarge,
                elevation: 0,
                color: AppColors.surface,
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 34),
                child: Center(
                  child: Column(
                    children: [
                      Container(
                        width: 52,
                        height: 52,
                        decoration: BoxDecoration(
                          color: AppColors.successSoft,
                          borderRadius: BorderRadius.circular(AppRadius.iconContainer + 2),
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
                          final activity = ActivityRepository.instance.activities
                              .firstWhere(
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
                              timestamp: DateTime.now(),
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
