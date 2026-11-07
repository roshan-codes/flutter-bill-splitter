import 'package:flutter/material.dart';
import 'package:flutter_neumorphism_ui/flutter_neumorphism_ui.dart';
import 'package:flutter_bill_splitter/core/theme/app_colors.dart';
import 'package:flutter_bill_splitter/core/theme/neumorphic_styles.dart';
import 'package:flutter_bill_splitter/features/friends/domain/models/group.dart';

/// Single group selection card matching the neumorphic friend tile style.
class GroupSelectionTile extends StatelessWidget {
  final Group group;
  final bool isSelected;
  final VoidCallback onToggle;

  const GroupSelectionTile({
    super.key,
    required this.group,
    required this.isSelected,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onToggle,
      borderRadius: BorderRadius.circular(18),
      child: FlutterNeumorphism(
        style: NeumorphicStyles.card(borderRadius: 18, depth: 4),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            // Squircle Checkbox
            Container(
              width: 22,
              height: 22,
              decoration: BoxDecoration(
                color: isSelected ? const Color(0xFF86E829) : Colors.white,
                borderRadius: BorderRadius.circular(7),
                border: isSelected
                    ? null
                    : Border.all(color: const Color(0xFFCFDAE2), width: 1.5),
              ),
              child: isSelected
                  ? const Icon(
                      Icons.check_rounded,
                      color: Color(0xFF10210A),
                      size: 16,
                    )
                  : null,
            ),
            const SizedBox(width: 14),

            // Group Avatar
            Container(
              width: 38,
              height: 38,
              decoration: const BoxDecoration(
                color: Color(0xFFE8F8D8),
                shape: BoxShape.circle,
              ),
              child: const Center(
                child: Icon(
                  Icons.groups_rounded,
                  color: Color(0xFF284821),
                  size: 20,
                ),
              ),
            ),
            const SizedBox(width: 14),

            // Group Name & Member Count
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    group.name,
                    style: const TextStyle(
                      fontSize: 15.5,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                      letterSpacing: -0.2,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '${group.members.length} members',
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
