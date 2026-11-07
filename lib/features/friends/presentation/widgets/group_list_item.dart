import 'package:flutter/material.dart';
import 'package:flutter_neumorphism_ui/flutter_neumorphism_ui.dart';
import 'package:flutter_bill_splitter/core/theme/app_colors.dart';
import 'package:flutter_bill_splitter/core/theme/neumorphic_styles.dart';
import 'package:flutter_bill_splitter/features/friends/domain/models/group.dart';

/// Single neumorphic item tile for displaying a group in the Groups tab.
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
    return FlutterNeumorphism(
      style: NeumorphicStyles.card(borderRadius: 18, depth: 5),
      padding: const EdgeInsets.all(14),
      child: Row(
        children: [
          FlutterNeumorphism(
            style: NeumorphicStyles.card(
              borderRadius: 14,
              depth: 4,
              color: AppColors.primaryLight,
            ),
            width: 48,
            height: 48,
            padding: EdgeInsets.zero,
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
