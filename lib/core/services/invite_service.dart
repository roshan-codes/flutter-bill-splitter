import 'package:flutter/foundation.dart';
import 'package:flutter_bill_splitter/core/services/storage_service.dart';
import 'package:flutter_bill_splitter/core/services/url_strategy_helper.dart'
    if (dart.library.html) 'package:flutter_bill_splitter/core/services/url_strategy_helper_web.dart';

/// Centralized service for handling Story Invite Links and deep-linking.
class InviteService {
  static const String _pendingInviteKey = 'pending_invite_story_id';
  static final Set<String> _handledStoryIds = {};

  /// Extracts an invited story ID from the current browser URI or deep-link.
  static String? getInviteStoryIdFromUri() {
    try {
      final uri = Uri.base;

      // 1. Direct query parameter: ?story_id=xyz
      if (uri.queryParameters.containsKey('story_id')) {
        final id = uri.queryParameters['story_id'];
        if (id != null && id.trim().isNotEmpty) {
          final trimmed = id.trim();
          if (!_handledStoryIds.contains(trimmed)) {
            return trimmed;
          }
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
              final trimmed = id.trim();
              if (!_handledStoryIds.contains(trimmed)) {
                return trimmed;
              }
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
    final stored = await StorageService.instance.getString(_pendingInviteKey);
    if (stored != null && _handledStoryIds.contains(stored)) {
      await StorageService.instance.remove(_pendingInviteKey);
      return null;
    }
    return stored;
  }

  /// Clears any pending invite ID after joining or declining.
  static Future<void> clearPendingInvite([String? storyId]) async {
    if (storyId != null && storyId.isNotEmpty) {
      _handledStoryIds.add(storyId);
    }
    await StorageService.instance.remove(_pendingInviteKey);
    clearWebUrlQuery();
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
