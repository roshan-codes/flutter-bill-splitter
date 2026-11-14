import 'dart:math' as math;
import 'package:flutter/material.dart';

/// CustomPainter rendering realistic tropical palm leaves in the top right corner,
/// matching the design mockup for the story / group overview screen.
class PalmBranchPainter extends CustomPainter {
  const PalmBranchPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final stemPaint1 = Paint()
      ..color = const Color(0xFF1B3D23)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.4
      ..strokeCap = StrokeCap.round;

    final stemPaint2 = Paint()
      ..color = const Color(0xFF265230)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.8
      ..strokeCap = StrokeCap.round;

    // Stem 1: Main arching stem from top right corner
    final stem1 = Path();
    stem1.moveTo(size.width, 0);
    stem1.quadraticBezierTo(
      size.width * 0.55,
      size.height * 0.25,
      size.width * 0.15,
      size.height * 0.85,
    );
    canvas.drawPath(stem1, stemPaint1);

    // Stem 2: Secondary overlapping branch
    final stem2 = Path();
    stem2.moveTo(size.width, size.height * 0.15);
    stem2.quadraticBezierTo(
      size.width * 0.70,
      size.height * 0.40,
      size.width * 0.35,
      size.height * 0.95,
    );
    canvas.drawPath(stem2, stemPaint2);

    // Draw fan-like leaflets along stem 1
    _drawFronds(
      canvas: canvas,
      startX: size.width,
      startY: 0,
      controlX: size.width * 0.55,
      controlY: size.height * 0.25,
      endX: size.width * 0.15,
      endY: size.height * 0.85,
      count: 22,
      baseLength: size.height * 0.42,
    );

    // Draw fan-like leaflets along stem 2
    _drawFronds(
      canvas: canvas,
      startX: size.width,
      startY: size.height * 0.15,
      controlX: size.width * 0.70,
      controlY: size.height * 0.40,
      endX: size.width * 0.35,
      endY: size.height * 0.95,
      count: 16,
      baseLength: size.height * 0.32,
    );
  }

  void _drawFronds({
    required Canvas canvas,
    required double startX,
    required double startY,
    required double controlX,
    required double controlY,
    required double endX,
    required double endY,
    required int count,
    required double baseLength,
  }) {
    final leafPaintLight = Paint()
      ..color = const Color(0xFF3E7E4C)
      ..style = PaintingStyle.fill;

    final leafPaintMid = Paint()
      ..color = const Color(0xFF2C6237)
      ..style = PaintingStyle.fill;

    final leafPaintDark = Paint()
      ..color = const Color(0xFF1F4727)
      ..style = PaintingStyle.fill;

    for (int i = 2; i < count; i++) {
      final t = i / count;
      // Bezier curve point evaluation
      final mt = 1.0 - t;
      final x = mt * mt * startX + 2 * mt * t * controlX + t * t * endX;
      final y = mt * mt * startY + 2 * mt * t * controlY + t * t * endY;

      // Tangent vector
      final dx = 2 * (1 - t) * (controlX - startX) + 2 * t * (endX - controlX);
      final dy = 2 * (1 - t) * (controlY - startY) + 2 * t * (endY - controlY);
      final angle = math.atan2(dy, dx);

      final leafLen = baseLength * (0.55 + 0.45 * math.sin(t * math.pi));

      // Leaflet pointing downward-left
      final leafAngleLeft = angle + math.pi / 2.3 + (i % 3) * 0.08;
      final leafEndX = x + leafLen * math.cos(leafAngleLeft);
      final leafEndY = y + leafLen * math.sin(leafAngleLeft);

      final leafTipControlX = x + leafLen * 0.5 * math.cos(leafAngleLeft - 0.2);
      final leafTipControlY = y + leafLen * 0.5 * math.sin(leafAngleLeft - 0.2);

      final leafPath = Path();
      leafPath.moveTo(x, y);
      leafPath.quadraticBezierTo(
          leafTipControlX, leafTipControlY, leafEndX, leafEndY);
      leafPath.quadraticBezierTo(
        x + leafLen * 0.5 * math.cos(leafAngleLeft + 0.15),
        y + leafLen * 0.5 * math.sin(leafAngleLeft + 0.15),
        x,
        y,
      );

      final paint = (i % 3 == 0)
          ? leafPaintLight
          : (i % 3 == 1)
              ? leafPaintMid
              : leafPaintDark;

      canvas.drawPath(leafPath, paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
