import 'package:animations/animations.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_bill_splitter/core/animations/app_motion.dart';
import 'package:flutter_bill_splitter/core/animations/app_transitions.dart';
import 'package:flutter_bill_splitter/core/theme/app_colors.dart';
import 'package:flutter_bill_splitter/features/activity/data/repositories/activity_repository.dart';
import 'package:flutter_bill_splitter/features/activity/domain/models/activity_display_item.dart';
import 'package:flutter_bill_splitter/features/activity/presentation/widgets/activity_section_card.dart';
import 'package:flutter_bill_splitter/features/expenses/presentation/screens/add_expense_screen.dart';
import 'package:flutter_bill_splitter/features/friends/data/repositories/friends_repository.dart';
import 'package:flutter_bill_splitter/shared/widgets/empty_state_illustration.dart';
import 'package:flutter_bill_splitter/shared/widgets/platform_adaptive.dart';

/// Activity Tab displaying platform-adaptive activity feed with filter tabs,
/// or a high-fidelity empty state matching the UI mock when no records exist.
class ActivityTab extends StatefulWidget {
  final ActivityRepository? repository;
  final List<ActivityDisplayItem>? customItems;
  final VoidCallback? onCreateStory;

  const ActivityTab({
    super.key,
    this.repository,
    this.customItems,
    this.onCreateStory,
  });

  /// Sample items available for tests or preview.
  static const List<ActivityDisplayItem> sampleThisWeek = [
    ActivityDisplayItem(
      id: 'tw_1',
      title: 'Dinner at Sakali',
      memberCount: 3,
      totalAmount: 549.0,
      statusText: 'You get ₹317',
      statusColor: AppColors.success,
      icon: Icons.restaurant_rounded,
      iconBgColor: AppColors.surfaceSubtle,
      iconColor: AppColors.textPrimary,
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
      iconBgColor: AppColors.surfaceSubtle,
      iconColor: AppColors.textPrimary,
      section: 'This Week',
      isSettlement: true,
    ),
    ActivityDisplayItem(
      id: 'tw_3',
      title: 'Goa Trip Fuel',
      memberCount: 4,
      totalAmount: 2800.0,
      statusText: 'You owe ₹700',
      statusColor: AppColors.danger,
      icon: Icons.local_gas_station_rounded,
      iconBgColor: AppColors.dangerSoft,
      iconColor: AppColors.danger,
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
      iconBgColor: AppColors.surfaceSubtle,
      iconColor: AppColors.textPrimary,
      section: 'Last Week',
      isSettlement: true,
    ),
  ];

  @override
  State<ActivityTab> createState() => _ActivityTabState();
}

class _ActivityTabState extends State<ActivityTab> {
  int _selectedFilterIndex = 0;
  final List<String> _filters = const [
    'All',
    'Expenses',
    'Settlements',
    'Members',
  ];

