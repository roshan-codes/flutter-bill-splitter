import 'package:flutter/material.dart';
import 'package:flutter_bill_splitter/core/theme/app_colors.dart';
import 'package:flutter_bill_splitter/core/utils/string_utils.dart';

/// Reusable squircle/rounded rectangle avatar with image loading & initials fallback.
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
    this.borderRadius = 14,
    this.backgroundColor,
    this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    final initials = StringUtils.getInitials(name);
    final bg = backgroundColor ?? AppColors.primary.withOpacity(0.18);
    final fg = textColor ?? AppColors.primaryDeep;

    return ClipRRect(
      borderRadius: BorderRadius.circular(borderRadius),
      child: Container(
        width: size,
        height: size,
        color: bg,
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
        style: TextStyle(
          color: fg,
          fontWeight: FontWeight.w800,
          fontSize: size * 0.36,
        ),
      ),
    );
  }
}
