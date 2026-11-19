import 'package:flutter_bill_splitter/core/services/storage_service.dart';
import 'package:flutter_bill_splitter/core/services/supabase_service.dart';
import 'package:flutter_bill_splitter/features/stories/domain/models/story.dart';

/// Centralized helper to consistently determine whether a group member
/// represents the currently authenticated or active local user ("You").
class UserIdentityResolver {
  UserIdentityResolver._();

  /// Resolves the single primary user ID for the current session within a story.
  static String? resolveCurrentMemberId(Story story) {
    final currentId = SupabaseService.currentUser?.id;
    final currentName = SupabaseService.userDisplayName ??
        StorageService.instance.getStringSync('user_profile_name');
    final myClean = currentName
            ?.replaceAll(RegExp(r'\s*\(you\)\s*$', caseSensitive: false), '')
            .toLowerCase()
            .trim() ??
        '';

    // 1. Authenticated user ID matches a member's userId
    if (currentId != null && currentId.isNotEmpty) {
      for (final m in story.members) {
        if (m.userId == currentId) return m.userId;
      }
    }

    // 2. Profile display name matches member name
    if (myClean.isNotEmpty) {
      for (final m in story.members) {
        final cleanM = m.name
            .replaceAll(RegExp(r'\s*\(you\)\s*$', caseSensitive: false), '')
            .toLowerCase()
            .trim();
        if (cleanM == myClean) return m.userId;
      }
    }

    // 3. Member named 'you' literally (e.g. offline-created starter story where user is literally 'You')
    for (final m in story.members) {
      final cleanM = m.name.toLowerCase().trim();
      if (cleanM == 'you' || cleanM == '(you)') return m.userId;
    }

    // Strict Access Control: If neither authenticated UID, saved profile name,
    // nor literal 'You' matches, this active session is a non-member/guest/viewer.
    // NEVER fall back to claiming story.createdBy, admin, or first member!
    return null;
  }

  /// Checks if a member name / userId corresponds to the active user.
  static bool isCurrentUser({
    required String name,
    String? userId,
    required Story story,
    String? resolvedCurrentMemberId,
  }) {
    final cleanName = name
        .replaceAll(RegExp(r'\s*\(you\)\s*$', caseSensitive: false), '')
        .trim();
    final clean = cleanName.toLowerCase();

    final myId = resolvedCurrentMemberId ?? resolveCurrentMemberId(story);
    if (myId != null && myId.isNotEmpty) {
      if (userId != null && userId.isNotEmpty) {
        return userId == myId;
      }
      final myMember =
          story.members.where((m) => m.userId == myId).firstOrNull;
      if (myMember != null) {
        final myClean = myMember.name
            .replaceAll(RegExp(r'\s*\(you\)\s*$', caseSensitive: false), '')
            .toLowerCase()
            .trim();
        return clean == myClean;
      }
      return false;
    }

    final currentId = SupabaseService.currentUser?.id;
    if (userId != null &&
        userId.isNotEmpty &&
        currentId != null &&
        currentId.isNotEmpty) {
      return userId == currentId;
    }

    final currentName = SupabaseService.userDisplayName ??
        StorageService.instance.getStringSync('user_profile_name');
    if (currentName != null && currentName.trim().isNotEmpty) {
      final myClean = currentName
          .replaceAll(RegExp(r'\s*\(you\)\s*$', caseSensitive: false), '')
          .toLowerCase()
          .trim();
      return clean == myClean ||
          clean.startsWith('$myClean ') ||
          myClean.startsWith('$clean ');
    }

    return clean == 'you';
  }

  /// Formats member name: returns 'Name (You)' if isMe is true (or 'You' if name is literally 'You'),
  /// preserving the exact name from the database while identifying the active user.
  /// If isMe is false, NEVER return 'You'. If stored name was literally 'You',
  /// resolve a clean fallback name from story/member role, or 'Host'.
  static String formatMemberDisplayName(
    String name,
    bool isMe, {
    String? memberUserId,
    Story? story,
    String? fallbackOtherName,
    bool includeYouSuffix = true,
  }) {
    final clean = name
        .replaceAll(RegExp(r'\s*\(you\)\s*$', caseSensitive: false), '')
        .trim();

    if (isMe) {
      if (clean.isEmpty || clean.toLowerCase() == 'you') {
        return 'You';
      }
      return includeYouSuffix ? '$clean (You)' : clean;
    }

    if (clean.toLowerCase() == 'you' || clean.isEmpty) {
      // NEVER show 'You' when isMe is false!
      if (fallbackOtherName != null &&
          fallbackOtherName.trim().isNotEmpty &&
          fallbackOtherName.toLowerCase() != 'you') {
        return fallbackOtherName.trim();
      }

      if (story != null) {
        // Try finding member in story.members with a better name
        for (final m in story.members) {
          final mClean = m.name
              .replaceAll(RegExp(r'\s*\(you\)\s*$', caseSensitive: false), '')
              .trim();
          final isSameMember = (memberUserId != null &&
                  memberUserId.isNotEmpty &&
                  m.userId == memberUserId) ||
              (m.userId == story.createdBy &&
                  (memberUserId == null || memberUserId.isEmpty));
          if (isSameMember &&
              mClean.isNotEmpty &&
              mClean.toLowerCase() != 'you') {
            return mClean;
          }
        }

        // If this member is the creator/host of the story
        final isCreator = (memberUserId != null &&
                memberUserId.isNotEmpty &&
                memberUserId == story.createdBy) ||
            story.members.any((m) =>
                m.userId == memberUserId &&
                (m.role == 'creator' || m.role == 'admin'));
        if (isCreator) {
          return 'Host';
        }
      }

      return 'Host';
    }
    return clean;
  }
}
