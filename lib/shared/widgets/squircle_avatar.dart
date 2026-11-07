import 'package:flutter/material.dart';
import 'package:flutter_neumorphism_ui/flutter_neumorphism_ui.dart';
import 'package:flutter_bill_splitter/core/theme/app_colors.dart';
import 'package:flutter_bill_splitter/core/theme/neumorphic_styles.dart';
import 'package:flutter_bill_splitter/core/utils/string_utils.dart';

/// Reusable neumorphic squircle avatar with image loading & initials fallback.
class SquircleAvatar extends StatelessWidget {
  final String name;
  final String? avatarUrl;
  final double size;
  final double borderRadius;
  final Color? backgroundColor;
  final Color? textColor;
  final bool isNeumorphic;

  const SquircleAvatar({
    super.key,
    required this.name,
    this.avatarUrl,
    this.size = 40,
    this.borderRadius = 14,
    this.backgroundColor,
    this.textColor,
    this.isNeumorphic = true,
  });

  @override
  Widget build(BuildContext context) {
    final initials = StringUtils.getInitials(name);
    final bg = backgroundColor ?? AppColors.primaryLight;
    final fg = textColor ?? AppColors.primaryDeep;

    final avatarContent = ClipRRect(
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

    if (!isNeumorphic) return avatarContent;

    return FlutterNeumorphism(
      style: NeumorphicStyles.card(
        borderRadius: borderRadius,
        depth: 4,
        color: bg,
      ),
      padding: EdgeInsets.zero,
      width: size,
      height: size,
      child: avatarContent,
    );
  }

  Widget _buildFallback(String initials, Color fg) {
    return Center(
      child: Text(
        initials,
        style: TextStyle(
          color: fg,
          fontWeight: FontWeight.w800,
          fontSize: size * 0.38,
        ),
      ),
    );
  }
}
