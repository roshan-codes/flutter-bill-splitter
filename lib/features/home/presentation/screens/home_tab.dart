import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_bill_splitter/core/animations/app_motion.dart';
import 'package:flutter_bill_splitter/core/animations/app_transitions.dart';
import 'package:flutter_bill_splitter/core/services/storage_service.dart';
import 'package:flutter_bill_splitter/core/theme/app_colors.dart';
import 'package:flutter_bill_splitter/features/expenses/presentation/screens/split_detail_screen.dart';
import 'package:flutter_bill_splitter/features/friends/domain/models/friend.dart';
import 'package:flutter_bill_splitter/features/home/domain/models/recent_expense.dart';
import 'package:flutter_bill_splitter/features/home/presentation/widgets/active_story_card.dart';
import 'package:flutter_bill_splitter/features/home/presentation/widgets/home_header.dart';
import 'package:flutter_bill_splitter/features/home/presentation/widgets/recent_expenses_card.dart';
import 'package:flutter_bill_splitter/features/stories/data/repositories/story_repository.dart';
import 'package:flutter_bill_splitter/shared/widgets/platform_adaptive.dart';

/// The Home Tab screen with platform-adaptive UI (Material for Android, Cupertino for iOS).
class HomeTab extends StatefulWidget {
  final VoidCallback? onAddExpense;
  final VoidCallback? onScanBill;
  final VoidCallback? onSettleUp;
  final VoidCallback? onBalanceTap;
  final double? youGetAmount;
  final double? youOweAmount;
  final List<RecentExpense>? customExpenses;

  const HomeTab({
    super.key,
    this.onAddExpense,
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
              // Header: Lightning badge, bell icon, Good Evening greeting
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

              // Active Stories Section
              AnimatedBuilder(
                animation: StoryRepository.instance,
                builder: (context, _) {
                  final stories = StoryRepository.instance.stories;
                  if (stories.isEmpty) return const SizedBox.shrink();

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
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
                          if (widget.onAddExpense != null)
                            TextButton(
                              onPressed: widget.onAddExpense,
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
                            openColor: isIOS
                                ? AppColors.iosBackground
                                : AppColors.background,
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
                  );
                },
              ),

              // Recent Expenses Card
              RecentExpensesCard(
                customExpenses: widget.customExpenses,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
