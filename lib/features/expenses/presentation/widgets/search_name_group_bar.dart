import 'package:flutter/material.dart';
import 'package:flutter_neumorphism_ui/flutter_neumorphism_ui.dart';
import 'package:flutter_bill_splitter/core/theme/app_colors.dart';
import 'package:flutter_bill_splitter/core/theme/neumorphic_styles.dart';

/// Neumorphic Search input bar with debossed search well and raised action button.
class SearchNameGroupBar extends StatelessWidget {
  final TextEditingController controller;
  final ValueChanged<String> onChanged;
  final VoidCallback onSearchPressed;

  const SearchNameGroupBar({
    super.key,
    required this.controller,
    required this.onChanged,
    required this.onSearchPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: FlutterNeumorphism(
            style: NeumorphicStyles.inset(borderRadius: 28, depth: 4),
            padding: const EdgeInsets.symmetric(horizontal: 4),
            height: 54,
            child: TextField(
              controller: controller,
              onChanged: onChanged,
              style: const TextStyle(
                color: AppColors.textPrimary,
                fontSize: 15,
                fontWeight: FontWeight.w600,
              ),
              decoration: const InputDecoration(
                hintText: 'Search name, group',
                hintStyle: TextStyle(
                  color: AppColors.textMuted,
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                ),
                prefixIcon: Icon(
                  Icons.search_rounded,
                  color: AppColors.textSecondary,
                  size: 22,
                ),
                border: InputBorder.none,
                contentPadding: EdgeInsets.symmetric(vertical: 16),
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        FlutterNeumorphism(
          style: NeumorphismStyle(
            color: AppColors.amber,
            borderRadius: 18,
            depth: 5,
            lightShadow: Colors.white.withOpacity(0.6),
            darkShadow: const Color(0xFFC78F1A),
          ),
          width: 54,
          height: 54,
          padding: EdgeInsets.zero,
          child: IconButton(
            icon: const Icon(
              Icons.search_rounded,
              color: AppColors.primaryDark,
              size: 24,
            ),
            onPressed: onSearchPressed,
          ),
        ),
      ],
    );
  }
}
