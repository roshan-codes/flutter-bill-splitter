import 'package:flutter/material.dart';

/// Centralized motion design constants for TTMM app.
/// Follows premium fintech motion guidelines with subtle, purposeful transitions.
class AppMotion {
  // Durations
  static const Duration fast = Duration(milliseconds: 150);
  static const Duration normal = Duration(milliseconds: 250);
  static const Duration medium = Duration(milliseconds: 350);
  static const Duration emphasized = Duration(milliseconds: 400);

  // Motion Curves
  static const Curve standard = Curves.easeInOut;
  static const Curve enter = Curves.easeOut;
  static const Curve exit = Curves.easeIn;
  static const Curve emphasizedCurve = Curves.easeInOutCubic;

  /// Respects user accessibility preferences (Reduce Motion / Disable Animations).
  static Duration getDuration(BuildContext? context, Duration defaultDuration) {
    if (context == null) return defaultDuration;
    final mediaQuery = MediaQuery.maybeOf(context);
    if (mediaQuery != null && mediaQuery.disableAnimations) {
      return Duration.zero;
    }
    return defaultDuration;
  }
}
