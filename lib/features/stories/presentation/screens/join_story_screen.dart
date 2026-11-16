import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_bill_splitter/core/animations/app_motion.dart';
import 'package:flutter_bill_splitter/core/animations/app_transitions.dart';
import 'package:flutter_bill_splitter/core/services/invite_service.dart';
import 'package:flutter_bill_splitter/core/services/storage_service.dart';
import 'package:flutter_bill_splitter/core/services/supabase_service.dart';
import 'package:flutter_bill_splitter/core/theme/app_colors.dart';
import 'package:flutter_bill_splitter/core/utils/avatar_resolver.dart';
import 'package:flutter_bill_splitter/features/expenses/presentation/screens/split_detail_screen.dart';
import 'package:flutter_bill_splitter/features/friends/domain/models/friend.dart';
import 'package:flutter_bill_splitter/features/navigation/presentation/screens/main_screen.dart';
import 'package:flutter_bill_splitter/features/stories/data/repositories/story_repository.dart';
import 'package:flutter_bill_splitter/features/stories/domain/models/story.dart';
import 'package:flutter_bill_splitter/shared/widgets/app_avatar.dart';
import 'package:flutter_bill_splitter/shared/widgets/platform_adaptive.dart';

/// Dedicated Invitation Preview & Join Group screen for deep link authentication flows.
/// Displays story details, member list, and allows accepting or declining the invite.
class JoinStoryScreen extends StatefulWidget {
  final String storyId;

  const JoinStoryScreen({
    super.key,
    required this.storyId,
  });

  @override
  State<JoinStoryScreen> createState() => _JoinStoryScreenState();
}

class _JoinStoryScreenState extends State<JoinStoryScreen> {
  bool _isLoading = true;
  Story? _story;
  bool _isAlreadyMember = false;
  String? _errorMessage;
  bool _isActionInProgress = false;

  @override
  void initState() {
    super.initState();
    _loadStoryDetails();
  }

  Future<void> _loadStoryDetails() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      // 1. Fetch from Supabase Cloud first, fallback to StoryRepository
      var story = await SupabaseService.fetchStoryById(widget.storyId);
      story ??= StoryRepository.instance.getStoryById(widget.storyId);

      if (story == null) {
        await InviteService.clearPendingInvite(widget.storyId);
        if (mounted) {
          setState(() {
            _isLoading = false;
            _errorMessage =
                'This invitation link is invalid, expired, or has already been used.';
          });
        }
        return;
      }

      // 2. Check if current user is already a member
      final currentUserId = SupabaseService.currentUser?.id;
      final currentUserName = SupabaseService.userDisplayName ??
          await StorageService.instance.getString('user_profile_name') ??
          '';

      final cleanUser = currentUserName.toLowerCase().trim();
      final uFirst = cleanUser.split(' ').first;

      final alreadyMember = story.members.any((m) {
        final cleanM = m.name.toLowerCase().trim();
        final mId = m.userId.trim();

        if (currentUserId != null &&
            currentUserId.isNotEmpty &&
            mId.isNotEmpty &&
            mId == currentUserId) {
          return true;
        }
        if (cleanUser.isNotEmpty && cleanM == cleanUser) return true;
        if (cleanM == 'you' &&
            (story!.createdBy == currentUserId || currentUserId == null)) {
          return true;
        }
        final mFirst = cleanM.split(' ').first;
        if (mFirst == uFirst && mFirst.length > 2) return true;
        if (mId == 'user_${cleanUser.replaceAll(' ', '_')}') return true;
        return false;
      });

