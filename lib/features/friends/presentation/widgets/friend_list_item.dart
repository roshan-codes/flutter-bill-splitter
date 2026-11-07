import 'package:flutter/material.dart';
import 'package:flutter_neumorphism_ui/flutter_neumorphism_ui.dart';
import 'package:flutter_bill_splitter/core/theme/app_colors.dart';
import 'package:flutter_bill_splitter/core/theme/neumorphic_styles.dart';
import 'package:flutter_bill_splitter/core/utils/string_utils.dart';
import 'package:flutter_bill_splitter/features/friends/domain/models/friend.dart';

/// Single neumorphic item tile for displaying a friend in the Friends list.
class FriendListItem extends StatelessWidget {
  final Friend friend;
  final VoidCallback? onDelete;

  const FriendListItem({
    super.key,
    required this.friend,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final initials = StringUtils.getInitials(friend.name);

    return FlutterNeumorphism(
      style: NeumorphicStyles.card(borderRadius: 18, depth: 5),
      padding: const EdgeInsets.all(14),
      child: Row(
        children: [
          FlutterNeumorphism(
            style: NeumorphicStyles.circle(
              depth: 4,
              color: AppColors.primaryLight,
            ),
            width: 44,
            height: 44,
            padding: EdgeInsets.zero,
            child: Text(
              initials,
              style: const TextStyle(
                color: AppColors.primaryDeep,
                fontWeight: FontWeight.w800,
                fontSize: 15,
              ),
            ),
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
                    fontWeight: FontWeight.w800,
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
          if (onDelete != null)
            IconButton(
              tooltip: 'Delete friend',
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
