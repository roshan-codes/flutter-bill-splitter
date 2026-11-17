import 'package:animations/animations.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_bill_splitter/core/animations/app_motion.dart';
import 'package:flutter_bill_splitter/core/animations/app_transitions.dart';
import 'package:flutter_bill_splitter/core/services/storage_service.dart';
import 'package:flutter_bill_splitter/core/services/supabase_service.dart';
import 'package:flutter_bill_splitter/core/theme/app_colors.dart';
import 'package:flutter_bill_splitter/features/activity/data/repositories/activity_repository.dart';
import 'package:flutter_bill_splitter/features/expenses/presentation/screens/split_detail_screen.dart';
import 'package:flutter_bill_splitter/features/friends/domain/models/friend.dart';
import 'package:flutter_bill_splitter/features/home/domain/models/recent_expense.dart';
import 'package:flutter_bill_splitter/features/home/presentation/widgets/active_story_card.dart';
import 'package:flutter_bill_splitter/features/home/presentation/widgets/home_header.dart';
import 'package:flutter_bill_splitter/features/home/presentation/widgets/recent_expenses_card.dart';
import 'package:flutter_bill_splitter/features/profile/presentation/screens/profile_tab.dart';
import 'package:flutter_bill_splitter/features/stories/data/repositories/story_repository.dart';
import 'package:flutter_bill_splitter/features/stories/domain/models/story.dart';
import 'package:flutter_bill_splitter/features/stories/presentation/screens/create_story_screen.dart';
import 'package:flutter_bill_splitter/shared/widgets/empty_state_illustration.dart';
import 'package:flutter_bill_splitter/shared/widgets/platform_adaptive.dart';

/// The Home Tab screen with platform-adaptive UI (Material for Android, Cupertino for iOS).
/// Displays a high-fidelity empty state matching the UI mock when no stories or expenses exist,
/// or active stories and recent expenses when data is available.
class HomeTab extends StatefulWidget {
  final VoidCallback? onCreateStory;
  final VoidCallback? onAddExpense;
  final void Function(String? title)? onAddExpenseWithTitle;
  final VoidCallback? onScanBill;
  final VoidCallback? onSettleUp;
  final VoidCallback? onBalanceTap;
  final double? youGetAmount;
  final double? youOweAmount;
  final List<RecentExpense>? customExpenses;
  final String? userName;
  final VoidCallback? onOpenProfile;
  final VoidCallback? onNavigateToActivity;

  const HomeTab({
    super.key,
    this.onCreateStory,
    this.onAddExpense,
    this.onAddExpenseWithTitle,
    this.onScanBill,
    this.onSettleUp,
    this.onBalanceTap,
    this.youGetAmount,
    this.youOweAmount,
    this.customExpenses,
    this.userName,
    this.onOpenProfile,
    this.onNavigateToActivity,
  });

  @override
  State<HomeTab> createState() => _HomeTabState();
}

class _HomeTabState extends State<HomeTab> {
  String? _resolvedName;
  int? _avatarIndex;
  String? _avatarUrl;

  String get _displayName {
    if (widget.userName != null && widget.userName!.trim().isNotEmpty) {
      return widget.userName!.trim();
    }
    if (_resolvedName != null && _resolvedName!.isNotEmpty) {
      return _resolvedName!;
    }
    return 'Friend';
  }

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    final googleName = SupabaseService.userDisplayName;
    final savedName =
        await StorageService.instance.getString('user_profile_name');
    final nameToUse = googleName ?? savedName;

    final savedAvatarIndex =
        await StorageService.instance.getInt('user_profile_avatar_index') ??
            SupabaseService.userAvatarIndex;
    final savedAvatarUrl =
        await StorageService.instance.getString('user_profile_avatar_url') ??
            SupabaseService.userAvatarUrl;

