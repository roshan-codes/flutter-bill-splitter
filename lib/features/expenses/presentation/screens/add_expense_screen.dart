import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_bill_splitter/core/theme/app_colors.dart';
import 'package:flutter_bill_splitter/core/theme/app_radius.dart';
import 'package:flutter_bill_splitter/features/expenses/presentation/screens/split_detail_screen.dart';
import 'package:flutter_bill_splitter/features/expenses/presentation/widgets/expense_title_input.dart';
import 'package:flutter_bill_splitter/features/expenses/presentation/widgets/friend_selection_tile.dart';
import 'package:flutter_bill_splitter/features/expenses/presentation/widgets/friends_groups_toggle.dart';
import 'package:flutter_bill_splitter/features/expenses/presentation/widgets/group_selection_tile.dart';
import 'package:flutter_bill_splitter/features/friends/domain/models/friend.dart';
import 'package:flutter_bill_splitter/features/friends/domain/models/group.dart';
import 'package:flutter_bill_splitter/shared/widgets/platform_adaptive.dart';

/// Full-screen view for Adding an Expense & Splitting between friends or groups,
/// matching platform design (Material for Android, Cupertino for iOS):
/// Expense Title input, Friends/Groups toggle, Search bar, individual selection tiles, and fixed Continue button.
class AddExpenseScreen extends StatefulWidget {
  final List<Friend> friends;
  final List<Group> groups;

  const AddExpenseScreen({
    super.key,
    required this.friends,
    required this.groups,
  });

  /// Sample friends list for preview or fallback.
  static const List<Friend> sampleFriends = [
    Friend(name: 'Vinit', phone: '+91 98765 11111'),
    Friend(name: 'Nishant', phone: '+91 98765 22222'),
    Friend(name: 'Saurabh', phone: '+91 98765 33333'),
    Friend(name: 'Harshal', phone: '+91 98765 44444'),
  ];

  @override
  State<AddExpenseScreen> createState() => _AddExpenseScreenState();
}

class _AddExpenseScreenState extends State<AddExpenseScreen> {
  final _expenseTitleController = TextEditingController();
  final _searchController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  int _selectedTab = 0; // 0: Friends, 1: Groups
  final Set<int> _selectedFriendIndices = {};
  int? _selectedGroupIndex;
  String _searchQuery = '';

  List<Friend> get _effectiveFriends {
    return widget.friends.isNotEmpty
        ? widget.friends
        : (widget.groups.isEmpty ? AddExpenseScreen.sampleFriends : <Friend>[]);
  }

  List<Friend> get filteredFriends {
    if (_searchQuery.isEmpty) return _effectiveFriends;
    return _effectiveFriends
        .where((f) =>
            f.name.toLowerCase().contains(_searchQuery) ||
            f.phone.toLowerCase().contains(_searchQuery))
        .toList();
  }

  List<Group> get filteredGroups {
    if (_searchQuery.isEmpty) return widget.groups;
    return widget.groups
        .where((g) => g.name.toLowerCase().contains(_searchQuery))
        .toList();
  }

