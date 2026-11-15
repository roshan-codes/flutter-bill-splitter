import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_bill_splitter/core/animations/app_motion.dart';
import 'package:flutter_bill_splitter/core/animations/app_transitions.dart';
import 'package:flutter_bill_splitter/core/services/invite_service.dart';
import 'package:flutter_bill_splitter/core/services/storage_service.dart';
import 'package:flutter_bill_splitter/core/services/supabase_service.dart';
import 'package:flutter_bill_splitter/features/expenses/presentation/screens/split_detail_screen.dart';
import 'package:flutter_bill_splitter/features/friends/domain/models/friend.dart';
import 'package:flutter_bill_splitter/features/stories/data/repositories/story_repository.dart';
import 'package:flutter_bill_splitter/features/stories/domain/models/story.dart';

/// Interactive modal dialog for handling story invite links:
/// - If user is ALREADY a member: displays "You are already a member of <story name>" with [View Story] & [Dismiss].
/// - If user is NOT a member: displays "Do you really want to join <story name>?" with [Accept] & [Decline].
class JoinStoryDialog extends StatefulWidget {
  final Story story;
  final bool isAlreadyMember;

  const JoinStoryDialog({
    super.key,
    required this.story,
    required this.isAlreadyMember,
  });

  static bool _isShowingDialog = false;

  /// Displays the invite confirmation dialog for a given [storyId].
  static Future<void> show(
    BuildContext context, {
    required String storyId,
  }) async {
    if (_isShowingDialog) return;
    _isShowingDialog = true;

    try {
      // 1. Resolve story details from Supabase Cloud first, fallback to local repository
      var story = await SupabaseService.fetchStoryById(storyId);
      story ??= StoryRepository.instance.getStoryById(storyId);

      if (story == null) {
        await InviteService.clearPendingInvite(storyId);
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'Story invite link could not be found or has expired.',
                style: GoogleFonts.manrope(fontWeight: FontWeight.w600),
              ),
              behavior: SnackBarBehavior.floating,
              backgroundColor: const Color(0xFF111111),
            ),
          );
        }
        return;
      }

      // 2. Check if the current user is already a member
      final currentUserId = SupabaseService.currentUser?.id;
      final currentUserName = SupabaseService.userDisplayName ??
          await StorageService.instance.getString('user_profile_name') ??
          'Friend';

      final cleanUser = currentUserName.toLowerCase().trim();
      final uFirst = cleanUser.split(' ').first;

      final isAlreadyMember = story.members.any((m) {
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

      if (!context.mounted) return;

      await showDialog<void>(
        context: context,
        barrierDismissible: false,
        builder: (dialogCtx) => JoinStoryDialog(
          story: story!,
          isAlreadyMember: isAlreadyMember,
        ),
      );
    } finally {
      _isShowingDialog = false;
    }
  }

  @override
  State<JoinStoryDialog> createState() => _JoinStoryDialogState();
}

class _JoinStoryDialogState extends State<JoinStoryDialog> {
  bool _isProcessing = false;

