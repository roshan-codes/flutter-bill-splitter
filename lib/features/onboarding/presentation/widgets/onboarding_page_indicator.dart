import 'package:flutter/material.dart';
import 'package:flutter_bill_splitter/core/theme/app_colors.dart';
import 'package:flutter_bill_splitter/core/theme/app_radius.dart';

/// Segmented dot/pill indicator for onboarding steps.
/// Adheres to design.md Section 2 & 4.
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
            width: currentPage == i ? 20 : 7,
            height: 7,
            decoration: BoxDecoration(
              color: currentPage == i
                  ? AppColors.primary
                  : AppColors.border,
              borderRadius: BorderRadius.circular(AppRadius.pill),
            ),
          ),
          if (i < totalPages - 1) const SizedBox(width: 8),
        ],
      ],
    );
  }
}