  @override
  void dispose() {
    _expenseTitleController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _onGroupSelected(int index) {
    HapticFeedback.selectionClick();
    setState(() {
      _selectedGroupIndex = index;
      final selectedGroup = filteredGroups[index];
      if (_expenseTitleController.text.trim().isEmpty) {
        _expenseTitleController.text = selectedGroup.name;
      }
      _selectedFriendIndices.clear();
      for (final m in selectedGroup.members) {
        final existingIdx = _effectiveFriends.indexWhere(
            (f) => f.name.toLowerCase() == m.name.toLowerCase());
        if (existingIdx != -1) {
          _selectedFriendIndices.add(existingIdx);
        }
      }
    });
  }

  void _onContinuePressed() {
    HapticFeedback.lightImpact();
    if (_formKey.currentState?.validate() ?? false) {
      if (_selectedFriendIndices.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Please select at least one friend or group member to split with'),
            behavior: SnackBarBehavior.floating,
          ),
        );
        return;
      }

      final chosenFriends = _selectedFriendIndices
          .map((i) => _effectiveFriends[i])
          .toList();

      final title = _expenseTitleController.text.trim().isNotEmpty
          ? _expenseTitleController.text.trim()
          : 'Shared Expense';

      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => SplitDetailScreen(
            groupName: title,
            members: chosenFriends,
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isIOS = isIOSPlatform(context);

    return Scaffold(
      backgroundColor: isIOS ? AppColors.iosBackground : AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        leadingWidth: 64,
        leading: Padding(
          padding: const EdgeInsets.only(left: 16),
          child: Center(
            child: PlatformBackButton(
              onPressed: () {
                HapticFeedback.lightImpact();
                Navigator.of(context).pop();
              },
            ),
          ),
        ),
        title: const Text(
          'Add & Split Expense',
          style: TextStyle(
            color: AppColors.textPrimary,
            fontSize: 20,
            fontWeight: FontWeight.w800,
            letterSpacing: -0.3,
          ),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          physics: isIOS ? const BouncingScrollPhysics() : const ClampingScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 1. Expense Title Input
                ExpenseTitleInput(
                  controller: _expenseTitleController,
                ),
                const SizedBox(height: 18),

                // 2. Friends vs Groups Segmented Toggle
                FriendsGroupsToggle(
                  selectedIndex: _selectedTab,
                  onToggle: (index) {
                    setState(() {
                      _selectedTab = index;
                      _searchQuery = '';
                      _searchController.clear();
                    });
                  },
                ),
                const SizedBox(height: 16),

                // 3. Search Bar
                PlatformInsetContainer(
                  borderRadius: 16,
                  height: 48,
                  padding: const EdgeInsets.symmetric(horizontal: 14),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.search_rounded,
                        color: AppColors.textSecondary,
                        size: 20,
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: TextField(
                          controller: _searchController,
                          onChanged: (val) {
                            setState(() {
                              _searchQuery = val.trim().toLowerCase();
                            });
                          },
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textPrimary,
                          ),
                          decoration: InputDecoration(
                            hintText: _selectedTab == 0 ? 'Search friends...' : 'Search groups...',
                            hintStyle: const TextStyle(
                              color: AppColors.textSecondary,
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                            ),
                            border: InputBorder.none,
                            isDense: true,
                            contentPadding: EdgeInsets.zero,
                          ),
                        ),
                      ),
                      if (_searchController.text.isNotEmpty)
                        GestureDetector(
                          onTap: () {
                            setState(() {
                              _searchController.clear();
                              _searchQuery = '';
                            });
                          },
                          child: const Icon(
                            Icons.close_rounded,
                            size: 18,
                            color: AppColors.textSecondary,
                          ),
                        ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // 4. Selection Tiles (Friends or Groups)
                if (_selectedTab == 0) ...[
                  if (_effectiveFriends.isEmpty)
                    const PlatformInsetContainer(
                      borderRadius: 18,
                      width: double.infinity,
                      padding: EdgeInsets.symmetric(horizontal: 20, vertical: 32),
                      child: Center(
                        child: Column(
                          children: [
                            Icon(
                              Icons.people_outline_rounded,
                              size: 40,
                              color: AppColors.textSecondary,
                            ),
                            SizedBox(height: 12),
                            Text(
                              'No Friends Added Yet',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w800,
                                color: AppColors.textPrimary,
                              ),
                            ),
                            SizedBox(height: 6),
                            Text(
                              'Add friends in the Friends tab to select them here.',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w500,
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    )
                  else if (filteredFriends.isEmpty)
                    PlatformInsetContainer(
                      borderRadius: 18,
                      width: double.infinity,
                      padding: const EdgeInsets.all(24),
                      child: Center(
                        child: Text(
                          'No friends matching "$_searchQuery"',
                          style: const TextStyle(
                            color: AppColors.textSecondary,
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    )
                  else
                    for (final friend in filteredFriends) ...[
                      () {
                        final origIdx = _effectiveFriends.indexOf(friend);
                        final isSelected = _selectedFriendIndices.contains(origIdx);
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: FriendSelectionTile(
                            friend: friend,
                            isSelected: isSelected,
                            onToggle: () {
                              setState(() {
                                if (isSelected) {
                                  _selectedFriendIndices.remove(origIdx);
                                } else {
                                  _selectedFriendIndices.add(origIdx);
                                }
                              });
                            },
                          ),
                        );
                      }(),
                    ],
                ] else ...[
                  if (filteredGroups.isEmpty)
                    const PlatformInsetContainer(
                      borderRadius: 18,
                      width: double.infinity,
                      padding: EdgeInsets.all(24),
                      child: Center(
                        child: Text(
                          'No groups available.\nCreate a group in the Friends tab to split by group.',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: AppColors.textSecondary,
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    )
                  else
                    for (int i = 0; i < filteredGroups.length; i++) ...[
                      Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: GroupSelectionTile(
                          group: filteredGroups[i],
                          isSelected: _selectedGroupIndex == i,
                          onToggle: () => _onGroupSelected(i),
                        ),
                      ),
                    ],
                ],
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),

      // 5. Fixed Bottom Continue Button with Arrow (Continue ->)
      bottomNavigationBar: Container(
        color: isIOS ? AppColors.iosBackground : AppColors.background,
        padding: const EdgeInsets.fromLTRB(24, 10, 24, 20),
        child: SafeArea(
          top: false,
          child: SizedBox(
            width: double.infinity,
            height: 56,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppRadius.button),
                ),
              ),
              onPressed: _onContinuePressed,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Continue',
                    style: GoogleFonts.manrope(
                      fontWeight: FontWeight.w700,
                      fontSize: 16,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(width: 8),
                  const Icon(
                    Icons.arrow_forward_rounded,
                    color: Colors.white,
                    size: 20,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
