import 'package:flutter/material.dart';
import 'package:flutter_neumorphism_ui/flutter_neumorphism_ui.dart';
import 'package:flutter_bill_splitter/core/theme/neumorphic_styles.dart';

/// Neumorphic pill button for user logout.
class ProfileLogoutButton extends StatelessWidget {
  final VoidCallback? onLogout;

  const ProfileLogoutButton({
    super.key,
    this.onLogout,
  });

  @override
  Widget build(BuildContext context) {
    const dangerColor = Color(0xFFE53935);

    return InkWell(
      onTap: onLogout,
      borderRadius: BorderRadius.circular(22),
      child: FlutterNeumorphism(
        style: NeumorphicStyles.card(
          borderRadius: 22,
          depth: 4,
        ),
        height: 54,
        width: double.infinity,
        padding: EdgeInsets.zero,
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
