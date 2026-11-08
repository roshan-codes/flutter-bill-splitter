import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bill_splitter/core/theme/app_colors.dart';

/// Helper to determine if current platform is iOS / macOS.
bool isIOSPlatform(BuildContext context) {
  final platform = Theme.of(context).platform;
  return platform == TargetPlatform.iOS || platform == TargetPlatform.macOS;
}

/// Platform-adaptive Card:
/// - Material 3 Card with elevation, rounded corners and ripple on Android.
/// - Cupertino rounded grouped container with subtle border and iOS tap feedback on iOS.
class PlatformCard extends StatelessWidget {
  final Widget child;
  final double? width;
  final double? height;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final double borderRadius;
  final Color? color;
  final double elevation;
  final BoxBorder? border;
  final VoidCallback? onTap;
  final Clip clipBehavior;

  const PlatformCard({
    super.key,
    required this.child,
    this.width,
    this.height,
    this.padding,
    this.margin,
    this.borderRadius = 16.0,
    this.color,
    this.elevation = 1.0,
    this.border,
    this.onTap,
    this.clipBehavior = Clip.none,
  });

  @override
  Widget build(BuildContext context) {
    final isIOS = isIOSPlatform(context);

    if (isIOS) {
      final cardContent = Container(
        width: width,
        height: height,
        margin: margin,
        padding: padding,
        decoration: BoxDecoration(
          color: color ?? CupertinoColors.secondarySystemGroupedBackground,
          borderRadius: BorderRadius.circular(borderRadius),
          border: border ??
              Border.all(
                color: CupertinoColors.separator.resolveFrom(context).withOpacity(0.18),
                width: 0.8,
              ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        clipBehavior: clipBehavior,
        child: child,
      );

      if (onTap != null) {
        return CupertinoButton(
          padding: EdgeInsets.zero,
          minSize: 0,
          onPressed: onTap,
          child: cardContent,
        );
      }
      return cardContent;
    }

    // Material 3 Design
    Widget card = Card(
      elevation: elevation,
      margin: margin ?? EdgeInsets.zero,
      color: color ?? Colors.white,
      shadowColor: Colors.black.withOpacity(0.08),
      clipBehavior: clipBehavior,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(borderRadius),
        side: border is Border
            ? (border as Border).top
            : const BorderSide(color: AppColors.border, width: 0.8),
      ),
      child: Container(
        width: width,
        height: height,
        padding: padding,
        child: child,
      ),
    );

    if (onTap != null) {
      card = Card(
        elevation: elevation,
        margin: margin ?? EdgeInsets.zero,
        color: color ?? Colors.white,
        shadowColor: Colors.black.withOpacity(0.08),
        clipBehavior: Clip.antiAlias,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(borderRadius),
          side: border is Border
              ? (border as Border).top
              : const BorderSide(color: AppColors.border, width: 0.8),
        ),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(borderRadius),
          child: Container(
            width: width,
            height: height,
            padding: padding,
            child: child,
          ),
        ),
      );
    }

    return card;
  }
}

/// Platform-adaptive Inset container (for input fields, search bars, filter bars):
/// - Material 3 filled surface container on Android.
/// - Cupertino tertiary system fill container on iOS.
class PlatformInsetContainer extends StatelessWidget {
  final Widget child;
  final double? width;
  final double? height;
  final EdgeInsetsGeometry? padding;
  final double borderRadius;
  final Color? color;

  const PlatformInsetContainer({
    super.key,
    required this.child,
    this.width,
    this.height,
    this.padding,
    this.borderRadius = 14.0,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    final isIOS = isIOSPlatform(context);

    return Container(
      width: width,
      height: height,
      padding: padding,
      decoration: BoxDecoration(
        color: color ??
            (isIOS
                ? CupertinoColors.tertiarySystemFill.resolveFrom(context)
                : const Color(0xFFEFF2F5)),
        borderRadius: BorderRadius.circular(borderRadius),
        border: isIOS
            ? null
            : Border.all(color: AppColors.border, width: 0.8),
      ),
      child: child,
    );
  }
}

/// Platform-adaptive Circular Icon / Button:
/// - Material circular container with ripple & elevation on Android.
/// - Cupertino circular button with smooth press opacity on iOS.
class PlatformCircleButton extends StatelessWidget {
  final Widget child;
  final double size;
  final Color? color;
  final VoidCallback? onTap;
  final String? tooltip;
  final double elevation;

