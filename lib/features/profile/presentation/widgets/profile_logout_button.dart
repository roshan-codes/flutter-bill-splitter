import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bill_splitter/shared/widgets/platform_adaptive.dart';

/// Platform-adaptive button for user logout.
class ProfileLogoutButton extends StatelessWidget {
  final VoidCallback? onLogout;

  const ProfileLogoutButton({
    super.key,
    this.onLogout,
  });

  @override
  Widget build(BuildContext context) {
    const dangerColor = Color(0xFFE53935);

    return Semantics(
      label: 'Logout',
      button: true,
      child: PlatformCard(
        borderRadius: 18,
        elevation: 1,
        height: 54,
        width: double.infinity,
        padding: EdgeInsets.zero,
        onTap: () {
          HapticFeedback.lightImpact();
          onLogout?.call();
        },
        child: const Center(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.logout_rounded,
                color: dangerColor,
                size: 22,
              ),
              SizedBox(width: 8),
              Text(
                'Logout',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  color: dangerColor,
                  letterSpacing: -0.2,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
