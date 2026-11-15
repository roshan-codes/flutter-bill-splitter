import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_bill_splitter/core/theme/app_colors.dart';

/// Custom painter for the 3 celebration sparkle rays seen at the top-right of the illustration.
class SparkleRaysPainter extends CustomPainter {
  final Color color;

  const SparkleRaysPainter({
    this.color = const Color(0xFF7E72F2),
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 2.4
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    // Ray 1: Top-most ray (nearly vertical, slanting slightly right)
    canvas.drawLine(
      Offset(size.width * 0.15, size.height * 0.72),
      Offset(size.width * 0.28, size.height * 0.18),
      paint,
    );

    // Ray 2: Middle ray (diagonal ~45 degrees)
    canvas.drawLine(
      Offset(size.width * 0.45, size.height * 0.76),
      Offset(size.width * 0.85, size.height * 0.42),
      paint,
    );

    // Ray 3: Bottom ray (near horizontal, pointing right)
    canvas.drawLine(
      Offset(size.width * 0.58, size.height * 0.96),
      Offset(size.width * 0.98, size.height * 0.86),
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// A squircle box with soft pastel background and celebration sparkle rays at top-right.
class EmptyStateIllustration extends StatelessWidget {
  final Widget child;
  final Color backgroundColor;
  final Color rayColor;
  final double size;

  const EmptyStateIllustration({
    super.key,
    required this.child,
    this.backgroundColor = const Color(0xFFEBE8FC),
    this.rayColor = const Color(0xFF7E72F2),
    this.size = 94.0,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size + 20,
      height: size + 20,
      child: Stack(
        clipBehavior: Clip.none,
        alignment: Alignment.center,
        children: [
          // Sparkle burst rays on top-right
          Positioned(
            top: 0,
            right: 0,
            width: 26,
            height: 26,
            child: CustomPaint(
              painter: SparkleRaysPainter(color: rayColor),
            ),
          ),
          // Squircle container
          Container(
            width: size,
            height: size,
            decoration: BoxDecoration(
              color: backgroundColor,
              borderRadius: BorderRadius.circular(28),
            ),
            child: Center(child: child),
          ),
        ],
      ),
    );
  }
}

/// Precision-rendered Checklist icon for the Activity empty state (3 bullet dots + 3 rounded bars).
class ChecklistIllustration extends StatelessWidget {
  final Color color;

  const ChecklistIllustration({
    super.key,
    this.color = const Color(0xFF5B4DFF),
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 38,
      height: 32,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: List.generate(3, (index) {
          return Row(
            children: [
              Container(
                width: 6.5,
                height: 6.5,
                decoration: BoxDecoration(
                  color: color,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Container(
                  height: 4.5,
                  decoration: BoxDecoration(
                    color: color,
                    borderRadius: BorderRadius.circular(3),
                  ),
                ),
              ),
            ],
          );
        }),
      ),
    );
  }
}

/// Standardized '+ Create Story' black pill button matching the empty state design.
class EmptyStateCreateStoryButton extends StatelessWidget {
  final VoidCallback? onPressed;

  const EmptyStateCreateStoryButton({
    super.key,
    this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: const Color(0xFF111111),
      borderRadius: BorderRadius.circular(28),
      child: InkWell(
        onTap: () {
          HapticFeedback.lightImpact();
          onPressed?.call();
        },
        borderRadius: BorderRadius.circular(28),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 14),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.add_rounded,
                size: 19,
                color: Colors.white,
              ),
              const SizedBox(width: 8),
              Text(
                'Create Story',
                style: GoogleFonts.manrope(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                  letterSpacing: -0.2,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Bottom suggestion category card (e.g. Trip Split, Group Expenses, Room Rent).
class EmptyStateCategoryCard extends StatelessWidget {
  final String label;
  final Widget icon;
  final Color iconBackgroundColor;
  final VoidCallback? onTap;

  const EmptyStateCategoryCard({
    super.key,
    required this.label,
    required this.icon,
    required this.iconBackgroundColor,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.selectionClick();
        onTap?.call();
      },
      behavior: HitTestBehavior.opaque,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 58,
            height: 58,
            decoration: BoxDecoration(
              color: iconBackgroundColor,
              borderRadius: BorderRadius.circular(18),
            ),
            child: Center(child: icon),
          ),
          const SizedBox(height: 10),
          Text(
            label,
            textAlign: TextAlign.center,
            style: GoogleFonts.manrope(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
              height: 1.2,
              letterSpacing: -0.2,
            ),
          ),
        ],
      ),
    );
  }
}
