import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:app_links/app_links.dart';
import 'package:flutter_bill_splitter/core/config/app_config.dart';
import 'package:flutter_bill_splitter/core/constants/app_constants.dart';
import 'package:flutter_bill_splitter/core/services/storage_service.dart';
import 'package:flutter_bill_splitter/core/services/supabase_service.dart';
import 'package:flutter_bill_splitter/core/services/url_strategy_helper.dart'
    if (dart.library.html) 'package:flutter_bill_splitter/core/services/url_strategy_helper_web.dart';
import 'package:flutter_bill_splitter/features/onboarding/presentation/screens/onboarding_screen.dart';
import 'package:flutter_bill_splitter/features/stories/presentation/screens/join_story_screen.dart';

typedef DeepLinkHandler = void Function(String storyId, bool isAuthenticated);

/// Centralized service for handling Story Invite Links and deep-linking.
/// Supports cold-launch initial links and hot runtime stream links (foreground/background).
class InviteService {
  static const String _pendingInviteKey = AppConstants.keyPendingInviteStoryId;
  static const String _pendingInviteUrlKey = AppConstants.keyPendingInviteUrl;
  static final Set<String> _handledStoryIds = {};

  static final AppLinks _appLinks = AppLinks();
  static StreamSubscription<Uri>? _linkSubscription;
  static bool _listenerInitialized = false;

  /// Global Navigator key used by incoming background/foreground deep links
  static final GlobalKey<NavigatorState> navigatorKey =
      GlobalKey<NavigatorState>();

  /// Optional test or custom callback invoked on deep link
  static DeepLinkHandler? onDeepLinkAction;

  /// String tracking the in-flight story ID to prevent duplicate dialogs or route loops
  static String? _activeProcessingStoryId;

