import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_bill_splitter/core/theme/app_colors.dart';
import 'package:flutter_bill_splitter/core/theme/app_radius.dart';
import 'package:flutter_bill_splitter/features/profile/presentation/widgets/profile_menu_item.dart';
import 'package:flutter_bill_splitter/shared/widgets/platform_adaptive.dart';

/// Platform-adaptive Card container grouping profile navigation menu items into
/// distinct sections (SOCIAL, ACCOUNT, APP) matching the design screenshot.
class ProfileMenuCard extends StatelessWidget {
  final VoidCallback? onFriendsTap;
  final VoidCallback? onGroupsTap;
  final VoidCallback? onEditProfileTap;
  final VoidCallback? onPaymentSettlementTap;
  final VoidCallback? onAppSettingsTap;
  final VoidCallback? onHelpSupportTap;
  final VoidCallback? onAboutBillSplitTap;

  const ProfileMenuCard({
    super.key,
    this.onFriendsTap,
    this.onGroupsTap,
    this.onEditProfileTap,
    this.onPaymentSettlementTap,
    this.onAppSettingsTap,
    this.onHelpSupportTap,
    this.onAboutBillSplitTap,
  });

  Widget _buildSectionLabel(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 8),
      child: Text(
        title,
        style: GoogleFonts.manrope(
          fontSize: 11.5,
          fontWeight: FontWeight.w700,
          color: AppColors.textTertiary,
          letterSpacing: 0.8,
        ),
      ),
    );
  }

  Widget _buildGroupCard(List<Widget> children) {
    return PlatformCard(
      borderRadius: AppRadius.card,
      elevation: 0,
      color: AppColors.surface,
      width: double.infinity,
      padding: EdgeInsets.zero,
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: children,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    const divider = Divider(
      color: AppColors.border,
      height: 1,
      thickness: 0.8,
      indent: 18,
      endIndent: 18,
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // SECTION 1: SOCIAL
        _buildSectionLabel('SOCIAL'),
        _buildGroupCard([
          ProfileMenuItem(
            icon: Icons.people_outline_rounded,
            title: 'Friends',
            onTap: onFriendsTap,
          ),
          divider,
          ProfileMenuItem(
            icon: Icons.groups_outlined,
            title: 'Groups',
            onTap: onGroupsTap,
          ),
        ]),
        const SizedBox(height: 20),

        // SECTION 2: ACCOUNT
        _buildSectionLabel('ACCOUNT'),
        _buildGroupCard([
          ProfileMenuItem(
            icon: Icons.person_outline_rounded,
            title: 'Edit Profile',
            onTap: onEditProfileTap,
          ),
          divider,
          ProfileMenuItem(
            icon: Icons.account_balance_wallet_outlined,
            title: 'Payment & Settlement',
            onTap: onPaymentSettlementTap,
          ),
        ]),
        const SizedBox(height: 20),

        // SECTION 3: APP
        _buildSectionLabel('APP'),
        _buildGroupCard([
          ProfileMenuItem(
            icon: Icons.settings_outlined,
            title: 'App Settings',
            onTap: onAppSettingsTap,
          ),
          divider,
          ProfileMenuItem(
            icon: Icons.help_outline_rounded,
            title: 'Help & Support',
            onTap: onHelpSupportTap,
          ),
          divider,
          ProfileMenuItem(
            icon: Icons.info_outline_rounded,
            title: 'About TTMM',
            onTap: onAboutBillSplitTap,
          ),
        ]),
      ],
    );
  }
}
