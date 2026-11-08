import 'package:flutter/material.dart';
import 'package:flutter_bill_splitter/core/theme/app_colors.dart';
import 'package:flutter_bill_splitter/core/utils/string_utils.dart';
import 'package:flutter_bill_splitter/shared/widgets/platform_adaptive.dart';

/// Reusable platform-adaptive squircle avatar with image loading & initials fallback.
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
    final bg = backgroundColor ?? AppColors.primaryLight;
    final fg = textColor ?? AppColors.primaryDeep;
    final isIOS = isIOSPlatform(context);

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(borderRadius),
        border: Border.all(
          color: isIOS
              ? AppColors.primary.withOpacity(0.2)
              : AppColors.border,
          width: 0.8,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 4,
            offset: const Offset(0, 1),
          ),
        ],
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
        style: TextStyle(
          color: fg,
          fontWeight: FontWeight.w800,
          fontSize: size * 0.38,
        ),
      ),
    );
  }
}
