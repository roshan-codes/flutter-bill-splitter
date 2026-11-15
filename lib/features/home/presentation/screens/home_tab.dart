import 'package:animations/animations.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_bill_splitter/core/animations/app_motion.dart';
import 'package:flutter_bill_splitter/core/animations/app_transitions.dart';
import 'package:flutter_bill_splitter/core/services/storage_service.dart';
import 'package:flutter_bill_splitter/core/theme/app_colors.dart';
import 'package:flutter_bill_splitter/features/activity/data/repositories/activity_repository.dart';
import 'package:flutter_bill_splitter/features/expenses/presentation/screens/add_expense_screen.dart';
import 'package:flutter_bill_splitter/features/expenses/presentation/screens/split_detail_screen.dart';
import 'package:flutter_bill_splitter/features/friends/data/repositories/friends_repository.dart';
import 'package:flutter_bill_splitter/features/friends/domain/models/friend.dart';
import 'package:flutter_bill_splitter/features/home/domain/models/recent_expense.dart';
import 'package:flutter_bill_splitter/features/home/presentation/widgets/active_story_card.dart';
import 'package:flutter_bill_splitter/features/home/presentation/widgets/home_header.dart';
import 'package:flutter_bill_splitter/features/home/presentation/widgets/recent_expenses_card.dart';
import 'package:flutter_bill_splitter/features/stories/data/repositories/story_repository.dart';
import 'package:flutter_bill_splitter/features/stories/domain/models/story.dart';
import 'package:flutter_bill_splitter/shared/widgets/empty_state_illustration.dart';
import 'package:flutter_bill_splitter/shared/widgets/platform_adaptive.dart';

/// The Home Tab screen with platform-adaptive UI (Material for Android, Cupertino for iOS).
/// Displays a high-fidelity empty state matching the UI mock when no stories or expenses exist,
/// or active stories and recent expenses when data is available.
class HomeTab extends StatefulWidget {
  final VoidCallback? onAddExpense;
  final void Function(String? title)? onAddExpenseWithTitle;
  final VoidCallback? onScanBill;
  final VoidCallback? onSettleUp;
  final VoidCallback? onBalanceTap;
  final double? youGetAmount;
  final double? youOweAmount;
  final List<RecentExpense>? customExpenses;

  const HomeTab({
    super.key,
    this.onAddExpense,
    this.onAddExpenseWithTitle,
    this.onScanBill,
    this.onSettleUp,
    this.onBalanceTap,
    this.youGetAmount,
    this.youOweAmount,
    this.customExpenses,
  });

  @override
  State<HomeTab> createState() => _HomeTabState();
}

class _HomeTabState extends State<HomeTab> {
  String _userName = 'Roshan';

  @override
  void initState() {
    super.initState();
    _loadUserName();
  }

  Future<void> _loadUserName() async {
    final savedName =
        await StorageService.instance.getString('user_profile_name');
    if (mounted && savedName != null && savedName.trim().isNotEmpty) {
      setState(() => _userName = savedName.trim().split(' ').first);
    }
  }

