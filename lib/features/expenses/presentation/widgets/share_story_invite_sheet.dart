import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_bill_splitter/core/services/invite_service.dart';
import 'package:flutter_bill_splitter/core/theme/app_colors.dart';
import 'package:flutter_bill_splitter/core/theme/app_radius.dart';
import 'package:flutter_bill_splitter/features/stories/domain/models/story.dart';

/// Modal bottom sheet allowing users to copy and share an invite link for a given [Story].
class ShareStoryInviteSheet extends StatelessWidget {
  final Story story;

  const ShareStoryInviteSheet({
    super.key,
    required this.story,
  });

  /// Displays the share invite modal bottom sheet.
  static Future<void> show(BuildContext context, Story story) {
    HapticFeedback.lightImpact();
    return showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: AppRadius.borderModalTop,
      ),
      builder: (ctx) => ShareStoryInviteSheet(story: story),
    );
  }

  @override
  Widget build(BuildContext context) {
    final inviteUrl = InviteService.buildInviteUrl(story.storyId);

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 36,
                height: 4,
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: AppColors.divider,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: const Color(0xFFEEEDFA),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Center(
                    child: Icon(Icons.group_add_rounded,
                        color: Color(0xFF5B4DFF), size: 24),
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Invite to ${story.title}',
                        style: GoogleFonts.manrope(
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Friends join after Google sign-in',
                        style: GoogleFonts.manrope(
                          fontSize: 12.5,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 18),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: AppColors.cardAlt,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.divider),
              ),
              child: Row(
                children: [
                  const Icon(Icons.link_rounded,
                      size: 20, color: Color(0xFF6B7280)),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      inviteUrl,
                      style: GoogleFonts.manrope(
                        fontSize: 13,
                        color: const Color(0xFF374151),
                        fontWeight: FontWeight.w500,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      minimumSize: const Size(70, 36),
                      padding: const EdgeInsets.symmetric(horizontal: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    onPressed: () {
                      Clipboard.setData(ClipboardData(text: inviteUrl));
                      Navigator.of(context).pop();
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            'Invite link copied to clipboard! Share it with friends.',
                            style: GoogleFonts.manrope(
                                fontWeight: FontWeight.w600),
                          ),
                          backgroundColor: AppColors.primary,
                          behavior: SnackBarBehavior.floating,
                        ),
                      );
                    },
                    child: const Text('Copy'),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),
            Text(
              'When your friend clicks this link and signs in with Google, they will automatically be added to this story.',
              style: GoogleFonts.manrope(
                fontSize: 12,
                color: AppColors.textSecondary,
                height: 1.4,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
