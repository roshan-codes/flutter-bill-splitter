import 'package:flutter/material.dart';
import 'package:flutter_bill_splitter/core/theme/app_colors.dart';
import 'package:flutter_bill_splitter/features/profile/presentation/widgets/profile_menu_item.dart';
import 'package:flutter_bill_splitter/shared/widgets/platform_adaptive.dart';

/// Platform-adaptive Card container grouping profile navigation menu items.
class ProfileMenuCard extends StatelessWidget {
  final VoidCallback? onEditProfileTap;
  final VoidCallback? onPaymentSettlementTap;
  final VoidCallback? onAppSettingsTap;
  final VoidCallback? onHelpSupportTap;
  final VoidCallback? onAboutBillSplitTap;

  const ProfileMenuCard({
    super.key,
    this.onEditProfileTap,
    this.onPaymentSettlementTap,
    this.onAppSettingsTap,
    this.onHelpSupportTap,
    this.onAboutBillSplitTap,
  });

  @override
  Widget build(BuildContext context) {
    return PlatformCard(
      borderRadius: 20,
      elevation: 1.5,
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
      child: Column(
        children: [
          ProfileMenuItem(
            icon: Icons.person_outline_rounded,
            title: 'Edit Profile',
            onTap: onEditProfileTap,
          ),
          const Divider(color: AppColors.border, height: 1, thickness: 0.8),
          ProfileMenuItem(
            icon: Icons.account_balance_wallet_outlined,
            title: 'Payment & Settlement',
            onTap: onPaymentSettlementTap,
          ),
          const Divider(color: AppColors.border, height: 1, thickness: 0.8),
          ProfileMenuItem(
            icon: Icons.settings_outlined,
            title: 'App Settings',
            onTap: onAppSettingsTap,
          ),
          const Divider(color: AppColors.border, height: 1, thickness: 0.8),
          ProfileMenuItem(
            icon: Icons.help_outline_rounded,
            title: 'Help & Support',
            onTap: onHelpSupportTap,
          ),
          const Divider(color: AppColors.border, height: 1, thickness: 0.8),
          ProfileMenuItem(
            icon: Icons.info_outline_rounded,
            title: 'About BillSplit',
            onTap: onAboutBillSplitTap,
          ),
        ],
      ),
    );
  }
}
