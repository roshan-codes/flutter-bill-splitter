import 'package:flutter/material.dart';
import 'package:flutter_bill_splitter/core/theme/app_colors.dart';
import 'package:flutter_bill_splitter/shared/widgets/platform_adaptive.dart';

/// Platform-adaptive segmented pill toggle for switching between Friends and Groups.
class FriendsGroupsToggle extends StatelessWidget {
  final int selectedIndex; // 0: Friends, 1: Groups
  final ValueChanged<int> onToggle;

  const FriendsGroupsToggle({
    super.key,
    required this.selectedIndex,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    return PlatformInsetContainer(
      borderRadius: 18,
      width: double.infinity,
      height: 52,
      padding: const EdgeInsets.all(4),
      child: Row(
        children: [
          // Friends Pill
          Expanded(
            child: _buildTogglePill(
              title: 'Friends',
              icon: Icons.person_outline_rounded,
              isSelected: selectedIndex == 0,
              onTap: () => onToggle(0),
            ),
          ),
          const SizedBox(width: 4),

          // Groups Pill
          Expanded(
            child: _buildTogglePill(
              title: 'Groups',
              icon: Icons.groups_rounded,
              isSelected: selectedIndex == 1,
              onTap: () => onToggle(1),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTogglePill({
    required String title,
    required IconData icon,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    if (isSelected) {
      return Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(14),
          color: AppColors.primary,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 4,
              offset: const Offset(0, 1),
            ),
          ],
        ),
        child: Center(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                color: AppColors.primaryDark,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w800,
                  color: AppColors.primaryDark,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Center(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              color: AppColors.textPrimary,
              size: 20,
            ),
            const SizedBox(width: 8),
            Text(
              title,
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
