import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_neumorphism_ui/flutter_neumorphism_ui.dart';
import 'package:flutter_bill_splitter/core/theme/app_colors.dart';
import 'package:flutter_bill_splitter/core/theme/neumorphic_styles.dart';
import 'package:flutter_bill_splitter/features/activity/data/repositories/activity_repository.dart';
import 'package:flutter_bill_splitter/features/activity/domain/models/split_activity.dart';
import 'package:flutter_bill_splitter/features/activity/presentation/widgets/activity_detail_sheet.dart';
import 'package:flutter_bill_splitter/features/expenses/domain/models/settlement_transaction.dart';
import 'package:flutter_bill_splitter/features/friends/domain/models/friend.dart';
import 'package:flutter_bill_splitter/features/home/domain/models/recent_expense.dart';
import 'package:flutter_bill_splitter/features/home/presentation/widgets/recent_expense_item.dart';

/// Neumorphic Card container displaying "Recent Expenses".
class RecentExpensesCard extends StatelessWidget {
  final List<RecentExpense>? customExpenses;
  final void Function(RecentExpense expense)? onExpenseTap;

  const RecentExpensesCard({
    super.key,
    this.customExpenses,
    this.onExpenseTap,
  });

  static const List<RecentExpense> _defaultExpenses = [
    RecentExpense(
      id: 'default_1',
      title: 'Dinner at Sakali',
      category: 'Sakali',
      memberCount: 3,
      amount: 549.0,
      icon: Icons.restaurant_rounded,
      iconBgColor: Color(0xFFE8F8D8),
      iconColor: Color(0xFF284821),
    ),
    RecentExpense(
      id: 'default_2',
      title: 'Goa Trip Fuel',
      category: 'Trip',
      memberCount: 4,
      amount: 2800.0,
      icon: Icons.local_gas_station_rounded,
      iconBgColor: Color(0xFFFFECE0),
      iconColor: Color(0xFFC85A17),
    ),
    RecentExpense(
      id: 'default_3',
      title: 'Groceries',
      category: 'Home',
      memberCount: 2,
      amount: 620.0,
      icon: Icons.shopping_bag_outlined,
      iconBgColor: Color(0xFFE0F2FE),
      iconColor: Color(0xFF0284C7),
    ),
  ];

  static final Map<String, SplitActivity> _defaultActivityMap = {
    'default_1': SplitActivity(
      id: 'default_1',
      groupName: 'Dinner at Sakali',
      totalAmount: 549.0,
      sharePerPerson: 183.0,
      members: const [
        Friend(name: 'Vinit', phone: '+91 98765 11111'),
        Friend(name: 'Nishant', phone: '+91 98765 22222'),
        Friend(name: 'Saurabh', phone: '+91 98765 33333'),
      ],
      memberExpenses: const {'Vinit': 500.0, 'Nishant': 49.0, 'Saurabh': 0.0},
      settlements: const [
        SettlementTransaction(
          from: Friend(name: 'Saurabh', phone: '+91 98765 33333'),
          to: Friend(name: 'Vinit', phone: '+91 98765 11111'),
          amount: 183.0,
        ),
        SettlementTransaction(
          from: Friend(name: 'Nishant', phone: '+91 98765 22222'),
          to: Friend(name: 'Vinit', phone: '+91 98765 11111'),
          amount: 134.0,
        ),
      ],
      timestamp: DateTime.now(),
    ),
    'default_2': SplitActivity(
      id: 'default_2',
      groupName: 'Goa Trip Fuel',
      totalAmount: 2800.0,
      sharePerPerson: 700.0,
      members: const [
        Friend(name: 'Roshan', phone: '+91 98765 43210'),
        Friend(name: 'Vinit', phone: '+91 98765 11111'),
        Friend(name: 'Nishant', phone: '+91 98765 22222'),
        Friend(name: 'Saurabh', phone: '+91 98765 33333'),
      ],
      memberExpenses: const {'Vinit': 2800.0, 'Roshan': 0.0, 'Nishant': 0.0, 'Saurabh': 0.0},
      settlements: const [
        SettlementTransaction(
          from: Friend(name: 'Roshan', phone: '+91 98765 43210'),
          to: Friend(name: 'Vinit', phone: '+91 98765 11111'),
          amount: 700.0,
        ),
      ],
      timestamp: DateTime.now(),
    ),
    'default_3': SplitActivity(
      id: 'default_3',
      groupName: 'Groceries',
      totalAmount: 620.0,
      sharePerPerson: 310.0,
      members: const [
        Friend(name: 'Roshan', phone: '+91 98765 43210'),
        Friend(name: 'Vinit', phone: '+91 98765 11111'),
      ],
      memberExpenses: const {'Roshan': 310.0, 'Vinit': 310.0},
      settlements: const [],
      timestamp: DateTime.now(),
    ),
  };

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
            color: AppColors.textPrimary,
            letterSpacing: -0.3,
          ),
        ),
        const SizedBox(height: 14),

        // Neumorphic Container
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
                iconColor: const Color(0xFF284821),
              );
            }).toList();

            final displayExpenses = customExpenses ??
                (dynamicExpenses.isNotEmpty
                    ? [...dynamicExpenses, ..._defaultExpenses]
                    : _defaultExpenses);

            return FlutterNeumorphism(
              style: NeumorphicStyles.card(borderRadius: 24, depth: 6),
              width: double.infinity,
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
                          final activity = ActivityRepository.instance.activities.firstWhere(
                            (a) => a.id == displayExpenses[i].id,
                            orElse: () => _defaultActivityMap[displayExpenses[i].id] ?? SplitActivity(
                              id: displayExpenses[i].id,
                              groupName: displayExpenses[i].title,
                              totalAmount: displayExpenses[i].amount,
                              sharePerPerson: displayExpenses[i].amount / displayExpenses[i].memberCount,
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
