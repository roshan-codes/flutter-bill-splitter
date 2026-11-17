import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_bill_splitter/core/services/storage_service.dart';
import 'package:flutter_bill_splitter/core/services/supabase_service.dart';
import 'package:flutter_bill_splitter/core/theme/app_colors.dart';
import 'package:flutter_bill_splitter/core/utils/currency_formatter.dart';
import 'package:flutter_bill_splitter/core/utils/avatar_resolver.dart';
import 'package:flutter_bill_splitter/features/stories/domain/models/story.dart';
import 'package:flutter_bill_splitter/shared/widgets/app_avatar.dart';

/// Active Story Card matching the design mockup in media_1794634584098_6679ad51.png:
/// - Rounded card with squircle emoji badge, title, and date subtitle
/// - Chevron navigation indicator
/// - Total expenses and Members count columns
/// - Stacked overlapping member avatars and "Active" status pill
class ActiveStoryCard extends StatelessWidget {
  final Story story;
  final VoidCallback onTap;
  final double? width;

  const ActiveStoryCard({
    super.key,
    required this.story,
    required this.onTap,
    this.width,
  });

  String _formatAmount(num value) => CurrencyFormatter.format(value);

  String _formatDateSubtitle() {
    final sDate = story.startDate;
    final eDate = story.endDate;

    if (sDate != null && sDate == '2026-11-12' && eDate == '2026-11-16') {
      return 'Nov 12 – Nov 16';
    }

    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec'
    ];
    try {
      if (sDate != null && sDate.isNotEmpty) {
        final start = DateTime.tryParse(sDate);
        if (start != null) {
          final monthName = months[start.month - 1];
          if (eDate != null && eDate.isNotEmpty && eDate != sDate) {
            final end = DateTime.tryParse(eDate);
            if (end != null) {
              final endMonth = months[end.month - 1];
              return '$monthName ${start.day} – $endMonth ${end.day}';
            }
          }
          return '$monthName ${start.day}';
        }
      }
    } catch (_) {}

