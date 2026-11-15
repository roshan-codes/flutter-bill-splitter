import 'package:flutter/foundation.dart';
import 'package:flutter_bill_splitter/core/services/storage_service.dart';

/// Centralized service for handling Story Invite Links and deep-linking.
class InviteService {
  static const String _pendingInviteKey = 'pending_invite_story_id';

  /// Extracts an invited story ID from the current browser URI or deep-link.
  static String? getInviteStoryIdFromUri() {
    try {
      final uri = Uri.base;

      // 1. Direct query parameter: ?story_id=xyz
      if (uri.queryParameters.containsKey('story_id')) {
        final id = uri.queryParameters['story_id'];
        if (id != null && id.trim().isNotEmpty) {
          return id.trim();
        }
      }

      // 2. Fragment parsing: #/join?story_id=xyz or #?story_id=xyz
      if (uri.hasFragment) {
        final frag = uri.fragment;
        final qIndex = frag.indexOf('?');
        if (qIndex != -1) {
          final query = frag.substring(qIndex + 1);
          final params = Uri.splitQueryString(query);
          if (params.containsKey('story_id')) {
            final id = params['story_id'];
            if (id != null && id.trim().isNotEmpty) {
              return id.trim();
            }
          }
        }
      }
    } catch (e) {
      debugPrint('InviteService uri parse error: $e');
    }
    return null;
  }

  /// Stores a pending story invite ID in local storage across redirects.
  static Future<void> savePendingInvite(String storyId) async {
    await StorageService.instance.setString(_pendingInviteKey, storyId);
  }

  /// Retrieves any stored pending story invite ID.
  static Future<String?> getPendingInvite() async {
    return await StorageService.instance.getString(_pendingInviteKey);
  }

  /// Clears any pending invite ID after joining.
  static Future<void> clearPendingInvite() async {
    await StorageService.instance.remove(_pendingInviteKey);
  }

  /// Builds a shareable invite link for a given story ID.
  static String buildInviteUrl(String storyId) {
    if (kIsWeb) {
      final origin = Uri.base.origin;
      return '$origin/?story_id=$storyId';
    }
    return 'https://flutter-bill-splitter.onrender.com/?story_id=$storyId';
  }
}
