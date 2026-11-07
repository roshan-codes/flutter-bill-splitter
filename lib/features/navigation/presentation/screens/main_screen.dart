import 'package:flutter/material.dart';
import 'package:dark_glassmorphic_bottom_bar/dark_glassmorphic_bottom_bar.dart';
import 'package:flutter_bill_splitter/core/theme/app_colors.dart';
import 'package:flutter_bill_splitter/features/activity/presentation/screens/activity_tab.dart';
import 'package:flutter_bill_splitter/features/expenses/presentation/screens/add_expense_screen.dart';
import 'package:flutter_bill_splitter/features/friends/domain/models/friend.dart';
import 'package:flutter_bill_splitter/features/friends/domain/models/group.dart';
import 'package:flutter_bill_splitter/features/friends/presentation/screens/friends_tab.dart';

/// Main scaffold with bottom navigation bar and active tab rendering.
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

  final List<IconData> _tabIcons = const [
    Icons.home_outlined,
    Icons.people_outline_rounded,
    Icons.access_time_rounded,
    Icons.person_outline_rounded,
  ];

  final List<IconData> _tabActiveIcons = const [
    Icons.home_rounded,
    Icons.people_rounded,
    Icons.access_time_filled_rounded,
    Icons.person_rounded,
  ];

  final List<Friend> _friends = [];
  final List<Group> _groups = [];

  void _openAddExpenseScreen() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => AddExpenseScreen(
          friends: _friends,
          groups: _groups,
        ),
      ),
    );
  }

  Widget _buildDefaultTab(int index) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: const BoxDecoration(
              color: AppColors.primary,
              shape: BoxShape.circle,
            ),
            child: Icon(
              _tabActiveIcons[index],
              size: 40,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            _tabTitles[index],
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBody() {
    switch (_currentIndex) {
      case 1:
        return FriendsTab(
          friends: _friends,
          groups: _groups,
          onFriendAdded: (newFriend) {
            setState(() {
              _friends.add(newFriend);
            });
          },
          onGroupCreated: (newGroup) {
            setState(() {
              _groups.add(newGroup);
            });
          },
          onFriendDeleted: (index) {
            setState(() {
              _friends.removeAt(index);
            });
          },
          onGroupDeleted: (index) {
            setState(() {
              _groups.removeAt(index);
            });
          },
        );
      case 2:
        return const ActivityTab();
      default:
        return _buildDefaultTab(_currentIndex);
    }
  }

  @override
  Widget build(BuildContext context) {
    final hasCustomHeader = _currentIndex == 1 || _currentIndex == 2;

    return Scaffold(
      extendBody: true,
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
      bottomNavigationBar: DarkGlassmorphicBottomBar(
        selectedIndex: _currentIndex,
        onTabSelected: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        centerAction: DarkGlassActionItem(
          icon: Icons.add,
          onTap: _openAddExpenseScreen,
        ),
        items: List.generate(
          _tabTitles.length,
          (i) => DarkGlassNavItem(
            icon: _tabIcons[i],
            activeIcon: _tabActiveIcons[i],
            label: _tabTitles[i],
          ),
        ),
      ),
    );
  }
}
