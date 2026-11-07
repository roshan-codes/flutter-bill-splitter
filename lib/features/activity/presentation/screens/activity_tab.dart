import 'package:flutter/material.dart';
import 'package:flutter_bill_splitter/core/theme/app_colors.dart';
import 'package:flutter_bill_splitter/core/theme/neumorphic_styles.dart';
import 'package:flutter_bill_splitter/features/activity/data/repositories/activity_repository.dart';
import 'package:flutter_bill_splitter/features/activity/domain/models/activity_display_item.dart';
import 'package:flutter_bill_splitter/features/activity/presentation/widgets/activity_section_card.dart';
import 'package:flutter_neumorphism_ui/flutter_neumorphism_ui.dart';

/// Activity Tab displaying neumorphic activity feed with real activity records or a clean empty state.
class ActivityTab extends StatelessWidget {
  final ActivityRepository? repository;
  final List<ActivityDisplayItem>? customItems;

  const ActivityTab({
    super.key,
    this.repository,
    this.customItems,
  });

  /// Sample items available for tests or preview.
  static const List<ActivityDisplayItem> sampleThisWeek = [
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

  static const List<ActivityDisplayItem> sampleLastWeek = [
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

              // Dynamic Activity Content
              AnimatedBuilder(
                animation: repo,
                builder: (context, _) {
                  if (customItems != null && customItems!.isNotEmpty) {
                    final sections = <String, List<ActivityDisplayItem>>{};
                    for (final item in customItems!) {
                      sections.putIfAbsent(item.section, () => []).add(item);
                    }
                    return Column(
                      children: [
                        for (final entry in sections.entries) ...[
                          ActivitySectionCard(
                            title: entry.key,
                            items: entry.value,
                          ),
                          const SizedBox(height: 24),
                        ],
                      ],
                    );
                  }

                  final recordedActivities = repo.activities;

                  if (recordedActivities.isEmpty) {
                    return Padding(
                      padding: const EdgeInsets.only(top: 40),
                      child: FlutterNeumorphism(
                        style: NeumorphicStyles.card(
                          borderRadius: 24,
                          depth: 4,
                        ),
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 40,
                        ),
                        child: Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Container(
                                width: 64,
                                height: 64,
                                decoration: BoxDecoration(
                                  color: const Color(0xFFE8F8D8),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: const Icon(
                                  Icons.receipt_long_rounded,
                                  size: 32,
                                  color: Color(0xFF284821),
                                ),
                              ),
                              const SizedBox(height: 18),
                              const Text(
                                'No Activity Yet',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w800,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                              const SizedBox(height: 6),
                              const Text(
                                'When you create and settle splits with friends,\nyour activity will appear here.',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                  color: AppColors.textSecondary,
                                  height: 1.35,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  }

                  final dynamicItems = recordedActivities.map((act) {
                    final isSettled = act.settlements.isEmpty;
                    return ActivityDisplayItem(
                      id: act.id,
                      title: act.groupName,
                      memberCount: act.members.length,
                      totalAmount: act.totalAmount,
                      statusText: isSettled
                          ? 'Settled'
                          : 'You get ₹${act.sharePerPerson.toInt()}',
                      statusColor: isSettled
                          ? AppColors.textSecondary
                          : const Color(0xFF16A34A),
                      icon: Icons.receipt_long_rounded,
                      iconBgColor: const Color(0xFFE8F8D8),
                      iconColor: const Color(0xFF284821),
                      section: 'Recent Activity',
                      isSettlement: isSettled,
                      splitActivity: act,
                    );
                  }).toList();

                  return ActivitySectionCard(
                    title: 'Recent Activity',
                    items: dynamicItems,
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
