import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:neumorphic_glass_navbar/neumorphic_glass_navbar.dart';
import 'package:flutter_neumorphism_ui/flutter_neumorphism_ui.dart';
import 'package:flutter_bill_splitter/core/theme/app_colors.dart';
import 'package:flutter_bill_splitter/core/theme/neumorphic_styles.dart';
import 'package:flutter_bill_splitter/features/activity/presentation/screens/activity_tab.dart';
import 'package:flutter_bill_splitter/features/expenses/presentation/screens/add_expense_screen.dart';
import 'package:flutter_bill_splitter/features/friends/data/repositories/friends_repository.dart';
import 'package:flutter_bill_splitter/features/friends/presentation/screens/friends_tab.dart';
import 'package:flutter_bill_splitter/features/home/presentation/screens/home_tab.dart';
import 'package:flutter_bill_splitter/features/profile/presentation/screens/profile_tab.dart';

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
        );
      case 2:
        return const ActivityTab();
      case 3:
        return const ProfileTab();
      default:
        return _buildDefaultTab(_currentIndex);
    }
  }

  @override
  Widget build(BuildContext context) {
    final hasCustomHeader = _currentIndex >= 0 && _currentIndex <= 3;

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
        currentIndex: _currentIndex,
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
            icon: Icon(_currentIndex == 0 ? _tabActiveIcons[0] : _tabIcons[0]),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(_currentIndex == 1 ? _tabActiveIcons[1] : _tabIcons[1]),
            label: 'Friends',
          ),
          BottomNavigationBarItem(
            icon: Icon(_currentIndex == 2 ? _tabActiveIcons[2] : _tabIcons[2]),
            label: 'Activity',
          ),
          BottomNavigationBarItem(
            icon: Icon(_currentIndex == 3 ? _tabActiveIcons[3] : _tabIcons[3]),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}
