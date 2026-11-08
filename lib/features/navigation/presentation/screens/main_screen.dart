import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bill_splitter/core/theme/app_colors.dart';
import 'package:flutter_bill_splitter/features/activity/presentation/screens/activity_tab.dart';
import 'package:flutter_bill_splitter/features/expenses/presentation/screens/add_expense_screen.dart';
import 'package:flutter_bill_splitter/features/friends/data/repositories/friends_repository.dart';
import 'package:flutter_bill_splitter/features/friends/presentation/screens/friends_tab.dart';
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
    'Friends',
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
        FriendsTab(
          friends: FriendsRepository.instance.friends,
          groups: FriendsRepository.instance.groups,
          onFriendAdded: (newFriend) {
            FriendsRepository.instance.addFriend(newFriend);
          },
          onGroupCreated: (newGroup) {
            FriendsRepository.instance.addGroup(newGroup);
          },
          onFriendDeleted: (index) {
            FriendsRepository.instance.removeFriendAt(index);
          },
          onGroupDeleted: (index) {
            FriendsRepository.instance.removeGroupAt(index);
          },
        ),
        const ActivityTab(),
        const ProfileTab(),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final hasCustomHeader = _currentIndex >= 0 && _currentIndex <= 3;
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
              backgroundColor: Colors.white.withOpacity(0.95),
              activeColor: const Color(0xFF1B4D20),
              inactiveColor: const Color(0xFF9CA3AF),
              iconSize: 25,
              items: const [
                BottomNavigationBarItem(
                  icon: Icon(Icons.home_outlined),
                  activeIcon: Icon(Icons.home_rounded),
                  label: 'Home',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.people_outline_rounded),
                  activeIcon: Icon(Icons.people_rounded),
                  label: 'Friends',
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
          : NavigationBar(
              selectedIndex: _currentIndex,
              onDestinationSelected: _onNavTap,
              backgroundColor: Colors.white,
              elevation: 2,
              indicatorColor: AppColors.primary.withOpacity(0.35),
              destinations: const [
                NavigationDestination(
                  icon: Icon(Icons.home_outlined),
                  selectedIcon: Icon(Icons.home_rounded, color: AppColors.primaryDeep),
                  label: 'Home',
                ),
                NavigationDestination(
                  icon: Icon(Icons.people_outline_rounded),
                  selectedIcon: Icon(Icons.people_rounded, color: AppColors.primaryDeep),
                  label: 'Friends',
                ),
                NavigationDestination(
                  icon: Icon(Icons.access_time_rounded),
                  selectedIcon: Icon(Icons.access_time_filled_rounded, color: AppColors.primaryDeep),
                  label: 'Activity',
                ),
                NavigationDestination(
                  icon: Icon(Icons.person_outline_rounded),
                  selectedIcon: Icon(Icons.person_rounded, color: AppColors.primaryDeep),
                  label: 'Profile',
                ),
              ],
            ),
      ),
    );
  }
}
