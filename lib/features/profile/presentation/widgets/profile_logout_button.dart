import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_bill_splitter/core/theme/app_radius.dart';

/// Platform-adaptive button for user logout with a soft tinted background
/// and crisp danger action text/icon matching the design screenshot.
class ProfileLogoutButton extends StatelessWidget {
  final VoidCallback? onLogout;

  const ProfileLogoutButton({
    super.key,
    this.onLogout,
  });

  @override
  Widget build(BuildContext context) {
    const dangerColor = Color(0xFFE53935);
    const softRedBg = Color(0xFFFDECE8);
    const softRedBorder = Color(0xFFFCDCD6);

    return Semantics(
      label: 'Logout',
      button: true,
      child: Material(
        color: softRedBg,
        borderRadius: BorderRadius.circular(AppRadius.card),
        child: InkWell(
          onTap: () {
            HapticFeedback.lightImpact();
            onLogout?.call();
          },
          borderRadius: BorderRadius.circular(AppRadius.card),
          child: Container(
            height: 52,
            width: double.infinity,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(AppRadius.card),
              border: Border.all(color: softRedBorder, width: 1.0),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.logout_rounded,
                  color: dangerColor,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Text(
                  'Logout',
                  style: GoogleFonts.manrope(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: dangerColor,
                    letterSpacing: -0.2,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
