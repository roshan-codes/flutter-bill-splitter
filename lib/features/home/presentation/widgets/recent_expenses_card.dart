import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bill_splitter/core/theme/app_colors.dart';
import 'package:flutter_bill_splitter/features/activity/data/repositories/activity_repository.dart';
import 'package:flutter_bill_splitter/features/activity/domain/models/split_activity.dart';
import 'package:flutter_bill_splitter/features/activity/presentation/widgets/activity_detail_sheet.dart';
import 'package:flutter_bill_splitter/features/home/domain/models/recent_expense.dart';
import 'package:flutter_bill_splitter/features/home/presentation/widgets/recent_expense_item.dart';
import 'package:flutter_bill_splitter/shared/widgets/platform_adaptive.dart';

/// Platform-adaptive Card container displaying "Recent Expenses".
/// Displays real activities from [ActivityRepository], custom expenses, or a clean empty state.
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
      iconBgColor: Color(0xFFE8F8D8),
      iconColor: Color(0xFF284821),
    ),
    RecentExpense(
      id: 'sample_2',
      title: 'Goa Trip Fuel',
      category: 'Trip',
      memberCount: 4,
      amount: 2800.0,
      icon: Icons.local_gas_station_rounded,
      iconBgColor: Color(0xFFFFECE0),
      iconColor: Color(0xFFC85A17),
    ),
    RecentExpense(
      id: 'sample_3',
      title: 'Groceries',
      category: 'Home',
      memberCount: 2,
      amount: 620.0,
      icon: Icons.shopping_bag_outlined,
      iconBgColor: Color(0xFFE0F2FE),
      iconColor: Color(0xFF0284C7),
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Section Header
        const Text(
          'Recent Expenses',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w800,
            color: Color(0xFF1B241E),
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
                iconBgColor: const Color(0xFFE8F8D8),
                iconColor: const Color(0xFF166534),
              );
            }).toList();

            final displayExpenses = customExpenses ?? dynamicExpenses;

            if (displayExpenses.isEmpty) {
              return PlatformCard(
                borderRadius: 22,
                elevation: 1,
                color: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 34),
                child: Center(
                  child: Column(
                    children: [
                      Container(
                        width: 52,
                        height: 52,
                        decoration: BoxDecoration(
                          color: const Color(0xFFE8F8D8),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: const Icon(
                          Icons.receipt_long_rounded,
                          color: Color(0xFF166534),
                          size: 26,
                        ),
                      ),
                      const SizedBox(height: 14),
                      const Text(
                        'No Recent Expenses',
                        style: TextStyle(
                          fontSize: 16.5,
                          fontWeight: FontWeight.w800,
                          color: Color(0xFF1B241E),
                        ),
                      ),
                      const SizedBox(height: 4),
                      const Text(
                        'Splits you create will appear here.',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                          color: Color(0xFF6B7280),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }

            return PlatformCard(
              borderRadius: 22,
              elevation: 1,
              color: Colors.white,
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
                        thickness: 0.8,
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
