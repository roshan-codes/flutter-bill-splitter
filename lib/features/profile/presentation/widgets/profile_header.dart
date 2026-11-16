import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_bill_splitter/core/theme/app_colors.dart';

/// Top header for Profile Tab displaying screen title and circular edit button.
/// Adheres to design.md Section 3.
class ProfileHeader extends StatelessWidget {
  final VoidCallback? onEditPressed;
  final VoidCallback? onBackPressed;

  const ProfileHeader({
    super.key,
    this.onEditPressed,
    this.onBackPressed,
  });

  @override
  Widget build(BuildContext context) {
    final canPop = Navigator.of(context).canPop() || onBackPressed != null;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (canPop) ...[
              GestureDetector(
                onTap: () {
                  HapticFeedback.lightImpact();
                  if (onBackPressed != null) {
                    onBackPressed!();
                  } else {
                    Navigator.of(context).pop();
                  }
                },
                behavior: HitTestBehavior.opaque,
                child: Container(
                  width: 40,
                  height: 40,
                  margin: const EdgeInsets.only(right: 12),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColors.surface,
                    border: Border.all(color: AppColors.border, width: 1.0),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.04),
                        blurRadius: 6,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: const Center(
                    child: Icon(
                      Icons.arrow_back_ios_new_rounded,
                      color: AppColors.textPrimary,
                      size: 18,
                    ),
                  ),
                ),
              ),
            ],
            Text(
              'Profile',
              style: GoogleFonts.manrope(
                fontSize: 28,
                fontWeight: FontWeight.w800,
                color: AppColors.textPrimary,
                letterSpacing: -0.5,
              ),
            ),
          ],
        ),
        GestureDetector(
          onTap: () {
            HapticFeedback.lightImpact();
            onEditPressed?.call();
          },
          behavior: HitTestBehavior.opaque,
          child: Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.surface,
              border: Border.all(color: AppColors.border, width: 1.0),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.04),
                  blurRadius: 6,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: const Center(
              child: Icon(
                Icons.edit_outlined,
                color: AppColors.textPrimary,
                size: 19,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
