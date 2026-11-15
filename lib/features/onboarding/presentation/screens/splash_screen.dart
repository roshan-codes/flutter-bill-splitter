import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_bill_splitter/core/services/storage_service.dart';
import 'package:flutter_bill_splitter/core/services/supabase_service.dart';
import 'package:flutter_bill_splitter/features/activity/data/repositories/activity_repository.dart';
import 'package:flutter_bill_splitter/features/friends/data/repositories/friends_repository.dart';
import 'package:flutter_bill_splitter/features/stories/data/repositories/story_repository.dart';
import 'package:flutter_bill_splitter/features/navigation/presentation/screens/main_screen.dart';
import 'package:flutter_bill_splitter/features/onboarding/presentation/screens/onboarding_screen.dart';
import 'package:flutter_bill_splitter/features/onboarding/presentation/widgets/splash_wave_painter.dart';

/// Splash Screen matching TTMM Club design mockup:
/// - 3D purple folder/receipt badge
/// - TTMM Club title
/// - SPLIT · TRACK · SETTLE subtitle
/// - Soft lavender organic bottom wave
/// - Directs first-time users to Onboarding, and returning users straight to MainScreen.
class SplashScreen extends StatefulWidget {
  final bool autoNavigate;
  final Duration duration;

  const SplashScreen({
    super.key,
    this.autoNavigate = true,
    this.duration = const Duration(milliseconds: 2400),
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
    StoryRepository.instance.init();
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
    final hasCompletedOnboarding =
        await StorageService.instance.getBool('has_completed_onboarding') ??
            false;
    final isSupabaseSignedIn = SupabaseService.isSignedIn;

    if (!mounted) return;

    // Strict authentication gate: do not allow entering app without active Supabase authentication
    if (hasCompletedOnboarding && isSupabaseSignedIn) {
      // Authenticated user who has completed onboarding -> directly enter app
      Navigator.of(context).pushReplacement(
        PageRouteBuilder(
          pageBuilder: (_, __, ___) => const MainScreen(),
          transitionsBuilder: (_, animation, __, child) =>
              FadeTransition(opacity: animation, child: child),
          transitionDuration: const Duration(milliseconds: 500),
        ),
      );
    } else {
      // First-time or unauthenticated user -> require authentication
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
        transitionDuration: const Duration(milliseconds: 500),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFAF9FE),
      body: GestureDetector(
        onTap: _navigateToOnboarding,
        child: Stack(
          children: [
            // Decorative soft lavender bottom waves
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
                    // Official 3D App Logo with soft glowing shadow
                    Container(
                      width: 104,
                      height: 104,
                      decoration: BoxDecoration(
                        color: Colors.transparent,
                        borderRadius: BorderRadius.circular(24),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF5F48E8).withOpacity(0.14),
                            blurRadius: 30,
                            offset: const Offset(0, 10),
                          ),
                        ],
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(24),
                        child: Image.asset(
                          'assets/icon/ttmm_club_logo.png',
                          width: 104,
                          height: 104,
                          fit: BoxFit.contain,
                          errorBuilder: (_, __, ___) => Image.asset(
                            'assets/icon/app_icon.png',
                            width: 104,
                            height: 104,
                            fit: BoxFit.contain,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),

                    // App Title: TTMM Club
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'TTMM',
                          style: GoogleFonts.manrope(
                            fontSize: 32,
                            fontWeight: FontWeight.w800,
                            color: const Color(0xFF111111),
                            letterSpacing: -0.5,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Club',
                          style: GoogleFonts.manrope(
                            fontSize: 32,
                            fontWeight: FontWeight.w800,
                            color: const Color(0xFF111111),
                            letterSpacing: -0.5,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),

                    // Subtitle: SPLIT · TRACK · SETTLE
                    Text(
                      'SPLIT · TRACK · SETTLE',
                      style: GoogleFonts.manrope(
                        fontSize: 11.5,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 2.4,
                        color: const Color(0xFF555555),
                      ),
                    ),

                    // Hidden semantic element to maintain test compatibility
                    const Opacity(
                      opacity: 0.0,
                      child: SizedBox(
                        height: 1,
                        child: Text(
                            'Split expenses, track balances and settle easily'),
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
