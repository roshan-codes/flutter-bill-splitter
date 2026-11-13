import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_bill_splitter/core/theme/app_colors.dart';
import 'package:flutter_bill_splitter/core/theme/app_radius.dart';

/// Helper to determine if current platform is iOS / macOS.
bool isIOSPlatform(BuildContext context) {
  final platform = Theme.of(context).platform;
  return platform == TargetPlatform.iOS || platform == TargetPlatform.macOS;
}

/// Platform-adaptive Card adhering to design.md Section 5:
/// - Pure white surface on off-white background
/// - Subtle 1 px border (#EAEAE7)
/// - 20 px default corner radius
/// - Minimal subtle elevation (0 - 1)
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
    this.borderRadius = AppRadius.card,
    this.color,
    this.elevation = 0.0,
    this.border,
    this.onTap,
    this.clipBehavior = Clip.none,
  });

  @override
  Widget build(BuildContext context) {
    final isIOS = isIOSPlatform(context);
    final cardColor = color ?? AppColors.surface;
    final cardBorder = border ?? Border.all(color: AppColors.border, width: 1.0);

    if (isIOS) {
      final cardContent = Container(
        width: width,
        height: height,
        margin: margin,
        padding: padding,
        decoration: BoxDecoration(
          color: cardColor,
          borderRadius: BorderRadius.circular(borderRadius),
          border: cardBorder,
          boxShadow: elevation > 0
              ? [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.04),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ]
              : null,
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
    final borderSide = cardBorder is Border
        ? cardBorder.top
        : const BorderSide(color: AppColors.border, width: 1.0);

    Widget card = Card(
      elevation: elevation,
      margin: margin ?? EdgeInsets.zero,
      color: cardColor,
      shadowColor: Colors.black.withOpacity(0.04),
      clipBehavior: clipBehavior,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(borderRadius),
        side: borderSide,
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
        color: cardColor,
        shadowColor: Colors.black.withOpacity(0.04),
        clipBehavior: Clip.antiAlias,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(borderRadius),
          side: borderSide,
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

/// Platform-adaptive Inset container (for input fields, search bars, filter bars)
/// following design.md Section 7.
class PlatformInsetContainer extends StatelessWidget {
  final Widget child;
  final double? width;
  final double? height;
  final EdgeInsetsGeometry? padding;
  final double borderRadius;
  final Color? color;
  final BoxBorder? border;

  const PlatformInsetContainer({
    super.key,
    required this.child,
    this.width,
    this.height,
    this.padding,
    this.borderRadius = AppRadius.input,
    this.color,
    this.border,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      padding: padding,
      decoration: BoxDecoration(
        color: color ?? AppColors.surfaceSubtle,
        borderRadius: BorderRadius.circular(borderRadius),
        border: border ?? Border.all(color: AppColors.border, width: 1.0),
      ),
      child: child,
    );
  }
}

/// Platform-adaptive Circular Icon / Button:
/// Clean white surface with subtle 1px border (#EAEAE7) and monochrome icon (#111111).
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
    this.elevation = 0.0,
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
          color: color ?? AppColors.surface,
          border: Border.all(
            color: AppColors.border,
            width: 1.0,
          ),
          boxShadow: elevation > 0
              ? [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.04),
                    blurRadius: 6,
                    offset: const Offset(0, 1),
                  ),
                ]
              : null,
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
        shape: const CircleBorder(
          side: BorderSide(color: AppColors.border, width: 1.0),
        ),
        color: color ?? AppColors.surface,
        elevation: elevation,
        shadowColor: Colors.black.withOpacity(0.05),
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

/// Platform-adaptive Primary Button adhering to design.md Section 6:
/// Height: 54–56 px (default 56)
/// Background: #111111 (near-black)
/// Text: #FFFFFF (white)
/// Font: Manrope SemiBold/Bold, 15–16 px
/// Radius: 16–18 px (default 18)
/// Elevation: 0
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
    this.height = 56.0,
    this.borderRadius = AppRadius.button,
    this.elevation = 0.0,
  });

  @override
  Widget build(BuildContext context) {
    final isIOS = isIOSPlatform(context);
    final btnBg = color ?? AppColors.primary;
    final btnFg = textColor ?? Colors.white;

    if (isIOS) {
      return SizedBox(
        width: double.infinity,
        height: height,
        child: CupertinoButton(
          padding: EdgeInsets.zero,
          color: btnBg,
          disabledColor: AppColors.surfaceSubtle,
          borderRadius: BorderRadius.circular(borderRadius),
          onPressed: onPressed,
          child: DefaultTextStyle(
            style: GoogleFonts.manrope(
              color: btnFg,
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
          backgroundColor: btnBg,
          foregroundColor: btnFg,
          elevation: elevation,
          disabledBackgroundColor: AppColors.surfaceSubtle,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(borderRadius),
          ),
        ),
        onPressed: onPressed,
        child: DefaultTextStyle(
          style: GoogleFonts.manrope(
            color: btnFg,
            fontWeight: FontWeight.w700,
            fontSize: 16,
          ),
          child: child,
        ),
      ),
    );
  }
}

/// Platform-adaptive Secondary Button adhering to design.md Section 6:
/// Height: 48–52 px (default 50)
/// Background: #F1F1EF or white with #EAEAE7 border
/// Text: #111111
/// Radius: 14–16 px (default 16)
class PlatformSecondaryButton extends StatelessWidget {
  final Widget child;
  final VoidCallback? onPressed;
  final Color? color;
  final Color? textColor;
  final double height;
  final double borderRadius;

  const PlatformSecondaryButton({
    super.key,
    required this.child,
    required this.onPressed,
    this.color,
    this.textColor,
    this.height = 50.0,
    this.borderRadius = AppRadius.buttonSecondary,
  });

  @override
  Widget build(BuildContext context) {
    final isIOS = isIOSPlatform(context);
    final btnBg = color ?? AppColors.surfaceSubtle;
    final btnFg = textColor ?? AppColors.textPrimary;

    if (isIOS) {
      return SizedBox(
        width: double.infinity,
        height: height,
        child: CupertinoButton(
          padding: EdgeInsets.zero,
          color: btnBg,
          borderRadius: BorderRadius.circular(borderRadius),
          onPressed: onPressed,
          child: DefaultTextStyle(
            style: GoogleFonts.manrope(
              color: btnFg,
              fontWeight: FontWeight.w600,
              fontSize: 15,
            ),
            child: child,
          ),
        ),
      );
    }

    return SizedBox(
      width: double.infinity,
      height: height,
      child: OutlinedButton(
        style: OutlinedButton.styleFrom(
          backgroundColor: btnBg,
          foregroundColor: btnFg,
          side: const BorderSide(color: AppColors.border, width: 1.0),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(borderRadius),
          ),
        ),
        onPressed: onPressed,
        child: DefaultTextStyle(
          style: GoogleFonts.manrope(
            color: btnFg,
            fontWeight: FontWeight.w600,
            fontSize: 15,
          ),
          child: child,
        ),
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