      if (mounted) {
        setState(() {
          _story = story;
          _isAlreadyMember = alreadyMember;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _errorMessage = 'Could not load story details: $e';
        });
      }
    }
  }

  Future<void> _acceptInvitation() async {
    if (_story == null || _isActionInProgress) return;
    setState(() => _isActionInProgress = true);
    HapticFeedback.mediumImpact();

    try {
      final joinedStory = await StoryRepository.instance
          .joinStoryWithCurrentUser(_story!.storyId);

      await InviteService.clearPendingInvite(_story!.storyId);

      if (!mounted) return;

      final targetStory = joinedStory ?? _story!;
      Navigator.of(context).pushReplacement(
        AppTransitions.sharedAxisRoute(
          duration: AppMotion.normal,
          builder: (_) => SplitDetailScreen(
            groupName: targetStory.title,
            members: targetStory.members
                .map((m) => Friend(name: m.name, phone: ''))
                .toList(),
            story: targetStory,
          ),
        ),
      );
    } catch (e) {
      if (mounted) {
        setState(() => _isActionInProgress = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to join story: $e'),
            backgroundColor: AppColors.danger,
          ),
        );
      }
    }
  }

  Future<void> _declineInvitation() async {
    HapticFeedback.lightImpact();
    await InviteService.clearPendingInvite(widget.storyId);
    if (!mounted) return;
    _navigateToHome();
  }

  void _navigateToHome() {
    Navigator.of(context).pushReplacement(
      AppTransitions.sharedAxisRoute(
        duration: AppMotion.normal,
        builder: (_) => const MainScreen(),
      ),
    );
  }

  void _navigateToStory(Story story) {
    Navigator.of(context).pushReplacement(
      AppTransitions.sharedAxisRoute(
        duration: AppMotion.normal,
        builder: (_) => SplitDetailScreen(
          groupName: story.title,
          members: story.members
              .map((m) => Friend(name: m.name, phone: ''))
              .toList(),
          story: story,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isIOS = isIOSPlatform(context);

    return Scaffold(
      backgroundColor: isIOS ? AppColors.iosBackground : AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded, color: AppColors.textPrimary),
          onPressed: _declineInvitation,
        ),
        title: Text(
          'Group Invitation',
          style: GoogleFonts.manrope(
            fontSize: 17,
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
          ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            child: _buildContent(context),
          ),
        ),
      ),
    );
  }

  Widget _buildContent(BuildContext context) {
    if (_isLoading) {
      return Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const CircularProgressIndicator(
            color: AppColors.primary,
            strokeWidth: 2.5,
          ),
          const SizedBox(height: 20),
          Text(
            'Loading invitation details...',
            style: GoogleFonts.manrope(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      );
    }

    if (_errorMessage != null || _story == null) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(28),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: const Color(0xFFE5E5E5), width: 1.0),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 16,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: Color(0xFFFEECEB),
              ),
              child: const Icon(
                Icons.link_off_rounded,
                size: 28,
                color: Color(0xFFDC2626),
              ),
            ),
            const SizedBox(height: 18),
            Text(
              'Invitation Expired or Invalid',
              style: GoogleFonts.manrope(
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: AppColors.textPrimary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              _errorMessage ?? 'This story could not be found.',
              style: GoogleFonts.manrope(
                fontSize: 14,
                color: AppColors.textSecondary,
                height: 1.4,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: _navigateToHome,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: Text(
                  'Go to Home',
                  style: GoogleFonts.manrope(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
          ],
        ),
      );
    }

    final story = _story!;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFFE5E5E5), width: 1.0),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Icon badge
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: _isAlreadyMember
                  ? const Color(0xFFE8F8EE)
                  : const Color(0xFFF4F4F5),
            ),
            child: Icon(
              _isAlreadyMember
                  ? Icons.check_circle_rounded
                  : Icons.group_add_rounded,
              size: 30,
              color: _isAlreadyMember
                  ? const Color(0xFF16A34A)
                  : AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 18),

          Text(
            _isAlreadyMember ? 'Already a Member' : 'Join Story',
            style: GoogleFonts.manrope(
              fontSize: 22,
              fontWeight: FontWeight.w800,
              color: AppColors.textPrimary,
              letterSpacing: -0.4,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            _isAlreadyMember
                ? 'You are already a member of "${story.title}".'
                : 'You have been invited to join this shared expense story.',
            textAlign: TextAlign.center,
            style: GoogleFonts.manrope(
              fontSize: 14,
              color: AppColors.textSecondary,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 24),

          // Story Card Preview
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFFF9FAFB),
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: const Color(0xFFE5E5E5), width: 1.0),
            ),
            child: Row(
              children: [
                Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    color: const Color(0xFFE8F5E9),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Center(
                    child: Text(
                      story.coverEmoji.isNotEmpty ? story.coverEmoji : '🌴',
                      style: const TextStyle(fontSize: 26),
                    ),
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        story.title,
                        style: GoogleFonts.manrope(
                          fontSize: 17,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 3),
                      Text(
                        '${story.members.length} members  •  ${story.summary.expenseCount} expenses',
                        style: GoogleFonts.manrope(
                          fontSize: 13,
                          fontWeight: FontWeight.w400,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 18),

          // Member Avatars row preview
          if (story.members.isNotEmpty) ...[
            Row(
              children: [
                SizedBox(
                  height: 34,
                  width: 32.0 + (story.members.take(4).length - 1) * 22.0,
                  child: Stack(
                    children: [
                      for (int i = 0; i < story.members.take(4).length; i++)
                        Positioned(
                          left: i * 22.0,
                          child: Container(
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.06),
                                  blurRadius: 5,
                                  spreadRadius: 0.5,
                                  offset: const Offset(0, 1),
                                ),
                              ],
                            ),
                            child: AppAvatar(
                              size: 32,
                              avatarUrl: story.members[i].avatar ??
                                  AvatarResolver.getDefaultAvatarForName(
                                      story.members[i].name),
                              name: story.members[i].name,
                              border: Border.all(
                                color: const Color(0xFFE5E5E5),
                                width: 1.0,
                              ),
                              backgroundColor: Colors.white,
                              fontSize: 12,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    story.members.map((m) => m.name).take(3).join(', ') +
                        (story.members.length > 3
                            ? ' +${story.members.length - 3} more'
                            : ''),
                    style: GoogleFonts.manrope(
                      fontSize: 12.5,
                      fontWeight: FontWeight.w500,
                      color: AppColors.textSecondary,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 28),
          ],

          // Actions
          if (_isAlreadyMember) ...[
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                onPressed: () => _navigateToStory(story),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: Text(
                  'View Story →',
                  style: GoogleFonts.manrope(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 10),
            TextButton(
              onPressed: _navigateToHome,
              child: Text(
                'Go to Home',
                style: GoogleFonts.manrope(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textSecondary,
                ),
              ),
            ),
          ] else ...[
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                onPressed: _isActionInProgress ? null : _acceptInvitation,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: _isActionInProgress
                    ? const SizedBox(
                        width: 22,
                        height: 22,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : Text(
                        'Accept Invitation →',
                        style: GoogleFonts.manrope(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
              ),
            ),
            const SizedBox(height: 10),
            TextButton(
              onPressed: _isActionInProgress ? null : _declineInvitation,
              child: Text(
                'Decline',
                style: GoogleFonts.manrope(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textSecondary,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
