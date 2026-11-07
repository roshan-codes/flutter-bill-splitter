import 'package:flutter/material.dart';
import 'package:flutter_neumorphism_ui/flutter_neumorphism_ui.dart';
import 'package:flutter_bill_splitter/core/theme/app_colors.dart';

/// Predefined Neumorphism styles using flutter_neumorphism_ui.
class NeumorphicStyles {
  NeumorphicStyles._();

  /// Standard raised neumorphic card.
  static NeumorphismStyle card({
    double borderRadius = 20.0,
    double depth = 6.0,
    Color? color,
  }) {
    return NeumorphismStyle(
      color: color ?? AppColors.surface,
      borderRadius: borderRadius,
      depth: depth,
      type: NeumorphismType.flat,
      shape: BoxShape.rectangle,
      lightShadow: AppColors.neumorphicLight,
      darkShadow: AppColors.neumorphicDark,
    );
  }

  /// Inset / debossed neumorphic style for input fields, recessed wells, and active states.
  static NeumorphismStyle inset({
    double borderRadius = 16.0,
    double depth = 5.0,
    Color? color,
  }) {
    return NeumorphismStyle(
      color: color ?? AppColors.neumorphicPressed,
      borderRadius: borderRadius,
      depth: depth,
      type: NeumorphismType.pressed,
      shape: BoxShape.rectangle,
      lightShadow: AppColors.neumorphicLight,
      darkShadow: AppColors.neumorphicDark,
    );
  }

  /// Circular raised neumorphic style for icons, avatars, and floating action buttons.
  static NeumorphismStyle circle({
    double depth = 6.0,
    Color? color,
    NeumorphismType type = NeumorphismType.flat,
  }) {
    return NeumorphismStyle(
      color: color ?? AppColors.surface,
      depth: depth,
      type: type,
      shape: BoxShape.circle,
      lightShadow: AppColors.neumorphicLight,
      darkShadow: AppColors.neumorphicDark,
    );
  }

  /// Vibrant primary colored neumorphic button style.
  static NeumorphismStyle primaryButton({
    double borderRadius = 18.0,
    double depth = 6.0,
  }) {
    return NeumorphismStyle(
      color: AppColors.primary,
      borderRadius: borderRadius,
      depth: depth,
      type: NeumorphismType.flat,
      shape: BoxShape.rectangle,
      lightShadow: Colors.white.withOpacity(0.6),
      darkShadow: const Color(0xFF63B01C),
    );
  }
}
