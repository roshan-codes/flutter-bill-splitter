import 'package:flutter/material.dart';
import 'package:flutter_neumorphism_ui/flutter_neumorphism_ui.dart';
import 'package:flutter_bill_splitter/core/theme/app_colors.dart';
import 'package:flutter_bill_splitter/core/theme/neumorphic_styles.dart';

/// User profile avatar featuring a glowing lime neumorphic circle and user identity.
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
        // Lime-green glowing Neumorphic circular avatar
        InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(44),
          child: FlutterNeumorphism(
            style: NeumorphicStyles.circle(
              depth: 6,
              color: AppColors.primary,
            ),
            width: 88,
            height: 88,
            padding: EdgeInsets.zero,
            child: Center(
              child: Text(
                initial,
                style: const TextStyle(
                  fontSize: 34,
                  fontWeight: FontWeight.w900,
                  color: AppColors.primaryDark,
                ),
              ),
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
