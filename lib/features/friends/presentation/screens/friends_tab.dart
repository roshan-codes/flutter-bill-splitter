import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bill_splitter/core/theme/app_colors.dart';
import 'package:flutter_bill_splitter/features/friends/domain/models/friend.dart';
import 'package:flutter_bill_splitter/features/friends/domain/models/group.dart';
import 'package:flutter_bill_splitter/features/friends/presentation/widgets/add_friend_dialog.dart';
import 'package:flutter_bill_splitter/features/friends/presentation/widgets/add_options_bottom_sheet.dart';
import 'package:flutter_bill_splitter/features/friends/presentation/widgets/create_group_bottom_sheet.dart';
import 'package:flutter_bill_splitter/features/friends/presentation/widgets/friend_list_item.dart';
import 'package:flutter_bill_splitter/features/friends/presentation/widgets/group_list_item.dart';
import 'package:flutter_bill_splitter/features/friends/presentation/widgets/import_contacts_sheet.dart';
import 'package:flutter_bill_splitter/shared/widgets/platform_adaptive.dart';

/// Friends & Groups Tab with platform-adaptive UI (Material for Android, Cupertino for iOS).
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
  int _subTabIndex = 0; // 0 = Friends, 1 = Groups

  void _showAddOptionsMenu() {
    HapticFeedback.lightImpact();
    AddOptionsBottomSheet.show(
      context,
      onAddNewFriend: () => AddFriendDialog.show(
        context,
        onFriendAdded: widget.onFriendAdded,
      ),
      onImportContacts: () => ImportContactsSheet.show(
        context,
        existingFriends: widget.friends,
        onContactsImported: (imported) {
          for (final friend in imported) {
            widget.onFriendAdded(friend);
          }
        },
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
    final isIOS = isIOSPlatform(context);

    return Scaffold(
      backgroundColor: isIOS ? AppColors.iosBackground : AppColors.background,
      body: SafeArea(
        bottom: false,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 16, 14),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  isIOS
                      ? CupertinoSlidingSegmentedControl<int>(
                          groupValue: _subTabIndex,
                          backgroundColor: CupertinoColors.tertiarySystemFill.resolveFrom(context),
                          thumbColor: CupertinoColors.secondarySystemGroupedBackground.resolveFrom(context),
                          children: const {
                            0: Padding(
                              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                              child: Text(
                                'Friends',
                                style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                            ),
                            1: Padding(
                              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                              child: Text(
                                'Groups',
                                style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                            ),
                          },
                          onValueChanged: (val) {
                            if (val != null) setState(() => _subTabIndex = val);
                          },
                        )
                      : Container(
                          decoration: BoxDecoration(
                            color: const Color(0xFFEFF2F5),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: AppColors.border, width: 0.8),
                          ),
                          padding: const EdgeInsets.all(4),
                          child: Row(
                            children: [
                              GestureDetector(
                                onTap: () => setState(() => _subTabIndex = 0),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
                                  decoration: BoxDecoration(
                                    color: _subTabIndex == 0 ? Colors.white : Colors.transparent,
                                    borderRadius: BorderRadius.circular(12),
                                    boxShadow: _subTabIndex == 0
                                        ? [
                                            BoxShadow(
                                              color: Colors.black.withOpacity(0.06),
                                              blurRadius: 4,
                                              offset: const Offset(0, 1),
                                            ),
                                          ]
                                        : null,
                                  ),
                                  child: Text(
                                    'Friends',
                                    style: TextStyle(
                                      fontSize: 15,
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
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
                                  decoration: BoxDecoration(
                                    color: _subTabIndex == 1 ? Colors.white : Colors.transparent,
                                    borderRadius: BorderRadius.circular(12),
                                    boxShadow: _subTabIndex == 1
                                        ? [
                                            BoxShadow(
                                              color: Colors.black.withOpacity(0.06),
                                              blurRadius: 4,
                                              offset: const Offset(0, 1),
                                            ),
                                          ]
                                        : null,
                                  ),
                                  child: Text(
                                    'Groups',
                                    style: TextStyle(
                                      fontSize: 15,
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
                    icon: Container(
                      width: 44,
                      height: 44,
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color: AppColors.primary,
                      ),
                      child: const Center(
                        child: Icon(
                          Icons.add,
                          color: AppColors.primaryDark,
                          size: 22,
                        ),
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
      ),
    );
  }

  void _confirmDeleteFriend(int index, Friend friend) {
    HapticFeedback.lightImpact();
    if (isIOSPlatform(context)) {
      showCupertinoDialog(
        context: context,
        builder: (ctx) => CupertinoAlertDialog(
          title: Text('Delete ${friend.name}?'),
          content: const Text('This will remove this friend from your saved list.'),
          actions: [
            CupertinoDialogAction(
              onPressed: () => Navigator.of(ctx).pop(),
              child: const Text('Cancel'),
            ),
            CupertinoDialogAction(
              isDestructiveAction: true,
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
    } else {
      showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          backgroundColor: Colors.white,
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
  }

  void _confirmDeleteGroup(int index, Group group) {
    HapticFeedback.lightImpact();
    if (isIOSPlatform(context)) {
      showCupertinoDialog(
        context: context,
        builder: (ctx) => CupertinoAlertDialog(
          title: Text('Delete ${group.name}?'),
          content: const Text('This will remove this group from your saved list.'),
          actions: [
            CupertinoDialogAction(
              onPressed: () => Navigator.of(ctx).pop(),
              child: const Text('Cancel'),
            ),
            CupertinoDialogAction(
              isDestructiveAction: true,
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
    } else {
      showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          backgroundColor: Colors.white,
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
