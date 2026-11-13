import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_bill_splitter/core/theme/app_colors.dart';

/// Clean Receipt illustration with currency symbol, placeholder bars, and minimal surfaces.
/// Adheres to design.md Section 2 & 8.
class OnboardingReceiptCard extends StatelessWidget {
  const OnboardingReceiptCard({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 260,
      height: 240,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Background soft floating sphere (top-left)
          Positioned(
            top: 24,
            left: 36,
            child: Container(
              width: 18,
              height: 18,
              decoration: const BoxDecoration(
                color: AppColors.surfaceSubtle,
                shape: BoxShape.circle,
              ),
            ),
          ),

          // Background tilted subtle card (behind receipt)
          Positioned(
            right: 28,
            top: 52,
            child: Transform.rotate(
              angle: 0.15,
              child: Container(
                width: 110,
                height: 38,
                decoration: BoxDecoration(
                  color: AppColors.surfaceSubtle,
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: AppColors.border, width: 1.0),
                ),
              ),
            ),
          ),

          // Main Raised Receipt with jagged bottom edge
          Transform.rotate(
            angle: -0.06,
            child: SizedBox(
              width: 140,
              height: 175,
              child: CustomPaint(
                painter: const _ReceiptShadowPainter(),
                child: ClipPath(
                  clipper: const _ReceiptClipper(),
                  child: Container(
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      border: Border.all(color: AppColors.border, width: 1.0),
                    ),
                    padding: const EdgeInsets.fromLTRB(16, 22, 16, 20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        // Rupee Symbol inside squircle container
                        Container(
                          width: 52,
                          height: 52,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(14),
                            color: AppColors.surfaceSubtle,
                            border: Border.all(color: AppColors.border, width: 1.0),
                          ),
                          child: Center(
                            child: Text(
                              '₹',
                              style: GoogleFonts.manrope(
                                fontSize: 30,
                                fontWeight: FontWeight.w800,
                                color: AppColors.textPrimary,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 18),

                        // Placeholder lines simulating receipt bill items
                        Container(
                          width: 68,
                          height: 5,
                          decoration: BoxDecoration(
                            color: AppColors.border,
                            borderRadius: BorderRadius.circular(3),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Container(
                          width: 44,
                          height: 5,
                          decoration: BoxDecoration(
                            color: AppColors.surfaceSubtle,
                            borderRadius: BorderRadius.circular(3),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Clipper producing a receipt with rounded top corners and a jagged/sawtooth bottom tear.
class _ReceiptClipper extends CustomClipper<Path> {
  const _ReceiptClipper();

  @override
  Path getClip(Size size) {
    final path = Path();
    const radius = 18.0;

    // Top-left corner
    path.moveTo(0, radius);
    path.quadraticBezierTo(0, 0, radius, 0);

    // Top edge & Top-right corner
    path.lineTo(size.width - radius, 0);
    path.quadraticBezierTo(size.width, 0, size.width, radius);

    // Right edge down
    path.lineTo(size.width, size.height - 10);

    // Jagged bottom edge (sawtooth waves)
    const teeth = 5;
    final toothWidth = size.width / teeth;
    for (int i = teeth; i > 0; i--) {
      final xMiddle = (i - 0.5) * toothWidth;
      final xEnd = (i - 1) * toothWidth;
      path.lineTo(xMiddle, size.height);
      path.lineTo(xEnd, size.height - 10);
    }

    // Left edge up
    path.lineTo(0, radius);
    path.close();

    return path;
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) => false;
}

class _ReceiptShadowPainter extends CustomPainter {
  const _ReceiptShadowPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final path = const _ReceiptClipper().getClip(size);
    final paint = Paint()
      ..color = Colors.black.withOpacity(0.04)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8);
    canvas.drawPath(path.shift(const Offset(0, 4)), paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