  const PlatformCircleButton({
    super.key,
    required this.child,
    this.size = 46.0,
    this.color,
    this.onTap,
    this.tooltip,
    this.elevation = 1.0,
  });

  @override
  Widget build(BuildContext context) {
    final isIOS = isIOSPlatform(context);

    Widget button;
    if (isIOS) {
      button = Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: color ?? CupertinoColors.secondarySystemGroupedBackground,
          border: Border.all(
            color: CupertinoColors.separator.resolveFrom(context).withOpacity(0.18),
            width: 0.8,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 6,
              offset: const Offset(0, 1),
            ),
          ],
        ),
        child: onTap != null
            ? CupertinoButton(
                padding: EdgeInsets.zero,
                minSize: size,
                onPressed: onTap,
                child: child,
              )
            : Center(child: child),
      );
    } else {
      button = Material(
        shape: const CircleBorder(),
        color: color ?? Colors.white,
        elevation: elevation,
        shadowColor: Colors.black.withOpacity(0.1),
        child: InkWell(
          customBorder: const CircleBorder(),
          onTap: onTap,
          child: SizedBox(
            width: size,
            height: size,
            child: Center(child: child),
          ),
        ),
      );
    }

    if (tooltip != null) {
      return Tooltip(
        message: tooltip!,
        child: button,
      );
    }
    return button;
  }
}

/// Platform-adaptive Primary Button:
/// - Material ElevatedButton with bold typography and ripple on Android.
/// - CupertinoButton.filled with smooth press opacity on iOS.
class PlatformButton extends StatelessWidget {
  final Widget child;
  final VoidCallback? onPressed;
  final Color? color;
  final Color? textColor;
  final double height;
  final double borderRadius;
  final double elevation;

  const PlatformButton({
    super.key,
    required this.child,
    required this.onPressed,
    this.color,
    this.textColor,
    this.height = 52.0,
    this.borderRadius = 16.0,
    this.elevation = 1.0,
  });

  @override
  Widget build(BuildContext context) {
    final isIOS = isIOSPlatform(context);

    if (isIOS) {
      return SizedBox(
        width: double.infinity,
        height: height,
        child: CupertinoButton(
          padding: EdgeInsets.zero,
          color: color ?? AppColors.primary,
          borderRadius: BorderRadius.circular(borderRadius),
          onPressed: onPressed,
          child: DefaultTextStyle(
            style: TextStyle(
              color: textColor ?? AppColors.primaryDark,
              fontWeight: FontWeight.w700,
              fontSize: 16,
            ),
            child: child,
          ),
        ),
      );
    }

    return SizedBox(
      width: double.infinity,
      height: height,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: color ?? AppColors.primary,
          foregroundColor: textColor ?? AppColors.primaryDark,
          elevation: elevation,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(borderRadius),
          ),
        ),
        onPressed: onPressed,
        child: child,
      ),
    );
  }
}

/// Platform-adaptive Back Button:
/// Ensures minimum 44x44pt hit target and platform-specific back icon.
class PlatformBackButton extends StatelessWidget {
  final VoidCallback? onPressed;
  final Color? color;
  final double size;

  const PlatformBackButton({
    super.key,
    this.onPressed,
    this.color,
    this.size = 44.0,
  });

  @override
  Widget build(BuildContext context) {
    final isIOS = isIOSPlatform(context);
    final iconColor = color ?? AppColors.textPrimary;

    return Semantics(
      label: 'Back',
      button: true,
      child: Tooltip(
        message: 'Back',
        child: PlatformCircleButton(
          size: size,
          onTap: onPressed ?? () => Navigator.of(context).pop(),
          child: Icon(
            isIOS ? CupertinoIcons.chevron_back : Icons.arrow_back_rounded,
            color: iconColor,
            size: 22,
          ),
        ),
      ),
    );
  }
}

