import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_bill_splitter/core/theme/app_colors.dart';
import 'package:flutter_bill_splitter/core/theme/app_radius.dart';
import 'package:flutter_bill_splitter/features/friends/data/repositories/friends_repository.dart';
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
/// Friends & Groups screen with platform-adaptive UI (Material for Android, Cupertino for iOS).
/// Adheres to design.md Section 2, 3, 4, 6 & 9.
class FriendsTab extends StatefulWidget {
  final List<Friend> friends;
  final List<Group> groups;
  final ValueChanged<Friend> onFriendAdded;
  final ValueChanged<Group> onGroupCreated;
  final ValueChanged<int> onFriendDeleted;
  final ValueChanged<int> onGroupDeleted;
  final List<Friend>? friends;
  final List<Group>? groups;
  final ValueChanged<Friend>? onFriendAdded;
  final ValueChanged<Group>? onGroupCreated;
  final ValueChanged<int>? onFriendDeleted;
  final ValueChanged<int>? onGroupDeleted;
  final int initialSubTabIndex;
  final bool showBackButton;

  const FriendsTab({
    super.key,
    required this.friends,
    required this.groups,
    required this.onFriendAdded,
    required this.onGroupCreated,
    required this.onFriendDeleted,
    required this.onGroupDeleted,
    this.friends,
    this.groups,
    this.onFriendAdded,
    this.onGroupCreated,
    this.onFriendDeleted,
    this.onGroupDeleted,
    this.initialSubTabIndex = 0,
    this.showBackButton = false,
  });

  @override
  State<FriendsTab> createState() => _FriendsTabState();
}

typedef FriendsScreen = FriendsTab;

class _FriendsTabState extends State<FriendsTab> {
  int _subTabIndex = 0; // 0 = Friends, 1 = Groups
  late int _subTabIndex;

  @override
  void initState() {
    super.initState();
    _subTabIndex = widget.initialSubTabIndex;
    FriendsRepository.instance.addListener(_onRepoChanged);
  }

  @override
  void dispose() {
    FriendsRepository.instance.removeListener(_onRepoChanged);
    super.dispose();
  }

  void _onRepoChanged() {
    if (mounted) setState(() {});
  }

  List<Friend> get _currentFriends =>
      widget.friends ?? FriendsRepository.instance.friends;

  List<Group> get _currentGroups =>
      widget.groups ?? FriendsRepository.instance.groups;

  void _handleFriendAdded(Friend friend) {
    if (widget.onFriendAdded != null) {
      widget.onFriendAdded!(friend);
    } else {
      FriendsRepository.instance.addFriend(friend);
    }
    if (mounted) setState(() {});
  }

  void _handleGroupCreated(Group group) {
    if (widget.onGroupCreated != null) {
      widget.onGroupCreated!(group);
    } else {
      FriendsRepository.instance.addGroup(group);
    }
    if (mounted) setState(() {});
  }

  void _handleFriendDeleted(int index) {
    if (widget.onFriendDeleted != null) {
      widget.onFriendDeleted!(index);
    } else {
      FriendsRepository.instance.removeFriendAt(index);
    }
    if (mounted) setState(() {});
  }

  void _handleGroupDeleted(int index) {
    if (widget.onGroupDeleted != null) {
      widget.onGroupDeleted!(index);
    } else {
      FriendsRepository.instance.removeGroupAt(index);
    }
    if (mounted) setState(() {});
  }

