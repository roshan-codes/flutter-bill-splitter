import 'package:flutter/material.dart';
import 'package:flutter_bill_splitter/core/theme/app_colors.dart';
import 'package:flutter_bill_splitter/features/activity/data/repositories/activity_repository.dart';
import 'package:flutter_bill_splitter/features/activity/presentation/widgets/activity_card.dart';
import 'package:flutter_bill_splitter/shared/widgets/empty_state_view.dart';

/// Activity Tab displaying all historical recorded splits.
class ActivityTab extends StatelessWidget {
  final ActivityRepository? repository;

  const ActivityTab({
    super.key,
    this.repository,
  });

  @override
  Widget build(BuildContext context) {
    final repo = repository ?? ActivityRepository.instance;

    return SafeArea(
      bottom: false,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header matching Friends tab style
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Activity',
                  style: TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.w800,
                    color: AppColors.textPrimary,
                    letterSpacing: -0.5,
                  ),
                ),
                ListenableBuilder(
                  listenable: repo,
                  builder: (context, _) {
                    final count = repo.activities.length;
                    if (count == 0) return const SizedBox.shrink();
                    return Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppColors.primaryLight,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        '$count split${count > 1 ? 's' : ''}',
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w800,
                          color: AppColors.primaryDeep,
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
          const Divider(height: 1, color: AppColors.border),

          // Activity List or Empty State
          Expanded(
            child: ListenableBuilder(
              listenable: repo,
              builder: (context, _) {
                final activities = repo.activities;

                if (activities.isEmpty) {
                  return const EmptyStateView(
                    icon: Icons.receipt_long_outlined,
                    title: 'No Activity Yet',
                    subtitle: 'Whenever a split is confirmed, it will be recorded and shown here.',
                  );
                }

                return ListView.separated(
                  padding: const EdgeInsets.fromLTRB(20, 16, 20, 110),
                  itemCount: activities.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 14),
                  itemBuilder: (context, index) {
                    final activity = activities[index];
                    return ActivityCard(activity: activity);
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

