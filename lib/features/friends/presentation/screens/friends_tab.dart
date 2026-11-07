import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_neumorphism_ui/flutter_neumorphism_ui.dart';
import 'package:flutter_bill_splitter/core/theme/app_colors.dart';
import 'package:flutter_bill_splitter/core/theme/neumorphic_styles.dart';
import 'package:flutter_bill_splitter/features/friends/domain/models/friend.dart';
import 'package:flutter_bill_splitter/features/friends/domain/models/group.dart';
import 'package:flutter_bill_splitter/features/friends/presentation/widgets/add_friend_dialog.dart';
import 'package:flutter_bill_splitter/features/friends/presentation/widgets/add_options_bottom_sheet.dart';
import 'package:flutter_bill_splitter/features/friends/presentation/widgets/create_group_bottom_sheet.dart';
import 'package:flutter_bill_splitter/features/friends/presentation/widgets/friend_list_item.dart';
import 'package:flutter_bill_splitter/features/friends/presentation/widgets/group_list_item.dart';

/// Friends & Groups view tab.
class FriendsTab extends StatefulWidget {
  final List<Friend> friends;
  final List<Group> groups;
  final ValueChanged<Friend> onFriendAdded;
  final ValueChanged<Group> onGroupCreated;
  final ValueChanged<int> onFriendDeleted;
  final ValueChanged<int> onGroupDeleted;

  const FriendsTab({
    super.key,
    required this.friends,
    required this.groups,
    required this.onFriendAdded,
    required this.onGroupCreated,
    required this.onFriendDeleted,
    required this.onGroupDeleted,
  });

  @override
  State<FriendsTab> createState() => _FriendsTabState();
}

class _FriendsTabState extends State<FriendsTab> {
  int _subTabIndex = 0; // 0: Friends, 1: Groups

  void _showAddOptionsMenu() {
    AddOptionsBottomSheet.show(
      context,
      onAddFriend: () => AddFriendDialog.show(
        context,
        onFriendAdded: widget.onFriendAdded,
      ),
      onCreateGroup: () => CreateGroupBottomSheet.show(
        context,
        availableFriends: widget.friends,
        onGroupCreated: (newGroup) {
          widget.onGroupCreated(newGroup);
          setState(() {
            _subTabIndex = 1; // Switch to Groups tab
          });
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      bottom: false,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 16, 14),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                FlutterNeumorphism(
                  style: NeumorphicStyles.inset(borderRadius: 18, depth: 3),
                  padding: const EdgeInsets.all(4),
                  child: Row(
                    children: [
                      GestureDetector(
                        onTap: () => setState(() => _subTabIndex = 0),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
                          decoration: BoxDecoration(
                            color: _subTabIndex == 0 ? AppColors.surface : Colors.transparent,
                            borderRadius: BorderRadius.circular(14),
                            boxShadow: _subTabIndex == 0
                                ? [
                                    BoxShadow(
                                      color: AppColors.neumorphicDark.withOpacity(0.5),
                                      offset: const Offset(1, 2),
                                      blurRadius: 4,
                                    ),
                                    const BoxShadow(
                                      color: AppColors.neumorphicLight,
                                      offset: Offset(-1, -1),
                                      blurRadius: 4,
                                    ),
                                  ]
                                : null,
                          ),
                          child: Text(
                            'Friends',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w800,
                              color: _subTabIndex == 0
                                  ? AppColors.textPrimary
                                  : AppColors.textSecondary,
                            ),
                          ),
                        ),
                      ),
                      GestureDetector(
                        onTap: () => setState(() => _subTabIndex = 1),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
                          decoration: BoxDecoration(
                            color: _subTabIndex == 1 ? AppColors.surface : Colors.transparent,
                            borderRadius: BorderRadius.circular(14),
                            boxShadow: _subTabIndex == 1
                                ? [
                                    BoxShadow(
                                      color: AppColors.neumorphicDark.withOpacity(0.5),
                                      offset: const Offset(1, 2),
                                      blurRadius: 4,
                                    ),
                                    const BoxShadow(
                                      color: AppColors.neumorphicLight,
                                      offset: Offset(-1, -1),
                                      blurRadius: 4,
                                    ),
                                  ]
                                : null,
                          ),
                          child: Text(
                            'Groups',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w800,
                              color: _subTabIndex == 1
                                  ? AppColors.textPrimary
                                  : AppColors.textSecondary,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  tooltip: 'Add',
                  icon: FlutterNeumorphism(
                    style: NeumorphicStyles.circle(
                      depth: 5,
                      color: AppColors.primary,
                    ),
                    width: 44,
                    height: 44,
                    padding: EdgeInsets.zero,
                    child: const Icon(
                      Icons.add,
                      color: AppColors.primaryDark,
                      size: 22,
                    ),
                  ),
                  onPressed: _showAddOptionsMenu,
                ),
              ],
            ),
          ),
          Expanded(
            child: _subTabIndex == 0 ? _buildFriendsList() : _buildGroupsList(),
          ),
        ],
      ),
    );
  }

  void _confirmDeleteFriend(int index, Friend friend) {
    HapticFeedback.lightImpact();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          'Delete ${friend.name}?',
          style: const TextStyle(
            fontWeight: FontWeight.w800,
            color: AppColors.textPrimary,
          ),
        ),
        content: const Text(
          'This will remove this friend from your saved list.',
          style: TextStyle(color: AppColors.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFDC2626),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            onPressed: () {
              HapticFeedback.mediumImpact();
              Navigator.of(ctx).pop();
              widget.onFriendDeleted(index);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('${friend.name} removed'),
                  behavior: SnackBarBehavior.floating,
                ),
              );
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  void _confirmDeleteGroup(int index, Group group) {
    HapticFeedback.lightImpact();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          'Delete ${group.name}?',
          style: const TextStyle(
            fontWeight: FontWeight.w800,
            color: AppColors.textPrimary,
          ),
        ),
        content: const Text(
          'This will remove this group from your saved list.',
          style: TextStyle(color: AppColors.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFDC2626),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            onPressed: () {
              HapticFeedback.mediumImpact();
              Navigator.of(ctx).pop();
              widget.onGroupDeleted(index);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('${group.name} removed'),
                  behavior: SnackBarBehavior.floating,
                ),
              );
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  Widget _buildFriendsList() {
    if (widget.friends.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.people_outline_rounded,
              size: 64,
              color: Colors.grey.shade400,
            ),
            const SizedBox(height: 12),
            Text(
              'No friends yet',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Colors.grey.shade700,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'Tap + to add your first friend',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey.shade500,
              ),
            ),
          ],
        ),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 110),
      itemCount: widget.friends.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final friend = widget.friends[index];
        return FriendListItem(
          friend: friend,
          onDelete: () => _confirmDeleteFriend(index, friend),
        );
      },
    );
  }

  Widget _buildGroupsList() {
    if (widget.groups.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.groups_outlined,
              size: 64,
              color: Colors.grey.shade400,
            ),
            const SizedBox(height: 12),
            Text(
              'No groups yet',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Colors.grey.shade700,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'Tap + to create your first group',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey.shade500,
              ),
            ),
          ],
        ),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 110),
      itemCount: widget.groups.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final group = widget.groups[index];
        return GroupListItem(
          group: group,
          onDelete: () => _confirmDeleteGroup(index, group),
        );
      },
    );
  }
}
