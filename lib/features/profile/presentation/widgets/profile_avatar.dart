import 'package:flutter/material.dart';
import 'package:flutter_avatar_kit/flutter_avatar_kit.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_bill_splitter/core/theme/app_colors.dart';

/// User profile avatar featuring a customizable memo avatar or clean initial letter.
/// Matches the clean minimal design in screenshot: dark circle, prominent name, and phone.
class ProfileAvatar extends StatelessWidget {
  final String name;
  final String phone;
  final String initial;
  final int? avatarIndex;
  final VoidCallback? onTap;

  const ProfileAvatar({
    super.key,
    this.name = 'Roshan Badwaik',
    this.phone = '+91 9876543210',
    this.initial = 'R',
    this.avatarIndex,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    Widget avatarWidget;

    if (avatarIndex != null) {
      avatarWidget = Container(
        width: 84,
        height: 84,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: AppColors.surfaceSubtle,
          border: Border.all(color: AppColors.border, width: 1.5),
        ),
        child: ClipOval(
          child: AvatarWidget(
            type: AvatarType.memo,
            index: avatarIndex!,
            size: 84,
            shape: AvatarShape.circle,
          ),
        ),
      );
    } else {
      avatarWidget = Container(
        width: 84,
        height: 84,
        decoration: const BoxDecoration(
          shape: BoxShape.circle,
          color: Color(0xFF22262E), // Dark charcoal circle as seen in screenshot
        ),
        child: Center(
          child: Text(
            initial,
            style: GoogleFonts.manrope(
              fontSize: 32,
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
          ),
        ),
      );
    }

    return Column(
      children: [
        GestureDetector(
          onTap: onTap,
          behavior: HitTestBehavior.opaque,
          child: Tooltip(
            message: 'Change Avatar',
            child: avatarWidget,
          ),
        ),
        const SizedBox(height: 14),

        // User Name
        Text(
          name,
          textAlign: TextAlign.center,
          style: GoogleFonts.manrope(
            fontSize: 19,
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
          style: GoogleFonts.manrope(
            fontSize: 13.5,
            fontWeight: FontWeight.w500,
            color: AppColors.textSecondary,
          ),
        ),
      ],
    );
  }
}
