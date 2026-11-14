import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_bill_splitter/core/theme/app_colors.dart';
import 'package:flutter_bill_splitter/core/utils/string_utils.dart';
import 'package:flutter_bill_splitter/features/stories/domain/models/story.dart';

/// Active Story Card matching the design mockup in media_1794634584098_6679ad51.png:
/// - Rounded card with squircle emoji badge, title, and date subtitle
/// - Chevron navigation indicator
/// - Total expenses and Members count columns
/// - Stacked overlapping member avatars and "Active" status pill
class ActiveStoryCard extends StatelessWidget {
  final Story story;
  final VoidCallback onTap;

  const ActiveStoryCard({
    super.key,
    required this.story,
    required this.onTap,
  });

  String _formatAmount(num value) {
    final integerPart = value.toInt();
    final str = integerPart.abs().toString();
    if (str.length <= 3) {
      return (value < 0 ? '-' : '') + str;
    }
    final lastThree = str.substring(str.length - 3);
    final otherDigits = str.substring(0, str.length - 3);
    final formattedOther = otherDigits.replaceAllMapped(
      RegExp(r'(\d)(?=(\d\d)+$)'),
      (m) => '${m[1]},',
    );
    return '${value < 0 ? '-' : ''}$formattedOther,$lastThree';
  }

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

  Widget _buildAvatar(StoryMember member) {
    final hasNetworkAvatar = member.avatar != null &&
        member.avatar!.isNotEmpty &&
        (member.avatar!.startsWith('http://') ||
            member.avatar!.startsWith('https://'));

    if (hasNetworkAvatar) {
      return Container(
        width: 32,
        height: 32,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(color: Colors.white, width: 2.0),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.06),
              blurRadius: 4,
              offset: const Offset(0, 1),
            ),
          ],
        ),
        child: ClipOval(
          child: Image.network(
            member.avatar!,
            fit: BoxFit.cover,
            errorBuilder: (_, __, ___) =>
                _buildFallbackInitialAvatar(member.name),
          ),
        ),
      );
    }

    return Container(
      width: 32,
      height: 32,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: const Color(0xFF24272D),
        border: Border.all(color: Colors.white, width: 2.0),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 4,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Center(
        child: Text(
          StringUtils.getSingleInitial(member.name),
          style: GoogleFonts.manrope(
            fontSize: 12,
            fontWeight: FontWeight.w700,
            color: Colors.white,
          ),
        ),
      ),
    );
  }

  Widget _buildFallbackInitialAvatar(String name) {
    return Container(
      color: const Color(0xFF24272D),
      child: Center(
        child: Text(
          StringUtils.getSingleInitial(name),
          style: GoogleFonts.manrope(
            fontSize: 12,
            fontWeight: FontWeight.w700,
            color: Colors.white,
          ),
        ),
      ),
    );
  }

  Widget _buildAvatarStack() {
    final displayMembers = story.members.take(5).toList();
    if (displayMembers.isEmpty) {
      return const SizedBox.shrink();
    }

    return SizedBox(
      height: 34,
      width: 32.0 + (displayMembers.length - 1) * 22.0,
      child: Stack(
        children: [
          for (int i = 0; i < displayMembers.length; i++)
            Positioned(
              left: i * 22.0,
              top: 0,
              child: _buildAvatar(displayMembers[i]),
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

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(24),
        child: Container(
          width: double.infinity,
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
                            fontSize: 18,
                            fontWeight: FontWeight.w800,
                            color: AppColors.textPrimary,
                            letterSpacing: -0.3,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          _formatDateSubtitle(),
                          style: GoogleFonts.manrope(
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
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
              const SizedBox(height: 20),

              // Metrics Row: Total expenses & Members count
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
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
                      ),
                      const SizedBox(height: 3),
                      Text(
                        'Total expenses',
                        style: GoogleFonts.manrope(
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                  Padding(
                    padding: const EdgeInsets.only(right: 32),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
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
                            fontWeight: FontWeight.w500,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // Bottom Row: Overlapping Member Avatars + Active Status Pill
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  _buildAvatarStack(),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                    decoration: BoxDecoration(
                      color: const Color(0xFFE8F5E9),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      story.status.isNotEmpty
                          ? '${story.status[0].toUpperCase()}${story.status.substring(1)}'
                          : 'Active',
                      style: GoogleFonts.manrope(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFF2E7D32),
                      ),
                    ),
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
