import 'package:flutter/material.dart';
import 'package:flutter_bill_splitter/core/theme/app_colors.dart';
import 'package:flutter_bill_splitter/features/activity/data/repositories/activity_repository.dart';
import 'package:flutter_bill_splitter/features/activity/domain/models/activity_display_item.dart';
import 'package:flutter_bill_splitter/features/activity/presentation/widgets/activity_section_card.dart';

/// Activity Tab displaying neumorphic activity feed with This Week and Last Week sections.
class ActivityTab extends StatelessWidget {
  final ActivityRepository? repository;

  const ActivityTab({
    super.key,
    this.repository,
  });

  static const List<ActivityDisplayItem> _defaultThisWeek = [
    ActivityDisplayItem(
      id: 'tw_1',
      title: 'Dinner at Sakali',
      memberCount: 3,
      totalAmount: 549.0,
      statusText: 'You get ₹317',
      statusColor: Color(0xFF16A34A),
      icon: Icons.restaurant_rounded,
      iconBgColor: Color(0xFFE8F8D8),
      iconColor: Color(0xFF284821),
      section: 'This Week',
      isSettlement: false,
    ),
    ActivityDisplayItem(
      id: 'tw_2',
      title: 'Groceries',
      memberCount: 2,
      totalAmount: 620.0,
      statusText: 'Settled',
      statusColor: AppColors.textSecondary,
      icon: Icons.shopping_bag_outlined,
      iconBgColor: Color(0xFFE0F2FE),
      iconColor: Color(0xFF0284C7),
      section: 'This Week',
      isSettlement: true,
    ),
    ActivityDisplayItem(
      id: 'tw_3',
      title: 'Goa Trip Fuel',
      memberCount: 4,
      totalAmount: 2800.0,
      statusText: 'You owe ₹700',
      statusColor: Color(0xFFDC2626),
      icon: Icons.local_gas_station_rounded,
      iconBgColor: Color(0xFFFFECE0),
      iconColor: Color(0xFFC85A17),
      section: 'This Week',
      isSettlement: false,
    ),
  ];

  static const List<ActivityDisplayItem> _defaultLastWeek = [
    ActivityDisplayItem(
      id: 'lw_1',
      title: 'Movie Night',
      memberCount: 3,
      totalAmount: 480.0,
      statusText: 'Settled',
      statusColor: AppColors.textSecondary,
      icon: Icons.local_movies_rounded,
      iconBgColor: Color(0xFFE0F2FE),
      iconColor: Color(0xFF0284C7),
      section: 'Last Week',
      isSettlement: true,
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
                      const ActivitySectionCard(
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
