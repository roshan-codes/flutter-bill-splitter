import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_bill_splitter/features/stories/domain/models/story.dart';
import 'package:flutter_bill_splitter/features/activity/domain/models/split_activity.dart';

/// Centralized Supabase backend service for TTMM.
/// Handles Authentication, Database sync, and Cloud Storage for stories, expenses, and files.
class SupabaseService {
  static const String supabaseUrl = 'https://hqfdwqrhtertpvlmwvsk.supabase.co';
  static const String supabasePublishableKey =
      'sb_publishable_E55yVbk-WsMaVFFi6BP50g_VCIXQOez';

  static const String storageBucket = 'app_data';

  static bool _initialized = false;
  static bool get isInitialized => _initialized;

  /// Supabase client instance (or null if not initialized).
  static SupabaseClient? get client {
    if (!_initialized) return null;
    try {
      return Supabase.instance.client;
    } catch (_) {
      return null;
    }
  }

  /// Initialize Supabase connection.
  static Future<void> init() async {
    try {
      await Supabase.initialize(
        url: supabaseUrl,
        publishableKey: supabasePublishableKey,
      );
      _initialized = true;
      debugPrint('Supabase successfully initialized.');
    } catch (e) {
      debugPrint('Supabase init warning (running in offline/local mode): $e');
    }
  }

  /// Current authenticated user (or null).
  static User? get currentUser => client?.auth.currentUser;

  /// Whether a user is currently signed in.
  static bool get isSignedIn => currentUser != null;

  /// Initiates Google OAuth Sign-In.
  static Future<bool> signInWithGoogle() async {
    try {
      final cli = client;
      if (cli == null) return false;

      return await cli.auth.signInWithOAuth(
        OAuthProvider.google,
        redirectTo: kIsWeb ? null : 'ttmm://login-callback',
      );
    } catch (e) {
      debugPrint('Google Sign-In Error: $e');
      return false;
    }
  }

  /// Sign out current user.
  static Future<void> signOut() async {
    try {
      await client?.auth.signOut();
    } catch (e) {
      debugPrint('Sign-out error: $e');
    }
  }

  // =========================================================================
  // SUPABASE CLOUD STORAGE & DATABASE SYNC
  // =========================================================================

  /// Persists a Story to Supabase (Database table + Cloud Storage backup).
  static Future<bool> saveStory(Story story) async {
    final cli = client;
    if (cli == null) return false;

    bool savedToDb = false;
    bool savedToStorage = false;

    // 1. Save to Supabase Database Table ('stories')
    try {
      final userId = currentUser?.id ?? 'anonymous';
      await cli.from('stories').upsert({
        'story_id': story.storyId,
        'user_id': userId,
        'title': story.title,
        'description': story.description,
        'cover_emoji': story.coverEmoji,
        'currency': story.currency,
        'status': story.status,
        'created_by': story.createdBy,
        'created_at': story.createdAt,
        'data': story.toJson(),
      });
      savedToDb = true;
      debugPrint('Saved story "${story.title}" to Supabase database table.');
    } catch (e) {
      debugPrint('Supabase table upsert note: $e');
    }

    // 2. Save JSON backup to Supabase Cloud Storage bucket ('app_data')
    try {
      final userId = currentUser?.id ?? 'shared';
      final path = 'stories/$userId/${story.storyId}.json';
      final bytes =
          Uint8List.fromList(utf8.encode(jsonEncode(story.toJson())));

      await cli.storage.from(storageBucket).uploadBinary(
            path,
            bytes,
            fileOptions: const FileOptions(upsert: true, contentType: 'application/json'),
          );
      savedToStorage = true;
      debugPrint('Backed up story "${story.title}" to Supabase storage ($path).');
    } catch (e) {
      debugPrint('Supabase storage upload note: $e');
    }

    return savedToDb || savedToStorage;
  }

  /// Fetches stories from Supabase (Database or Cloud Storage).
  static Future<List<Story>> fetchStories() async {
    final cli = client;
    if (cli == null) return [];

    // 1. Try querying Database table
    try {
      final userId = currentUser?.id;
      var query = cli.from('stories').select();
      if (userId != null) {
        query = query.or('user_id.eq.$userId,created_by.eq.$userId');
      }
      final response = await query.order('created_at', ascending: false);

      final List<Story> results = [];
      for (final item in response as List) {
        if (item is Map<String, dynamic> && item['data'] != null) {
          final data = item['data'];
          if (data is Map<String, dynamic>) {
            results.add(Story.fromJson(data));
          } else if (data is String) {
            results.add(Story.fromJson(jsonDecode(data)));
          }
        }
      }
      if (results.isNotEmpty) return results;
    } catch (e) {
      debugPrint('Supabase fetchStories table note: $e');
    }

    // 2. Fallback: read from Cloud Storage bucket
    try {
      final userId = currentUser?.id ?? 'shared';
      final files = await cli.storage.from(storageBucket).list(path: 'stories/$userId');
      final List<Story> storageResults = [];
      for (final file in files) {
        if (file.name.endsWith('.json')) {
          final data = await cli.storage
              .from(storageBucket)
              .download('stories/$userId/${file.name}');
          final jsonMap = jsonDecode(utf8.decode(data)) as Map<String, dynamic>;
          storageResults.add(Story.fromJson(jsonMap));
        }
      }
      return storageResults;
    } catch (e) {
      debugPrint('Supabase storage fetch note: $e');
    }

    return [];
  }

  /// Persists a SplitActivity to Supabase.
  static Future<bool> saveActivity(SplitActivity activity) async {
    final cli = client;
    if (cli == null) return false;

    try {
      final userId = currentUser?.id ?? 'anonymous';
      await cli.from('activities').upsert({
        'id': activity.id,
        'user_id': userId,
        'group_name': activity.groupName,
        'total_amount': activity.totalAmount,
        'share_per_person': activity.sharePerPerson,
        'timestamp': activity.timestamp.toIso8601String(),
        'data': activity.toJson(),
      });
      return true;
    } catch (e) {
      debugPrint('Supabase saveActivity note: $e');
      return false;
    }
  }

  /// Uploads binary files (such as receipt images or user avatars) to Supabase Storage.
  static Future<String?> uploadFile({
    required String bucket,
    required String path,
    required Uint8List bytes,
    String? contentType,
  }) async {
    final cli = client;
    if (cli == null) return null;

    try {
      await cli.storage.from(bucket).uploadBinary(
            path,
            bytes,
            fileOptions: FileOptions(upsert: true, contentType: contentType),
          );
      return cli.storage.from(bucket).getPublicUrl(path);
    } catch (e) {
      debugPrint('Supabase uploadFile error: $e');
      return null;
    }
  }
}
