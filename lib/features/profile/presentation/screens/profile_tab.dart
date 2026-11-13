import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_bill_splitter/core/theme/app_colors.dart';
import 'package:flutter_bill_splitter/core/theme/app_radius.dart';
import 'package:flutter_bill_splitter/features/friends/presentation/screens/friends_tab.dart';
import 'package:flutter_bill_splitter/features/profile/presentation/widgets/profile_avatar.dart';
import 'package:flutter_bill_splitter/features/profile/presentation/widgets/profile_header.dart';
import 'package:flutter_bill_splitter/features/profile/presentation/widgets/profile_logout_button.dart';
import 'package:flutter_bill_splitter/features/profile/presentation/widgets/profile_menu_card.dart';
import 'package:flutter_bill_splitter/shared/widgets/platform_adaptive.dart';

/// Profile Tab screen matching platform design (Material on Android, Cupertino on iOS).
/// Adheres to design.md Section 2, 3, 4, 6 & 9.
class ProfileTab extends StatelessWidget {
  final VoidCallback? onLogout;
  final VoidCallback? onFriendsTap;
  final VoidCallback? onGroupsTap;

  const ProfileTab({
    super.key,
    this.onLogout,
    this.onFriendsTap,
    this.onGroupsTap,
  });

  void _openFriends(BuildContext context) {
    if (onFriendsTap != null) {
      onFriendsTap!();
      return;
    }
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => const FriendsTab(
          initialSubTabIndex: 0,
          showBackButton: true,
        ),
      ),
    );
  }

  void _openGroups(BuildContext context) {
    if (onGroupsTap != null) {
      onGroupsTap!();
      return;
    }
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => const FriendsTab(
          initialSubTabIndex: 1,
          showBackButton: true,
        ),
      ),
    );
  }

  void _showNotice(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message, style: GoogleFonts.manrope()),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _showLogoutConfirmation(BuildContext context) {
    if (isIOSPlatform(context)) {
      showCupertinoDialog(
        context: context,
        builder: (ctx) => CupertinoAlertDialog(
          title: Text('Confirm Logout', style: GoogleFonts.manrope(fontWeight: FontWeight.w700)),
          content: Text('Are you sure you want to log out of BillSplit?', style: GoogleFonts.manrope()),
          actions: [
            CupertinoDialogAction(
              onPressed: () => Navigator.of(ctx).pop(),
              child: const Text('Cancel'),
            ),
            CupertinoDialogAction(
              isDestructiveAction: true,
              onPressed: () {
                Navigator.of(ctx).pop();
                if (onLogout != null) {
                  onLogout!();
                } else {
                  _showNotice(context, 'Logged out successfully');
                }
              },
              child: const Text('Logout'),
            ),
          ],
        ),
      );
    } else {
      showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          backgroundColor: AppColors.surface,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadius.card),
            side: const BorderSide(color: AppColors.border, width: 1.0),
          ),
          title: Text(
            'Confirm Logout',
            style: GoogleFonts.manrope(
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
          content: Text(
            'Are you sure you want to log out of BillSplit?',
            style: GoogleFonts.manrope(color: AppColors.textSecondary),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: Text('Cancel', style: GoogleFonts.manrope(color: AppColors.textSecondary)),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.danger,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppRadius.buttonSecondary),
                ),
              ),
              onPressed: () {
                Navigator.of(ctx).pop();
                if (onLogout != null) {
                  onLogout!();
                } else {
                  _showNotice(context, 'Logged out successfully');
                }
              },
              child: Text('Logout', style: GoogleFonts.manrope(fontWeight: FontWeight.w700)),
            ),
          ],
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isIOS = isIOSPlatform(context);

    return Scaffold(
      backgroundColor: isIOS ? AppColors.iosBackground : AppColors.background,
      body: SafeArea(
        bottom: false,
        child: SingleChildScrollView(
          physics: isIOS ? const BouncingScrollPhysics() : const ClampingScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 110),
          child: Column(
            children: [
              // Header: Profile title + Edit icon
              ProfileHeader(
                onEditPressed: () => _showNotice(context, 'Edit Profile opened'),
              ),
              const SizedBox(height: 20),

              // Avatar with primary circle, name, and phone
              ProfileAvatar(
                name: 'Roshan Badwaik',
                phone: '+91 9876543210',
                initial: 'R',
                onTap: () => _showNotice(context, 'Avatar selected'),
              ),
              const SizedBox(height: 28),

              // Menu Card with Friends, Groups, and settings
              ProfileMenuCard(
                onFriendsTap: () => _openFriends(context),
                onGroupsTap: () => _openGroups(context),
                onEditProfileTap: () => _showNotice(context, 'Edit Profile opened'),
                onPaymentSettlementTap: () => _showNotice(context, 'Payment & Settlement opened'),
                onAppSettingsTap: () => _showNotice(context, 'App Settings opened'),
                onHelpSupportTap: () => _showNotice(context, 'Help & Support opened'),
                onAboutBillSplitTap: () => _showNotice(context, 'About BillSplit opened'),
              ),
              const SizedBox(height: 24),

              // Logout Button
              ProfileLogoutButton(
                onLogout: () => _showLogoutConfirmation(context),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
