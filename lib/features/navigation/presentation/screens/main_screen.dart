import 'package:flutter/material.dart';
import 'package:neumorphic_glass_navbar/neumorphic_glass_navbar.dart';
import 'package:flutter_neumorphism_ui/flutter_neumorphism_ui.dart';
import 'package:flutter_bill_splitter/core/theme/app_colors.dart';
import 'package:flutter_bill_splitter/core/theme/neumorphic_styles.dart';
import 'package:flutter_bill_splitter/features/activity/presentation/screens/activity_tab.dart';
import 'package:flutter_bill_splitter/features/expenses/presentation/screens/add_expense_screen.dart';
import 'package:flutter_bill_splitter/features/friends/domain/models/friend.dart';
import 'package:flutter_bill_splitter/features/friends/domain/models/group.dart';
import 'package:flutter_bill_splitter/features/friends/presentation/screens/friends_tab.dart';
import 'package:flutter_bill_splitter/features/home/presentation/screens/home_tab.dart';

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

  int get _navbarIndex {
    switch (_currentIndex) {
      case 0:
        return 0;
      case 1:
        return 1;
      case 2:
        return 3;
      case 3:
        return 4;
      default:
        return 0;
    }
  }

  void _onNavTap(int navIndex) {
    switch (navIndex) {
      case 0:
        setState(() => _currentIndex = 0);
        break;
      case 1:
        setState(() => _currentIndex = 1);
        break;
      case 2:
        _openAddExpenseScreen();
        break;
      case 3:
        setState(() => _currentIndex = 2);
        break;
      case 4:
        setState(() => _currentIndex = 3);
        break;
    }
  }

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
          FlutterNeumorphism(
            style: NeumorphicStyles.circle(depth: 8),
            width: 90,
            height: 90,
            padding: EdgeInsets.zero,
            child: Icon(
              _tabActiveIcons[index],
              size: 44,
              color: AppColors.primaryDeep,
            ),
          ),
          const SizedBox(height: 20),
          Text(
            _tabTitles[index],
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w800,
              color: AppColors.textPrimary,
              letterSpacing: -0.3,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBody() {
    switch (_currentIndex) {
      case 0:
        return HomeTab(
          onAddExpense: _openAddExpenseScreen,
        );
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
    final hasCustomHeader = _currentIndex == 0 || _currentIndex == 1 || _currentIndex == 2;

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
      bottomNavigationBar: NeumorphicGlassNavbar(
        currentIndex: _navbarIndex,
        onTap: _onNavTap,
        height: 68,
        settings: const NeumorphicGlassNavbarSettings(
          tintColor: AppColors.background,
          opacity: 0.65,
          borderRadius: 28.0,
          iconSize: 20.0,
          maxBlurIntensity: 12.0,
          minBlurIntensity: 6.0,
          vibrancyIntensity: 0.35,
          enableSpecularHighlights: true,
          selectedOpacity: 1.0,
          adaptToTheme: true,
        ),
        items: [
          BottomNavigationBarItem(
            icon: Icon(_navbarIndex == 0 ? _tabActiveIcons[0] : _tabIcons[0]),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(_navbarIndex == 1 ? _tabActiveIcons[1] : _tabIcons[1]),
            label: 'Friends',
          ),
          const BottomNavigationBarItem(
            icon: Icon(
              Icons.add,
              color: AppColors.primaryDeep,
            ),
            label: 'Add',
          ),
          BottomNavigationBarItem(
            icon: Icon(_navbarIndex == 3 ? _tabActiveIcons[2] : _tabIcons[2]),
            label: 'Activity',
          ),
          BottomNavigationBarItem(
            icon: Icon(_navbarIndex == 4 ? _tabActiveIcons[3] : _tabIcons[3]),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}
