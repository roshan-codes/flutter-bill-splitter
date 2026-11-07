import 'package:flutter/material.dart';
import 'package:flutter_bill_splitter/core/theme/app_colors.dart';
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
            padding: const EdgeInsets.fromLTRB(20, 16, 16, 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    GestureDetector(
                      onTap: () => setState(() => _subTabIndex = 0),
                      child: Text(
                        'Friends',
                        style: TextStyle(
                          fontSize: 26,
                          fontWeight: FontWeight.w800,
                          color: _subTabIndex == 0
                              ? AppColors.textPrimary
                              : Colors.grey.shade400,
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    GestureDetector(
                      onTap: () => setState(() => _subTabIndex = 1),
                      child: Text(
                        'Groups',
                        style: TextStyle(
                          fontSize: 26,
                          fontWeight: FontWeight.w800,
                          color: _subTabIndex == 1
                              ? AppColors.textPrimary
                              : Colors.grey.shade400,
                        ),
                      ),
                    ),
                  ],
                ),
                IconButton(
                  tooltip: 'Add',
                  icon: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      borderRadius: BorderRadius.circular(14),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.primary.withOpacity(0.35),
                          blurRadius: 10,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
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
          onDelete: () => widget.onFriendDeleted(index),
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
          onDelete: () => widget.onGroupDeleted(index),
        );
      },
    );
  }
}
