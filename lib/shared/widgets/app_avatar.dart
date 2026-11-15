import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_bill_splitter/core/services/storage_service.dart';
import 'package:flutter_bill_splitter/core/services/supabase_service.dart';

/// Universal avatar widget for BillSplit that renders:
/// 1. Memo avatars ('assets/avatars/memo_X.png' or avatarIndex)
/// 2. Google OAuth profile photos (network URLs)
/// 3. Current user automatic resolution (from local storage & Supabase)
/// 4. Fallback to clean, elegant initials.
class AppAvatar extends StatelessWidget {
  final double size;
  final String? avatarUrl;
  final int? avatarIndex;
  final String name;
  final String? initial;
  final bool isCurrentUser;
  final BoxBorder? border;
  final Color? backgroundColor;
  final Color? textColor;
  final double fontSize;

  const AppAvatar({
    super.key,
    this.size = 40,
    this.avatarUrl,
    this.avatarIndex,
    this.name = '',
    this.initial,
    this.isCurrentUser = false,
    this.border,
    this.backgroundColor,
    this.textColor,
    this.fontSize = 14,
  });

  String _getInitial() {
    if (initial != null && initial!.isNotEmpty) return initial!;
    if (name.trim().isNotEmpty) return name.trim()[0].toUpperCase();
    return 'U';
  }

  bool _checkIsCurrentUser() {
    if (isCurrentUser) return true;
    final clean = name.toLowerCase().trim();
    if (clean.isEmpty) return false;
    if (clean == 'you') return true;

    final currentName = SupabaseService.userDisplayName ??
        StorageService.instance.getStringSync('user_profile_name');
    if (currentName != null && currentName.trim().isNotEmpty) {
      final myClean = currentName.toLowerCase().trim();
      if (clean == myClean ||
          clean.contains(myClean) ||
          myClean.contains(clean)) {
        return true;
      }
    }

    if (clean == 'roshan' || clean == 'roshan badwaik') {
      return true;
    }
    return false;
  }

  @override
  Widget build(BuildContext context) {
    final effectiveIsCurrentUser = _checkIsCurrentUser();

    // 1. Resolve effective avatar string & index
    String? effectiveAvatar = avatarUrl;
    int? effectiveIndex = avatarIndex;

    if (effectiveIsCurrentUser) {
      final savedIndex =
          StorageService.instance.getIntSync('user_profile_avatar_index') ??
              SupabaseService.userAvatarIndex;
      if (savedIndex != null) {
        effectiveIndex = savedIndex;
        effectiveAvatar = 'assets/avatars/memo_${(savedIndex % 35) + 1}.png';
      } else {
        final savedUrl =
            StorageService.instance.getStringSync('user_profile_avatar_url') ??
                SupabaseService.userAvatarUrl;
        if (savedUrl != null && savedUrl.trim().isNotEmpty) {
          effectiveAvatar = savedUrl.trim();
        }
      }
    }

    final letter = _getInitial();
    Widget imageContent;

    if (effectiveIndex != null) {
      final assetPath = 'assets/avatars/memo_${(effectiveIndex % 35) + 1}.png';
      imageContent = Image.asset(
        assetPath,
        width: size,
        height: size,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => _buildFallbackInitial(letter),
      );
    } else if (effectiveAvatar != null && effectiveAvatar.trim().isNotEmpty) {
      final trimmed = effectiveAvatar.trim();
      if (trimmed.startsWith('assets/')) {
        imageContent = Image.asset(
          trimmed,
          width: size,
          height: size,
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) => _buildFallbackInitial(letter),
        );
      } else if (trimmed.startsWith('http://') ||
          trimmed.startsWith('https://')) {
        imageContent = Image.network(
          trimmed,
          width: size,
          height: size,
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) => _buildFallbackInitial(letter),
        );
      } else {
        imageContent = _buildFallbackInitial(letter);
      }
    } else {
      imageContent = _buildFallbackInitial(letter);
    }

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: backgroundColor ?? const Color(0xFF111111),
        border: border,
      ),
      child: ClipOval(child: imageContent),
    );
  }

  Widget _buildFallbackInitial(String letter) {
    return Center(
      child: Text(
        letter,
        style: GoogleFonts.manrope(
          color: textColor ?? Colors.white,
          fontWeight: FontWeight.w800,
          fontSize: fontSize,
        ),
      ),
    );
  }
}