  void _navigateToCreateStory() {
    if (widget.onCreateStory != null) {
      widget.onCreateStory!();
      return;
    }
    Navigator.of(context).push(
      AppTransitions.sharedAxisRoute(
        type: SharedAxisTransitionType.vertical,
        duration: AppMotion.medium,
        builder: (context) => AddExpenseScreen(
          friends: FriendsRepository.instance.friends,
          groups: FriendsRepository.instance.groups,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final repo = widget.repository ?? ActivityRepository.instance;
    final isIOS = isIOSPlatform(context);

    return Scaffold(
      backgroundColor: isIOS ? AppColors.iosBackground : AppColors.background,
      body: SafeArea(
        bottom: false,
        child: SingleChildScrollView(
          physics: isIOS
              ? const BouncingScrollPhysics()
              : const ClampingScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 120),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Screen Header Title
              Text(
                'Activity',
                style: GoogleFonts.manrope(
                  fontSize: 28,
                  fontWeight: FontWeight.w800,
                  color: AppColors.textPrimary,
                  letterSpacing: -0.5,
                ),
              ),
              const SizedBox(height: 16),

              // Filter Chips (shown when customItems is not set, matching screenshot mock)
              if (widget.customItems == null || widget.customItems!.isEmpty) ...[
                _buildFilterChips(),
                const SizedBox(height: 20),
              ],

              // Dynamic Activity Content
              AnimatedBuilder(
                animation: repo,
                builder: (context, _) {
                  // Custom items passed in tests or previews
                  if (widget.customItems != null &&
                      widget.customItems!.isNotEmpty) {
                    final sections = <String, List<ActivityDisplayItem>>{};
                    for (final item in widget.customItems!) {
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

                  // Empty State matching the right mockup screen
                  if (recordedActivities.isEmpty) {
                    return _buildEmptyState(context);
                  }

                  // Filter recorded activities based on selected chip
                  final dynamicItems = recordedActivities
                      .where((act) {
                        if (_selectedFilterIndex == 1) {
                          // Expenses only
                          return act.settlements.isNotEmpty;
                        } else if (_selectedFilterIndex == 2) {
                          // Settlements only
                          return act.settlements.isEmpty;
                        }
                        // 0: All, 3: Members
                        return true;
                      })
                      .map((act) {
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
                              : AppColors.success,
                          icon: Icons.receipt_long_rounded,
                          iconBgColor: isSettled
                              ? AppColors.surfaceSubtle
                              : AppColors.successSoft,
                          iconColor: isSettled
                              ? AppColors.textPrimary
                              : AppColors.success,
                          section: 'Recent Activity',
                          isSettlement: isSettled,
                          splitActivity: act,
                        );
                      })
                      .toList();

                  if (dynamicItems.isEmpty) {
                    return _buildEmptyState(context);
                  }

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

  /// Segmented filter pill chips (All, Expenses, Settlements, Members)
  Widget _buildFilterChips() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      physics: const BouncingScrollPhysics(),
      child: Row(
        children: List.generate(_filters.length, (index) {
          final isSelected = _selectedFilterIndex == index;
          return Padding(
            padding: EdgeInsets.only(right: index < _filters.length - 1 ? 8 : 0),
            child: GestureDetector(
              onTap: () {
                HapticFeedback.selectionClick();
                setState(() => _selectedFilterIndex = index);
              },
              child: AnimatedContainer(
                duration: AppMotion.fast,
                padding: const EdgeInsets.symmetric(
                  horizontal: 18,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: isSelected
                      ? const Color(0xFF111111)
                      : const Color(0xFFF4F4F5),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  _filters[index],
                  style: GoogleFonts.manrope(
                    fontSize: 13,
                    fontWeight:
                        isSelected ? FontWeight.w700 : FontWeight.w600,
                    color: isSelected
                        ? Colors.white
                        : const Color(0xFF18181B),
                    letterSpacing: -0.2,
                  ),
                ),
              ),
            ),
          );
        }),
      ),
    );
  }

  /// Empty state matching the right mockup screen when no activity records exist.
  Widget _buildEmptyState(BuildContext context) {
    return Column(
      children: [
        const SizedBox(height: 52),

        // Squircle with Checklist illustration + sparkle rays
        const Center(
          child: EmptyStateIllustration(
            child: ChecklistIllustration(
              color: Color(0xFF5B4DFF),
            ),
          ),
        ),
        const SizedBox(height: 24),

        // Title
        Text(
          'No activity yet',
          textAlign: TextAlign.center,
          style: GoogleFonts.manrope(
            fontSize: 22,
            fontWeight: FontWeight.w800,
            color: AppColors.textPrimary,
            letterSpacing: -0.4,
          ),
        ),
        const SizedBox(height: 10),

        // Description / Subtitle
        Text(
          'Your expenses, settlements and\nmember updates will appear here\nonce you create a story.',
          textAlign: TextAlign.center,
          style: GoogleFonts.manrope(
            fontSize: 14,
            fontWeight: FontWeight.w400,
            color: AppColors.textSecondary,
            height: 1.45,
          ),
        ),
        const SizedBox(height: 24),

        // Black Pill Action Button: + Create Story
        Center(
          child: EmptyStateCreateStoryButton(
            onPressed: _navigateToCreateStory,
          ),
        ),
      ],
    );
  }
}
