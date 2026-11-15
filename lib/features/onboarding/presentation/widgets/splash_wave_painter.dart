import 'package:flutter/material.dart';

/// Custom Painter that renders the soft lavender bottom wave on the Splash screen.
class SplashWavePainter extends CustomPainter {
  const SplashWavePainter();

  @override
  void paint(Canvas canvas, Size size) {
    // Back subtle lilac wave
    final backPaint = Paint()
      ..color = const Color(0xFFF0ECFC).withOpacity(0.85)
      ..style = PaintingStyle.fill;

    final backPath = Path()
      ..moveTo(0, size.height * 0.76)
      ..cubicTo(
        size.width * 0.25,
        size.height * 0.72,
        size.width * 0.45,
        size.height * 0.82,
        size.width * 0.75,
        size.height * 0.76,
      )
      ..cubicTo(
        size.width * 0.90,
        size.height * 0.73,
        size.width * 0.96,
        size.height * 0.78,
        size.width,
        size.height * 0.80,
      )
      ..lineTo(size.width, size.height)
      ..lineTo(0, size.height)
      ..close();
    canvas.drawPath(backPath, backPaint);

    // Front soft lavender wave
    final frontRect =
        Rect.fromLTWH(0, size.height * 0.78, size.width, size.height * 0.22);
    final frontPaint = Paint()
      ..shader = const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          Color(0xFFEBE6FB),
          Color(0xFFDDD5F8),
        ],
      ).createShader(frontRect)
      ..style = PaintingStyle.fill;

    final frontPath = Path()
      ..moveTo(0, size.height * 0.82)
      ..cubicTo(
        size.width * 0.25,
        size.height * 0.78,
        size.width * 0.55,
        size.height * 0.86,
        size.width * 0.78,
        size.height * 0.88,
      )
      ..cubicTo(
        size.width * 0.88,
        size.height * 0.89,
        size.width * 0.95,
        size.height * 0.93,
        size.width,
        size.height * 0.95,
      )
      ..lineTo(size.width, size.height)
      ..lineTo(0, size.height)
      ..close();
    canvas.drawPath(frontPath, frontPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
