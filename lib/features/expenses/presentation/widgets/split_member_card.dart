import 'package:flutter/material.dart';
import 'package:flutter_bill_splitter/core/theme/app_colors.dart';
import 'package:flutter_bill_splitter/features/friends/domain/models/friend.dart';
import 'package:flutter_bill_splitter/shared/widgets/squircle_avatar.dart';

/// Card displaying an individual selected member in the Split Detail screen.
class SplitMemberCard extends StatelessWidget {
  final Friend friend;
  final int index;

  const SplitMemberCard({
    super.key,
    required this.friend,
    required this.index,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: AppColors.border,
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        children: [
          SquircleAvatar(
            name: friend.name,
            avatarUrl: friend.avatarUrl,
            size: 46,
            borderRadius: 16,
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  friend.name,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  friend.phone,
                  style: const TextStyle(
                    fontSize: 13,
                    color: AppColors.textSecondary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.16),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: AppColors.primary.withOpacity(0.3),
              ),
            ),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.check_circle_rounded,
                  size: 15,
                  color: AppColors.primaryDeep,
                ),
                SizedBox(width: 5),
                Text(
                  'Included',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: AppColors.primaryDeep,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
