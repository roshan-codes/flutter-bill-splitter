import 'package:flutter/material.dart';
import 'package:flutter_bill_splitter/core/theme/app_colors.dart';

/// Top header for Profile Tab displaying screen title and edit profile shortcut.
class ProfileHeader extends StatelessWidget {
  final VoidCallback? onEditPressed;

  const ProfileHeader({
    super.key,
    this.onEditPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Text(
          'Profile',
          style: TextStyle(
            fontSize: 26,
            fontWeight: FontWeight.w900,
            color: AppColors.textPrimary,
            letterSpacing: -0.5,
          ),
        ),
        IconButton(
          onPressed: onEditPressed,
          icon: const Icon(
            Icons.edit_outlined,
            color: AppColors.textPrimary,
            size: 22,
          ),
          tooltip: 'Edit Profile',
        ),
      ],
    );
  }
}

