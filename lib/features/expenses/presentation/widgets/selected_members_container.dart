import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_bill_splitter/core/theme/app_colors.dart';
import 'package:flutter_bill_splitter/core/theme/app_radius.dart';
import 'package:flutter_bill_splitter/core/utils/string_utils.dart';
import 'package:flutter_bill_splitter/features/friends/domain/models/friend.dart';
import 'package:flutter_bill_splitter/shared/widgets/platform_adaptive.dart';

/// Platform-adaptive container displaying selected members with 'x' remove badges.
/// Adheres to design.md Section 4, 5 & 8.
class SelectedMembersContainer extends StatelessWidget {
  final List<Friend> allFriends;
  final Set<int> selectedIndices;
  final ValueChanged<int> onRemove;

  const SelectedMembersContainer({
    super.key,
    required this.allFriends,
    required this.selectedIndices,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Selected Members',
              style: GoogleFonts.manrope(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
                letterSpacing: -0.2,
              ),
            ),
            if (selectedIndices.isNotEmpty)
              Text(
                '${selectedIndices.length} selected',
                style: GoogleFonts.manrope(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: AppColors.primary,
                ),
              ),
          ],
        ),
        const SizedBox(height: 10),
        PlatformCard(
          borderRadius: AppRadius.card,
          elevation: 0,
          color: selectedIndices.isEmpty ? AppColors.surfaceSubtle : AppColors.surface,
          width: double.infinity,
          height: 110,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: selectedIndices.isEmpty
              ? Center(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.touch_app_outlined,
                        color: AppColors.textTertiary,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Select friends below to add them here',
                        style: GoogleFonts.manrope(
                          color: AppColors.textSecondary,
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                )
              : ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: selectedIndices.length,
                  separatorBuilder: (_, __) => const SizedBox(width: 18),
                  itemBuilder: (context, idx) {
                    final friendIndex = selectedIndices.elementAt(idx);
                    final friend = allFriends[friendIndex];
                    final initials = StringUtils.getInitials(friend.name);

                    return Stack(
                      clipBehavior: Clip.none,
                      children: [
                        Container(
                          width: 72,
                          height: 72,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(AppRadius.card),
                            color: AppColors.surfaceSubtle,
                            border: Border.all(color: AppColors.border, width: 1.0),
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(AppRadius.card),
                            child: friend.avatarUrl != null && friend.avatarUrl!.isNotEmpty
                                ? Image.network(
                                    friend.avatarUrl!,
                                    width: 72,
                                    height: 72,
                                    fit: BoxFit.cover,
                                    errorBuilder: (_, __, ___) => _buildFallback(initials),
                                  )
                                : _buildFallback(initials),
                          ),
                        ),
                        Positioned(
                          top: -6,
                          right: -6,
                          child: GestureDetector(
                            key: ValueKey('remove_selected_${friend.name}'),
                            onTap: () => onRemove(friendIndex),
                            child: Container(
                              width: 26,
                              height: 26,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: AppColors.surface,
                                border: Border.all(color: AppColors.border, width: 1.0),
                              ),
                              child: const Icon(
                                Icons.close_rounded,
                                color: AppColors.textPrimary,
                                size: 14,
                              ),
                            ),
                          ),
                        ),
                      ],
                    );
                  },
                ),
        ),
      ],
    );
  }

  Widget _buildFallback(String initials) {
    return Center(
      child: Text(
        initials,
        style: GoogleFonts.manrope(
          color: AppColors.textPrimary,
          fontWeight: FontWeight.w700,
          fontSize: 20,
        ),
      ),
    );
  }
}
