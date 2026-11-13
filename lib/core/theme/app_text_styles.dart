import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';

/// Centralized typography styles following design.md Section 3 (Manrope typeface).
class AppTextStyles {
  AppTextStyles._();

  /// Display: 32 px, ExtraBold (800) - Major expense total
  static TextStyle get display => GoogleFonts.manrope(
        fontSize: 32,
        fontWeight: FontWeight.w800,
        color: AppColors.textPrimary,
        letterSpacing: -0.5,
      );

  /// Screen title: 28 px, Bold (700) - Page headings
  static TextStyle get screenTitle => GoogleFonts.manrope(
        fontSize: 28,
        fontWeight: FontWeight.w700,
        color: AppColors.textPrimary,
        letterSpacing: -0.3,
      );

  /// Section title: 20 px, Bold (700) - Group summary, transactions
  static TextStyle get sectionTitle => GoogleFonts.manrope(
        fontSize: 20,
        fontWeight: FontWeight.w700,
        color: AppColors.textPrimary,
      );

  /// Alias for backward compatibility
  static TextStyle get sectionHeader => sectionTitle;

  /// Card title: 17 px, SemiBold (600) - Story and expense names
  static TextStyle get cardTitle => GoogleFonts.manrope(
        fontSize: 17,
        fontWeight: FontWeight.w600,
        color: AppColors.textPrimary,
      );

  /// Body: 15 px, Regular (400) - Main descriptions
  static TextStyle get body => GoogleFonts.manrope(
        fontSize: 15,
        fontWeight: FontWeight.w400,
        color: AppColors.textPrimary,
      );

  /// Body emphasis: 15 px, SemiBold (600) - Important values
  static TextStyle get bodyEmphasis => GoogleFonts.manrope(
        fontSize: 15,
        fontWeight: FontWeight.w600,
        color: AppColors.textPrimary,
      );

  /// Alias for backward compatibility
  static TextStyle get bodyPrimary => bodyEmphasis;

  /// Supporting: 13 px, Regular (400) - Dates and metadata
  static TextStyle get supporting => GoogleFonts.manrope(
        fontSize: 13,
        fontWeight: FontWeight.w400,
        color: AppColors.textSecondary,
      );

  /// Alias for backward compatibility
  static TextStyle get bodySecondary => supporting;

  /// Caption: 12 px, Medium (500) - Small labels
  static TextStyle get caption => GoogleFonts.manrope(
        fontSize: 12,
        fontWeight: FontWeight.w500,
        color: AppColors.textSecondary,
      );

  /// Field label: 14 px, SemiBold (600)
  static TextStyle get fieldLabel => GoogleFonts.manrope(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        color: AppColors.textPrimary,
      );
}
