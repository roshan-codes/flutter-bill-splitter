import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bill_splitter/core/theme/app_colors.dart';
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
      bottomNavigationBar: isIOS
          ? CupertinoTabBar(
              currentIndex: _currentIndex,
              onTap: _onNavTap,
              backgroundColor: AppColors.surface.withOpacity(0.96),
              activeColor: AppColors.primary,
              inactiveColor: AppColors.textTertiary,
              iconSize: 24,
              border: const Border(
                top: BorderSide(color: AppColors.border, width: 1.0),
              ),
              items: const [
                BottomNavigationBarItem(
                  icon: Icon(Icons.home_outlined),
                  activeIcon: Icon(Icons.home_rounded),
                  label: 'Home',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.access_time_rounded),
                  activeIcon: Icon(Icons.access_time_filled_rounded),
                  label: 'Activity',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.person_outline_rounded),
                  activeIcon: Icon(Icons.person_rounded),
                  label: 'Profile',
                ),
              ],
            )
          : Container(
              decoration: const BoxDecoration(
                border: Border(
                  top: BorderSide(color: AppColors.border, width: 1.0),
                ),
              ),
              child: NavigationBar(
                selectedIndex: _currentIndex,
                onDestinationSelected: _onNavTap,
                backgroundColor: AppColors.surface,
                surfaceTintColor: Colors.transparent,
                elevation: 0,
                indicatorColor: AppColors.surfaceSubtle,
                destinations: const [
                  NavigationDestination(
                    icon: Icon(Icons.home_outlined, color: AppColors.textSecondary),
                    selectedIcon: Icon(Icons.home_rounded, color: AppColors.primary),
                    label: 'Home',
                  ),
                  NavigationDestination(
                    icon: Icon(Icons.access_time_rounded, color: AppColors.textSecondary),
                    selectedIcon: Icon(Icons.access_time_filled_rounded, color: AppColors.primary),
                    label: 'Activity',
                  ),
                  NavigationDestination(
                    icon: Icon(Icons.person_outline_rounded, color: AppColors.textSecondary),
                    selectedIcon: Icon(Icons.person_rounded, color: AppColors.primary),
                    label: 'Profile',
                  ),
                ],
              ),
            ),
      ),
    );
  }
}
