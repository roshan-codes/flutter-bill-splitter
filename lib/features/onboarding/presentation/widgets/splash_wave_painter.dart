import 'package:flutter/material.dart';

/// Custom Painter that renders the bottom and top decorative waves on the Splash screen.
/// Adheres to design.md Section 2 (restrained neutral accents).
class SplashWavePainter extends CustomPainter {
  const SplashWavePainter();

  @override
  void paint(Canvas canvas, Size size) {
    // Top-left subtle soft grey wave
    final topPaint = Paint()
      ..color = const Color(0xFFEAEAE7).withOpacity(0.5)
      ..style = PaintingStyle.fill;

    final topPath = Path()
      ..moveTo(0, size.height * 0.25)
      ..cubicTo(
        size.width * 0.35,
        size.height * 0.22,
        size.width * 0.25,
        size.height * 0.05,
        size.width * 0.6,
        0,
      )
      ..lineTo(0, 0)
      ..close();
    canvas.drawPath(topPath, topPaint);

    // Bottom back wave (soft translucent surface-subtle)
    final backWavePaint = Paint()
      ..color = const Color(0xFFEAEAE7).withOpacity(0.6)
      ..style = PaintingStyle.fill;

    final backWavePath = Path()
      ..moveTo(0, size.height * 0.82)
      ..cubicTo(
        size.width * 0.25,
        size.height * 0.84,
        size.width * 0.45,
        size.height * 0.76,
        size.width * 0.75,
        size.height * 0.82,
      )
      ..cubicTo(
        size.width * 0.88,
        size.height * 0.85,
        size.width * 0.95,
        size.height * 0.88,
        size.width,
        size.height * 0.85,
      )
      ..lineTo(size.width, size.height)
      ..lineTo(0, size.height)
      ..close();
    canvas.drawPath(backWavePath, backWavePaint);

    // Bottom front wave (restrained subtle gradient wave)
    final rect = Rect.fromLTWH(0, size.height * 0.78, size.width, size.height * 0.22);
    final frontWavePaint = Paint()
      ..shader = const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          Color(0xFFF1F1EF),
          Color(0xFFEAEAE7),
          Color(0xFFF7F7F5),
        ],
      ).createShader(rect)
      ..style = PaintingStyle.fill;

    final frontWavePath = Path()
      ..moveTo(0, size.height * 0.82)
      ..cubicTo(
        size.width * 0.25,
        size.height * 0.77,
        size.width * 0.55,
        size.height * 0.84,
        size.width * 0.78,
        size.height * 0.88,
      )
      ..cubicTo(
        size.width * 0.88,
        size.height * 0.90,
        size.width * 0.95,
        size.height * 0.93,
        size.width,
        size.height * 0.96,
      )
      ..lineTo(size.width, size.height)
      ..lineTo(0, size.height)
      ..close();
    canvas.drawPath(frontWavePath, frontWavePaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
