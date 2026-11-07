import 'package:flutter/material.dart';
import 'package:flutter_bill_splitter/core/theme/app_colors.dart';
import 'package:flutter_bill_splitter/features/activity/data/repositories/activity_repository.dart';
import 'package:flutter_bill_splitter/features/activity/domain/models/activity_display_item.dart';
import 'package:flutter_bill_splitter/features/activity/domain/models/split_activity.dart';
import 'package:flutter_bill_splitter/features/activity/presentation/widgets/activity_section_card.dart';
import 'package:flutter_bill_splitter/features/expenses/domain/models/settlement_transaction.dart';
import 'package:flutter_bill_splitter/features/friends/domain/models/friend.dart';

/// Activity Tab displaying neumorphic activity feed with This Week and Last Week sections.
class ActivityTab extends StatelessWidget {
  final ActivityRepository? repository;

  const ActivityTab({
    super.key,
    this.repository,
  });

  static const _friendVinit =
      Friend(name: 'Vinit', phone: '+91 98765 11111');
  static const _friendNishant =
      Friend(name: 'Nishant', phone: '+91 98765 22222');
  static const _friendSaurabh =
      Friend(name: 'Saurabh', phone: '+91 98765 33333');
  static const _friendRoshan =
      Friend(name: 'Roshan', phone: '+91 98765 43210');

  static final List<ActivityDisplayItem> _defaultThisWeek = [
    ActivityDisplayItem(
      id: 'tw_1',
      title: 'Dinner at Sakali',
      memberCount: 3,
      totalAmount: 549.0,
      statusText: 'You get ₹317',
      statusColor: const Color(0xFF16A34A),
      icon: Icons.restaurant_rounded,
      iconBgColor: const Color(0xFFE8F8D8),
      iconColor: const Color(0xFF284821),
      section: 'This Week',
      isSettlement: false,
      splitActivity: SplitActivity(
        id: 'tw_1',
        groupName: 'Dinner at Sakali',
        totalAmount: 549.0,
        sharePerPerson: 183.0,
        members: const [_friendVinit, _friendNishant, _friendSaurabh],
        memberExpenses: const {'Vinit': 500.0, 'Nishant': 49.0, 'Saurabh': 0.0},
        settlements: const [
          SettlementTransaction(from: _friendSaurabh, to: _friendVinit, amount: 183.0),
          SettlementTransaction(from: _friendNishant, to: _friendVinit, amount: 134.0),
        ],
        timestamp: DateTime.now().subtract(const Duration(days: 2)),
      ),
    ),
    ActivityDisplayItem(
      id: 'tw_2',
      title: 'Groceries',
      memberCount: 2,
      totalAmount: 620.0,
      statusText: 'Settled',
      statusColor: AppColors.textSecondary,
      icon: Icons.shopping_bag_outlined,
      iconBgColor: const Color(0xFFE0F2FE),
      iconColor: const Color(0xFF0284C7),
      section: 'This Week',
      isSettlement: true,
      splitActivity: SplitActivity(
        id: 'tw_2',
        groupName: 'Groceries',
        totalAmount: 620.0,
        sharePerPerson: 310.0,
        members: const [_friendRoshan, _friendVinit],
        memberExpenses: const {'Roshan': 310.0, 'Vinit': 310.0},
        settlements: const [],
        timestamp: DateTime.now().subtract(const Duration(days: 4)),
      ),
    ),
    ActivityDisplayItem(
      id: 'tw_3',
      title: 'Goa Trip Fuel',
      memberCount: 4,
      totalAmount: 2800.0,
      statusText: 'You owe ₹700',
      statusColor: const Color(0xFFDC2626),
      icon: Icons.local_gas_station_rounded,
      iconBgColor: const Color(0xFFFFECE0),
      iconColor: const Color(0xFFC85A17),
      section: 'This Week',
      isSettlement: false,
      splitActivity: SplitActivity(
        id: 'tw_3',
        groupName: 'Goa Trip Fuel',
        totalAmount: 2800.0,
        sharePerPerson: 700.0,
        members: const [_friendRoshan, _friendVinit, _friendNishant, _friendSaurabh],
        memberExpenses: const {'Vinit': 2800.0, 'Roshan': 0.0, 'Nishant': 0.0, 'Saurabh': 0.0},
        settlements: const [
          SettlementTransaction(from: _friendRoshan, to: _friendVinit, amount: 700.0),
          SettlementTransaction(from: _friendNishant, to: _friendVinit, amount: 700.0),
          SettlementTransaction(from: _friendSaurabh, to: _friendVinit, amount: 700.0),
        ],
        timestamp: DateTime.now().subtract(const Duration(days: 6)),
      ),
    ),
  ];

  static final List<ActivityDisplayItem> _defaultLastWeek = [
    ActivityDisplayItem(
      id: 'lw_1',
      title: 'Movie Night',
      memberCount: 3,
      totalAmount: 480.0,
      statusText: 'Settled',
      statusColor: AppColors.textSecondary,
      icon: Icons.local_movies_rounded,
      iconBgColor: const Color(0xFFE0F2FE),
      iconColor: const Color(0xFF0284C7),
      section: 'Last Week',
      isSettlement: true,
      splitActivity: SplitActivity(
        id: 'lw_1',
        groupName: 'Movie Night',
        totalAmount: 480.0,
        sharePerPerson: 160.0,
        members: const [_friendRoshan, _friendVinit, _friendNishant],
        memberExpenses: const {'Roshan': 160.0, 'Vinit': 160.0, 'Nishant': 160.0},
        settlements: const [],
        timestamp: DateTime.now().subtract(const Duration(days: 10)),
      ),
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final repo = repository ?? ActivityRepository.instance;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        bottom: false,
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 110),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Screen Header
              const Text(
                'Activity',
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.w900,
                  color: AppColors.textPrimary,
                  letterSpacing: -0.5,
                ),
              ),
              const SizedBox(height: 20),

              // Sections: This Week & Last Week with dynamic repository listener
              AnimatedBuilder(
                animation: repo,
                builder: (context, _) {
                  final recordedActivities = repo.activities;
                  final dynamicThisWeek = recordedActivities.map((act) {
                    final isSettled = act.settlements.isEmpty;
                    return ActivityDisplayItem(
                      id: act.id,
                      title: act.groupName,
                      memberCount: act.members.length,
                      totalAmount: act.totalAmount,
                      statusText: isSettled ? 'Settled' : 'You get ₹${act.sharePerPerson.toInt()}',
                      statusColor: isSettled ? AppColors.textSecondary : const Color(0xFF16A34A),
                      icon: Icons.receipt_long_rounded,
                      iconBgColor: const Color(0xFFE8F8D8),
                      iconColor: const Color(0xFF284821),
                      section: 'This Week',
                      isSettlement: isSettled,
                      splitActivity: act,
                    );
                  }).toList();

                  final thisWeekItems = [...dynamicThisWeek, ..._defaultThisWeek];

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Section 1: This Week
                      ActivitySectionCard(
                        title: 'This Week',
                        items: thisWeekItems,
                      ),
                      const SizedBox(height: 24),

                      // Section 2: Last Week
                      ActivitySectionCard(
                        title: 'Last Week',
                        items: _defaultLastWeek,
                      ),
                    ],
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
