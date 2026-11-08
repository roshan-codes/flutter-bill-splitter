import 'package:flutter/material.dart';

/// Centralized color palette and platform design tokens for the Bill Splitter app.
class AppColors {
  AppColors._();

  // Canvas and surface base
  static const Color background = Color(0xFFF5F7FA);
  static const Color surface = Colors.white;
  static const Color surfaceElevated = Colors.white;

  // Cupertino / iOS specific surface colors
  static const Color iosBackground = Color(0xFFF5F7FA);
  static const Color iosCard = Colors.white;
  static const Color iosSeparator = Color(0x33000000);
  static const Color iosTertiaryFill = Color(0xFFE5E5EA);

  // Vibrant primary accents
  static const Color primary = Color(0xFF76E026);
  static const Color primaryDark = Color(0xFF10210A);
  static const Color primaryDeep = Color(0xFF284821);
  static const Color primaryLight = Color(0xFFD6F3BF);

  // Text hierarchy
  static const Color textPrimary = Color(0xFF1B241E);
  static const Color textSecondary = Color(0xFF6E7E75);
  static const Color textMuted = Color(0xFF97A69E);

  // Borders & subtle accents
  static const Color border = Color(0xFFE2E8F0);
  static const Color borderMedium = Color(0xFFCBD5E1);

  static const Color amber = Color(0xFFF7B731);
  static const Color danger = Colors.redAccent;
}
