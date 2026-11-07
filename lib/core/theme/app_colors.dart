import 'package:flutter/material.dart';

/// Centralized color palette and Neumorphic design tokens for the Bill Splitter app.
class AppColors {
  AppColors._();

  // Neumorphic canvas and surface base (matching flutter_neumorphism_ui standard)
  static const Color background = Color(0xFFE8EEF2);
  static const Color surface = Color(0xFFE8EEF2);
  static const Color surfaceElevated = Color(0xFFECF2F6);
  static const Color neumorphicLight = Colors.white;
  static const Color neumorphicDark = Color(0xFFC7D3DC);
  static const Color neumorphicPressed = Color(0xFFE1E8EE);

  // Vibrant primary accents
  static const Color primary = Color(0xFF86E829);
  static const Color primaryDark = Color(0xFF10210A);
  static const Color primaryDeep = Color(0xFF284821);
  static const Color primaryLight = Color(0xFFD6F3BF);

  // Text hierarchy
  static const Color textPrimary = Color(0xFF1B241E);
  static const Color textSecondary = Color(0xFF6E7E75);
  static const Color textMuted = Color(0xFF97A69E);

  // Borders & subtle accents
  static const Color border = Color(0xFFDAE3EA);
  static const Color borderMedium = Color(0xFFCFDAE2);

  static const Color amber = Color(0xFFF7B731);
  static const Color danger = Colors.redAccent;
}
