import 'package:animations/animations.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_bill_splitter/core/animations/app_motion.dart';
import 'package:flutter_bill_splitter/core/animations/app_transitions.dart';
import 'package:flutter_bill_splitter/core/services/storage_service.dart';
import 'package:flutter_bill_splitter/core/services/supabase_service.dart';
import 'package:flutter_bill_splitter/core/theme/app_colors.dart';
import 'package:flutter_bill_splitter/core/theme/app_radius.dart';
import 'package:flutter_bill_splitter/features/friends/presentation/screens/friends_tab.dart';
import 'package:flutter_bill_splitter/features/onboarding/presentation/screens/onboarding_screen.dart';
import 'package:flutter_bill_splitter/features/profile/presentation/widgets/memo_avatar_picker_sheet.dart';
import 'package:flutter_bill_splitter/features/profile/presentation/widgets/profile_avatar.dart';
import 'package:flutter_bill_splitter/features/profile/presentation/widgets/profile_header.dart';
import 'package:flutter_bill_splitter/features/profile/presentation/widgets/profile_logout_button.dart';
import 'package:flutter_bill_splitter/features/profile/presentation/widgets/profile_menu_card.dart';
import 'package:flutter_bill_splitter/features/stories/data/repositories/story_repository.dart';
import 'package:flutter_bill_splitter/shared/widgets/platform_adaptive.dart';

/// Profile Tab screen matching platform design (Material on Android, Cupertino on iOS).
/// Adheres to design.md Section 2, 3, 4, 6 & 9.
class ProfileTab extends StatefulWidget {
  final VoidCallback? onLogout;
  final VoidCallback? onFriendsTap;
  final VoidCallback? onGroupsTap;
  final int? initialAvatarIndex;
  final String? initialUserName;
  final String? initialPhone;
  final String? initialEmail;

  const ProfileTab({
    super.key,
    this.onLogout,
    this.onFriendsTap,
    this.onGroupsTap,
    this.initialAvatarIndex,
    this.initialUserName,
    this.initialPhone,
    this.initialEmail,
  });

  @override
  State<ProfileTab> createState() => _ProfileTabState();
}

class _ProfileTabState extends State<ProfileTab> {
  int? _avatarIndex;
  String? _avatarUrl;
  String _userName = 'Guest User';
  String _userEmail = '';
  String _userPhone = '';

  @override
  void initState() {
    super.initState();
    _avatarIndex = widget.initialAvatarIndex;
    if (widget.initialUserName != null && widget.initialUserName!.isNotEmpty) {
      _userName = widget.initialUserName!;
    }
    if (widget.initialPhone != null && widget.initialPhone!.isNotEmpty) {
      _userPhone = widget.initialPhone!;
    }
    if (widget.initialEmail != null && widget.initialEmail!.isNotEmpty) {
      _userEmail = widget.initialEmail!;
    }
    _loadSavedProfile();
  }

  Future<void> _loadSavedProfile() async {
    final googleName = SupabaseService.userDisplayName;
    final googleEmail = SupabaseService.userEmail;
    final googleContact = SupabaseService.userContactInfo;
    final googleAvatar = SupabaseService.userAvatarUrl;
    final dbAvatarIndex = SupabaseService.userAvatarIndex;

    final savedAvatar =
        await StorageService.instance.getInt('user_profile_avatar_index');
    final savedName =
        await StorageService.instance.getString('user_profile_name');
    final savedEmail =
        await StorageService.instance.getString('user_profile_email');
    final savedPhone =
        await StorageService.instance.getString('user_profile_phone');
    final savedAvatarUrl =
        await StorageService.instance.getString('user_profile_avatar_url');

    if (mounted) {
      setState(() {
        final resolvedName = widget.initialUserName ?? googleName ?? savedName;
        if (resolvedName != null && resolvedName.isNotEmpty) {
          _userName = resolvedName;
        }

        _avatarIndex ??= savedAvatar ?? dbAvatarIndex;
        _avatarUrl = googleAvatar ?? savedAvatarUrl;

        final resolvedEmail = widget.initialEmail ?? googleEmail ?? savedEmail;
        if (resolvedEmail != null && resolvedEmail.isNotEmpty) {
          _userEmail = resolvedEmail;
        }

        final resolvedContact = widget.initialPhone ?? googleContact ?? savedPhone;
        if (resolvedContact != null && resolvedContact.isNotEmpty) {
          _userPhone = resolvedContact;
        }
      });
    }
  }

