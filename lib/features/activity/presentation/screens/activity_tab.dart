import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_bill_splitter/core/animations/app_motion.dart';
import 'package:flutter_bill_splitter/core/theme/app_colors.dart';
import 'package:flutter_bill_splitter/core/utils/expense_icon_resolver.dart';
import 'package:flutter_bill_splitter/features/activity/data/repositories/activity_repository.dart';
import 'package:flutter_bill_splitter/features/activity/domain/models/activity_display_item.dart';
import 'package:flutter_bill_splitter/features/activity/presentation/widgets/activity_section_card.dart';
import 'package:flutter_bill_splitter/features/stories/data/repositories/story_repository.dart';
import 'package:flutter_bill_splitter/shared/widgets/empty_state_illustration.dart';
import 'package:flutter_bill_splitter/shared/widgets/platform_adaptive.dart';

/// Activity Tab displaying platform-adaptive activity feed matching the mockup:
/// - Header: "Activity" title + circular filter button on right
/// - Horizontal filter chips: All, Expenses, Settlements
/// - Feed sections: Today, Yesterday, Recent Activity
/// - Empty state when no records exist
class ActivityTab extends StatefulWidget {
  final ActivityRepository? repository;
  final List<ActivityDisplayItem>? customItems;
  final VoidCallback? onCreateStory;
  final bool showMockupFeed;