  void _navigateToCreateStory([String? initialTitle]) {
    if (initialTitle != null && widget.onAddExpenseWithTitle != null) {
      widget.onAddExpenseWithTitle!(initialTitle);
      return;
    }
    if (widget.onAddExpense != null) {
      widget.onAddExpense!();
      return;
    }
    Navigator.of(context).push(
      AppTransitions.sharedAxisRoute(
        type: SharedAxisTransitionType.vertical,
        duration: AppMotion.medium,
        builder: (context) => AddExpenseScreen(
          friends: FriendsRepository.instance.friends,
          groups: FriendsRepository.instance.groups,
          initialTitle: initialTitle,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isIOS = isIOSPlatform(context);

    return Scaffold(
      backgroundColor: isIOS ? AppColors.iosBackground : AppColors.background,
      body: SafeArea(
        bottom: false,
        child: SingleChildScrollView(
          physics: isIOS
              ? const BouncingScrollPhysics()
              : const ClampingScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 110),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header: Greeting, user name, waving hand, and circular bell icon button
              HomeHeader(
                userName: _userName,
                onNotificationPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('No new notifications'),
                      duration: Duration(seconds: 2),
                    ),
                  );
                },
              ),
              const SizedBox(height: 24),

              // Dynamic content: Empty state or Active Stories + Recent Expenses
              AnimatedBuilder(
                animation: Listenable.merge([
                  StoryRepository.instance,
                  ActivityRepository.instance,
                ]),
                builder: (context, _) {
                  final stories = StoryRepository.instance.stories;
                  final activities = ActivityRepository.instance.activities;
                  final hasCustomExpenses = widget.customExpenses != null &&
                      widget.customExpenses!.isNotEmpty;
                  final hasData = stories.isNotEmpty ||
                      activities.isNotEmpty ||
                      hasCustomExpenses;

                  if (!hasData) {
                    return _buildEmptyState(context);
                  }

                  return _buildPopulatedContent(context, stories, isIOS);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Empty state matching the left mockup screen when no stories or expenses are present.
  Widget _buildEmptyState(BuildContext context) {
    return Column(
      children: [
        const SizedBox(height: 38),

        // Illustration Box with squircle + purple group icon + sparkle rays
        const Center(
          child: EmptyStateIllustration(
            child: Icon(
              Icons.groups_rounded,
              size: 44,
              color: Color(0xFF5B4DFF),
            ),
          ),
        ),
        const SizedBox(height: 24),

        // Title
        Text(
          'Create your first story',
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
          'Start a trip, group expense or any\nshared spend to track and split easily.',
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
            onPressed: () => _navigateToCreateStory(),
          ),
        ),
        const SizedBox(height: 48),

        // Suggestion Categories Row (Trip Split, Group Expenses, Room Rent)
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            EmptyStateCategoryCard(
              label: 'Trip Split',
              icon: Transform.rotate(
                angle: -0.15,
                child: const Icon(
                  Icons.near_me_rounded,
                  color: Color(0xFF5B4DFF),
                  size: 24,
                ),
              ),
              iconBackgroundColor: const Color(0xFFEEEDFA),
              onTap: () => _navigateToCreateStory('Trip Split'),
            ),
            EmptyStateCategoryCard(
              label: 'Group\nExpenses',
              icon: const Icon(
                Icons.restaurant_rounded,
                color: Color(0xFF1E1E1E),
                size: 22,
              ),
              iconBackgroundColor: const Color(0xFFFFF4E5),
              onTap: () => _navigateToCreateStory('Group Expenses'),
            ),
            EmptyStateCategoryCard(
              label: 'Room Rent',
              icon: const Icon(
                Icons.home_outlined,
                color: Color(0xFF1E1E1E),
                size: 24,
              ),
              iconBackgroundColor: const Color(0xFFE8F8EE),
              onTap: () => _navigateToCreateStory('Room Rent'),
            ),
          ],
        ),
      ],
    );
  }

  /// Populated content when stories or expenses exist.
  Widget _buildPopulatedContent(
      BuildContext context, List<Story> stories, bool isIOS) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (stories.isNotEmpty) ...[
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Active Stories',
                style: GoogleFonts.manrope(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                  letterSpacing: -0.3,
                ),
              ),
              TextButton(
                onPressed: () => _navigateToCreateStory(),
                child: Text(
                  '+ New Story',
                  style: GoogleFonts.manrope(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: stories.length,
            separatorBuilder: (_, __) => const SizedBox(height: 14),
            itemBuilder: (context, index) {
              final story = stories[index];
              return AppTransitions.openContainer(
                context: context,
                borderRadius: BorderRadius.circular(24),
                openColor:
                    isIOS ? AppColors.iosBackground : AppColors.background,
                duration: AppMotion.medium,
                closedBuilder: (context, openContainer) {
                  return ActiveStoryCard(
                    story: story,
                    onTap: openContainer,
                  );
                },
                openBuilder: (context, closeContainer) {
                  return SplitDetailScreen(
                    groupName: story.title,
                    members: story.members
                        .map((m) => Friend(name: m.name, phone: ''))
                        .toList(),
                    story: story,
                  );
                },
              );
            },
          ),
          const SizedBox(height: 24),
        ],

        // Recent Expenses Card
        RecentExpensesCard(
          customExpenses: widget.customExpenses,
        ),
      ],
    );
  }
}
