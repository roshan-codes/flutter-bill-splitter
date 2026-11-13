import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:floating_pill_navbar/floating_pill_navbar.dart';
import 'package:flutter_bill_splitter/core/theme/app_colors.dart';
import 'package:flutter_bill_splitter/core/theme/app_radius.dart';
import 'package:flutter_bill_splitter/features/activity/presentation/screens/activity_tab.dart';
import 'package:flutter_bill_splitter/features/expenses/presentation/screens/add_expense_screen.dart';
import 'package:flutter_bill_splitter/features/friends/data/repositories/friends_repository.dart';
import 'package:flutter_bill_splitter/features/home/presentation/screens/home_tab.dart';
import 'package:flutter_bill_splitter/features/profile/presentation/screens/profile_tab.dart';
import 'package:flutter_bill_splitter/shared/widgets/platform_adaptive.dart';

/// Main scaffold with platform-adaptive navigation bar (Material for Android, Cupertino for iOS).
class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;

  final List<String> _tabTitles = const [
    'Home',
    'Activity',
    'Profile',
  ];

  @override
  void initState() {
    super.initState();
    FriendsRepository.instance.addListener(_onFriendsRepoChanged);
  }

  @override
  void dispose() {
    FriendsRepository.instance.removeListener(_onFriendsRepoChanged);
    super.dispose();
  }

  void _onFriendsRepoChanged() {
    if (mounted) setState(() {});
  }

  void _onNavTap(int index) {
    if (_currentIndex != index) {
      HapticFeedback.selectionClick();
    }
    setState(() => _currentIndex = index);
  }

  void _openAddExpenseScreen() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => AddExpenseScreen(
          friends: FriendsRepository.instance.friends,
          groups: FriendsRepository.instance.groups,
        ),
      ),
    );
  }

  Widget _buildBody() {
    return IndexedStack(
      index: _currentIndex,
      children: [
        HomeTab(
          onAddExpense: _openAddExpenseScreen,
        ),
        const ActivityTab(),
        const ProfileTab(),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final hasCustomHeader = _currentIndex >= 0 && _currentIndex <= 2;
    final isIOS = isIOSPlatform(context);

    return PopScope(
      canPop: _currentIndex == 0,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop && _currentIndex != 0) {
          setState(() => _currentIndex = 0);
        }
      },
      child: Scaffold(
        extendBody: true,
        backgroundColor: isIOS ? AppColors.iosBackground : AppColors.background,
        appBar: hasCustomHeader
            ? null
            : AppBar(
              title: Text(
                _tabTitles[_currentIndex],
                style: const TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
        body: _buildBody(),
        bottomNavigationBar: FloatingPillNavBar(
          selectedIndex: _currentIndex,
          onDestinationSelected: _onNavTap,
          backgroundColor: AppColors.surface,
          border: Border.all(color: AppColors.border, width: 1.0),
          borderRadius: BorderRadius.circular(AppRadius.pill),
          height: 68,
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          selectedItemPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          selectedIconSize: 22,
          unselectedIconSize: 22,
          selectedFontSize: 11,
          unselectedFontSize: 11,
          margin: const EdgeInsets.fromLTRB(16, 0, 16, 12),
          elevation: 0,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 16,
              offset: const Offset(0, 4),
            ),
          ],
          selectedBackgroundColor: AppColors.surfaceSubtle,
          selectedIconColor: AppColors.primary,
          selectedLabelColor: AppColors.primary,
          unselectedIconColor: AppColors.textTertiary,
          unselectedLabelColor: AppColors.textTertiary,
          selectedItemBorderRadius: BorderRadius.circular(AppRadius.pill),
          showLabels: true,
          destinations: const [
            FloatingPillDestination(
              icon: Icons.home_outlined,
              selectedIcon: Icons.home_rounded,
              label: 'Home',
            ),
            FloatingPillDestination(
              icon: Icons.access_time_rounded,
              selectedIcon: Icons.access_time_filled_rounded,
              label: 'Activity',
            ),
            FloatingPillDestination(
              icon: Icons.person_outline_rounded,
              selectedIcon: Icons.person_rounded,
              label: 'Profile',
            ),
          ],
          actionButton: FloatingPillAction(
            heroTag: 'add_story_hero_pill',
            icon: Icons.add_rounded,
            backgroundColor: AppColors.primary,
            foregroundColor: Colors.white,
            tooltip: 'Add Story',
            onPressed: () {
              HapticFeedback.lightImpact();
              _openAddExpenseScreen();
            },
          ),
        ),
      ),
    );
  }
}
