import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_bill_splitter/core/theme/app_colors.dart';

/// Standardized modal bottom sheet container for TTMM Club.
/// Provides:
/// - Centered drag handle
/// - 24pt rounded top corners
/// - Clean header with title, subtitle, and close button
/// - Keyboard-adaptive padding (`viewInsets.bottom`)
/// - Optional sticky footer for primary action buttons
class AppBottomSheetShell extends StatelessWidget {
  final String? title;
  final String? subtitle;
  final Widget? headerAction;
  final Widget child;
  final Widget? footer;
  final VoidCallback? onClose;
  final EdgeInsetsGeometry padding;
  final double maxHeightFactor;
  final bool isDismissible;

  const AppBottomSheetShell({
    super.key,
    this.title,
    this.subtitle,
    this.headerAction,
    required this.child,
    this.footer,
    this.onClose,
    this.padding = const EdgeInsets.symmetric(horizontal: 20),
    this.maxHeightFactor = 0.90,
    this.isDismissible = true,
  });

  /// Shows the modal bottom sheet using standard TTMM styling.
  static Future<T?> show<T>({
    required BuildContext context,
    required WidgetBuilder builder,
    bool isScrollControlled = true,
    bool isDismissible = true,
    Color backgroundColor = Colors.transparent,
  }) {
    return showModalBottomSheet<T>(
      context: context,
      isScrollControlled: isScrollControlled,
      isDismissible: isDismissible,
      backgroundColor: backgroundColor,
      builder: builder,
    );
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;
    final maxHeight = MediaQuery.of(context).size.height * maxHeightFactor;

    return Container(
      constraints: BoxConstraints(maxHeight: maxHeight),
      padding: EdgeInsets.only(bottom: bottomInset),
      decoration: const BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 10),
            // Centered drag handle
            Center(
              child: Container(
                width: 38,
                height: 4.5,
                decoration: BoxDecoration(
                  color: AppColors.textSecondary.withOpacity(0.25),
                  borderRadius: BorderRadius.circular(3),
                ),
              ),
            ),
            const SizedBox(height: 12),

            // Header row if title or action is provided
            if (title != null || headerAction != null || onClose != null)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (title != null)
                            Text(
                              title!,
                              style: GoogleFonts.manrope(
                                fontSize: 18,
                                fontWeight: FontWeight.w800,
                                color: AppColors.textPrimary,
                                letterSpacing: -0.3,
                              ),
                            ),
                          if (subtitle != null) ...[
                            const SizedBox(height: 2),
                            Text(
                              subtitle!,
                              style: GoogleFonts.manrope(
                                fontSize: 13,
                                color: AppColors.textSecondary,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                    if (headerAction != null) headerAction!,
                    if (onClose != null)
                      GestureDetector(
                        onTap: onClose ?? () => Navigator.of(context).pop(),
                        child: Container(
                          width: 32,
                          height: 32,
                          decoration: BoxDecoration(
                            color: AppColors.textSecondary.withOpacity(0.08),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.close_rounded,
                            size: 18,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ),
                  ],
                ),
              ),

            if (title != null) const SizedBox(height: 14),

            // Content
            Flexible(
              child: Padding(
                padding: padding,
                child: child,
              ),
            ),

            // Optional footer
            if (footer != null) ...[
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 12, 20, 16),
                child: footer!,
              ),
            ],
          ],
        ),
      ),
    );
  }
}