  const ActivityTab({
    super.key,
    this.repository,
    this.customItems,
    this.onCreateStory,
    this.showMockupFeed = false,
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
  ];

  void _showFilterSheet(BuildContext context) {
    HapticFeedback.lightImpact();
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 32),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 36,
                height: 4,
                decoration: BoxDecoration(
                  color: const Color(0xFFE5E7EB),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Filter Activity',
              style: GoogleFonts.manrope(
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: const Color(0xFF111827),
              ),
            ),
            const SizedBox(height: 16),
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const Icon(Icons.calendar_today_outlined,
                  color: Color(0xFF111827)),
              title: Text('All Time',
                  style: GoogleFonts.manrope(fontWeight: FontWeight.w600)),
              trailing:
                  const Icon(Icons.check_rounded, color: Color(0xFF111827)),
              onTap: () => Navigator.of(ctx).pop(),
            ),
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading:
                  const Icon(Icons.place_outlined, color: Color(0xFF111827)),
              title: Text('Delhi Trip',
                  style: GoogleFonts.manrope(fontWeight: FontWeight.w600)),
              trailing:
                  const Icon(Icons.check_rounded, color: Color(0xFF111827)),
              onTap: () => Navigator.of(ctx).pop(),
            ),
          ],
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
              // Screen Header: "Activity" + Circular Filter Button
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    'Activity',
                    style: GoogleFonts.manrope(
                      fontSize: 28,
                      fontWeight: FontWeight.w800,
                      color: AppColors.textPrimary,
                      letterSpacing: -0.5,
                    ),
                  ),
                  GestureDetector(
                    onTap: () => _showFilterSheet(context),
                    child: Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white,
                        border: Border.all(
                            color: const Color(0xFFE5E7EB), width: 1.0),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.04),
                            blurRadius: 6,
                            offset: const Offset(0, 1),
                          ),
                        ],
                      ),
                      child: const Center(
                        child: Icon(
                          Icons.filter_alt_outlined,
                          size: 22,
                          color: Color(0xFF111827),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Filter Chips (shown when customItems is not set)
              if (widget.customItems == null || widget.customItems!.isEmpty) ...[
                _buildFilterChips(),
                const SizedBox(height: 20),
              ],

              // Dynamic Activity Content
              AnimatedBuilder(
                animation: repo,
                builder: (context, _) {
                  // 1. Custom items passed in tests or previews
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

                  // 2. Real dynamic recorded activities (if available)
                  if (recordedActivities.isNotEmpty) {
                    final dynamicItems = recordedActivities
                        .where((act) {
                          final isSettlement = act.type == 'settlement' ||
                              act.settlements.isNotEmpty;
                          if (_selectedFilterIndex == 1) {
                            // Expenses tab: only expenses
                            return !isSettlement;
                          } else if (_selectedFilterIndex == 2) {
                            // Settlements tab: only settlements
                            return isSettlement;
                          }
                          return true; // All
                        })
                        .map((act) {
                          final isSettlement = act.type == 'settlement' ||
                              act.settlements.isNotEmpty;

                          // 1. Resolve Expense Title vs Story Name
                          String displayTitle = (act.expenseTitle != null &&
                                  act.expenseTitle!.isNotEmpty)
                              ? act.expenseTitle!
                              : '';
                          String storyName = act.groupName;

                          if (displayTitle.isEmpty) {
                            // Search StoryRepository for matching expense by ID
                            for (final story in StoryRepository.instance.stories) {
                              final matchById = story.expenses
                                  .where((e) => e.expenseId == act.id)
                                  .firstOrNull;
                              if (matchById != null &&
                                  matchById.title.isNotEmpty &&
                                  !matchById.title.startsWith('Expense by ')) {
                                displayTitle = matchById.title;
                                storyName = story.title;
                                break;
                              }
                            }
                          }

                          if (displayTitle.isEmpty) {
                            displayTitle = storyName;
                          }

                          // 2. Subtitle: show story name if title is expense name, else members count
                          final String subtitle;
                          if (displayTitle.toLowerCase().trim() !=
                              storyName.toLowerCase().trim()) {
                            subtitle =
                                '$storyName  •  ${act.members.length} members';
                          } else {
                            subtitle = '${act.members.length} members';
                          }

                          // 3. Status text, status color, and icons
                          final String statusText;
                          final Color statusColor;
                          final IconData icon;
                          final Color iconBg;
                          final Color iconColor;

                          if (isSettlement) {
                            statusText = 'Settled';
                            statusColor = const Color(0xFF16A34A);
                            icon = Icons.check_circle_outline_rounded;
                            iconBg = const Color(0xFFE8F8EE);
                            iconColor = const Color(0xFF16A34A);
                          } else {
                            // Find primary payer
                            String? payer;
                            if (act.memberExpenses.isNotEmpty) {
                              final sorted = act.memberExpenses.entries.toList()
                                ..sort((x, y) => y.value.compareTo(x.value));
                              if (sorted.isNotEmpty && sorted.first.value > 0) {
                                payer = sorted.first.key;
                              }
                            }

                            // Check if story is settled
                            final story = StoryRepository.instance.stories
                                .where((s) =>
                                    s.title.trim().toLowerCase() ==
                                    storyName.trim().toLowerCase())
                                .firstOrNull;
                            final isStorySettled = story?.status == 'settled';

                            if (isStorySettled) {
                              statusText = 'Settled';
                              statusColor = AppColors.textSecondary;
                            } else if (payer != null && payer.isNotEmpty) {
                              final isMe =
                                  payer.toLowerCase().trim() == 'you' ||
                                      payer.toLowerCase().contains('(you)');
                              statusText = isMe ? 'You paid' : 'Paid by $payer';
                              statusColor = isMe
                                  ? const Color(0xFF16A34A)
                                  : AppColors.textSecondary;
                            } else {
                              statusText = 'Split';
                              statusColor = AppColors.textSecondary;
                            }

                            icon = ExpenseIconResolver.resolveIcon(displayTitle);
                            iconBg = ExpenseIconResolver.resolveBgColor(icon);
                            iconColor =
                                ExpenseIconResolver.resolveIconColor(icon);
                          }

                          return ActivityDisplayItem(
                            id: act.id,
                            title: displayTitle,
                            subtitle: subtitle,
                            memberCount: act.members.length,
                            totalAmount: act.totalAmount,
                            statusText: statusText,
                            statusColor: statusColor,
                            icon: icon,
                            iconBgColor: iconBg,
                            iconColor: iconColor,
                            section: 'Recent Activity',
                            isSettlement: isSettlement,
                            splitActivity: act,
                          );
                        })
                        .toList();

                    if (dynamicItems.isNotEmpty) {
                      return ActivitySectionCard(
                        title: 'Recent Activity',
                        items: dynamicItems,
                      );
                    }
                  }

                  // 3. Mockup Feed matching media_1794729268088_39ebec66.jpg
                  if (widget.showMockupFeed) {
                    final filtered =
                        ActivityDisplayItem.mockupFeed.where((it) {
                      if (_selectedFilterIndex == 1) {
                        return it.type == 'expense';
                      }
                      if (_selectedFilterIndex == 2) {
                        return it.type == 'settlement';
                      }
                      return true; // 0: All
                    }).toList();

                    final sections = <String, List<ActivityDisplayItem>>{};
                    for (final item in filtered) {
                      sections.putIfAbsent(item.section, () => []).add(item);
                    }

                    return Column(
                      children: [
                        for (final entry in sections.entries) ...[
                          ActivitySectionCard(
                            title: entry.key,
                            items: entry.value,
                          ),
                          const SizedBox(height: 20),
                        ],
                      ],
                    );
                  }

                  // 4. Empty State when no activity exists and mockup feed is not requested
                  return _buildEmptyState(context);
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
            padding:
                EdgeInsets.only(right: index < _filters.length - 1 ? 8 : 0),
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

  /// Empty state matching test expectations when no activity records exist.
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
      ],
    );
  }
}
