import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_bill_splitter/core/theme/app_colors.dart';
import 'package:flutter_bill_splitter/core/theme/app_radius.dart';
import 'package:flutter_bill_splitter/shared/widgets/platform_adaptive.dart';

/// Modal bottom sheet giving the user the choice between adding a friend, importing from contacts, or creating a group.
/// Adheres to design.md Section 5, 8 & 9.
class AddOptionsBottomSheet extends StatelessWidget {
  final VoidCallback onAddNewFriend;
  final VoidCallback onImportContacts;
  final VoidCallback onCreateGroup;

  const AddOptionsBottomSheet({
    super.key,
    required this.onAddNewFriend,
    required this.onImportContacts,
    required this.onCreateGroup,
  });

  static Future<void> show(
    BuildContext context, {
    required VoidCallback onAddNewFriend,
    required VoidCallback onImportContacts,
    required VoidCallback onCreateGroup,
  }) {
    HapticFeedback.lightImpact();
    final isIOS = isIOSPlatform(context);

    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: isIOS ? AppColors.iosBackground : AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(AppRadius.cardLarge)),
      ),
      builder: (_) => AddOptionsBottomSheet(
        onAddNewFriend: onAddNewFriend,
        onImportContacts: onImportContacts,
        onCreateGroup: onCreateGroup,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isIOS = isIOSPlatform(context);

    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Center(
              child: Container(
                width: 44,
                height: 5,
                decoration: BoxDecoration(
                  color: AppColors.border,
                  borderRadius: BorderRadius.circular(AppRadius.pill),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'Choose an Option',
              style: GoogleFonts.manrope(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
                letterSpacing: -0.3,
              ),
            ),
            const SizedBox(height: 20),

            // Option 1: Add Friend
            PlatformCard(
              borderRadius: AppRadius.card,
              elevation: 0,
              onTap: () {
                Navigator.pop(context);
                onAddNewFriend();
              },
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              child: Row(
                children: [
                  Container(
                    width: 46,
                    height: 46,
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppColors.surfaceSubtle,
                    ),
                    child: const Icon(
                      Icons.person_add_rounded,
                      color: AppColors.textPrimary,
                      size: 22,
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Text(
                      'Add New Friend',
                      style: GoogleFonts.manrope(
                        fontWeight: FontWeight.w700,
                        fontSize: 16,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ),
                  Icon(
                    isIOS ? CupertinoIcons.chevron_right : Icons.chevron_right_rounded,
                    color: AppColors.textSecondary,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),

            // Option 2: Import from Contacts
            PlatformCard(
              borderRadius: AppRadius.card,
              elevation: 0,
              onTap: () {
                Navigator.pop(context);
                onImportContacts();
              },
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              child: Row(
                children: [
                  Container(
                    width: 46,
                    height: 46,
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppColors.surfaceSubtle,
                    ),
                    child: const Icon(
                      Icons.contacts_rounded,
                      color: AppColors.textPrimary,
                      size: 22,
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Text(
                      'Import from Contacts',
                      style: GoogleFonts.manrope(
                        fontWeight: FontWeight.w700,
                        fontSize: 16,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ),
                  Icon(
                    isIOS ? CupertinoIcons.chevron_right : Icons.chevron_right_rounded,
                    color: AppColors.textSecondary,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),

            // Option 3: Create Group
            PlatformCard(
              borderRadius: AppRadius.card,
              elevation: 0,
              onTap: () {
                Navigator.pop(context);
                onCreateGroup();
              },
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              child: Row(
                children: [
                  Container(
                    width: 46,
                    height: 46,
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppColors.surfaceSubtle,
                    ),
                    child: const Icon(
                      Icons.group_add_rounded,
                      color: AppColors.textPrimary,
                      size: 22,
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Text(
                      'Create New Group',
                      style: GoogleFonts.manrope(
                        fontWeight: FontWeight.w700,
                        fontSize: 16,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ),
                  Icon(
                    isIOS ? CupertinoIcons.chevron_right : Icons.chevron_right_rounded,
                    color: AppColors.textSecondary,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
          ],
        ),
      ),
    );
  }
}
