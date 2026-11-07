import 'package:flutter/material.dart';
import 'package:flutter_bill_splitter/core/theme/app_colors.dart';
import 'package:flutter_bill_splitter/features/profile/presentation/widgets/profile_avatar.dart';
import 'package:flutter_bill_splitter/features/profile/presentation/widgets/profile_header.dart';
import 'package:flutter_bill_splitter/features/profile/presentation/widgets/profile_logout_button.dart';
import 'package:flutter_bill_splitter/features/profile/presentation/widgets/profile_menu_card.dart';

/// Profile Tab screen matching the user-provided neumorphic design.
class ProfileTab extends StatelessWidget {
  final VoidCallback? onLogout;

  const ProfileTab({
    super.key,
    this.onLogout,
  });

  void _showNotice(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _showLogoutConfirmation(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text(
          'Confirm Logout',
          style: TextStyle(
            fontWeight: FontWeight.w800,
            color: AppColors.textPrimary,
          ),
        ),
        content: const Text(
          'Are you sure you want to log out of BillSplit?',
          style: TextStyle(color: AppColors.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFE53935),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
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
            child: const Text('Logout'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        bottom: false,
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 110),
          child: Column(
            children: [
              // Header: Profile title + Edit icon
              ProfileHeader(
                onEditPressed: () => _showNotice(context, 'Edit Profile opened'),
              ),
              const SizedBox(height: 20),

              // Avatar with glowing lime circle, name, and phone
              ProfileAvatar(
                name: 'Roshan Badwaik',
                phone: '+91 9876543210',
                initial: 'R',
                onTap: () => _showNotice(context, 'Avatar selected'),
              ),
              const SizedBox(height: 28),

              // Menu Card with 5 items
              ProfileMenuCard(
                onEditProfileTap: () => _showNotice(context, 'Edit Profile opened'),
                onPaymentSettlementTap: () => _showNotice(context, 'Payment & Settlement opened'),
                onAppSettingsTap: () => _showNotice(context, 'App Settings opened'),
                onHelpSupportTap: () => _showNotice(context, 'Help & Support opened'),
                onAboutBillSplitTap: () => _showNotice(context, 'About BillSplit opened'),
              ),
              const SizedBox(height: 22),

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
