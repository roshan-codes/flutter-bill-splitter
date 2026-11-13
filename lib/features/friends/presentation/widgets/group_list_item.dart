import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_bill_splitter/core/theme/app_colors.dart';
import 'package:flutter_bill_splitter/core/theme/app_radius.dart';
import 'package:flutter_bill_splitter/features/friends/domain/models/group.dart';
import 'package:flutter_bill_splitter/shared/widgets/platform_adaptive.dart';

/// Single platform-adaptive item tile for displaying a group in the Groups tab.
/// Adheres to design.md Section 5, 8 & 10.
class GroupListItem extends StatelessWidget {
  final Group group;
  final VoidCallback? onDelete;

  const GroupListItem({
    super.key,
    required this.group,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return PlatformCard(
      borderRadius: AppRadius.card,
      elevation: 0,
      padding: const EdgeInsets.all(14),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(AppRadius.iconContainer),
              color: AppColors.surfaceSubtle,
            ),
            child: const Icon(
              Icons.groups_rounded,
              color: AppColors.textPrimary,
              size: 26,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  group.name,
                  style: GoogleFonts.manrope(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  '${group.members.length} members',
                  style: GoogleFonts.manrope(
                    fontSize: 13,
                    color: AppColors.textSecondary,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ],
            ),
          ),
          if (onDelete != null)
            IconButton(
              tooltip: 'Delete group',
              icon: const Icon(
                Icons.delete_outline_rounded,
                color: AppColors.danger,
                size: 20,
              ),
              onPressed: onDelete,
            ),
        ],
      ),
    );
  }
}
