import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_neumorphism_ui/flutter_neumorphism_ui.dart';
import 'package:flutter_bill_splitter/core/theme/app_colors.dart';
import 'package:flutter_bill_splitter/core/theme/neumorphic_styles.dart';
import 'package:flutter_bill_splitter/features/onboarding/presentation/screens/onboarding_screen.dart';
import 'package:flutter_bill_splitter/features/onboarding/presentation/widgets/splash_wave_painter.dart';

/// Splash Screen matching the neumorphic design:
/// Centered lightning squircle badge, BillSplit title, subtitle, and decorative waves.
class SplashScreen extends StatefulWidget {
  final bool autoNavigate;
  final Duration duration;

  const SplashScreen({
    super.key,
    this.autoNavigate = true,
    this.duration = const Duration(milliseconds: 2500),
  });

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    if (widget.autoNavigate) {
      _timer = Timer(widget.duration, _navigateToOnboarding);
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _navigateToOnboarding() {
    if (!mounted) return;
    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        pageBuilder: (_, __, ___) => const OnboardingScreen(),
        transitionsBuilder: (_, animation, __, child) =>
            FadeTransition(opacity: animation, child: child),
        transitionDuration: const Duration(milliseconds: 600),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: GestureDetector(
        onTap: _navigateToOnboarding,
        child: Stack(
          children: [
            // Decorative background waves
            const Positioned.fill(
              child: CustomPaint(
                painter: SplashWavePainter(),
              ),
            ),

            // Centered Branding
            Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 32),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Vibrant Lime Neumorphic Squircle with Lightning Bolt
                    FlutterNeumorphism(
                      style: NeumorphicStyles.card(
                        borderRadius: 28,
                        depth: 8,
                        color: AppColors.primary,
                      ),
                      width: 96,
                      height: 96,
                      padding: EdgeInsets.zero,
                      child: const Center(
                        child: Icon(
                          Icons.bolt_rounded,
                          color: AppColors.primaryDark,
                          size: 54,
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),

                    // App Title
                    const Text(
                      'BillSplit',
                      style: TextStyle(
                        fontSize: 34,
                        fontWeight: FontWeight.w900,
                        color: AppColors.textPrimary,
                        letterSpacing: -0.6,
                      ),
                    ),
                    const SizedBox(height: 12),

                    // Subtitle / Tagline
                    const Text(
                      'Split expenses, track balances\nand settle easily',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w500,
                        color: AppColors.textSecondary,
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

