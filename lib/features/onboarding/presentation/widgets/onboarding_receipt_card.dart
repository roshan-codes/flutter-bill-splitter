import 'package:flutter/material.dart';
import 'package:flutter_neumorphism_ui/flutter_neumorphism_ui.dart';
import 'package:flutter_bill_splitter/core/theme/neumorphic_styles.dart';

/// 3D Neumorphic Receipt illustration with currency symbol, placeholder bars, and lime accents.
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
                color: Color(0xFF86E829),
                shape: BoxShape.circle,
              ),
            ),
          ),

          // Background tilted lime pill (behind receipt)
          Positioned(
            right: 28,
            top: 52,
            child: Transform.rotate(
              angle: 0.15,
              child: Container(
                width: 110,
                height: 38,
                decoration: BoxDecoration(
                  color: const Color(0xFF86E829),
                  borderRadius: BorderRadius.circular(18),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF86E829).withOpacity(0.4),
                      blurRadius: 16,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Main Neumorphic Raised Receipt with jagged bottom edge
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
                      color: const Color(0xFFF9FBFC),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.08),
                          blurRadius: 18,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    padding: const EdgeInsets.fromLTRB(16, 22, 16, 20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        // Rupee Symbol inside squircle container
                        FlutterNeumorphism(
                          style: NeumorphicStyles.card(
                            borderRadius: 14,
                            depth: 3,
                            color: Colors.white,
                          ),
                          width: 52,
                          height: 52,
                          padding: EdgeInsets.zero,
                          child: const Center(
                            child: Text(
                              '₹',
                              style: TextStyle(
                                fontSize: 30,
                                fontWeight: FontWeight.w900,
                                color: Color(0xFF1E293B),
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
                            color: const Color(0xFFCBD5E1),
                            borderRadius: BorderRadius.circular(3),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Container(
                          width: 44,
                          height: 5,
                          decoration: BoxDecoration(
                            color: const Color(0xFFE2E8F0),
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
      ..color = const Color(0xFFC7D3DC).withOpacity(0.4)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 10);
    canvas.drawPath(path.shift(const Offset(4, 6)), paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
