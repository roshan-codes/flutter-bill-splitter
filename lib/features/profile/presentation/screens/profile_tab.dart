import 'package:animations/animations.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
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
import 'package:flutter_bill_splitter/shared/widgets/platform_adaptive.dart';

/// Profile Tab screen matching platform design (Material on Android, Cupertino on iOS).
/// Adheres to design.md Section 2, 3, 4, 6 & 9.
class ProfileTab extends StatefulWidget {
  final VoidCallback? onLogout;
  final VoidCallback? onFriendsTap;
  final VoidCallback? onGroupsTap;
  final int? initialAvatarIndex;

  const ProfileTab({
    super.key,
    this.onLogout,
    this.onFriendsTap,
    this.onGroupsTap,
    this.initialAvatarIndex,
  });

  @override
  State<ProfileTab> createState() => _ProfileTabState();
}

class _ProfileTabState extends State<ProfileTab> {
  int? _avatarIndex;
  String? _avatarUrl;
  String _userName = 'Roshan Badwaik';
  String _userPhone = '+91 9876543210';

  @override
  void initState() {
    super.initState();
    _avatarIndex = widget.initialAvatarIndex;
    _loadSavedProfile();
  }

  Future<void> _loadSavedProfile() async {
    final googleName = SupabaseService.userDisplayName;
    final googleContact = SupabaseService.userContactInfo;
    final googleAvatar = SupabaseService.userAvatarUrl;

    final savedAvatar =
        await StorageService.instance.getInt('user_profile_avatar_index');
    final savedName =
        await StorageService.instance.getString('user_profile_name');
    final savedPhone =
        await StorageService.instance.getString('user_profile_phone');
    final savedAvatarUrl =
        await StorageService.instance.getString('user_profile_avatar_url');

    if (mounted) {
      setState(() {
        if (_avatarIndex == null && savedAvatar != null) {
          _avatarIndex = savedAvatar;
        }
        _avatarUrl = googleAvatar ?? savedAvatarUrl;

        final resolvedName = savedName ?? googleName;
        if (resolvedName != null && resolvedName.isNotEmpty) {
          _userName = resolvedName;
        }

        final resolvedContact = savedPhone ?? googleContact;
        if (resolvedContact != null && resolvedContact.isNotEmpty) {
          _userPhone = resolvedContact;
        }
      });
    }
  }

  void _openFriends(BuildContext context) {
    if (widget.onFriendsTap != null) {
      widget.onFriendsTap!();
      return;
    }
    Navigator.of(context).push(
      AppTransitions.sharedAxisRoute(
        type: SharedAxisTransitionType.horizontal,
        duration: AppMotion.medium,
        builder: (context) => const FriendsTab(
          initialSubTabIndex: 0,
          showBackButton: true,
        ),
      ),
    );
  }

  void _openGroups(BuildContext context) {
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

  void _openAvatarPicker(BuildContext context) {
    MemoAvatarPickerSheet.show(
      context,
      initialIndex: _avatarIndex,
      onAvatarSelected: (newIndex) async {
        setState(() => _avatarIndex = newIndex);
        await StorageService.instance
            .setInt('user_profile_avatar_index', newIndex);
        if (context.mounted) {
          _showNotice(context, 'Avatar updated successfully!');
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
          padding: const EdgeInsets.fromLTRB(16, 14, 16, 110),
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
                phone: _userPhone,
                initial:
                    _userName.isNotEmpty ? _userName[0].toUpperCase() : 'R',
                avatarIndex: _avatarIndex,
                avatarUrl: _avatarUrl,
                onTap: () => _openAvatarPicker(context),
              ),
              const SizedBox(height: 24),

              // Menu Cards grouped into SOCIAL, ACCOUNT, APP
              ProfileMenuCard(
                onFriendsTap: () => _openFriends(context),
                onGroupsTap: () => _openGroups(context),
                onEditProfileTap: () => _openEditProfileSheet(context),
                onPaymentSettlementTap: () =>
                    _showNotice(context, 'Payment & Settlement opened'),
                onAppSettingsTap: () =>
                    _showNotice(context, 'App Settings opened'),
                onHelpSupportTap: () =>
                    _showNotice(context, 'Help & Support opened'),
                onAboutBillSplitTap: () =>
                    _showNotice(context, 'About TTMM opened'),
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
