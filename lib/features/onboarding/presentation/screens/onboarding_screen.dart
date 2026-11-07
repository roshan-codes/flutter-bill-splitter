import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_neumorphism_ui/flutter_neumorphism_ui.dart';
import 'package:flutter_bill_splitter/core/theme/app_colors.dart';
import 'package:flutter_bill_splitter/core/theme/neumorphic_styles.dart';
import 'package:flutter_bill_splitter/features/navigation/presentation/screens/main_screen.dart';
import 'package:flutter_bill_splitter/features/onboarding/presentation/widgets/onboarding_page_indicator.dart';
import 'package:flutter_bill_splitter/features/onboarding/presentation/widgets/onboarding_receipt_card.dart';

/// Onboarding Screen matching the neumorphic design:
/// Stylized 3D receipt visual, swipeable headline & body with 3-dot indicator, "Get Started" button, and "I already have an account".
class OnboardingScreen extends StatefulWidget {
  final VoidCallback? onGetStarted;

  const OnboardingScreen({
    super.key,
    this.onGetStarted,
  });

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  static const List<Map<String, String>> _pages = [
    {
      'title': 'Split Expenses\nwith Friends',
      'subtitle': 'Add bills, split fairly and\ntrack who owes whom.',
    },
    {
      'title': 'Real-Time Balance\n& Debt Tracking',
      'subtitle': 'Know instantly who owes you\nand whom you need to settle with.',
    },
    {
      'title': 'Settle Up with\na Single Tap',
      'subtitle': 'Automatically calculate optimal paths\nto minimize total transactions.',
    },
  ];

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _navigateToMain(BuildContext context) {
    HapticFeedback.lightImpact();
    if (widget.onGetStarted != null) {
      widget.onGetStarted!();
      return;
    }
    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        pageBuilder: (_, __, ___) => const MainScreen(),
        transitionsBuilder: (_, animation, __, child) =>
            FadeTransition(opacity: animation, child: child),
        transitionDuration: const Duration(milliseconds: 500),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 20),
          child: Column(
            children: [
              Expanded(
                child: PageView.builder(
                  controller: _pageController,
                  itemCount: _pages.length,
                  onPageChanged: (index) {
                    HapticFeedback.selectionClick();
                    setState(() => _currentPage = index);
                  },
                  itemBuilder: (context, index) {
                    final page = _pages[index];
                    return Column(
                      children: [
                        const Spacer(flex: 2),

                        // Visual 3D Receipt with Rupee symbol and lime accents
                        const OnboardingReceiptCard(),
                        const Spacer(flex: 2),

                        // Title Headline
                        Text(
                          page['title']!,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.w900,
                            color: AppColors.textPrimary,
                            letterSpacing: -0.5,
                            height: 1.25,
                          ),
                        ),
                        const SizedBox(height: 14),

                        // Subtitle Description
                        Text(
                          page['subtitle']!,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w500,
                            color: AppColors.textSecondary,
                            height: 1.4,
                          ),
                        ),
                        const Spacer(),
                      ],
                    );
                  },
                ),
              ),

              // 3-dot indicator matching active page
              OnboardingPageIndicator(
                totalPages: _pages.length,
                currentPage: _currentPage,
              ),
              const SizedBox(height: 32),

              // Primary "Get Started" Neumorphic Button
              SizedBox(
                width: double.infinity,
                height: 54,
                child: FlutterNeumorphism(
                  style:
                      NeumorphicStyles.primaryButton(borderRadius: 20, depth: 6),
                  padding: EdgeInsets.zero,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.transparent,
                      foregroundColor: AppColors.primaryDark,
                      shadowColor: Colors.transparent,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                    onPressed: () => _navigateToMain(context),
                    child: const Text(
                      'Get Started',
                      style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w800,
                        color: AppColors.primaryDark,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Secondary "I already have an account" button
              TextButton(
                onPressed: () => _navigateToMain(context),
                child: const Text(
                  'I already have an account',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
    );
  }
}