  void _showAddOptionsMenu() {
    HapticFeedback.lightImpact();
    AddOptionsBottomSheet.show(
      context,
      onAddNewFriend: () => AddFriendDialog.show(
        context,
        onFriendAdded: widget.onFriendAdded,
        onFriendAdded: _handleFriendAdded,
      ),
      onImportContacts: () => ImportContactsSheet.show(
        context,
        existingFriends: widget.friends,
        existingFriends: _currentFriends,
        onContactsImported: (imported) {
          for (final friend in imported) {
            widget.onFriendAdded(friend);
            _handleFriendAdded(friend);
          }
        },
      ),
      onCreateGroup: () => CreateGroupBottomSheet.show(
        context,
        availableFriends: widget.friends,
        availableFriends: _currentFriends,
        onGroupCreated: (newGroup) {
          widget.onGroupCreated(newGroup);
          _handleGroupCreated(newGroup);
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
              padding: EdgeInsets.fromLTRB(
                  widget.showBackButton ? 16 : 20, 16, 16, 14),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  if (widget.showBackButton) ...[
                    PlatformBackButton(
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                    const SizedBox(width: 12),
                  ],
                  isIOS
                      ? CupertinoSlidingSegmentedControl<int>(
                          groupValue: _subTabIndex,
                          backgroundColor: AppColors.surfaceSubtle,
                          thumbColor: AppColors.surface,
                          children: {
                            0: Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 16, vertical: 8),
                              child: Text(
                                'Friends',
                                style: GoogleFonts.manrope(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                            ),
                            1: Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 16, vertical: 8),
                              child: Text(
                                'Groups',
                                style: GoogleFonts.manrope(
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
                            color: AppColors.surfaceSubtle,
                            borderRadius: BorderRadius.circular(AppRadius.input),
                            border: Border.all(color: AppColors.border, width: 1.0),
                            borderRadius:
                                BorderRadius.circular(AppRadius.input),
                            border:
                                Border.all(color: AppColors.border, width: 1.0),
                          ),
                          padding: const EdgeInsets.all(4),
                          child: Row(
                            children: [
                              GestureDetector(
                                onTap: () => setState(() => _subTabIndex = 0),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 18, vertical: 8),
                                  decoration: BoxDecoration(
                                    color: _subTabIndex == 0 ? AppColors.surface : Colors.transparent,
                                    color: _subTabIndex == 0
                                        ? AppColors.surface
                                        : Colors.transparent,
                                    borderRadius: BorderRadius.circular(12),
                                    boxShadow: _subTabIndex == 0
                                        ? [
                                            BoxShadow(
                                              color: Colors.black.withOpacity(0.04),
                                              color: Colors.black
                                                  .withOpacity(0.04),
                                              blurRadius: 4,
                                              offset: const Offset(0, 1),
                                            ),
                                          ]
                                        : null,
                                  ),
                                  child: Text(
                                    'Friends',
                                    style: GoogleFonts.manrope(
                                      fontSize: 15,
                                      fontWeight: FontWeight.w700,
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
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 18, vertical: 8),
                                  decoration: BoxDecoration(
                                    color: _subTabIndex == 1 ? AppColors.surface : Colors.transparent,
                                    color: _subTabIndex == 1
                                        ? AppColors.surface
                                        : Colors.transparent,
                                    borderRadius: BorderRadius.circular(12),
                                    boxShadow: _subTabIndex == 1
                                        ? [
                                            BoxShadow(
                                              color: Colors.black.withOpacity(0.04),
                                              color: Colors.black
                                                  .withOpacity(0.04),
                                              blurRadius: 4,
                                              offset: const Offset(0, 1),
                                            ),
                                          ]
                                        : null,
                                  ),
                                  child: Text(
                                    'Groups',
                                    style: GoogleFonts.manrope(
                                      fontSize: 15,
                                      fontWeight: FontWeight.w700,
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
                  const Spacer(),
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
                          color: Colors.white,
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
              child:
                  _subTabIndex == 0 ? _buildFriendsList() : _buildGroupsList(),
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
          content:
              const Text('This will remove this friend from your saved list.'),
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
                _handleFriendDeleted(index);
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
          backgroundColor: AppColors.surface,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.card)),
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppRadius.card)),
          title: Text(
            'Delete ${friend.name}?',
            style: GoogleFonts.manrope(
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
          content: Text(
            'This will remove this friend from your saved list.',
            style: GoogleFonts.manrope(color: AppColors.textSecondary),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: Text('Cancel', style: GoogleFonts.manrope(color: AppColors.textSecondary)),
              child: Text('Cancel',
                  style: GoogleFonts.manrope(color: AppColors.textSecondary)),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.danger,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppRadius.buttonSecondary),
                  borderRadius:
                      BorderRadius.circular(AppRadius.buttonSecondary),
                ),
              ),
              onPressed: () {
                HapticFeedback.mediumImpact();
                Navigator.of(ctx).pop();
                widget.onFriendDeleted(index);
                _handleFriendDeleted(index);
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
          content:
              const Text('This will remove this group from your saved list.'),
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
                _handleGroupDeleted(index);
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
          backgroundColor: AppColors.surface,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.card)),
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppRadius.card)),
          title: Text(
            'Delete ${group.name}?',
            style: GoogleFonts.manrope(
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
          content: Text(
            'This will remove this group from your saved list.',
            style: GoogleFonts.manrope(color: AppColors.textSecondary),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: Text('Cancel', style: GoogleFonts.manrope(color: AppColors.textSecondary)),
              child: Text('Cancel',
                  style: GoogleFonts.manrope(color: AppColors.textSecondary)),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.danger,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppRadius.buttonSecondary),
                  borderRadius:
                      BorderRadius.circular(AppRadius.buttonSecondary),
                ),
              ),
              onPressed: () {
                HapticFeedback.mediumImpact();
                Navigator.of(ctx).pop();
                widget.onGroupDeleted(index);
                _handleGroupDeleted(index);
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
    if (_currentFriends.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.people_outline_rounded,
              size: 64,
              color: AppColors.textTertiary,
            ),
            const SizedBox(height: 12),
            Text(
              'No friends yet',
              style: GoogleFonts.manrope(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'Tap + to add your first friend',
              style: GoogleFonts.manrope(
                fontSize: 14,
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 110),
      itemCount: widget.friends.length,
      itemCount: _currentFriends.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final friend = widget.friends[index];
        final friend = _currentFriends[index];
        return FriendListItem(
          friend: friend,
          onDelete: () => _confirmDeleteFriend(index, friend),
        );
      },
    );
  }

  Widget _buildGroupsList() {
    if (widget.groups.isEmpty) {
    if (_currentGroups.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.groups_outlined,
              size: 64,
              color: AppColors.textTertiary,
            ),
            const SizedBox(height: 12),
            Text(
              'No groups yet',
              style: GoogleFonts.manrope(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'Tap + to create your first group',
              style: GoogleFonts.manrope(
                fontSize: 14,
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 110),
      itemCount: widget.groups.length,
      itemCount: _currentGroups.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final group = widget.groups[index];
        final group = _currentGroups[index];
        return GroupListItem(
          group: group,
          onDelete: () => _confirmDeleteGroup(index, group),
        );
      },
    );
  }
}
