import 'package:flutter/material.dart';
import 'package:flutter_bill_splitter/core/theme/app_colors.dart';
import 'package:flutter_bill_splitter/shared/widgets/platform_adaptive.dart';

/// User profile avatar featuring a primary accented circle and user identity.
class ProfileAvatar extends StatelessWidget {
  final String name;
  final String phone;
  final String initial;
  final VoidCallback? onTap;

  const ProfileAvatar({
    super.key,
    this.name = 'Roshan Badwaik',
    this.phone = '+91 9876543210',
    this.initial = 'R',
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        PlatformCircleButton(
          size: 88,
          color: AppColors.primary,
          elevation: 2,
          onTap: onTap,
          child: Text(
            initial,
            style: const TextStyle(
              fontSize: 34,
              fontWeight: FontWeight.w900,
              color: AppColors.primaryDark,
            ),
          ),
        ),
        const SizedBox(height: 16),

        // User Name
        Text(
          name,
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w800,
            color: AppColors.textPrimary,
            letterSpacing: -0.3,
          ),
        ),
        const SizedBox(height: 4),

        // Phone Number
        Text(
          phone,
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: AppColors.textSecondary,
          ),
        ),
      ],
    );
  }
}
