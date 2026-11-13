import 'package:flutter/material.dart';

/// Centralized color palette following design.md Section 2 (CRED-inspired minimal fintech).
class AppColors {
  AppColors._();

  // Backgrounds & Surfaces
  static const Color background = Color(0xFFF7F7F5);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color surfaceSubtle = Color(0xFFF1F1EF);
  static const Color surfaceElevated = Color(0xFFFFFFFF);

  // iOS specific tokens aligned with design.md
  static const Color iosBackground = Color(0xFFF7F7F5);
  static const Color iosCard = Color(0xFFFFFFFF);
  static const Color iosSeparator = Color(0xFFEAEAE7);
  static const Color iosTertiaryFill = Color(0xFFF1F1EF);

  // Primary action tokens (near-black #111111)
  static const Color primary = Color(0xFF111111);
  static const Color primaryDark = Color(0xFF111111);
  static const Color primaryDeep = Color(0xFF111111);
  static const Color primaryLight = Color(0xFFF1F1EF);

  // Text hierarchy
  static const Color textPrimary = Color(0xFF111111);
  static const Color textSecondary = Color(0xFF777777);
  static const Color textTertiary = Color(0xFFA0A0A0);
  static const Color textMuted = Color(0xFFA0A0A0);

  // Borders & Dividers
  static const Color border = Color(0xFFEAEAE7);
  static const Color borderMedium = Color(0xFFEAEAE7);

  // Financial status tokens
  static const Color success = Color(0xFF247A45);
  static const Color successSoft = Color(0xFFE7F4E9);
  static const Color danger = Color(0xFFC74747);
  static const Color dangerSoft = Color(0xFFFBEAEA);
  static const Color warning = Color(0xFFA66A16);
  static const Color warningSoft = Color(0xFFFFF3DC);
  static const Color amber = Color(0xFFA66A16);
}
