import 'package:flutter/material.dart';

/// Segmented dot/pill indicator for onboarding steps.
class OnboardingPageIndicator extends StatelessWidget {
  final int totalPages;
  final int currentPage;

  const OnboardingPageIndicator({
    super.key,
    this.totalPages = 3,
    this.currentPage = 0,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        for (int i = 0; i < totalPages; i++) ...[
          AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            width: currentPage == i ? 18 : 7,
            height: 7,
            decoration: BoxDecoration(
              color: currentPage == i
                  ? const Color(0xFF86E829)
                  : const Color(0xFFCBD5E1),
              borderRadius: BorderRadius.circular(4),
              boxShadow: currentPage == i
                  ? [
                      BoxShadow(
                        color: const Color(0xFF86E829).withOpacity(0.5),
                        blurRadius: 6,
                        offset: const Offset(0, 1),
                      ),
                    ]
                  : null,
            ),
          ),
          if (i < totalPages - 1) const SizedBox(width: 8),
        ],
      ],
    );
  }
}

