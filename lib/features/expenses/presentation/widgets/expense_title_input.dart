import 'package:flutter/material.dart';
import 'package:flutter_neumorphism_ui/flutter_neumorphism_ui.dart';
import 'package:flutter_bill_splitter/core/theme/app_colors.dart';
import 'package:flutter_bill_splitter/core/theme/neumorphic_styles.dart';

/// Neumorphic input field for entering the Expense Title / Group Name.
class ExpenseTitleInput extends StatelessWidget {
  final TextEditingController controller;
  final String? Function(String?)? validator;

  const ExpenseTitleInput({
    super.key,
    required this.controller,
    this.validator,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Expense Title',
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w800,
            color: AppColors.textPrimary,
            letterSpacing: -0.2,
          ),
        ),
        const SizedBox(height: 10),
        FlutterNeumorphism(
          style: NeumorphicStyles.card(borderRadius: 20, depth: 4),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          child: TextFormField(
            controller: controller,
            style: const TextStyle(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.w700,
              fontSize: 15,
            ),
            decoration: const InputDecoration(
              hintText: 'e.g. Dinner, Groceries, Trip',
              hintStyle: TextStyle(
                color: AppColors.textSecondary,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
              prefixIcon: Icon(
                Icons.restaurant_rounded,
                color: AppColors.textPrimary,
                size: 22,
              ),
              border: InputBorder.none,
              contentPadding: EdgeInsets.symmetric(vertical: 14),
            ),
            validator: validator ??
                (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter an expense title';
                  }
                  return null;
                },
          ),
        ),
      ],
    );
  }
}

