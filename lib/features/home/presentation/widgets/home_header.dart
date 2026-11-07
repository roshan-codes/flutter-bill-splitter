import 'package:flutter/material.dart';
import 'package:flutter_neumorphism_ui/flutter_neumorphism_ui.dart';
import 'package:flutter_bill_splitter/core/theme/app_colors.dart';
import 'package:flutter_bill_splitter/core/theme/neumorphic_styles.dart';

/// Top header for Home Tab: lightning badge, notification bell, and greeting.
class HomeHeader extends StatelessWidget {
  final String userName;
  final VoidCallback? onNotificationPressed;

  const HomeHeader({
    super.key,
    this.userName = 'Roshan',
    this.onNotificationPressed,
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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Top Icon Bar: Lime bolt on left, bell on right
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            FlutterNeumorphism(
              style: NeumorphicStyles.card(
                borderRadius: 16,
                depth: 5,
                color: AppColors.primary,
              ),
              width: 48,
              height: 48,
              padding: EdgeInsets.zero,
              child: const Icon(
                Icons.bolt_rounded,
                color: AppColors.primaryDark,
                size: 26,
              ),
            ),
            InkWell(
              onTap: onNotificationPressed,
              borderRadius: BorderRadius.circular(20),
              child: FlutterNeumorphism(
                style: NeumorphicStyles.circle(depth: 4),
                width: 46,
                height: 46,
                padding: EdgeInsets.zero,
                child: const Icon(
                  Icons.notifications_none_rounded,
                  color: AppColors.textPrimary,
                  size: 24,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 20),

        // Greeting
        Text(
          _getGreeting(),
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.w800,
            color: AppColors.textPrimary,
            letterSpacing: -0.4,
          ),
        ),
        const SizedBox(height: 2),
        Row(
          children: [
            Text(
              userName,
              style: const TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.w900,
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
    );
  }
}