  void _openCommunities(BuildContext context) {
    if (widget.onGroupsTap != null) {
      widget.onGroupsTap!();
      return;
    }
    Navigator.of(context).push(
      AppTransitions.sharedAxisRoute(
        type: SharedAxisTransitionType.horizontal,
        duration: AppMotion.medium,
        builder: (context) => const FriendsTab(
          initialSubTabIndex: 1,
          showBackButton: true,
        ),
      ),
    );
  }

  void _openAppSettings(BuildContext context) {
    HapticFeedback.lightImpact();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.info_outline_rounded,
                color: Colors.white, size: 20),
            const SizedBox(width: 10),
            Text(
              'App Settings is coming soon!',
              style: GoogleFonts.manrope(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
          ],
        ),
        backgroundColor: const Color(0xFF1E1E1E),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        margin: const EdgeInsets.fromLTRB(16, 0, 16, 20),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _showHelpSupportSheet(BuildContext context) {
    HapticFeedback.lightImpact();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(ctx).size.height * 0.88,
        ),
        padding: EdgeInsets.fromLTRB(
            20, 16, 20, MediaQuery.of(ctx).padding.bottom + 24),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        ),
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 36,
                height: 4,
                decoration: BoxDecoration(
                  color: const Color(0xFFE5E7EB),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: const Color(0xFFF3F0FF),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: const Center(
                    child: Icon(
                      Icons.support_agent_rounded,
                      color: Color(0xFF5B4DFF),
                      size: 24,
                    ),
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Help & Support',
                        style: GoogleFonts.manrope(
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                          color: const Color(0xFF111111),
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'We are here to assist you anytime',
                        style: GoogleFonts.manrope(
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                          color: const Color(0xFF6B7280),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Contact Item 1: Email
            _buildContactTile(
              icon: Icons.mail_outline_rounded,
              iconColor: const Color(0xFF2563EB),
              iconBgColor: const Color(0xFFEFF6FF),
              label: 'Email Support',
              value: 'support@ttmm.app',
              onTap: () {
                Clipboard.setData(
                    const ClipboardData(text: 'support@ttmm.app'));
                HapticFeedback.mediumImpact();
                _showNotice(
                    context, 'Email copied to clipboard: support@ttmm.app');
              },
            ),
            const SizedBox(height: 12),

            // Contact Item 2: Phone
            _buildContactTile(
              icon: Icons.phone_outlined,
              iconColor: const Color(0xFF16A34A),
              iconBgColor: const Color(0xFFF0FDF4),
              label: 'Phone Support',
              value: '+91 98765 43210',
              onTap: () {
                Clipboard.setData(
                    const ClipboardData(text: '+91 98765 43210'));
                HapticFeedback.mediumImpact();
                _showNotice(
                    context, 'Phone copied to clipboard: +91 98765 43210');
              },
            ),
            const SizedBox(height: 12),

            // Working Hours
            Container(
              width: double.infinity,
              padding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: const Color(0xFFF9FAFB),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFFF3F4F6)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.access_time_rounded,
                      size: 18, color: Color(0xFF9CA3AF)),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'Mon - Fri: 9:00 AM - 6:00 PM IST',
                      style: GoogleFonts.manrope(
                        fontSize: 12.5,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF6B7280),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Close button
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF111111),
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                onPressed: () => Navigator.of(ctx).pop(),
                child: Text(
                  'Close',
                  style: GoogleFonts.manrope(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    ),
  );
  }

  Widget _buildContactTile({
    required IconData icon,
    required Color iconColor,
    required Color iconBgColor,
    required String label,
    required String value,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFE5E7EB)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.02),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: iconBgColor,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Center(
                child: Icon(icon, color: iconColor, size: 20),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: GoogleFonts.manrope(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: const Color(0xFF6B7280),
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    value,
                    style: GoogleFonts.manrope(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFF111111),
                    ),
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: const Color(0xFFF3F4F6),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.copy_rounded,
                      size: 13, color: Color(0xFF374151)),
                  const SizedBox(width: 4),
                  Text(
                    'Copy',
                    style: GoogleFonts.manrope(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFF374151),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showAboutTtmmSheet(BuildContext context) {
    HapticFeedback.lightImpact();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(ctx).size.height * 0.88,
        ),
        padding: EdgeInsets.fromLTRB(
            20, 16, 20, MediaQuery.of(ctx).padding.bottom + 24),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        ),
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Center(
              child: Container(
                width: 36,
                height: 4,
                decoration: BoxDecoration(
                  color: const Color(0xFFE5E7EB),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 20),

            // App Icon Badge
            Container(
              width: 68,
              height: 68,
              decoration: BoxDecoration(
                color: const Color(0xFF111111),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.12),
                    blurRadius: 16,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: const Center(
                child: Text(
                  '🌴',
                  style: TextStyle(fontSize: 32),
                ),
              ),
            ),
            const SizedBox(height: 14),

            // App Name & Tagline
            Text(
              'TTMM',
              style: GoogleFonts.manrope(
                fontSize: 24,
                fontWeight: FontWeight.w900,
                color: const Color(0xFF111111),
                letterSpacing: -0.5,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              'Tera Tu Mera Me • Bill Splitter',
              style: GoogleFonts.manrope(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: const Color(0xFF6B7280),
              ),
            ),
            const SizedBox(height: 8),

            // Version Pill
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: const Color(0xFFF3F4F6),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                'Version 1.0.0 (Build 2026.11)',
                style: GoogleFonts.manrope(
                  fontSize: 11.5,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF4B5563),
                ),
              ),
            ),
            const SizedBox(height: 18),

            // Description Box
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFFF9FAFB),
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: const Color(0xFFF3F4F6)),
              ),
              child: Text(
                'TTMM makes shared expenses effortless, transparent, and fair. Split bills on trips, outings, and events with smart settlement optimization, advance tracking, and real-time clarity.',
                style: GoogleFonts.manrope(
                  fontSize: 13.5,
                  fontWeight: FontWeight.w500,
                  color: const Color(0xFF374151),
                  height: 1.5,
                ),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 16),

            // Key Highlights
            _buildAboutFeatureRow(
              icon: Icons.flash_on_rounded,
              color: const Color(0xFFEAB308),
              title: 'Smart Settlement Paths',
              subtitle:
                  'Minimal transactions so everyone settles up quickly',
            ),
            const SizedBox(height: 10),
            _buildAboutFeatureRow(
              icon: Icons.payments_outlined,
              color: const Color(0xFF16A34A),
              title: 'Advance & Direct Transfers',
              subtitle:
                  'Track advances before trip expenses are finalized',
            ),
            const SizedBox(height: 10),
            _buildAboutFeatureRow(
              icon: Icons.cloud_done_outlined,
              color: const Color(0xFF2563EB),
              title: 'Real-Time & Offline Sync',
              subtitle:
                  'Works offline and synchronizes instantly across devices',
            ),
            const SizedBox(height: 20),

            // Close button
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF111111),
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                onPressed: () => Navigator.of(ctx).pop(),
                child: Text(
                  'Got it',
                  style: GoogleFonts.manrope(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    ),
  );
  }

  Widget _buildAboutFeatureRow({
    required IconData icon,
    required Color color,
    required String title,
    required String subtitle,
  }) {
    return Row(
      children: [
        Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: color.withOpacity(0.12),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Center(
            child: Icon(icon, color: color, size: 18),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: GoogleFonts.manrope(
                  fontSize: 13.5,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF111111),
                ),
              ),
              Text(
                subtitle,
                style: GoogleFonts.manrope(
                  fontSize: 11.5,
                  fontWeight: FontWeight.w500,
                  color: const Color(0xFF6B7280),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  void _openAvatarPicker(BuildContext context) {
    MemoAvatarPickerSheet.show(
      context,
      initialIndex: _avatarIndex,
      onAvatarSelected: (newIndex) async {
        setState(() => _avatarIndex = newIndex);
        final memoPath = 'assets/avatars/memo_${(newIndex % 35) + 1}.png';
        await StorageService.instance
            .setInt('user_profile_avatar_index', newIndex);
        await StorageService.instance
            .setString('user_profile_avatar_url', memoPath);
        await StoryRepository.instance.updateCurrentUserAvatar(memoPath);
        final success = await SupabaseService.updateUserAvatarInDb(
          avatarIndex: newIndex,
          avatarUrl: memoPath,
        );
        if (context.mounted) {
          _showNotice(
            context,
            success
                ? 'Avatar updated and saved to DB!'
                : 'Avatar updated locally!',
          );
        }
      },
    );
  }

  void _openEditProfileSheet(BuildContext context) {
    final nameCtrl = TextEditingController(text: _userName);
    final phoneCtrl = TextEditingController(text: _userPhone);
    final formKey = GlobalKey<FormState>();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor:
          isIOSPlatform(context) ? AppColors.iosBackground : AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => Padding(
        padding: EdgeInsets.fromLTRB(
          20,
          20,
          20,
          MediaQuery.of(ctx).viewInsets.bottom + 24,
        ),
        child: Form(
          key: formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 44,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppColors.border,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 18),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Edit Profile',
                    style: GoogleFonts.manrope(
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      Navigator.of(ctx).pop();
                      _openAvatarPicker(context);
                    },
                    child: Text(
                      'Change Avatar',
                      style: GoogleFonts.manrope(
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 18),
              Text(
                'Full Name',
                style: GoogleFonts.manrope(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 6),
              TextFormField(
                controller: nameCtrl,
                style: GoogleFonts.manrope(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
                decoration: InputDecoration(
                  hintText: 'Your name',
                  filled: true,
                  fillColor: AppColors.surfaceSubtle,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(AppRadius.input),
                    borderSide: const BorderSide(color: AppColors.border),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(AppRadius.input),
                    borderSide: const BorderSide(color: AppColors.border),
                  ),
                ),
                validator: (val) => val == null || val.trim().isEmpty
                    ? 'Please enter your name'
                    : null,
              ),
              const SizedBox(height: 14),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Email Address',
                    style: GoogleFonts.manrope(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  Row(
                    children: [
                      const Icon(Icons.lock_outline_rounded,
                          size: 13, color: AppColors.textTertiary),
                      const SizedBox(width: 4),
                      Text(
                        'Not editable',
                        style: GoogleFonts.manrope(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textTertiary,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 6),
              Container(
                width: double.infinity,
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                decoration: BoxDecoration(
                  color: const Color(0xFFF3F4F6),
                  borderRadius: BorderRadius.circular(AppRadius.input),
                  border: Border.all(color: AppColors.border),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.mail_outline_rounded,
                        size: 18, color: AppColors.textTertiary),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        _userEmail.isNotEmpty ? _userEmail : 'Not connected',
                        style: GoogleFonts.manrope(
                          fontSize: 14.5,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textSecondary,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const Icon(Icons.lock_rounded,
                        size: 16, color: Color(0xFF9CA3AF)),
                  ],
                ),
              ),
              const SizedBox(height: 14),
              Text(
                'Phone Number',
                style: GoogleFonts.manrope(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 6),
              TextFormField(
                controller: phoneCtrl,
                keyboardType: TextInputType.phone,
                style: GoogleFonts.manrope(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
                decoration: InputDecoration(
                  hintText: '+91 9876543210',
                  filled: true,
                  fillColor: AppColors.surfaceSubtle,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(AppRadius.input),
                    borderSide: const BorderSide(color: AppColors.border),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(AppRadius.input),
                    borderSide: const BorderSide(color: AppColors.border),
                  ),
                ),
              ),
              const SizedBox(height: 22),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppRadius.button),
                    ),
                  ),
                  onPressed: () async {
                    if (formKey.currentState?.validate() ?? false) {
                      final newName = nameCtrl.text.trim();
                      final newPhone = phoneCtrl.text.trim();
                      setState(() {
                        _userName = newName;
                        _userPhone = newPhone;
                      });
                      await StorageService.instance
                          .setString('user_profile_name', newName);
                      await StorageService.instance
                          .setString('user_profile_phone', newPhone);
                      if (ctx.mounted) Navigator.of(ctx).pop();
                      if (context.mounted) {
                        _showNotice(context, 'Profile updated!');
                      }
                    }
                  },
                  child: Text(
                    'Save Profile',
                    style: GoogleFonts.manrope(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ],
          ),
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

  Future<void> _performLogout(BuildContext context) async {
    await SupabaseService.signOut();
    await StorageService.instance.remove('is_logged_in_with_google');
    await StorageService.instance.remove('has_completed_onboarding');
    if (widget.onLogout != null) {
      widget.onLogout!();
    } else if (context.mounted) {
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const OnboardingScreen()),
        (route) => false,
      );
    }
  }

  void _showLogoutConfirmation(BuildContext context) {
    if (isIOSPlatform(context)) {
      showCupertinoDialog(
        context: context,
        builder: (ctx) => CupertinoAlertDialog(
          title: Text('Confirm Logout',
              style: GoogleFonts.manrope(fontWeight: FontWeight.w700)),
          content: Text('Are you sure you want to log out of TTMM?',
              style: GoogleFonts.manrope()),
          actions: [
            CupertinoDialogAction(
              onPressed: () => Navigator.of(ctx).pop(),
              child: const Text('Cancel'),
            ),
            CupertinoDialogAction(
              isDestructiveAction: true,
              onPressed: () {
                Navigator.of(ctx).pop();
                _performLogout(context);
              },
              child: const Text('Logout'),
            ),
          ],
        ),
      );
    } else {
      AppTransitions.showFadeScaleDialog(
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
            'Are you sure you want to log out of TTMM?',
            style: GoogleFonts.manrope(color: AppColors.textSecondary),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: Text('Cancel',
                  style: GoogleFonts.manrope(color: AppColors.textSecondary)),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.danger,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius:
                      BorderRadius.circular(AppRadius.buttonSecondary),
                ),
              ),
              onPressed: () {
                Navigator.of(ctx).pop();
                _performLogout(context);
              },
              child: Text('Logout',
                  style: GoogleFonts.manrope(fontWeight: FontWeight.w700)),
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
          physics: isIOS
              ? const BouncingScrollPhysics()
              : const ClampingScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(16, 14, 16, 120),
          child: Column(
            children: [
              // Header: Profile title + Edit icon
              ProfileHeader(
                onEditPressed: () => _openEditProfileSheet(context),
              ),
              const SizedBox(height: 16),

              // Avatar with memo avatar / primary circle, name, and phone
              ProfileAvatar(
                name: _userName,
                email: _userEmail.isNotEmpty ? _userEmail : null,
                phone: _userPhone,
                initial:
                    _userName.isNotEmpty ? _userName[0].toUpperCase() : 'G',
                avatarIndex: _avatarIndex,
                avatarUrl: _avatarUrl,
                onTap: () => _openAvatarPicker(context),
              ),
              const SizedBox(height: 24),

              // Menu Cards grouped into SOCIAL, ACCOUNT, APP
              ProfileMenuCard(
                onCommunitiesTap: () => _openCommunities(context),
                onEditProfileTap: () => _openEditProfileSheet(context),
                onAppSettingsTap: () => _openAppSettings(context),
                onHelpSupportTap: () => _showHelpSupportSheet(context),
                onAboutBillSplitTap: () => _showAboutTtmmSheet(context),
              ),
              const SizedBox(height: 20),

              // Logout Button with soft red tint
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
