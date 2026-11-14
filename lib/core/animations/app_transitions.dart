import 'package:animations/animations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bill_splitter/core/theme/app_colors.dart';
import 'app_motion.dart';

/// Reusable premium transitions utilizing Flutter's official `animations` package.
class AppTransitions {
  /// FadeScaleTransition modal configuration for alerts and confirmation dialogs (180–250ms).
  static const FadeScaleTransitionConfiguration fadeScaleConfig =
      FadeScaleTransitionConfiguration(
    transitionDuration: AppMotion.normal,
    reverseTransitionDuration: AppMotion.fast,
    barrierDismissible: true,
  );

  /// Shows an alert/confirmation dialog with smooth FadeScaleTransition.
  static Future<T?> showFadeScaleDialog<T>({
    required BuildContext context,
    required WidgetBuilder builder,
    bool barrierDismissible = true,
  }) {
    return showModal<T>(
      context: context,
      configuration: FadeScaleTransitionConfiguration(
        transitionDuration: AppMotion.getDuration(context, AppMotion.normal),
        reverseTransitionDuration:
            AppMotion.getDuration(context, AppMotion.fast),
        barrierDismissible: barrierDismissible,
      ),
      builder: builder,
    );
  }

  /// PageTransitionSwitcher helper with FadeThroughTransition (200–250ms).
  static Widget fadeThroughSwitcher({
    required BuildContext context,
    required Widget child,
    required Object transitionKey,
    Duration duration = AppMotion.normal,
    Color? fillColor,
  }) {
    final effectiveDuration = AppMotion.getDuration(context, duration);
    return PageTransitionSwitcher(
      duration: effectiveDuration,
      reverse: false,
      transitionBuilder: (child, primaryAnimation, secondaryAnimation) {
        return FadeThroughTransition(
          animation: primaryAnimation,
          secondaryAnimation: secondaryAnimation,
          fillColor: fillColor ?? Colors.transparent,
          child: child,
        );
      },
      child: KeyedSubtree(
        key: ValueKey<Object>(transitionKey),
        child: child,
      ),
    );
  }

  /// PageTransitionSwitcher helper with SharedAxisTransition (250–350ms).
  static Widget sharedAxisSwitcher({
    required BuildContext context,
    required Widget child,
    required Object transitionKey,
    bool reverse = false,
    SharedAxisTransitionType type = SharedAxisTransitionType.horizontal,
    Duration duration = AppMotion.medium,
    Color? fillColor,
  }) {
    final effectiveDuration = AppMotion.getDuration(context, duration);
    return PageTransitionSwitcher(
      duration: effectiveDuration,
      reverse: reverse,
      transitionBuilder: (child, primaryAnimation, secondaryAnimation) {
        return SharedAxisTransition(
          animation: primaryAnimation,
          secondaryAnimation: secondaryAnimation,
          transitionType: type,
          fillColor: fillColor ?? Colors.transparent,
          child: child,
        );
      },
      child: KeyedSubtree(
        key: ValueKey<Object>(transitionKey),
        child: child,
      ),
    );
  }

  /// Smooth OpenContainer transformation for Story card -> Story details navigation (350–400ms).
  static Widget openContainer({
    required BuildContext context,
    required Widget Function(BuildContext context, VoidCallback openContainer)
        closedBuilder,
    required Widget Function(BuildContext context, VoidCallback closeContainer)
        openBuilder,
    BorderRadius borderRadius = const BorderRadius.all(Radius.circular(24)),
    Color? closedColor,
    Color? openColor,
    Duration duration = AppMotion.medium,
  }) {
    final effectiveDuration = AppMotion.getDuration(context, duration);
    return OpenContainer(
      transitionType: ContainerTransitionType.fade,
      transitionDuration: effectiveDuration,
      openElevation: 0,
      closedElevation: 0,
      closedShape: RoundedRectangleBorder(borderRadius: borderRadius),
      openShape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
      closedColor: closedColor ?? Colors.transparent,
      openColor: openColor ?? AppColors.background,
      closedBuilder: (context, action) => closedBuilder(context, action),
      openBuilder: (context, action) => openBuilder(context, action),
    );
  }

  /// SharedAxis PageRoute for screen-to-screen navigation.
  static Route<T> sharedAxisRoute<T>({
    required WidgetBuilder builder,
    SharedAxisTransitionType type = SharedAxisTransitionType.horizontal,
    Duration duration = AppMotion.medium,
  }) {
    return PageRouteBuilder<T>(
      transitionDuration: duration,
      reverseTransitionDuration: AppMotion.normal,
      pageBuilder: (context, animation, secondaryAnimation) => builder(context),
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        return SharedAxisTransition(
          animation: animation,
          secondaryAnimation: secondaryAnimation,
          transitionType: type,
          child: child,
        );
      },
    );
  }

  /// FadeThrough PageRoute for bottom nav-level switching.
  static Route<T> fadeThroughRoute<T>({
    required WidgetBuilder builder,
    Duration duration = AppMotion.normal,
  }) {
    return PageRouteBuilder<T>(
      transitionDuration: duration,
      reverseTransitionDuration: AppMotion.fast,
      pageBuilder: (context, animation, secondaryAnimation) => builder(context),
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        return FadeThroughTransition(
          animation: animation,
          secondaryAnimation: secondaryAnimation,
          child: child,
        );
      },
    );
  }
}
