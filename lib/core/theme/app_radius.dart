import 'package:flutter/material.dart';

/// Centralized corner radius tokens following design.md Section 4.
class AppRadius {
  AppRadius._();

  /// Large feature card: 24 px
  static const double cardLarge = 24.0;
  static const BorderRadius borderCardLarge = BorderRadius.all(Radius.circular(24.0));

  /// Standard card: 20 px
  static const double card = 20.0;
  static const BorderRadius borderCard = BorderRadius.all(Radius.circular(20.0));

  /// Input field: 14–16 px (default 16 px)
  static const double input = 16.0;
  static const BorderRadius borderInput = BorderRadius.all(Radius.circular(16.0));

  /// Primary button: 16–18 px (default 18 px)
  static const double button = 18.0;
  static const BorderRadius borderButton = BorderRadius.all(Radius.circular(18.0));

  /// Secondary button: 14–16 px (default 16 px)
  static const double buttonSecondary = 16.0;
  static const BorderRadius borderButtonSecondary = BorderRadius.all(Radius.circular(16.0));

  /// Small icon container / squircle: 12–14 px (default 14 px)
  static const double iconContainer = 14.0;
  static const BorderRadius borderIconContainer = BorderRadius.all(Radius.circular(14.0));

  /// Chips and pills: 999 px (fully rounded)
  static const double pill = 999.0;
  static const BorderRadius borderPill = BorderRadius.all(Radius.circular(999.0));
}
