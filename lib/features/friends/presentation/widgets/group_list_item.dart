import 'package:flutter/material.dart';
import 'package:flutter_bill_splitter/core/theme/app_colors.dart';
import 'package:flutter_bill_splitter/features/friends/domain/models/group.dart';
import 'package:flutter_bill_splitter/shared/widgets/platform_adaptive.dart';

/// Single platform-adaptive item tile for displaying a group in the Groups tab.
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
      borderRadius: 18,
      elevation: 1.5,
      padding: const EdgeInsets.all(14),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(14),
              color: AppColors.primaryLight,
            ),
            child: const Icon(
              Icons.groups_rounded,
              color: AppColors.primaryDeep,
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
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  '${group.members.length} members',
                  style: const TextStyle(
                    fontSize: 13,
                    color: AppColors.textSecondary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          if (onDelete != null)
            IconButton(
              tooltip: 'Delete group',
              icon: Icon(
                Icons.delete_outline_rounded,
                color: Colors.red.shade400,
                size: 20,
              ),
              onPressed: onDelete,
            ),
        ],
      ),
    );
  }
}
