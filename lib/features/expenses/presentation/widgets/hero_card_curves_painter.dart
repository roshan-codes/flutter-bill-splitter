import 'package:flutter/material.dart';

/// CustomPainter rendering concentric contour curves in the bottom-right corner
/// of the total expenses card matching the fintech aesthetic in the design mockup.
class HeroCardCurvesPainter extends CustomPainter {
  const HeroCardCurvesPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final strokePaint = Paint()
      ..color = Colors.white.withOpacity(0.08)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;

    // Draw 3 concentric smooth curved lines emanating from bottom right
    final offsets = [0.0, 24.0, 48.0, 72.0];
    for (final offset in offsets) {
      final path = Path();
      path.moveTo(size.width * 0.45 + offset * 0.7, size.height);
      path.cubicTo(
        size.width * 0.55 + offset * 0.6,
        size.height * 0.55 - offset * 0.3,
        size.width * 0.75 + offset * 0.3,
        size.height * 0.35 + offset * 0.1,
        size.width,
        size.height * 0.40 + offset * 0.25,
      );
      canvas.drawPath(path, strokePaint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