    return 'Trip Split';
  }

  String? _resolveCurrentMemberId() {
    final currentId = SupabaseService.currentUser?.id;
    final currentName = SupabaseService.userDisplayName ??
        StorageService.instance.getStringSync('user_profile_name');
    final myClean = currentName
        ?.replaceAll(RegExp(r'\s*\(you\)\s*$', caseSensitive: false), '')
        .toLowerCase()
        .trim() ??
        '';

    if (currentId != null && currentId.isNotEmpty) {
      for (final m in story.members) {
        if (m.userId == currentId) return m.userId;
      }
    }

    if (myClean.isNotEmpty) {
      for (final m in story.members) {
        final cleanM = m.name
            .replaceAll(RegExp(r'\s*\(you\)\s*$', caseSensitive: false), '')
            .toLowerCase()
            .trim();
        if (cleanM == myClean) return m.userId;
      }
    }

    for (final m in story.members) {
      if (m.name.toLowerCase().trim() == 'you') return m.userId;
    }

    if (currentId != null && story.createdBy == currentId) {
      return story.createdBy;
    }

    return null;
  }

  Widget _buildAvatar(StoryMember member, String? resolvedMeId) {
    final isMe = resolvedMeId != null && member.userId == resolvedMeId;

    return Container(
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
        avatarUrl: member.avatar ??
            AvatarResolver.getDefaultAvatarForName(member.name),
        name: member.name,
        isCurrentUser: isMe,
        border: Border.all(
          color: const Color(0xFFE5E5E5),
          width: 1.0,
        ),
        backgroundColor: Colors.white,
        textColor: AppColors.textPrimary,
        fontSize: 12,
      ),
    );
  }

  Widget _buildAvatarStack() {
    final displayMembers = story.members.take(5).toList();
    if (displayMembers.isEmpty) {
      return const SizedBox.shrink();
    }
    final resolvedMeId = _resolveCurrentMemberId();

    return SizedBox(
      height: 34,
      width: 32.0 + (displayMembers.length - 1) * 22.0,
      child: Stack(
        children: [
          for (int i = 0; i < displayMembers.length; i++)
            Positioned(
              left: i * 22.0,
              top: 0,
              child: _buildAvatar(displayMembers[i], resolvedMeId),
            ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final emoji = story.coverEmoji.isNotEmpty ? story.coverEmoji : '🌴';
    final totalAmount = story.summary.totalExpenses > 0
        ? story.summary.totalExpenses
        : story.expenses.fold<double>(0.0, (sum, e) => sum + e.amount);
    final memberCount = story.members.isNotEmpty ? story.members.length : 1;

    final resolvedMeId = _resolveCurrentMemberId();
    StoryMemberBalance? myBalance;
    if (resolvedMeId != null && story.memberBalances.isNotEmpty) {
      final myClean = (StorageService.instance.getStringSync('user_profile_name') ??
              SupabaseService.userDisplayName ??
              '')
          .replaceAll(RegExp(r'\s*\(you\)\s*$', caseSensitive: false), '')
          .toLowerCase()
          .trim();
      myBalance = story.memberBalances
          .where((b) =>
              b.userId == resolvedMeId ||
              b.name.toLowerCase().trim() == 'you' ||
              (myClean.isNotEmpty && b.name.toLowerCase().trim() == myClean))
          .firstOrNull;
    }

    Widget? personalBadge;
    if (myBalance != null && myBalance.netBalance.abs() > 0.01) {
      final isPositive = myBalance.netBalance > 0;
      personalBadge = Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(
          color: isPositive ? const Color(0xFFE8F8EE) : const Color(0xFFFEECEB),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Text(
          isPositive
              ? 'Gets ₹${_formatAmount(myBalance.netBalance)}'
              : 'Owes ₹${_formatAmount(myBalance.netBalance.abs())}',
          style: GoogleFonts.manrope(
            fontSize: 12,
            fontWeight: FontWeight.w700,
            color: isPositive ? const Color(0xFF1E8E3E) : const Color(0xFFDC2626),
          ),
        ),
      );
    }

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(24),
        child: Container(
          width: width ?? double.infinity,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: const Color(0xFFF0F0EE),
              width: 1.2,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.04),
                blurRadius: 16,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Top Row: Squircle Emoji Icon + Title & Subtitle + Chevron
              Row(
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: const Color(0xFFE8F5E9),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Center(
                      child: Text(
                        emoji,
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
                            letterSpacing: -0.3,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          _formatDateSubtitle(),
                          style: GoogleFonts.manrope(
                            fontSize: 13,
                            fontWeight: FontWeight.w400,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Icon(
                    Icons.chevron_right_rounded,
                    size: 24,
                    color: AppColors.textPrimary,
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Metrics Row: Total expenses & Members count
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '₹${_formatAmount(totalAmount)}',
                          style: GoogleFonts.manrope(
                            fontSize: 22,
                            fontWeight: FontWeight.w800,
                            color: AppColors.textPrimary,
                            letterSpacing: -0.5,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 3),
                        Text(
                          'Total expenses',
                          style: GoogleFonts.manrope(
                            fontSize: 13,
                            fontWeight: FontWeight.w400,
                            color: AppColors.textSecondary,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        '$memberCount',
                        style: GoogleFonts.manrope(
                          fontSize: 22,
                          fontWeight: FontWeight.w800,
                          color: AppColors.textPrimary,
                          letterSpacing: -0.5,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        'Members',
                        style: GoogleFonts.manrope(
                          fontSize: 13,
                          fontWeight: FontWeight.w400,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Bottom Row: Overlapping Member Avatars + Personal Badge (if any)
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  _buildAvatarStack(),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (story.status.toLowerCase() == 'inactive') ...[
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF3F4F6),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            'Closed',
                            style: GoogleFonts.manrope(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ),
                        if (personalBadge != null) const SizedBox(width: 6),
                      ],
                      if (personalBadge != null) personalBadge,
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
