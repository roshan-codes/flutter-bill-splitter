import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_neumorphism_ui/flutter_neumorphism_ui.dart';
import 'package:flutter_bill_splitter/core/theme/app_colors.dart';
import 'package:flutter_bill_splitter/core/theme/neumorphic_styles.dart';
import 'package:flutter_bill_splitter/features/friends/domain/models/friend.dart';

/// Single friend selection card with custom squircle checkbox, pastel avatar, and name.
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

  Color _getAvatarBg(String name) {
    final firstChar = name.isNotEmpty ? name[0].toUpperCase() : 'A';
    switch (firstChar) {
      case 'V':
      case 'S':
        return const Color(0xFFE8F8D8);
      case 'N':
      case 'R':
        return const Color(0xFFFFECE0);
      case 'A':
        return const Color(0xFFE0E7FF);
      case 'P':
        return const Color(0xFFE2E8F0);
      default:
        final hash = name.hashCode.abs();
        final colors = [
          const Color(0xFFE8F8D8),
          const Color(0xFFFFECE0),
          const Color(0xFFE0E7FF),
          const Color(0xFFE2E8F0),
          const Color(0xFFFCE7F3),
          const Color(0xFFFEF3C7),
        ];
        return colors[hash % colors.length];
    }
  }

  Color _getAvatarTextColor(String name) {
    final firstChar = name.isNotEmpty ? name[0].toUpperCase() : 'A';
    switch (firstChar) {
      case 'V':
      case 'S':
        return const Color(0xFF284821);
      case 'N':
      case 'R':
        return const Color(0xFFDC2626);
      case 'A':
        return const Color(0xFF3730A3);
      case 'P':
        return const Color(0xFF334155);
      default:
        return AppColors.textPrimary;
    }
  }

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
      child: InkWell(
        onTap: () {
          HapticFeedback.selectionClick();
          onToggle();
        },
        borderRadius: BorderRadius.circular(18),
        child: FlutterNeumorphism(
        style: NeumorphicStyles.card(borderRadius: 18, depth: 4),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            // Squircle Checkbox
            Container(
              width: 22,
              height: 22,
              decoration: BoxDecoration(
                color: isSelected ? const Color(0xFF86E829) : Colors.white,
                borderRadius: BorderRadius.circular(7),
                border: isSelected
                    ? null
                    : Border.all(color: const Color(0xFFCFDAE2), width: 1.5),
              ),
              child: isSelected
                  ? const Icon(
                      Icons.check_rounded,
                      color: Color(0xFF10210A),
                      size: 16,
                    )
                  : null,
            ),
            const SizedBox(width: 14),

            // Circular Pastel Avatar
            Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: _getAvatarBg(friend.name),
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Text(
                  initial,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w900,
                    color: _getAvatarTextColor(friend.name),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 14),

            // Friend Name
            Expanded(
              child: Text(
                friend.name,
                style: const TextStyle(
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
    ),
  );
}
}

