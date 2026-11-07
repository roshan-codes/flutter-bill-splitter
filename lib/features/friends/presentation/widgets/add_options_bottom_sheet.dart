import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_neumorphism_ui/flutter_neumorphism_ui.dart';
import 'package:flutter_bill_splitter/core/theme/app_colors.dart';
import 'package:flutter_bill_splitter/core/theme/neumorphic_styles.dart';

/// Modal bottom sheet giving the user the choice between adding a friend or creating a group with Neumorphic cards.
class AddOptionsBottomSheet extends StatelessWidget {
  final VoidCallback onAddFriend;
  final VoidCallback onCreateGroup;

  const AddOptionsBottomSheet({
    super.key,
    required this.onAddFriend,
    required this.onCreateGroup,
  });

  static Future<void> show(
    BuildContext context, {
    required VoidCallback onAddFriend,
    required VoidCallback onCreateGroup,
  }) {
    HapticFeedback.lightImpact();
    return showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.background,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (_) => AddOptionsBottomSheet(
        onAddFriend: onAddFriend,
        onCreateGroup: onCreateGroup,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            FlutterNeumorphism(
              style: NeumorphicStyles.inset(borderRadius: 4, depth: 2),
              width: 44,
              height: 5,
              padding: EdgeInsets.zero,
              child: const SizedBox.shrink(),
            ),
            const SizedBox(height: 20),
            const Text(
              'Choose an Option',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w800,
                color: AppColors.textPrimary,
                letterSpacing: -0.3,
              ),
            ),
            const SizedBox(height: 20),

            // Option 1: Add Friend
            FlutterNeumorphism(
              style: NeumorphicStyles.card(borderRadius: 20, depth: 5),
              onTap: () {
                Navigator.pop(context);
                onAddFriend();
              },
              padding: const EdgeInsets.all(14),
              child: Row(
                children: [
                  FlutterNeumorphism(
                    style: NeumorphicStyles.circle(
                      depth: 4,
                      color: AppColors.primaryLight,
                    ),
                    width: 46,
                    height: 46,
                    padding: EdgeInsets.zero,
                    child: const Icon(
                      Icons.person_add_rounded,
                      color: AppColors.primaryDeep,
                      size: 22,
                    ),
                  ),
                  const SizedBox(width: 14),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Add New Friend',
                          style: TextStyle(
                            fontWeight: FontWeight.w800,
                            fontSize: 16,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        SizedBox(height: 2),
                        Text(
                          'Add an individual friend with name & phone',
                          style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
                        ),
                      ],
                    ),
                  ),
                  const Icon(Icons.chevron_right_rounded, color: AppColors.textSecondary),
                ],
              ),
            ),
            const SizedBox(height: 14),

            // Option 2: Create Group
            FlutterNeumorphism(
              style: NeumorphicStyles.card(borderRadius: 20, depth: 5),
              onTap: () {
                Navigator.pop(context);
                onCreateGroup();
              },
              padding: const EdgeInsets.all(14),
              child: Row(
                children: [
                  FlutterNeumorphism(
                    style: NeumorphicStyles.circle(
                      depth: 4,
                      color: const Color(0xFFFDEAC8),
                    ),
                    width: 46,
                    height: 46,
                    padding: EdgeInsets.zero,
                    child: const Icon(
                      Icons.group_add_rounded,
                      color: Color(0xFF8B6400),
                      size: 22,
                    ),
                  ),
                  const SizedBox(width: 14),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Create New Group',
                          style: TextStyle(
                            fontWeight: FontWeight.w800,
                            fontSize: 16,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        SizedBox(height: 2),
                        Text(
                          'Select multiple friends to create a split group',
                          style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
                        ),
                      ],
                    ),
                  ),
                  const Icon(Icons.chevron_right_rounded, color: AppColors.textSecondary),
                ],
              ),
            ),
            const SizedBox(height: 14),
          ],
        ),
      ),
    );
  }
}
