import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_bill_splitter/core/theme/app_colors.dart';
import 'package:flutter_bill_splitter/core/utils/avatar_resolver.dart';
import 'package:flutter_bill_splitter/shared/widgets/app_avatar.dart';

/// Top header for Home Tab: greeting and profile avatar button.
/// Adheres to design.md Section 2, 3, 8 & 10.
class HomeHeader extends StatelessWidget {
  final String userName;
  final int? avatarIndex;
  final String? avatarUrl;
  final VoidCallback? onNotificationPressed;
  final VoidCallback? onProfilePressed;

  const HomeHeader({
    super.key,
    this.userName = 'Roshan',
    this.avatarIndex,
    this.avatarUrl,
    this.onNotificationPressed,
    this.onProfilePressed,
  });

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) {
      return 'Good Morning,';
    } else if (hour < 17) {
      return 'Good Afternoon,';
    } else {
      return 'Good Evening,';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Greeting & User Name with TTMM Club app name above
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // App Name: TTMM Club micro-kicker badge
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: AppColors.surfaceSubtle,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  'TTMM CLUB',
                  style: GoogleFonts.manrope(
                    fontSize: 10.5,
                    fontWeight: FontWeight.w800,
                    color: AppColors.textSecondary,
                    letterSpacing: 1.1,
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                _getGreeting(),
                style: GoogleFonts.manrope(
                  fontSize: 22,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textSecondary,
                  letterSpacing: -0.3,
                ),
              ),
              const SizedBox(height: 2),
              Row(
                children: [
                  Text(
                    userName,
                    style: GoogleFonts.manrope(
                      fontSize: 28,
                      fontWeight: FontWeight.w800,
                      color: AppColors.textPrimary,
                      letterSpacing: -0.5,
                    ),
                  ),
                  const SizedBox(width: 8),
                  const Text(
                    '👋',
                    style: TextStyle(fontSize: 24),
                  ),
                ],
              ),
            ],
          ),
        ),

        // Actions: Profile Avatar Button
        Tooltip(
          message: 'Profile',
          child: GestureDetector(
            onTap: () {
              HapticFeedback.lightImpact();
              onProfilePressed?.call();
            },
            behavior: HitTestBehavior.opaque,
            child: Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white,
                border: Border.all(
                  color: AppColors.border,
                  width: 1.2,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.04),
                    blurRadius: 6,
                    offset: const Offset(0, 1),
                  ),
                ],
              ),
              child: Center(
                child: ClipOval(
                  child: AppAvatar(
                    size: 38,
                    name: userName,
                    avatarIndex: avatarIndex,
                    avatarUrl: avatarUrl ??
                        (avatarIndex != null
                            ? 'assets/avatars/memo_${(avatarIndex! % 35) + 1}.png'
                            : AvatarResolver.getDefaultAvatarForName(userName)),
                    isCurrentUser: true,
                    fontSize: 14,
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
