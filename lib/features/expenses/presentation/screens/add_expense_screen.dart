import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_neumorphism_ui/flutter_neumorphism_ui.dart';
import 'package:flutter_bill_splitter/core/theme/app_colors.dart';
import 'package:flutter_bill_splitter/core/theme/neumorphic_styles.dart';
import 'package:flutter_bill_splitter/features/expenses/presentation/screens/split_detail_screen.dart';
import 'package:flutter_bill_splitter/features/expenses/presentation/widgets/expense_title_input.dart';
import 'package:flutter_bill_splitter/features/expenses/presentation/widgets/friend_selection_tile.dart';
import 'package:flutter_bill_splitter/features/expenses/presentation/widgets/friends_groups_toggle.dart';
import 'package:flutter_bill_splitter/features/expenses/presentation/widgets/group_selection_tile.dart';
import 'package:flutter_bill_splitter/features/friends/domain/models/friend.dart';
import 'package:flutter_bill_splitter/features/friends/domain/models/group.dart';

/// Full-screen view for Adding an Expense & Splitting between friends or groups,
/// matching the exact neumorphic design:
/// Expense Title input, Friends/Groups toggle, Search bar, individual selection tiles, and fixed Continue button.
class AddExpenseScreen extends StatefulWidget {
  final List<Friend> friends;
  final List<Group> groups;

  const AddExpenseScreen({
    super.key,
    required this.friends,
    required this.groups,
  });

  static const List<Friend> defaultFriends = [
    Friend(name: 'Vinit', phone: '+91 98765 11111'),
    Friend(name: 'Nishant', phone: '+91 98765 22222'),
    Friend(name: 'Saurabh', phone: '+91 98765 33333'),
    Friend(name: 'Akash', phone: '+91 98765 44444'),
    Friend(name: 'Pratik', phone: '+91 98765 55555'),
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
  late List<Friend> _effectiveFriends;
  late List<Group> _availableGroups;

  @override
  void initState() {
    super.initState();
    if (widget.friends.isNotEmpty) {
      _effectiveFriends = List.from(widget.friends);
    } else {
      _effectiveFriends = List.from(AddExpenseScreen.defaultFriends);
      // Preselect Vinit, Nishant, Saurabh to match screenshot
      _selectedFriendIndices.addAll([0, 1, 2]);
    }
    _availableGroups = List.from(widget.groups);
  }

  @override
  void dispose() {
    _expenseTitleController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _onGroupSelected(int index) {
    setState(() {
      if (_selectedGroupIndex == index) {
        _selectedGroupIndex = null;
      } else {
        _selectedGroupIndex = index;
        final group = _availableGroups[index];
        if (_expenseTitleController.text.trim().isEmpty) {
          _expenseTitleController.text = group.name;
        }
        for (final member in group.members) {
          final found = _effectiveFriends.indexWhere(
            (f) => f.name == member.name || f.phone == member.phone,
          );
          if (found != -1) {
            _selectedFriendIndices.add(found);
          }
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
            content: Text('Please select at least 1 friend or group member to continue'),
            behavior: SnackBarBehavior.floating,
          ),
        );
        return;
      }

      final title = _expenseTitleController.text.trim();
      final selectedFriends = _selectedFriendIndices.map((i) => _effectiveFriends[i]).toList();

      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => SplitDetailScreen(
            groupName: title,
            members: selectedFriends,
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final filteredFriends = _effectiveFriends.where((f) {
      if (_searchQuery.isEmpty) return true;
      return f.name.toLowerCase().contains(_searchQuery);
    }).toList();

    final filteredGroups = _availableGroups.where((g) {
      if (_searchQuery.isEmpty) return true;
      return g.name.toLowerCase().contains(_searchQuery);
    }).toList();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        centerTitle: true,
        leading: Padding(
          padding: const EdgeInsets.only(left: 10),
          child: Center(
            child: Semantics(
              label: 'Back',
              button: true,
              child: Tooltip(
                message: 'Back',
                child: InkWell(
                  onTap: () {
                    HapticFeedback.lightImpact();
                    Navigator.of(context).pop();
                  },
                  borderRadius: BorderRadius.circular(22),
                  child: FlutterNeumorphism(
                    style: NeumorphicStyles.circle(depth: 4),
                    width: 44,
                    height: 44,
                    padding: EdgeInsets.zero,
                    child: const Icon(
                      Icons.arrow_back_ios_new_rounded,
                      color: AppColors.textPrimary,
                      size: 16,
                    ),
                  ),
                ),
              ),
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
          physics: const BouncingScrollPhysics(),
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
                FlutterNeumorphism(
                  style: NeumorphicStyles.inset(borderRadius: 18, depth: 3),
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
                  if (filteredFriends.isEmpty)
                    FlutterNeumorphism(
                      style: NeumorphicStyles.inset(borderRadius: 18, depth: 3),
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
                    FlutterNeumorphism(
                      style: NeumorphicStyles.inset(borderRadius: 18, depth: 3),
                      width: double.infinity,
                      padding: const EdgeInsets.all(24),
                      child: const Center(
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
        color: AppColors.background,
        padding: const EdgeInsets.fromLTRB(24, 10, 24, 20),
        child: SafeArea(
          top: false,
          child: SizedBox(
            width: double.infinity,
            height: 54,
            child: FlutterNeumorphism(
              style: NeumorphicStyles.primaryButton(borderRadius: 20, depth: 6),
              padding: EdgeInsets.zero,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.transparent,
                  foregroundColor: AppColors.primaryDark,
                  shadowColor: Colors.transparent,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
                onPressed: _onContinuePressed,
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Continue',
                      style: TextStyle(
                        fontWeight: FontWeight.w800,
                        fontSize: 17,
                        color: AppColors.primaryDark,
                      ),
                    ),
                    SizedBox(width: 8),
                    Icon(
                      Icons.arrow_forward_rounded,
                      color: AppColors.primaryDark,
                      size: 20,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