  void _navigateToStoryDetail(BuildContext context, Story targetStory) {
    Navigator.of(context).push(
      AppTransitions.sharedAxisRoute(
        duration: AppMotion.normal,
        builder: (context) => SplitDetailScreen(
          groupName: targetStory.title,
          members: targetStory.members
              .map((m) => Friend(name: m.name, phone: ''))
              .toList(),
          story: targetStory,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      backgroundColor: Colors.white,
      elevation: 16,
      insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Top Badge Icon
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: widget.isAlreadyMember
                    ? const Color(0xFFDCFCE7)
                    : const Color(0xFFF3F4F6),
              ),
              child: Center(
                child: Icon(
                  widget.isAlreadyMember
                      ? Icons.check_circle_rounded
                      : Icons.group_add_rounded,
                  size: 28,
                  color: widget.isAlreadyMember
                      ? const Color(0xFF16A34A)
                      : const Color(0xFF111111),
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Title
            Text(
              widget.isAlreadyMember ? 'Already a Member' : 'Join Story',
              style: GoogleFonts.manrope(
                fontSize: 20,
                fontWeight: FontWeight.w800,
                color: const Color(0xFF111827),
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),

            // Question / Message
            Text(
              widget.isAlreadyMember
                  ? 'You are already a member of "${widget.story.title}".'
                  : 'Do you really want to join this story?',
              style: GoogleFonts.manrope(
                fontSize: 14.5,
                color: const Color(0xFF4B5563),
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 18),

            // Story Info Card
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: const Color(0xFFF9FAFB),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFFE5E7EB)),
              ),
              child: Row(
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: const Color(0xFFE5E7EB)),
                    ),
                    child: Center(
                      child: Text(
                        widget.story.coverEmoji.isNotEmpty
                            ? widget.story.coverEmoji
                            : '🌴',
                        style: const TextStyle(fontSize: 22),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.story.title,
                          style: GoogleFonts.manrope(
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                            color: const Color(0xFF111827),
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 2),
                        Text(
                          '${widget.story.members.length} members • ${widget.story.summary.expenseCount} expenses',
                          style: GoogleFonts.manrope(
                            fontSize: 12,
                            color: const Color(0xFF6B7280),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Action Buttons
            if (widget.isAlreadyMember) ...[
              // Already a member: "View Story" and "Dismiss"
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF111111),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                    elevation: 0,
                  ),
                  onPressed: () async {
                    await InviteService.clearPendingInvite(widget.story.storyId);
                    if (context.mounted) {
                      Navigator.of(context).pop();
                      _navigateToStoryDetail(context, widget.story);
                    }
                  },
                  child: Text(
                    'View Story',
                    style: GoogleFonts.manrope(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 8),
              SizedBox(
                width: double.infinity,
                height: 42,
                child: TextButton(
                  onPressed: () async {
                    await InviteService.clearPendingInvite(widget.story.storyId);
                    if (context.mounted) {
                      Navigator.of(context).pop();
                    }
                  },
                  child: Text(
                    'Dismiss',
                    style: GoogleFonts.manrope(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF6B7280),
                    ),
                  ),
                ),
              ),
            ] else ...[
              // Not a member: [Accept] and [Decline]
              Row(
                children: [
                  Expanded(
                    child: SizedBox(
                      height: 48,
                      child: OutlinedButton(
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(color: Color(0xFFE5E7EB)),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                          foregroundColor: const Color(0xFF4B5563),
                        ),
                        onPressed: _isProcessing
                            ? null
                            : () async {
                                await InviteService.clearPendingInvite(
                                    widget.story.storyId);
                                if (context.mounted) {
                                  Navigator.of(context).pop();
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(
                                        'Declined invitation to join "${widget.story.title}".',
                                        style: GoogleFonts.manrope(
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                      behavior: SnackBarBehavior.floating,
                                      backgroundColor: const Color(0xFF111111),
                                    ),
                                  );
                                }
                              },
                        child: Text(
                          'Decline',
                          style: GoogleFonts.manrope(
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: SizedBox(
                      height: 48,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF111111),
                          foregroundColor: Colors.white,
                          disabledBackgroundColor: const Color(0xFF6B7280),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                          elevation: 0,
                        ),
                        onPressed: _isProcessing
                            ? null
                            : () async {
                                setState(() => _isProcessing = true);
                                try {
                                  final joined = await StoryRepository.instance
                                      .joinStoryWithCurrentUser(
                                          widget.story.storyId);
                                  await InviteService.clearPendingInvite(
                                      widget.story.storyId);

                                  if (context.mounted) {
                                    Navigator.of(context).pop();
                                    _navigateToStoryDetail(
                                        context, joined ?? widget.story);
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text(
                                          '🎉 You successfully joined "${widget.story.title}"!',
                                          style: GoogleFonts.manrope(
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                        behavior: SnackBarBehavior.floating,
                                        backgroundColor:
                                            const Color(0xFF111111),
                                      ),
                                    );
                                  }
                                } catch (e) {
                                  if (mounted) {
                                    setState(() => _isProcessing = false);
                                  }
                                }
                              },
                        child: _isProcessing
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                            : Text(
                                'Accept',
                                style: GoogleFonts.manrope(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}