  /// Parses an invited story ID or token from any Uri (query, fragment, or path segment).
  static String? parseStoryIdFromUri(Uri? uri) {
    if (uri == null) return null;
    try {
      // 1. Direct query parameter: ?story_id=xyz, ?token=xyz, or ?invite=xyz
      for (final key in ['story_id', 'token', 'invite']) {
        if (uri.queryParameters.containsKey(key)) {
          final id = uri.queryParameters[key]?.trim();
          if (id != null && id.isNotEmpty && !_handledStoryIds.contains(id)) {
            return id;
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
          for (final key in ['story_id', 'token', 'invite']) {
            if (params.containsKey(key)) {
              final id = params[key]?.trim();
              if (id != null && id.isNotEmpty && !_handledStoryIds.contains(id)) {
                return id;
              }
            }
          }
        }
      }

      // 3. Path segments: /join/:id or /story/:id or /invite/:id
      if (uri.pathSegments.isNotEmpty) {
        final segs = uri.pathSegments;
        if (segs.length >= 2 &&
            (segs[0] == 'join' || segs[0] == 'story' || segs[0] == 'invite')) {
          final id = segs[1].trim();
          if (id.isNotEmpty && !_handledStoryIds.contains(id)) {
            return id;
          }
        }
      }
    } catch (e) {
      debugPrint('InviteService uri parse error: $e');
    }
    return null;
  }

  /// Extracts an invited story ID from the current browser URI or deep-link.
  static String? getInviteStoryIdFromUri() {
    return parseStoryIdFromUri(Uri.base);
  }

  static Timer? _debounceTimer;

  /// Retrieves initial launch URI using AppLinks.
  static Future<Uri?> getInitialUri() async {
    try {
      return await _appLinks.getInitialLink().timeout(
            const Duration(milliseconds: 150),
            onTimeout: () => null,
          );
    } catch (e) {
      debugPrint('InviteService getInitialLink error: $e');
      return null;
    }
  }

  /// Initializes listening for incoming deep links while app is running (foreground or background).
  static void initDeepLinkListener() {
    if (_listenerInitialized) return;
    _listenerInitialized = true;

    try {
      _linkSubscription = _appLinks.uriLinkStream.listen(
        (uri) {
          handleIncomingUri(uri);
        },
        onError: (err) {
          debugPrint('InviteService deep-link stream error: $err');
        },
      );
    } catch (e) {
      debugPrint('InviteService initDeepLinkListener error: $e');
    }
  }

  /// Handles incoming deep links at runtime.
  static Future<void> handleIncomingUri(Uri uri) async {
    final storyId = parseStoryIdFromUri(uri);
    if (storyId == null || storyId.isEmpty) return;

    // Prevent duplicate processing of the same story link
    if (_activeProcessingStoryId == storyId) return;
    _activeProcessingStoryId = storyId;

    try {
      // Preserve invitation data
      await savePendingInvite(storyId, originalUrl: uri.toString());

      // Resolve authentication status
      final isAuthenticated = await isUserAuthenticated();

      if (onDeepLinkAction != null) {
        onDeepLinkAction!(storyId, isAuthenticated);
        return;
      }

      final navState = navigatorKey.currentState;
      if (navState == null) return;

      if (!isAuthenticated) {
        // Scenario 1 & 3: Unauthenticated -> redirect directly to login
        navState.push(
          MaterialPageRoute(
            builder: (_) => OnboardingScreen(inviteStoryId: storyId),
          ),
        );
      } else {
        // Scenario 2 & 3: Authenticated -> navigate directly to invitation preview
        navState.push(
          MaterialPageRoute(
            builder: (_) => JoinStoryScreen(storyId: storyId),
          ),
        );
      }
    } finally {
      // Clear in-flight guard after debounce delay
      _debounceTimer?.cancel();
      _debounceTimer = Timer(const Duration(milliseconds: 300), () {
        if (_activeProcessingStoryId == storyId) {
          _activeProcessingStoryId = null;
        }
      });
    }
  }

  /// Helper to check authentication state across Supabase and local credentials.
  static Future<bool> isUserAuthenticated() async {
    if (SupabaseService.isSignedIn) return true;
    final hasCompletedOnboarding = await StorageService.instance
            .getBool(AppConstants.keyHasCompletedOnboarding) ??
        false;
    final isLoggedInWithGoogle = await StorageService.instance
            .getBool(AppConstants.keyIsLoggedInWithGoogle) ??
        false;
    return hasCompletedOnboarding && isLoggedInWithGoogle;
  }

  /// Stores a pending story invite ID and original link URL in local storage across redirects.
  static Future<void> savePendingInvite(String storyId,
      {String? originalUrl}) async {
    await StorageService.instance.setString(_pendingInviteKey, storyId);
    if (originalUrl != null && originalUrl.isNotEmpty) {
      await StorageService.instance
          .setString(_pendingInviteUrlKey, originalUrl);
    }
  }

  /// Retrieves any stored pending story invite ID.
  static Future<String?> getPendingInvite() async {
    final stored = await StorageService.instance.getString(_pendingInviteKey);
    if (stored != null && _handledStoryIds.contains(stored)) {
      await StorageService.instance.remove(_pendingInviteKey);
      await StorageService.instance.remove(_pendingInviteUrlKey);
      return null;
    }
    return stored;
  }

  /// Retrieves the preserved complete invitation URL.
  static Future<String?> getPendingInviteUrl() async {
    return StorageService.instance.getString(_pendingInviteUrlKey);
  }

  /// Clears any pending invite ID and URL after joining or declining.
  static Future<void> clearPendingInvite([String? storyId]) async {
    if (storyId != null && storyId.isNotEmpty) {
      _handledStoryIds.add(storyId);
    }
    if (_activeProcessingStoryId == storyId) {
      _activeProcessingStoryId = null;
    }
    await StorageService.instance.remove(_pendingInviteKey);
    await StorageService.instance.remove(_pendingInviteUrlKey);
    clearWebUrlQuery();
  }

  /// Resets internal handled story set and in-flight tracking (useful in tests).
  static void resetForTesting() {
    _handledStoryIds.clear();
    _activeProcessingStoryId = null;
    _debounceTimer?.cancel();
    _debounceTimer = null;
  }

  /// Builds a shareable invite link for a given story ID.
  static String buildInviteUrl(String storyId) {
    if (kIsWeb) {
      final origin = Uri.base.origin;
      return '$origin/?story_id=$storyId';
    }
    return '${AppConfig.webHostedUrl}/?story_id=$storyId';
  }

  /// Disposes active deep-link streams.
  static void dispose() {
    _linkSubscription?.cancel();
    _linkSubscription = null;
    _listenerInitialized = false;
  }
}
