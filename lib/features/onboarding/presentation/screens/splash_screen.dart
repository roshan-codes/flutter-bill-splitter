import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_bill_splitter/core/services/storage_service.dart';
import 'package:flutter_bill_splitter/core/theme/app_colors.dart';
import 'package:flutter_bill_splitter/core/theme/app_radius.dart';
import 'package:flutter_bill_splitter/features/activity/data/repositories/activity_repository.dart';
import 'package:flutter_bill_splitter/features/friends/data/repositories/friends_repository.dart';
import 'package:flutter_bill_splitter/features/navigation/presentation/screens/main_screen.dart';
import 'package:flutter_bill_splitter/features/onboarding/presentation/screens/onboarding_screen.dart';
import 'package:flutter_bill_splitter/features/onboarding/presentation/widgets/splash_wave_painter.dart';
import 'package:flutter_bill_splitter/shared/widgets/platform_adaptive.dart';

/// Splash Screen matching platform design:
/// Centered lightning squircle badge, BillSplit title, subtitle, and decorative waves.
/// Adheres to design.md Section 2, 3, 5 & 10.
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
    ActivityRepository.instance.init();
    FriendsRepository.instance.init();
    if (widget.autoNavigate) {
      _timer = Timer(widget.duration, _checkNavigation);
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  Future<void> _checkNavigation() async {
    final hasSeenOnboarding =
        await StorageService.instance.getBool('has_completed_onboarding') ??
            false;
    if (!mounted) return;
    if (hasSeenOnboarding) {
      Navigator.of(context).pushReplacement(
        PageRouteBuilder(
          pageBuilder: (_, __, ___) => const MainScreen(),
          transitionsBuilder: (_, animation, __, child) =>
              FadeTransition(opacity: animation, child: child),
          transitionDuration: const Duration(milliseconds: 600),
        ),
      );
    } else {
      _navigateToOnboarding();
    }
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
    final isIOS = isIOSPlatform(context);

    return Scaffold(
      backgroundColor: isIOS ? AppColors.iosBackground : AppColors.background,
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
                    // Official App Logo
                    Container(
                      width: 96,
                      height: 96,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius:
                            BorderRadius.circular(AppRadius.cardLarge),
                        border: Border.all(color: AppColors.border, width: 1.0),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.08),
                            blurRadius: 16,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: ClipRRect(
                        borderRadius:
                            BorderRadius.circular(AppRadius.cardLarge),
                        child: Image.asset(
                          'assets/icon/app_icon.png',
                          width: 96,
                          height: 96,
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),

                    // App Title
                    Text(
                      'TTMM',
                      style: GoogleFonts.manrope(
                        fontSize: 34,
                        fontWeight: FontWeight.w800,
                        color: AppColors.textPrimary,
                        letterSpacing: -0.6,
                      ),
                    ),
                    const SizedBox(height: 12),

                    // Subtitle / Tagline
                    Text(
                      'Split expenses, track balances\nand settle easily',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.manrope(
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
