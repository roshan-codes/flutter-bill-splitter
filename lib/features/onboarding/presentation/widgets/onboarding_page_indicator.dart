import 'package:flutter/material.dart';

/// Segmented dot/pill indicator for onboarding steps matching the screenshot:
/// Active dot is purple capsule, inactive dots are soft lilac circles.
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
      mainAxisSize: MainAxisSize.min,
      children: [
        for (int i = 0; i < totalPages; i++) ...[
          AnimatedContainer(
            duration: const Duration(milliseconds: 250),
            curve: Curves.easeInOut,
            width: currentPage == i ? 20 : 7,
            height: 7,
            decoration: BoxDecoration(
              color: currentPage == i
                  ? const Color(0xFF5F48E8)
                  : const Color(0xFFDDD5F8),
              borderRadius: BorderRadius.circular(4),
            ),
          ),
          if (i < totalPages - 1) const SizedBox(width: 6),
        ],
      ],
    );
  }
}
