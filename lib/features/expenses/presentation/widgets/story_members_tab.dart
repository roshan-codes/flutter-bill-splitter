import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_bill_splitter/core/theme/app_colors.dart';
import 'package:flutter_bill_splitter/core/utils/avatar_resolver.dart';
import 'package:flutter_bill_splitter/core/utils/user_identity_resolver.dart';
import 'package:flutter_bill_splitter/features/stories/domain/models/story.dart';
import 'package:flutter_bill_splitter/shared/widgets/app_avatar.dart';

/// The Members tab widget for a story, rendering the member count,
/// "Add member" & "Invite" tiles, member balance rows, and story settings option tiles.
class StoryMembersTab extends StatelessWidget {
  final Story story;
  final double totalExpenses;
  final double perPersonAmount;
  final Future<void> Function() onRefresh;
  final VoidCallback onAddMember;
  final VoidCallback onInvite;
  final void Function(StoryMemberBalance balance) onMemberTap;
  final VoidCallback onSplitMethodTap;
  final String splitMethodDisplayName;
  final VoidCallback onEditStoryTap;
  final VoidCallback onStorySettingsTap;
  final String? resolvedCurrentMemberId;

  const StoryMembersTab({
    super.key,
    required this.story,
    required this.totalExpenses,
    required this.perPersonAmount,
    required this.onRefresh,
    required this.onAddMember,
    required this.onInvite,
    required this.onMemberTap,
    required this.onSplitMethodTap,
    required this.splitMethodDisplayName,
    required this.onEditStoryTap,
    required this.onStorySettingsTap,
    this.resolvedCurrentMemberId,
  });

  bool _isCurrentUser(String name, [String? userId]) {
    return UserIdentityResolver.isCurrentUser(
      name: name,
      userId: userId,
      story: story,
      resolvedCurrentMemberId: resolvedCurrentMemberId,
    );
  }

  String _formatMemberDisplayName(String name, bool isMe, [String? userId]) {
    return UserIdentityResolver.formatMemberDisplayName(
      name,
      isMe,
      memberUserId: userId,
      story: story,
    );
  }

  Widget _buildMembersTabMemberRow(StoryMemberBalance balance) {
    final isMe = _isCurrentUser(balance.name, balance.userId);
    final displayName = _formatMemberDisplayName(balance.name, isMe, balance.userId);

    return InkWell(
      onTap: () => onMemberTap(balance),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            AppAvatar(
              size: 42,
              name: balance.name,
              avatarUrl: story.members
                      .where((m) =>
                          m.userId == balance.userId ||
                          m.name.toLowerCase().trim() ==
                              balance.name.toLowerCase().trim())
                      .firstOrNull
                      ?.avatar ??
                  AvatarResolver.getDefaultAvatarForName(balance.name),
              isCurrentUser: isMe,
              backgroundColor: const Color(0xFF1E1E1E),
              textColor: Colors.white,
              fontSize: 16,
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Text(
                displayName,
                style: GoogleFonts.manrope(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
            ),
            const Icon(
              Icons.chevron_right_rounded,
              size: 20,
              color: Color(0xFF9CA3AF),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOptionTile({
    Key? key,
    required IconData icon,
    required String title,
    String? subtitle,
    required VoidCallback onTap,
  }) {
    return Container(
      key: key,
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border, width: 1.0),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 6,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            child: Row(
              children: [
                Container(
                  width: 38,
                  height: 38,
                  decoration: BoxDecoration(
                    color: AppColors.surfaceSubtle,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Center(
                    child: Icon(icon, size: 20, color: AppColors.textPrimary),
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: GoogleFonts.manrope(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      if (subtitle != null && subtitle.isNotEmpty) ...[
                        const SizedBox(height: 2),
                        Text(
                          subtitle,
                          style: GoogleFonts.manrope(
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                const Icon(
                  Icons.chevron_right_rounded,
                  size: 20,
                  color: Color(0xFF9CA3AF),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: onRefresh,
      color: AppColors.primary,
      child: SingleChildScrollView(
        key: const ValueKey('members_tab'),
        physics: const AlwaysScrollableScrollPhysics(
            parent: BouncingScrollPhysics()),
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 36),
        child: SizedBox(
          width: double.infinity,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header: Members (count)
              Row(
                children: [
                  Text(
                    'Members (${story.members.length})',
                    style: GoogleFonts.manrope(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      color: AppColors.textPrimary,
                      letterSpacing: -0.3,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),

              // Members list card
              Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: AppColors.border, width: 1.0),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.03),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    // 1st default item: Add member
                    InkWell(
                      key: const ValueKey('members_tab_add_member_tile'),
                      onTap: onAddMember,
                      borderRadius:
                          const BorderRadius.vertical(top: Radius.circular(20)),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 14),
                        child: Row(
                          children: [
                            Container(
                              width: 42,
                              height: 42,
                              decoration: const BoxDecoration(
                                shape: BoxShape.circle,
                                color: Color(0xFFF3F0FF),
                              ),
                              child: const Center(
                                child: Icon(
                                  Icons.person_add_rounded,
                                  color: Color(0xFF5B4DFF),
                                  size: 20,
                                ),
                              ),
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Text(
                                'Add member',
                                style: GoogleFonts.manrope(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                            ),
                            const Icon(
                              Icons.chevron_right_rounded,
                              size: 20,
                              color: Color(0xFF9CA3AF),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const Divider(
                        color: AppColors.border, height: 1, thickness: 1),

                    // 2nd default item: Invite via link or QR
                    InkWell(
                      key: const ValueKey('members_tab_invite_btn'),
                      onTap: onInvite,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 14),
                        child: Row(
                          children: [
                            Container(
                              width: 42,
                              height: 42,
                              decoration: const BoxDecoration(
                                shape: BoxShape.circle,
                                color: Color(0xFFF0FDF4),
                              ),
                              child: const Center(
                                child: Icon(
                                  Icons.qr_code_rounded,
                                  color: Color(0xFF16A34A),
                                  size: 20,
                                ),
                              ),
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Text(
                                'Invite via link or QR',
                                style: GoogleFonts.manrope(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                            ),
                            const Icon(
                              Icons.chevron_right_rounded,
                              size: 20,
                              color: Color(0xFF9CA3AF),
                            ),
                          ],
                        ),
                      ),
                    ),
                    if (story.memberBalances.isNotEmpty)
                      const Divider(
                          color: AppColors.border, height: 1, thickness: 1),

                    // Existing members list
                    for (int i = 0; i < story.memberBalances.length; i++) ...[
                      _buildMembersTabMemberRow(story.memberBalances[i]),
                      if (i < story.memberBalances.length - 1)
                        const Divider(
                          color: AppColors.border,
                          height: 1,
                          thickness: 1,
                        ),
                    ],
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // 3 Action Option Cards below Members list
              _buildOptionTile(
                key: const ValueKey('split_method_tile'),
                icon: Icons.alt_route_rounded,
                title: 'Split method',
                subtitle: splitMethodDisplayName,
                onTap: onSplitMethodTap,
              ),
              _buildOptionTile(
                key: const ValueKey('edit_story_tile'),
                icon: Icons.edit_outlined,
                title: 'Edit story',
                onTap: onEditStoryTap,
              ),
              _buildOptionTile(
                key: const ValueKey('story_settings_tile'),
                icon: Icons.settings_outlined,
                title: 'Story settings',
                onTap: onStorySettingsTap,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