    if (mounted) {
      setState(() {
        if (nameToUse != null && nameToUse.trim().isNotEmpty) {
          _resolvedName = nameToUse.trim().split(' ').first;
        }
        _avatarIndex = savedAvatarIndex;
        _avatarUrl = savedAvatarUrl;
      });
    }
  }

  void _navigateToCreateStory([String? initialTitle]) {
    if (initialTitle != null && widget.onAddExpenseWithTitle != null) {
      widget.onAddExpenseWithTitle!(initialTitle);
      return;
    }
    if (widget.onCreateStory != null) {
      widget.onCreateStory!();
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
        builder: (context) => CreateStoryScreen(
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
        child: RefreshIndicator(
          onRefresh: () => StoryRepository.instance.syncAllFromSupabase(),
          color: AppColors.primary,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(
                parent: BouncingScrollPhysics()),
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 150),
            child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header: Greeting, user name, waving hand, and profile avatar button
              HomeHeader(
                userName: _displayName,
                avatarIndex: _avatarIndex,
                avatarUrl: _avatarUrl,
                onNotificationPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('No new notifications'),
                      duration: Duration(seconds: 2),
                    ),
                  );
                },
                onProfilePressed: () {
                  if (widget.onOpenProfile != null) {
                    widget.onOpenProfile!();
                  } else {
                    Navigator.of(context).push(
                      AppTransitions.sharedAxisRoute(
                        type: SharedAxisTransitionType.horizontal,
                        duration: AppMotion.medium,
                        builder: (context) => const ProfileTab(),
                      ),
                    ).then((_) {
                      _loadUserData();
                    });
                  }
                },
              ),
              const SizedBox(height: 12),

              // Dynamic content: Empty state or Active Stories + Recent Expenses
              AnimatedBuilder(
                animation: Listenable.merge([
                  StoryRepository.instance,
                  ActivityRepository.instance,
                ]),
                builder: (context, _) {
                  final stories = StoryRepository.instance.stories;
                  final activeTitles = stories
                      .map((s) => s.title.trim().toLowerCase())
                      .toSet();
                  final activities = ActivityRepository.instance.activities
                      .where((a) => activeTitles
                          .contains(a.groupName.trim().toLowerCase()))
                      .toList();
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
    ),
    );
  }

  /// Empty state matching the left mockup screen when no stories or expenses are present.
  Widget _buildEmptyState(BuildContext context) {
    return Column(
      children: [
        const SizedBox(height: 24),

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
    // Deduplicate stories by storyId and normalized title as UI safeguard
    final List<Story> uniqueStories = [];
    final Set<String> seenIds = {};
    final Set<String> seenTitles = {};
    for (final s in stories) {
      final normTitle = s.title.toLowerCase().trim();
      if (!seenIds.contains(s.storyId) &&
          (normTitle.isEmpty || !seenTitles.contains(normTitle))) {
        seenIds.add(s.storyId);
        if (normTitle.isNotEmpty) seenTitles.add(normTitle);
        uniqueStories.add(s);
      }
    }

    final activeStories = uniqueStories
        .where((s) => s.status.toLowerCase() != 'inactive')
        .toList();
    final pastStories = uniqueStories
        .where((s) => s.status.toLowerCase() == 'inactive')
        .toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (activeStories.isNotEmpty) ...[
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Active Stories',
                style: GoogleFonts.manrope(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                  letterSpacing: -0.4,
                ),
              ),
              TextButton(
                onPressed: () => _navigateToCreateStory(),
                style: TextButton.styleFrom(
                  padding: EdgeInsets.zero,
                  minimumSize: Size.zero,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                child: Text(
                  '+ New Story',
                  style: GoogleFonts.manrope(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          for (int index = 0; index < activeStories.length; index++) ...[
            AppTransitions.openContainer(
              context: context,
              borderRadius: BorderRadius.circular(24),
              openColor:
                  isIOS ? AppColors.iosBackground : AppColors.background,
              duration: AppMotion.medium,
              closedBuilder: (context, openContainer) {
                return ActiveStoryCard(
                  story: activeStories[index],
                  onTap: openContainer,
                );
              },
              openBuilder: (context, closeContainer) {
                return SplitDetailScreen(
                  groupName: activeStories[index].title,
                  members: activeStories[index]
                      .members
                      .map((m) => Friend(name: m.name, phone: ''))
                      .toList(),
                  story: activeStories[index],
                );
              },
            ),
            if (index < activeStories.length - 1) const SizedBox(height: 14),
          ],
          const SizedBox(height: 28),
        ] else if (uniqueStories.isNotEmpty) ...[
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Active Stories',
                style: GoogleFonts.manrope(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                  letterSpacing: -0.4,
                ),
              ),
              TextButton(
                onPressed: () => _navigateToCreateStory(),
                style: TextButton.styleFrom(
                  padding: EdgeInsets.zero,
                  minimumSize: Size.zero,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                child: Text(
                  '+ New Story',
                  style: GoogleFonts.manrope(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'No active stories right now',
            style: GoogleFonts.manrope(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 24),
        ],

        // Past Story / Past Stories block
        if (pastStories.isNotEmpty) ...[
          Text(
            pastStories.length == 1 ? 'Past Story' : 'Past Stories',
            style: GoogleFonts.manrope(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
              letterSpacing: -0.4,
            ),
          ),
          const SizedBox(height: 14),
          if (pastStories.length == 1) ...[
            AppTransitions.openContainer(
              context: context,
              borderRadius: BorderRadius.circular(24),
              openColor:
                  isIOS ? AppColors.iosBackground : AppColors.background,
              duration: AppMotion.medium,
              closedBuilder: (context, openContainer) {
                return ActiveStoryCard(
                  story: pastStories.first,
                  onTap: openContainer,
                );
              },
              openBuilder: (context, closeContainer) {
                return SplitDetailScreen(
                  groupName: pastStories.first.title,
                  members: pastStories.first
                      .members
                      .map((m) => Friend(name: m.name, phone: ''))
                      .toList(),
                  story: pastStories.first,
                );
              },
            ),
          ] else ...[
            SizedBox(
              height: 265,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                physics: const BouncingScrollPhysics(),
                itemCount: pastStories.length,
                separatorBuilder: (_, __) => const SizedBox(width: 14),
                itemBuilder: (context, index) {
                  final story = pastStories[index];
                  return SizedBox(
                    width: 300,
                    child: AppTransitions.openContainer(
                      context: context,
                      borderRadius: BorderRadius.circular(24),
                      openColor: isIOS
                          ? AppColors.iosBackground
                          : AppColors.background,
                      duration: AppMotion.medium,
                      closedBuilder: (context, openContainer) {
                        return ActiveStoryCard(
                          story: story,
                          width: 300,
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
                    ),
                  );
                },
              ),
            ),
          ],
          const SizedBox(height: 28),
        ],

        // Recent Expenses Card
        RecentExpensesCard(
          customExpenses: widget.customExpenses,
          onNavigateToActivity: widget.onNavigateToActivity,
        ),
      ],
    );
  }
}
