import 'package:flutter/material.dart';

/// Centralized color palette following TTMM visual design system:
/// - Background: #F7F7F5
/// - Surface: #FFFFFF
/// - Primary: #111111
/// - Secondary text: #777777
/// - Border: #EAEAE7
/// - Success: #247A45
/// - Error / Danger: #C74747
class AppColors {
  AppColors._();

  // Backgrounds & Surfaces
  static const Color background = Color(0xFFF7F7F5);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color surfaceSubtle = Color(0xFFF1F1EF);
  static const Color surfaceElevated = Color(0xFFFFFFFF);
  static const Color card = Color(0xFFFFFFFF);
  static const Color cardAlt = Color(0xFFF9FAFB);

  // iOS specific tokens
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
  static const Color textHint = Color(0xFF9CA3AF);

  // Borders & Dividers
  static const Color border = Color(0xFFEAEAE7);
  static const Color borderMedium = Color(0xFFEAEAE7);
  static const Color divider = Color(0xFFE5E7EB);

  // Financial status tokens
  static const Color success = Color(0xFF247A45);
  static const Color successSoft = Color(0xFFE7F4E9);
  static const Color danger = Color(0xFFC74747);
  static const Color error = Color(0xFFC74747);
  static const Color dangerSoft = Color(0xFFFBEAEA);
  static const Color warning = Color(0xFFA66A16);
  static const Color warningSoft = Color(0xFFFFF3DC);
  static const Color amber = Color(0xFFA66A16);

  // Status pills & badges
  static const Color badgeGreenBg = Color(0xFFDCFCE7);
  static const Color badgeGreenText = Color(0xFF16A34A);
  static const Color badgeRedBg = Color(0xFFFEE2E2);
  static const Color badgeRedText = Color(0xFFDC2626);
  static const Color badgeGreyBg = Color(0xFFF3F4F6);
  static const Color badgeGreyText = Color(0xFF4B5563);

  // Disabled states
  static const Color disabled = Color(0xFF9CA3AF);
  static const Color disabledBackground = Color(0xFFE5E7EB);
}
