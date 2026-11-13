import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_bill_splitter/core/theme/app_colors.dart';
import 'package:flutter_bill_splitter/core/theme/app_radius.dart';
import 'package:flutter_bill_splitter/features/friends/domain/models/friend.dart';
import 'package:flutter_bill_splitter/shared/widgets/platform_adaptive.dart';

/// Single friend selection card with minimal checkbox, circular avatar, and name.
/// Adheres to design.md Section 4, 5, 8 & 10.
class FriendSelectionTile extends StatelessWidget {
  final Friend friend;
  final bool isSelected;
  final VoidCallback onToggle;

  const FriendSelectionTile({
    super.key,
    required this.friend,
    required this.isSelected,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    final initial = friend.name.isNotEmpty ? friend.name[0].toUpperCase() : '?';

    return Semantics(
      label: friend.name,
      checked: isSelected,
      button: true,
      enabled: true,
      onTap: () {
        HapticFeedback.selectionClick();
        onToggle();
      },
      excludeSemantics: true,
      child: PlatformCard(
        borderRadius: AppRadius.card,
        elevation: 0,
        color: AppColors.surface,
        onTap: () {
          HapticFeedback.selectionClick();
          onToggle();
        },
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            // Checkbox
            Container(
              width: 22,
              height: 22,
              decoration: BoxDecoration(
                color: isSelected ? AppColors.primary : AppColors.surface,
                borderRadius: BorderRadius.circular(6),
                border: isSelected
                    ? null
                    : Border.all(color: AppColors.border, width: 1.5),
              ),
              child: isSelected
                  ? const Icon(
                      Icons.check_rounded,
                      color: Colors.white,
                      size: 16,
                    )
                  : null,
            ),
            const SizedBox(width: 14),

            // Circular Neutral Avatar
            Container(
              width: 38,
              height: 38,
              decoration: const BoxDecoration(
                color: AppColors.surfaceSubtle,
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Text(
                  initial,
                  style: GoogleFonts.manrope(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 14),

            // Friend Name
            Expanded(
              child: Text(
                friend.name,
                style: GoogleFonts.manrope(
                  fontSize: 15.5,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                  letterSpacing: -0.2,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
