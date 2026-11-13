import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_bill_splitter/core/theme/app_colors.dart';
import 'package:flutter_bill_splitter/core/theme/app_radius.dart';
import 'package:flutter_bill_splitter/core/utils/string_utils.dart';

/// Reusable platform-adaptive squircle avatar with image loading & initials fallback.
/// Adheres to design.md Section 8.
class SquircleAvatar extends StatelessWidget {
  final String name;
  final String? avatarUrl;
  final double size;
  final double borderRadius;
  final Color? backgroundColor;
  final Color? textColor;

  const SquircleAvatar({
    super.key,
    required this.name,
    this.avatarUrl,
    this.size = 40,
    this.borderRadius = AppRadius.iconContainer,
    this.backgroundColor,
    this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    final initials = StringUtils.getInitials(name);
    final bg = backgroundColor ?? AppColors.surfaceSubtle;
    final fg = textColor ?? AppColors.textPrimary;

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(borderRadius),
        border: Border.all(
          color: AppColors.border,
          width: 1.0,
        ),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(borderRadius),
        child: avatarUrl != null && avatarUrl!.isNotEmpty
            ? Image.network(
                avatarUrl!,
                width: size,
                height: size,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => _buildFallback(initials, fg),
              )
            : _buildFallback(initials, fg),
      ),
    );
  }

  Widget _buildFallback(String initials, Color fg) {
    return Center(
      child: Text(
        initials,
        style: GoogleFonts.manrope(
          color: fg,
          fontWeight: FontWeight.w700,
          fontSize: size * 0.38,
        ),
      ),
    );
  }
}
