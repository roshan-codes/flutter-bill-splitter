import 'package:flutter/material.dart';
import 'package:flutter_bill_splitter/core/theme/app_colors.dart';

/// Modal bottom sheet giving the user the choice between adding a friend or creating a group.
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
    return showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
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
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.border,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'Choose an Option',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 20),
            ListTile(
              leading: Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.18),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.person_add_rounded, color: AppColors.primaryDeep),
              ),
              title: const Text(
                'Add New Friend',
                style: TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 16,
                  color: AppColors.textPrimary,
                ),
              ),
              subtitle: const Text(
                'Add an individual friend with name & phone',
                style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
              ),
              trailing: const Icon(Icons.chevron_right_rounded, color: AppColors.textSecondary),
              onTap: () {
                Navigator.pop(context);
                onAddFriend();
              },
            ),
            const SizedBox(height: 8),
            ListTile(
              leading: Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppColors.amber.withOpacity(0.18),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.group_add_rounded, color: Color(0xFF8B6400)),
              ),
              title: const Text(
                'Create New Group',
                style: TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 16,
                  color: AppColors.textPrimary,
                ),
              ),
              subtitle: const Text(
                'Select multiple friends to create a split group',
                style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
              ),
              trailing: const Icon(Icons.chevron_right_rounded, color: AppColors.textSecondary),
              onTap: () {
                Navigator.pop(context);
                onCreateGroup();
              },
            ),
            const SizedBox(height: 12),
          ],
        ),
      ),
    );
  }
}
